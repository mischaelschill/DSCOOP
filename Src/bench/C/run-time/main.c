/*

 #    #    ##       #    #    #           ####
 ##  ##   #  #      #    ##   #          #    #
 # ## #  #    #     #    # #  #          #
 #    #  ######     #    #  # #   ###    #
 #    #  #    #     #    #   ##   ###    #    #
 #    #  #    #     #    #    #   ###     ####

	Therein lie paths I would not have dared tredding alone.
*/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#include "eif_project.h"
#include "eif_config.h"
#ifdef I_STRING
#include <string.h>
#else
#include <strings.h>
#endif
#include "eif_portable.h"
#include "eif_urgent.h"
#include "eif_garcol.h"
#include "eif_except.h"
#include "eif_sig.h"
#include "eif_gen_conf.h"

#ifdef WORKBENCH
#include "eif_wbench.h"		/* %%ss added for create_desc */
#include "eif_interp.h"
#include "eif_update.h"
#include "server.h"						/* ../ipc/app */
#endif /* WORKBENCH */

#include "eif_err_msg.h"

#ifdef EIF_WIN32
#include <windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <direct.h>
#endif

#if !defined CUSTOM || defined NEED_UMAIN_H
#include "eif_umain.h"
#endif

#if !defined CUSTOM || defined NEED_ARGV_H
#include "eif_argv.h"
#endif

#include "eif_malloc.h"
#include "eif_lmalloc.h"
#include "eif_main.h"

#define null (char *) 0					/* Null pointer */

rt_public int eif_no_reclaim = 0;			/* Call reclaim on termination. */
#if defined VXWORKS
	/* when eif_malloc() fails, the system dies otherwise !!! */
	/* FIXME?? */
rt_public int cc_for_speed = 0;			/* Save memory. */
#else	/* VXWORKS */
#ifdef EIF_NO_SCAVENGING
rt_public int cc_for_speed = 0;			/* No scavenging. */
#else	/* EIF_NO_SCAVENGING */
rt_public int cc_for_speed = 1;			/* Fast memory allocation */
#endif	/* EIF_NO_SCAVENGING */
#endif	/* VXWORKS */

rt_public char *ename;						/* Eiffel program's name */

#ifndef VXWORKS  /* In the case of VxWorks, the declaration and 
					initialization of scount is added by finish_freezing
					to the file E1/ececil.c (paulv) */
rt_public int scount;						/* Number of dynamic types */
#endif

#ifndef EIF_THREADS
rt_public int in_assertion = 0;			/* Is an assertion being evaluated ? */
#endif

#ifdef WORKBENCH
rt_public int ccount;						/* Number of classes */
rt_public int fcount;						/* Number of frozen dynamic types */
rt_public struct cnode *esystem;			/* Updated Eiffel system */
rt_public struct conform **co_table;		/* Updated Eiffel conformance table */
rt_public int32 **ecall;					/* Routine id arrays */
rt_public struct rout_info *eorg_table;	/* Routine origin/offset table */
rt_public long dcount;						/* Count of `dispatch' */
rt_public uint32 *dispatch;				/* Update dispatch table */
rt_public uint32 zeroc;					/* Frozen level */
rt_public char **melt;						/* Byte code array */
rt_public int *mpatidtab;					/* Table of pattern id's indexed by body id's */
rt_public struct eif_opt *eoption;			/* Option table */
rt_public struct p_interface *pattern;		/* Pattern table */

#define exvec() exset(null, 0, null)	/* How to get an execution vector */
#else
rt_public struct cnode *esystem;			/* Eiffel system (updated by DLE) */
rt_public struct conform **co_table;		/* Eiffel conformance table (updated DLE) */
rt_public long *esize;						/* Size of objects (updated by DLE) */
rt_public long *nbref;						/* Gives # of references (updated by DLE) */

/*#define exvec() exft()		*/			/* No stack dump in final mode */
#define exvec() exset(null, 0, null)	/* How to get an execution vector */
#endif

rt_public void failure(void);					/* The Eiffel exectution failed */
rt_private Signal_t emergency(int sig);			/* Emergency exit */
rt_public unsigned TIMEOUT;     /* Time out for interprocess communications */

long EIF_once_count = 0;	/* Total nr. of once routines */
long EIF_bonce_count = 0;	/* Nr. of once routines in bytecode */

#ifndef EIF_THREADS
EIF_REFERENCE *EIF_once_values = (EIF_REFERENCE *) 0;	/* Array to save the value of each computed once */
#endif

char *starting_working_directory;	/* Store the working directory during the session, */
							/* ie where to put output files from the runtime */

rt_private void display_reminder (void);	/* display reminder of license */

rt_public void once_init (void)
{
	EIF_GET_CONTEXT

	/* At this point 'EIF_bonce_count' has already been
	   computed (by update) */

	/* Run through all modules and count once routines
	   This also assigns an offset to each module. The
	   sum of the module offset and a once routines own
	   key index gives the index in 'once_keys' */
	/* Addition: we also the previous value of EIF_once_count to
	 * EIF_once_count, since some once routines could have been
	 * supermelted */

	EIF_once_count = EIF_once_count + EIF_bonce_count;

	egc_system_mod_init ();

	/* Allocate room for once values */

	EIF_once_values = (EIF_REFERENCE *) eif_realloc (EIF_once_values, EIF_once_count * REFSIZ);
			/* needs malloc; crashes otherwise on some pure C-ansi compiler (SGI)*/
	if (EIF_once_values == (EIF_REFERENCE *) 0) /* Out of memory */
		enomem();

	memset (EIF_once_values, 0, EIF_once_count * sizeof (char *));
	
	EIF_END_GET_CONTEXT
}

rt_public void eif_alloc_init(void)
{
	/*
	 * This function initializes the global variables holding the values
	 * for memory allocation parameters (chunk and scavenge zone size) to
	 * their default values (env. variable or macro).
	 * The constant CHUNK has been replaced with eif_chunk_size everywhere.
	 * The constant GS_ZONE_SZ has been replaced with eif_scavenge_size.
	 * The constant TENURE_MAX is replaced by eif_tenure_max.
	 * The constant GS_LIMIT is replaced by eif_gs_limit. 
	 * The constant PLSC_PER is replaced by plsc_per.
	 * The constant CLSC_PER is replaced by clsc_per.
	 * The constants TH_ALLOC is replaced by th_alloc. 
	 */

	EIF_GET_CONTEXT

	char *env_var;						/* Environment variable recipient. */
	static int chunk_size = 0;
	static int scavenge_size = 0;		/* Generational scavenge zone size. */
	static int tenure_max	= 0;		/* Maximum age of tenuring. */
	static int gs_limit	= 0;			/* Maximum size (bytes) of 
										 * objects in GSZ.*/
	static int c_per = 0;				/* Full coalesc period.*/
	static int p_per = 0;				/* full collection period.*/
	static int thd	= 0;				/* Threshold of allocation.*/

	/* Special options. */
	env_var = getenv ("EIF_NO_RECLAIM");
	if (env_var != (char *) 0)
		eif_no_reclaim = atoi (env_var);
		
	/* Set chunk size. */
	if (!chunk_size) {
		env_var = getenv ("EIF_MEMORY_CHUNK");
		if (env_var != (char *) 0)
			chunk_size = atoi (env_var);
		else
			chunk_size = CHUNK_DEFAULT;
	}
	eif_chunk_size = chunk_size >= CHUNK_SZ_MIN ? chunk_size : CHUNK_SZ_MIN;
								/* Reasonable chunk size. */

	/* Set scavenge size. */
	if (!scavenge_size) {
		env_var = getenv ("EIF_MEMORY_SCAVENGE");
		if (env_var != (char *) 0)
			scavenge_size = atoi (env_var);
		else
			scavenge_size = GS_ZONE_SZ_DEFAULT;
	}
	eif_scavenge_size = scavenge_size >= GS_SZ_MIN ? scavenge_size : GS_SZ_MIN;
								/* Reasonable GSZ size. */	

	/* Set maximum tenuring age. */
	if (!tenure_max)	/* Is maximum tenuring age not set yet? */
	{
		env_var = getenv ("EIF_TENURE_MAX");
		if (env_var != (char *) 0)	/* Has user specified it? */
		{
			tenure_max = atoi (env_var);

			/* Must be in bounds. */
			if (tenure_max < 0)		
				tenure_max = 0;		/* Mimimun is 0. */
			else if (tenure_max > TENURE_MAX)
				tenure_max = TENURE_MAX;	/* Maximum is TENURE_MAX. */
		}
		else
			tenure_max = TENURE_MAX;	/* RT default setting. */
	}
	eif_tenure_max = tenure_max;	

	/* Set maximum size of objects in GSZ. */
	if (!gs_limit)	/* Is maximum size of objects in GSZ not set yet? */
	{
		env_var = getenv ("EIF_GS_LIMIT");
		if (env_var != (char *) 0)	/* Has user specified it? */
		{
			gs_limit = atoi (env_var);
			/* Must be in bounds. */
			if (gs_limit < 0)		
				gs_limit = 0;		/* Mimimun is 0. */
			else if (gs_limit > GS_FLOATMARK)
				gs_limit = GS_FLOATMARK;	/* Maximum we allow, may crash 
											 * otherwise. */
		}
		else
			gs_limit = GS_LIMIT;	/* RT default setting. */
	}
	eif_gs_limit = gs_limit;	
								/* Reasonable gs_limit. */
				

	/* Set full coalesce period. */
	if (!c_per)	/* Is full coalesce period not set yet? */
	{
		env_var = getenv ("EIF_FULL_COALESCE_PERIOD");
		if (env_var != (char *) 0)	/* Has user specified it? */
			c_per = atoi (env_var);
		else
			c_per = CLSC_PER;	/* RT default setting. */
	}
	clsc_per = c_per >= 0 ? c_per : 0;	

	/* Set full collection period. */
	if (!p_per)	/* Is full collection period not set yet? */
	{
		env_var = getenv ("EIF_FULL_COLLECTION_PERIOD");
		if (env_var != (char *) 0)	/* Has user specified it? */
			p_per = atoi (env_var);
		else
			p_per = PLSC_PER;	/* RT default setting. */
	}
	plsc_per = p_per >= 0 ? p_per : 0;	

	/* Set memory threshold. */
	if (!thd)	/* Is memory threshold not set yet? */
	{
		env_var = getenv ("EIF_MEMORY_THRESHOLD");
		if (env_var != (char *) 0)	/* Has user specified it? */
			thd = atoi (env_var);
		else
			thd = TH_ALLOC;	/* RT default setting. */
	}
	th_alloc = thd >= TH_ALLOC_MIN ? thd : TH_ALLOC_MIN;	

	/******************* Postconditions *******************/
	assert (eif_chunk_size >= CHUNK_SZ_MIN);	/* Chunk size must be over that. */
	assert (eif_scavenge_size >= GS_SZ_MIN);	/* GSZ size must be over that. */
	assert (eif_tenure_max >= 0 && eif_tenure_max <= TENURE_MAX);
									   /* Max tenure age in bounds. */
	assert (eif_gs_limit >= 0 && eif_gs_limit <= GS_FLOATMARK);
									/* Reasonable max size of objects in GSZ. */	
	assert (clsc_per >= 0);			/* Full coelesc period must be positive. */
	assert (plsc_per >= 0);			/* Full collection period must be postive.*/ 
	assert (th_alloc >= TH_ALLOC_MIN);		/* Threshold of allocation must
										   	 * be positive.*/ 
	/*************** End of Postconditions. ******************/

	EIF_END_GET_CONTEXT
}

rt_public void eif_rtinit(int argc, char **argv, char **envp)
{
	char *eif_timeout;

	/* Compute the program name, so that all the error messages can be tagged
	 * with that name (with the notable exception of the stack trace, for
	 * formatting purpose).
	 */

#ifdef EIF_WIN32
	static char module_name [255] = {0};
#endif
	
	starting_working_directory = (char *) eif_malloc (PATH_MAX + 1);

#ifdef EIF_WIN32
		/* Get the current working directory, ie the one where we
		 * are going to save the ouput files */
	if (getcwd(starting_working_directory, PATH_MAX) == NULL)
		print_err_msg(stderr, "Unable to get the current working directory.\n");

	_fmode = O_BINARY;
	GetModuleFileName (NULL, module_name, 255);

	ename = strrchr (module_name, '\\');
	if (ename++ == (char *) 0)
		ename = module_name;
#elif defined(VXWORKS)
	ename = "eiffelvx";
#else
	ename = rindex(argv[0], '/');		/* Only last name if '/' found */

	if (ename++ == (char *) 0)			/* There was no '/' in the name */
		ename = argv[0];				/* Program name is the filename */
#endif

	ufill();							/* Get urgent memory chunks */

#if defined (DEBUG) && ! defined (VXWORKS)
	/* The following install signal handlers for signals USR1 and USR2. Both
	 * raise an immediate scanning of memory and dumping of the free list usage
	 * and other statistics. The difference is that USR1 also performrs a full
	 * GC cycle before runnning the diagnosis. If memck() is programmed to
	 * panic when inconsistencies are detected, this may raise a system failure
	 * due to race condition. There is nothing the user can do about it, except
	 * pray--RAM.
	 */

	esignal(SIGUSR1, mem_diagnose);
	esignal(SIGUSR2, mem_diagnose);
#endif

	/* Check if the user wants to override the default timeout value
	 * for interprocess communications. This new value is specified in
	 * the EIF_TIMEOUT environment variable
	 */
	eif_timeout = getenv("EIF_TIMEOUT");
	if (eif_timeout != (char *) 0)		/* Environment variable set */
		TIMEOUT = (unsigned) atoi(eif_timeout);
	else
		TIMEOUT = 120;

#ifdef WORKBENCH
	xinitint();							/* Interpreter initialization */
	dispatch = egc_fdispatch;				/* Initialize run-time table pointers */
	esystem = egc_fsystem;
	ecall = egc_fcall;
	eoption = egc_foption;
	co_table = egc_fco_table;
	eif_par_table = egc_partab;
	eif_par_table_size = egc_partab_size;
	eorg_table = egc_forg_table;
	pattern = egc_fpattern;

	/* Initialize dynamically computed variables (i.e. system dependent) like
	 * 'zeroc' which is the melting temperature -- the last body id in the
	 * whole system. Then we may call update. Eventually, when debugging the
	 * application, the values loaded from the update file will be overridden
	 * by the workbench (via winit).
	 */

	egc_einit();							/* Various static initializations */
	fcount = scount;

	{
		char temp = 0;
		int i;

		for (i=1;i<argc;i++) {
			if (0 == strcmp (argv[i], "-ignore_updt")) {
				temp = (char) 1;	
				break;
			}
		}
		update(temp);					
	}									/* Read melted information
										 * Note: the `update' function takes
										 * care of the initialization of the 
										 * temporary descriptor structures
										 */

	create_desc();						/* Create descriptor (call) tables */
	
	/* In workbench mode, we have a slight problem: when we link ewb in
	 * workbench mode, since ewb is a child from ised, the run-time will
	 * assume, wrongly, that the executable is started in debug mode. Therefore,
	 * we need a special run-time, with no debugging hooks involved.
	 */

#ifndef NOHOOK
	winit();							/* Did we start under ewb control? */
#endif

#else

	/*
	 * Initialize the finalized system with the static data structures.
	 * These may be updated later on by loading DLE system.
	 */
	esystem = egc_fsystem;
	co_table = egc_fco_table;
	eif_par_table = egc_partab;
	eif_par_table_size = egc_partab_size;
	eif_gen_conf_init (eif_par_table_size);
	nbref = egc_fnbref;
	esize = egc_fsize;

#endif

#if !defined CUSTOM || defined NEED_UMAIN_H
	umain(argc, argv, envp);			/* User's initializations */
#endif
#if !defined CUSTOM || defined NEED_ARGV_H
	arg_init(argc, argv);				/* Save copy for class ARGUMENTS */
#endif
	once_init();

	/* Check for the license code and if it does not match displays the
	 * dialog */
	{
		int value;
		value = 0x00000025 * egc_platform_level;
		value = value + egc_compiler_tag;
		if (value != egc_type_of_gc)
			display_reminder();
	}
}

rt_public void failure(void)
{
	/* A fatal Eiffel exception has occurred. The stack of exceptions is dumped
	 * and the memory is cleaned up, if possible.
	 */
	
	trapsig(emergency);					/* Weird signals are trapped */
	esfail(MTC_NOARG);							/* Dump the execution stack trace */

	reclaim();							/* Reclaim all the objects */
	exit(1);							/* Abnormal termination */

	/* NOTREACHED */
}

rt_private Signal_t emergency(int sig)
{
	/* A signal has been trapped while we were failing peacefully. The memory
	 * must really be in a desastrous state, so print out a give-up message
	 * and exit.
	 */
	
	print_err_msg(stderr, "\n\n%s: PANIC: caught signal #%d (%s) -- Giving up...\n",
		ename, sig, signame(sig));

	exit(2);							/* Really abnormal termination */

	/* NOTREACHED */
}

#ifdef NOHOOK

/* When no debugging is allowed, the file network.o is not part of the
 * archive. However, we need to define dummy dserver() and dinterrupt() entries.
 */

rt_public void dserver(void) {}
rt_public void dinterrupt(void) {}
#endif

rt_public void dexit(int code)
{
	/* This routine is called by functions from libipc.a to raise immediate
	 * termination with a chance to trap the action and perform some clean-up.
	 * Here we call esdie() which will collect all the Eiffel objects and
	 * eventually call dispose() on some of them.
	 */

	esdie(code);						/* Propagate dying request */
}

rt_private void display_reminder(void)
{
	char *msg;

	msg = "This program has been produced with EiffelDemo, the demo version\nof ISE Eiffel, the roundtrip object-oriented software development\nenvironment from Interactive Software Engineering (ISE).\nEiffelDemo is reserved for evaluation of Eiffel. Any other use,\ncommercial or academic, requires purchase of a license.\n\nISE offers a variety of personal and professional licenses and\nsupport/maintenance contracts covering the diverse needs of\ncommercial and academic users. For more information please contact\nISE at the address below or consult the Eiffel products page\nat http://eiffel.com/products/.\n\n\tInteractive Software Engineering\n\tISE Building, 270 Storke Road, second floor\n\tGoleta CA 93117 USA \n\tTelephone 805-685-1006, Fax 805-685-6869\n\tE-mail sales@eiffel.com\n\thttp://eiffel.com\n";


#ifdef EIF_WIN32
	MessageBox (NULL, msg, 
			"Generated by unregistered version of ISE EIffel", MB_OK); 
#else
	printf ("%s", msg);
#endif
}


/*

  #   #    ##     ####    ####           ######  #####   #####            ####
   # #    #  #   #    #  #    #          #       #    #  #    #          #    #
    #    #    #  #       #               #####   #    #  #    #          #
    #    ######  #       #               #       #####   #####    ###    #
    #    #    #  #    #  #    #          #       #   #   #   #    ###    #    #
    #    #    #   ####    ####  #######  ######  #    #  #    #   ###     ####

*/
#include "yacc.h"
#include "hector.h"

char *Error_handler;			/* Compiler error handler */

fnptr syntax1;					/* Routine for syntax error */
fnptr syntax2;					/* Routine for manifest string too long */
fnptr syntax3;					/* Routine for bad string extension */
fnptr syntax4;					/* Routine for uncompleted string */
fnptr syntax5;					/* Routine for bad character */
fnptr syntax6;					/* Routine for empty string */
fnptr syntax7;					/* Routine for identifier too long */
fnptr syntax8;					/* Routine for generic basic type */
fnptr syntax9;					/* Routine for too many generic parameters */

char *yacc_file_name;			/* File name of the parsed file */

/* 
 * Initialization of Yacc error mechanism
 */

void error_init(error_obj, rout1, rout2, rout3, rout4, rout5, rout6, rout7, rout8, rout9)
char *error_obj;
fnptr rout1, rout2, rout3, rout4, rout5, rout6, rout7, rout8, rout9;
{
	Error_handler = error_obj;
	Error_handler = eif_freeze(&Error_handler);	/* Object should not move */
	syntax1 = rout1;
	syntax2 = rout2;
	syntax3 = rout3;
	syntax4 = rout4;
	syntax5 = rout5;
	syntax6 = rout6;
	syntax7 = rout7;
	syntax8 = rout8;
	syntax9 = rout9;
}


/*
 * Initialization of Eiffel syntax error messages 
 */

long get_start_position()
{
	/* Return `start_position'. */

	return (long) start_position;
}

long get_end_position()
{
	/* Return `end_position'. */

	return (long) end_position;
}

char *get_yacc_file_name()
{
	/* Return `yacc_file_name'. */
		
	return yacc_file_name;
}

<<<<<<< HEAD
: Makefile.SH generated from Jmake.tmpl and Jmakefile [jmake 3.5-206]
: $X-Id$
=======
: Makefile.SH generated from Jmake.tmpl and Jmakefile [jmake 3.5 PL0]
: $X-Id: Jmake.tmpl 91075 2005-12-28 23:58:23Z manus $
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15

case $CONFIG in
'')
	if test -f config.sh; then TOP=.;
	elif test -f ../config.sh; then TOP=..;
	elif test -f ../../config.sh; then TOP=../..;
	elif test -f ../../../config.sh; then TOP=../../..;
	elif test -f ../../../../config.sh; then TOP=../../../..;
	else
<<<<<<< HEAD
		echo "Can't find config.sh."; exit 1
=======
	 echo "Can't find config.sh."; exit 1
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	fi
	. $TOP/config.sh
	;;
esac
case "$0" in
*/*) cd `expr X$0 : 'X\(.*\)/'` ;;
esac
<<<<<<< HEAD
CURRENT=CURDIR
=======
CURRENT=.
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
DIR=`echo $CURRENT/ | sed -e 's/\.\///g'`
echo "Extracting ${DIR}Makefile (with variable substitutions)"

DATE=`date`

$spitshell >Makefile <<!GROK!THIS!
########################################################################
# Makefile generated from Makefile.SH on $DATE

SHELL = /bin/sh
JMAKE = jmake
<<<<<<< HEAD
TOP = TOPDIR
=======
TOP = .
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
CURRENT = $CURRENT
DIR = $DIR

########################################################################
# Parameters set by Configure -- edit config.sh if changes are needed

CTAGS = ctags
<<<<<<< HEAD
JCPPFLAGS = $cppflags
=======
MAKE = make
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
MV = $mv
RM = $rm -f

########################################################################
# Automatically generated parameters -- do not edit

SUBDIRS = \$(SUB)

!GROK!THIS!
$spitshell >>Makefile <<'!NO!SUBS!'
########################################################################
# Jmake rules for building libraries, programs, scripts, and data files
<<<<<<< HEAD
# $X-Id$

=======
# $X-Id: Jmake.rules 18 2006-12-27 10:35:09Z rmanfredi $
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
########################################################################
# Start of Jmakefile

SUB = idrs ipc run-time platform bench

all::

<<<<<<< HEAD
depend:: sub_depend

sub_depend::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "Depending" "in $(DIR)$$i..."; \
			$(MAKE) $(MFLAGS)  depend) || exit 1; \
=======
depend::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
	(cd $$i ; echo "Depending" "in $(DIR)$$i..."; \
	$(MAKE) $(MFLAGS)  depend) || exit 1; \
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	done

lint::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
<<<<<<< HEAD
		(cd $$i ; echo "Linting" "in $(DIR)$$i..."; \
			$(MAKE) $(MFLAGS)  lint) || exit 1; \
=======
	(cd $$i ; echo "Linting" "in $(DIR)$$i..."; \
	$(MAKE) $(MFLAGS)  lint) || exit 1; \
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	done

local_clobber::
	$(RM) mkdep cppstdin

########################################################################
# Common rules for all Makefiles -- do not edit

<<<<<<< HEAD
all::
=======
emptyrule::
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15

clean: sub_clean local_clean
realclean: sub_realclean local_realclean
clobber: sub_clobber local_clobber

local_clean::
	if test -f core; then $(RM) core; fi
	$(RM) *~ *.o

local_realclean:: local_clean
<<<<<<< HEAD

local_clobber:: local_realclean
	$(RM) Makefile config.sh

install:: local_install sub_install
	@exit 0

install-strip:: local_install-strip sub_install-strip
	@exit 0

install.man:: maybe_install.man sub_install.man
deinstall:: sub_deinstall local_deinstall
deinstall.man:: sub_deinstall.man maybe_deinstall.man

install.man-no:
deinstall.man-no:

maybe_install.man: install.man-no
maybe_deinstall.man: deinstall.man-no

Makefile.SH: Jmakefile
	-@if test -f $(TOP)/.package; then \
		if test -f Makefile.SH; then \
			echo "	$(RM) Makefile.SH~; $(MV) Makefile.SH Makefile.SH~"; \
			$(RM) Makefile.SH~; $(MV) Makefile.SH Makefile.SH~; \
		fi; \
		echo "	$(JMAKE) -DTOPDIR=$(TOP) -DCURDIR=$(CURRENT)" ; \
		$(JMAKE) -DTOPDIR=$(TOP) -DCURDIR=$(CURRENT) ; \
=======
	$(RM) -r UU

local_clobber:: local_realclean
	$(RM) config.sh eif_config.h
	$(RM) -r .config
	$(RM) Makefile

Makefile.SH: Jmakefile
	-@if test -f $(TOP)/.package; then \
	if test -f Makefile.SH; then \
	echo "	$(RM) Makefile.SH~; $(MV) Makefile.SH Makefile.SH~"; \
	$(RM) Makefile.SH~; $(MV) Makefile.SH Makefile.SH~; \
	fi; \
	echo "	$(JMAKE) -DTOPDIR=$(TOP) -DCURDIR=$(CURRENT)" ; \
	$(JMAKE) -DTOPDIR=$(TOP) -DCURDIR=$(CURRENT) ; \
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	else touch $@; fi

Makefile: Makefile.SH
	/bin/sh Makefile.SH

tags::
	$(CTAGS) -w *.[ch]
	$(CTAGS) -xw *.[ch] > tags

local_clobber::
	$(RM) tags

<<<<<<< HEAD
depend::

=======
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
########################################################################
# Rules for building in sub-directories -- do not edit

subdirs:
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
<<<<<<< HEAD
		(cd $$i ; echo "$(VERB) in $(DIR)$$i..."; \
			$(MAKE) $(MFLAGS) $(FLAGS) $(TARGET)) || exit 1; \
=======
	(cd $$i ; echo $(VERB) "in $(DIR)$$i..."; \
	$(MAKE) $(MFLAGS) $(FLAGS) $(TARGET)) || exit 1; \
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	done

sub_install::
	@$(MAKE) subdirs TARGET=install VERB="Installing" FLAGS=

<<<<<<< HEAD
sub_install-strip::
	@$(MAKE) subdirs TARGET=install-strip VERB="Installing (strip)" FLAGS=

=======
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
sub_deinstall::
	@$(MAKE) subdirs TARGET=deinstall VERB="Deinstalling" FLAGS=
	@echo "Back to $(CURRENT) for "deinstall...

sub_install.man::
	@$(MAKE) subdirs TARGET=install.man VERB="Installing man pages" FLAGS=

sub_deinstall.man::
	@$(MAKE) subdirs TARGET=deinstall.man VERB="Deinstalling man pages" FLAGS=
	@echo "Back to $(CURRENT) for "deinstall.man...

sub_clean::
	@$(MAKE) subdirs TARGET=clean VERB="Cleaning" FLAGS=
	@echo "Back to $(CURRENT) for "clean...

sub_realclean::
	@$(MAKE) subdirs TARGET=realclean VERB="Real cleaning" FLAGS=
	@echo "Back to $(CURRENT) for "realclean...

sub_clobber::
	@$(MAKE) subdirs TARGET=clobber VERB="Clobbering" FLAGS=
	@echo "Back to $(CURRENT) for "clobber...

tag::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
<<<<<<< HEAD
		(cd $$i ; echo "Tagging" "in $(DIR)$$i..."; \
			$(MAKE) $(MFLAGS)  tag) || exit 1; \
=======
	(cd $$i ; echo "Tagging" "in $(DIR)$$i..."; \
	$(MAKE) $(MFLAGS)  tag) || exit 1; \
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	done

Makefiles::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS);\
	do \
<<<<<<< HEAD
		echo "Making "Makefiles" in $(DIR)$$i..."; \
		(cd $$i || exit 1; \
		if test ! -f Makefile; then /bin/sh Makefile.SH; fi; \
		$(MAKE) $(MFLAGS) Makefiles) || exit 1;\
=======
	echo "Making "Makefiles " in $(DIR)$$i..."; \
	(cd $$i || exit 1; \
	if test ! -f Makefile; then /bin/sh Makefile.SH; fi; \
	$(MAKE) $(MFLAGS) Makefiles) || exit 1;\
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	done

Makefiles.SH:: Makefile.SH
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS);\
	do \
<<<<<<< HEAD
		case "$(DIR)$$i/" in \
		*/*/*/*/) newtop=../../../..;; \
		*/*/*/) newtop=../../..;; \
		*/*/) newtop=../..;; \
		*/) newtop=..;; \
		esac; \
		case "$(TOP)" in \
		/*) newtop="$(TOP)" ;; \
		esac; \
		echo "Making Makefiles.SH in $(DIR)$$i..."; \
		(cd $$i || exit 1; \
			if test -f Jmakefile; then \
				$(MAKE) $(MFLAGS) -f ../Makefile \
					Makefile TOP=$$newtop CURRENT=$(DIR)$$i && \
				$(MAKE) $(MFLAGS) Makefiles.SH; \
			fi; \
		) || exit 1; \
=======
	case "$(DIR)$$i/" in \
	*/*/*/*/) newtop=../../../..;; \
	*/*/*/) newtop=../../..;; \
	*/*/) newtop=../..;; \
	*/) newtop=..;; \
	esac; \
	case "$(TOP)" in \
	/*) newtop="$(TOP)" ;; \
	esac; \
	echo "Making Makefiles.SH in $(DIR)$$i..."; \
	(cd $$i || exit 1; \
	if test -f Jmakefile; then \
	$(MAKE) $(MFLAGS) -f ../Makefile \
	Makefile TOP=$$newtop CURRENT=$(DIR)$$i && \
	$(MAKE) $(MFLAGS) Makefiles.SH; \
	fi; \
	) || exit 1; \
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15
	done

all::
	@$(MAKE) subdirs TARGET=all VERB="Making all" FLAGS=

<<<<<<< HEAD
local_install::
local_install-strip::
local_deinstall::
local_install.man::
local_deinstall.man::

!NO!SUBS!
chmod 644 Makefile
$eunicefix Makefile

=======
!NO!SUBS!
chmod 644 Makefile
$eunicefix Makefile
>>>>>>> e410c41eb12074d811e4063b1808f7899551ad15

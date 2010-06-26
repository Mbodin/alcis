#*********************************************************************#
#                                                                     #
#                           Objective Caml                            #
#                                                                     #
#            Pierre Weis, projet Cristal, INRIA Rocquencourt          #
#                                                                     #
# Copyright 1998, 2004 Institut National de Recherche en Informatique #
# et en Automatique. Distributed only by permission.                  #
#                                                                     #
#*********************************************************************#

#                   Generic Makefile for Objective Caml Programs

# $Id: Exp $

############################ Documentation ######################
#
# To use this Makefile:
# -- You must fix the value of the variable SOURCES below.
# (The variable SOURCES is the list of your Caml source files.)
# -- You must create a file .depend, using
# $touch .depend
# (This file will contain the dependancies between your Caml modules,
#  automatically computed by this Makefile.)

# Usage of this Makefile:
# To incrementally recompile the system, type
#     make
# To recompute dependancies between modules, type
#     make depend
# To remove the executable and all the compiled files, type
#     make clean
# To compile using the native code compiler
#     make opt
#
##################################################################


##################################################################
#
# Advanced usage:
# ---------------

# If you want to fix the name of the executable, set the variable
# EXEC, for instance, if you want to obtain a program named my_prog:
# EXEC = my_prog

# If you need special libraries provided with the Caml system,
# (graphics, arbitrary precision numbers, regular expression on strings, ...),
# you must set the variable LIBS to the proper set of libraries. For
# instance, to use the graphics library set LIBS to $(WITHGRAPHICS):
# LIBS=$(WITHGRAPHICS)

# You may use any of the following predefined variable
# WITHGRAPHICS : provides the graphics library
# WITHUNIX : provides the Unix interface library
# WITHSTR : provides the regular expression string manipulation library
# WITHNUMS : provides the arbitrary precision arithmetic package
# WITHTHREADS : provides the byte-code threads library
# WITHDBM : provides the Data Base Manager library
#
#
########################## End of Documentation ####################

VPATH = .:src/parsing

########################## User's variables #####################


# The Caml sources (including camlyacc and camllex source files)

SOURCES = \
	lexer.mll parser.mly

INCLUDE = $(patsubst %,-I %,$(subst :, ,$(VPATH)))

# The executable file to generate (default a.out under Unix)

EXEC = compiler

# The documentation files to generate

DOCPATH = doc
DOC = userguide.pdf

########################## Advanced user's variables #####################
#
# The Caml compilers.
# You may fix here the path to access the Caml compiler on your machine
CAML = ocaml
CAMLC = ocamlc -w Ae
CAMLOPT = ocamlopt -w Ae
CAMLDEP = ocamldep
CAMLLEX = ocamllex
CAMLYACC = ocamlyacc

################ End of user's variables #####################


##############################################################
################ This part should be generic #################
################ Nothing to set up or fix here ###############
##############################################################
.PHONY: all pdf pres sweep clobber clean mrproper fixme

all : $(EXEC)

opt : $(EXEC).opt

SOURCES1 = $(SOURCES:.mly=.ml)
SOURCES2 = $(SOURCES1:.mll=.ml)
PRODLEX  = $(patsubst %.mll, %.ml, $(filter %.mll,$(SOURCES)))
PRODYACC = $(patsubst %.mly, %.ml, $(filter %.mly,$(SOURCES))) $(patsubst %.mly, %.mli, $(filter %.mly,$(SOURCES)))
OBJS     = $(SOURCES2:.ml=.cmo)
OPTOBJS  = $(SOURCES2:.ml=.cmx)
REMOVE   = find . -name $(var) -exec rm -vf {} \;
DUMP = sed -e 's/\\/\\\\/g' -e 's/\"/\\"/g' $(var) >> $@

$(EXEC): $(OBJS) .depend
	@echo "$(CAMLC) -o $(EXEC) $(LIBS)"
	@$(CAMLC) $(INCLUDE) -o $(EXEC) $(LIBS) $(OBJS)

$(EXEC).opt: $(OPTOBJS) .depend
	@echo "$(CAMLOPT) -o $(EXEC).opt $(LIBS:.cma=.cmxa)"
	@$(CAMLOPT) $(INCLUDE) -o $(EXEC).opt $(LIBS:.cma=.cmxa) $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx .mll .mly

.ml.cmo:
	@echo "$(CAMLC) -c $<"
	@$(CAMLC) $(INCLUDE) -c $<

.mli.cmi:
	@echo "$(CAMLC) -c $<"
	@$(CAMLC) $(INCLUDE) -c $<

.ml.cmx:
	@echo "$(CAMLOPT) -c $<"
	@$(CAMLOPT) $(INCLUDE) -c $<

.mll.cmo:
	$(CAMLLEX) $<
	@echo "$(CAMLC) -c $*.ml"
	@$(CAMLC) $(INCLUDE) -c $*.ml

.mll.cmx:
	$(CAMLLEX) $<
	@echo "$(CAMLOPT) -c $*.ml"
	@$(CAMLOPT) $(INCLUDE) -c $*.ml

.mly.cmo:
	$(CAMLYACC) $<
	@echo "$(CAMLC) -c $*.mli"
	@$(CAMLC) $(INCLUDE) -c $*.mli
	@echo "$(CAMLC) -c $*.ml"
	@$(CAMLC) $(INCLUDE) -c $*.ml

.mly.cmx:
	$(CAMLYACC) $<
	@echo "$(CAMLOPT) -c $*.mli"
	@$(CAMLOPT) $(INCLUDE) -c $*.mli
	@echo "$(CAMLOPT) -c $*.ml"
	@$(CAMLOPT) $(INCLUDE) -c $*.ml

.mly.cmi:
	$(CAMLYACC) $<
	@echo "$(CAMLC) -c $*.mli"
	@$(CAMLC) $(INCLUDE) -c $*.mli

.mll.ml:
	$(CAMLLEX) $<

.mly.ml:
	$(CAMLYACC) $<

##############################################################
################ Compiling C files ###########################
##############################################################

CC	= gcc
PEDANTIC_PARANOID_FREAK =       -O3 -Wshadow -Wcast-align \
				-Waggregate-return -Wmissing-prototypes -Wmissing-declarations \
				-Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations \
				-Wmissing-noreturn -Wredundant-decls -Wnested-externs \
				-Wpointer-arith -Wwrite-strings -finline-functions --pedantic -Wall
NORMAL = -Wall
WARNINGS = $(PEDANTIC_PARANOID_FREAK)
#WARNINGS = $(NORMAL)
CFLAGS = -D_REENTRANT -g $(WARNINGS) $(LIBS) $(INCLUDE)

.SUFFIXES: .c .o .bin

.c.bin:
	@echo "$(<F) → $(@F)"
	@$(CC) $(CFLAGS) -o $@ $<

.c.o:
	@echo "$(<F) → $(@F)"
	@$(CC) $(CFLAGS) -c -o $@ $<

##############################################################
################ Compiling Latex files #######################
##############################################################

DVITOPDF = dvipdfm
TEXTODVI = latex -interaction=nonstopmode
DVITOPS = dvips
PSTOPDF = ps2pdf

.SUFFIXES: .tex .aux .dvi .ps .pdf

pdf: $(DOC)

pres : $(SLIDES)

.tex.dvi:
	@echo $(<F) → $@
	@find . -name $(<F) -execdir ${TEXTODVI} {} 1> /dev/null \;
	@find . -name $(<F) -execdir ${TEXTODVI} {} 1> /dev/null \;

.dvi.ps:
	@echo $(<F)→ $@
	@find . -name $(<F) -execdir ${DVITOPS} {} 2> /dev/null \;

.ps.pdf:
	@echo $(<F) → $@
	@find . -name $(<F) -exec ${PSTOPDF} {} 2> /dev/null \;

#.dvi.pdf:
#	@echo $(<F) → $@
#	@find . -name $(<F) -exec $(DVITOPDF) {} 2> /dev/null \;

##############################################################
################### Other generic rules ######################
##############################################################

sweep:
	# produced c files
	@find ./examples -name "*.c" -exec rm -vf {} \;
	# binary files
	@$(foreach var,"*.bin",$(REMOVE);)

clobber:
	# temporary doc files
	@rm -vf $(addprefix $(DOCPATH)/,*~ *.dvi *.ps *.out *.log *.toc *.aux *.nav *.snm)
	# temporary slides files
	@rm -vf $(addprefix $(SLIDESPATH)/,*~ *.dvi *.ps *.out *.log *.toc *.aux *.nav *.vrb *.snm)

clean: sweep clobber
	# dependencies
	@rm -vf ".depend"
	# libraries
	@$(foreach var,"*.cm[iox]" "*~" ".*~",$(REMOVE);)
	# object files
	@$(foreach var,"*.o",$(REMOVE);)
	# lexer
	@$(foreach var,$(PRODLEX),$(REMOVE);)
	# parser
	@$(foreach var,$(PRODYACC),$(REMOVE);)
	# machine
	@$(foreach var,$(MBASE).ml,$(REMOVE);)

mrproper: clean clobber
	# executable
	@$(foreach var,$(EXEC) $(EXEC).opt,$(REMOVE);)
	# documentation files
	@$(foreach var,$(DOC) $(SLIDES),$(REMOVE);)

fixme:
	# debuging
	@grep -ir FIXME * | grep -e tex -e ml -e mli

.depend: $(SOURCES2)
	@echo "$(CAMLDEP) ... → $@"
	@$(CAMLDEP) $(INCLUDE) $(foreach var, $(notdir $^), $(shell find . -name $(var))) > $@

-include .depend


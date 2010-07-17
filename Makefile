

VPATH = .:src/parsing:src/interface

########################## User's variables #####################


# The Caml sources (including camlyacc and camllex source files)

SOURCES = \
	choices.ml errors.ml \
	parsed_syntax.ml \
	lexer.mll preparser.mly \
	parser.ml \


INCLUDE = $(patsubst %,-I %,$(subst :, ,$(VPATH)))

# The executable file to generate (default a.out under Unix)

EXEC = compiler

ECHO = echo

########################## Advanced user's variables #####################
#
# The Caml compilers.
# You may fix here the path to access the Caml compiler on your machine
CAML = ocaml
CAMLC = ocamlc -w Ae
CAMLOPT = ocamlopt -w Ae
CAMLDEP = ocamldep
CAMLLEX = ocamllex
CAMLYACC = ocamlyacc -v

################ End of user's variables #####################


##############################################################
################ This part should be generic #################
################ Nothing to set up or fix here ###############
##############################################################
.PHONY: all pdf clean mrproper fixme

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
	@${ECHO} "\033[33m${OBJS} → $@\033[0m"
	@$(CAMLC) $(INCLUDE) -o $(EXEC) $(LIBS) $(OBJS)

$(EXEC).opt: $(OPTOBJS) .depend
	@${ECHO} "\033[33m${OPTOBJS} → $@\033[0m"
	@$(CAMLOPT) $(INCLUDE) -o $(EXEC).opt $(LIBS:.cma=.cmxa) $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx .mll .mly

.ml.cmo:
	@${ECHO} "\033[32m$< → $@\033[0m"
	@$(CAMLC) $(INCLUDE) -c $<

.mli.cmi:
	@${ECHO} "\033[36m$< → $@\033[0m"
	@$(CAMLC) $(INCLUDE) -c $<

.ml.cmx:
	@${ECHO} "\033[32m$< → $@\033[0m"
	@$(CAMLOPT) $(INCLUDE) -c $<

.mll.cmo:
	@$(CAMLLEX) $<
	@${ECHO} "\033[35m$< → $@\033[0m"
	@$(CAMLC) $(INCLUDE) -c $*.ml

.mll.cmx:
	@$(CAMLLEX) $<
	@${ECHO} "\033[35m$< → $@\033[0m"
	@$(CAMLOPT) $(INCLUDE) -c $*.ml

.mly.cmo:
	@${ECHO} "\033[35m$< → $@\033[0m"
	@$(CAMLYACC) $<
	@$(CAMLC) $(INCLUDE) -c $*.mli
	@$(CAMLC) $(INCLUDE) -c $*.ml

.mly.cmx:
	@${ECHO} "\033[35m$< → $@\033[0m"
	@$(CAMLYACC) $<
	@$(CAMLOPT) $(INCLUDE) -c $*.mli
	@$(CAMLOPT) $(INCLUDE) -c $*.ml

.mly.cmi:
	@${ECHO} "\033[35m$< → $@\033[0m"
	@$(CAMLYACC) $<
	@$(CAMLC) $(INCLUDE) -c $*.mli

.mll.ml:
	@${ECHO} "\033[35m$< → $@\033[0m"
	$(CAMLLEX) $<

.mly.ml:
	@${ECHO} "\033[35m$< → $@\033[0m"
	@$(CAMLYACC) $<

##############################################################
################### Other generic rules ######################
##############################################################

clean:
	@# dependencies
	@rm -vf ".depend"
	@# libraries
	@$(foreach var,"*.cm[iox]" "*~" ".*~",$(REMOVE);)
	@# lexer
	@$(foreach var,$(PRODLEX),$(REMOVE);)
	@# parser
	@$(foreach var,$(PRODYACC),$(REMOVE);)

mrproper: clean
	@# executable
	@$(foreach var,$(EXEC) $(EXEC).opt,$(REMOVE);)

fixme:
	@# debuging
	@grep -ir FIXME * | grep -e tex -e ml -e mli

.depend: $(SOURCES2)
	@${ECHO} "\033[34m$(SOURCES2) → $@\033[0m"
	@$(CAMLDEP) $(INCLUDE) $(foreach var, $(notdir $^), $(shell find . -name $(var))) > $@

-include .depend

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



VPATH = doc \
		src/parsing src/interface

########################## User's variables #####################

# The Caml sources (including camlyacc and camllex source files)

SOURCES = \
	choices.ml errors.ml \
	parsed_syntax.ml \
	lexer.mll preparser.mly \
	parser.ml \
	io.ml \
	main.ml

INCLUDE = $(patsubst %,-I %,$(VPATH))

# The executable file to generate (default a.out under Unix)

EXEC = compiler

ECHO = echo

# The document to be created

DOC = implementation.pdf standard.pdf

DOCPATH = doc

########################## Advanced user's variables #####################

# The Caml compiler
CAML = ocaml
CAMLC = ocamlc -w Ae
CAMLOPT = ocamlopt -w Ae
CAMLDEP = ocamldep
CAMLLEX = ocamllex
CAMLYACC = ocamlyacc -v

# The LaTeX compiler
PDFLATEX = pdflatex

################ End of user's variables #####################


##############################################################
################ This part should be generic #################
################ Nothing to set up or fix here ###############
##############################################################
.PHONY: all documentation clean mrproper fixme

all : $(EXEC) documentation

opt : $(EXEC).opt

SOURCES1 = $(SOURCES:.mly=.ml)
SOURCES2 = $(SOURCES1:.mll=.ml)
PRODLEX  = $(patsubst %.mll, %.ml, $(filter %.mll,$(SOURCES)))
PRODYACC = $(patsubst %.mly, %.ml, $(filter %.mly,$(SOURCES))) $(patsubst %.mly, %.mli, $(filter %.mly,$(SOURCES)))
OBJS     = $(SOURCES2:.ml=.cmo)
OPTOBJS  = $(SOURCES2:.ml=.cmx)
REMOVE   = find . -name $(var) -exec rm -f {} \;
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
################### Creating documentation ###################
##############################################################

documentation: ${DOC}
	

.SUFFIXES: .tex .pdf

.tex.pdf:
	@${ECHO} "\033[33m$(<F) → $@\033[0m"
	@find . -name $(<F) -execdir ${PDFLATEX} {} 2> /dev/null \;
	@mv ${DOCPATH}/$@ .

##############################################################
################### Other generic rules ######################
##############################################################

clean:
	@# dependencies
	@rm -f ".depend"
	@# libraries
	@$(foreach var,"*.cm[iox]" "*~" ".*~",$(REMOVE);)
	@# lexer
	@$(foreach var,$(PRODLEX),$(REMOVE);)
	@# parser
	@$(foreach var,$(PRODYACC),$(REMOVE);)
	@# documentation files
	@rm -f $(addprefix $(DOCPATH)/,*~ *.dvi *.ps *.out *.log *.toc *.aux *.nav *.snm)

mrproper: clean
	@# executable
	@$(foreach var,$(EXEC) $(EXEC).opt,$(REMOVE);)
	@# documentation files
	@$(foreach var,${DOC},$(REMOVE);)

fixme:
	@# debuging
	@grep -i FIXME $(foreach d,${VPATH},$(foreach e,tex ml mli mll mly,$d/*.$e)) 2> /dev/null ; true

.depend: $(SOURCES2)
	@${ECHO} "\033[34m$(SOURCES2) → $@\033[0m"
	@$(CAMLDEP) $(INCLUDE) $(foreach var, $(notdir $^), $(shell find . -name $(var))) > $@

-include .depend


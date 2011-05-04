# Makefile
# Well… It’s the global Makefile!
# author: Martin BODIN <martin.bodin@ens-lyon.fr>

CAML = ocaml
CAMLC = ocamlc -w Ae
CAMLOPT = ocamlopt -w Ae
CAMLDEP = ocamldep
CAMLLEX = ocamllex
CAMLYACC = ocamlyacc

LIBS = unix.cma

EXEC = alcix

FILES = \
	position.mli choices.mli errors.mli \
	parsed_syntax.mli \
	parser.mli parser_printer.mli \
	io.mli \
	main.mli \
	\
	position.ml choices.ml errors.ml \
	parsed_syntax.ml \
	lexer.mll preparser.mly \
	parser.ml parser_printer.ml \
	io.ml \
	main.ml

COMPILE = compile
SRC = src
SUBFOLDERS = \
			parsing \
			interface

OTHER_FOLDERS = 
ECHO = echo

VPATH = ${COMPILE}:${foreach dir, ${SUBFOLDERS}, ${SRC}/${dir}}${foreach dir, ${OTHER_FOLDERS}, :${dir}}:.
INCLUDE = ${patsubst %,-I %,${subst :, ,${VPATH}}}

.PHONY: all opt clean mrproper recycle fixme

all: ${EXEC}


opt: ${EXEC}.opt

recycle:
	@rm -rf *~
	@rm -rf ${SRC}/*~ ${SRC}/*/*~

mrproper: recycle clean
	@rm -rf ${EXEC} ${EXEC}.opt


SOURCES  = ${FILES}
SOURCES1 = $(SOURCES:.mly=.ml)
SOURCES2 = ${filter %.ml, $(SOURCES1:.mll=.ml)}
HEADERS  = ${filter %.mli, $(SOURCES1:.mll=.ml)}
PRODLEX  = $(patsubst %.mll, %.ml, $(filter %.mll,$(SOURCES)))
PRODYACC = $(patsubst %.mly, %.ml, $(filter %.mly,$(SOURCES))) $(patsubst %.mly, %.mli, $(filter %.mly,$(SOURCES)))
CMI      = ${foreach file, ${HEADERS:.mli=.cmi}, ${COMPILE}/${file}}
OBJS     = ${foreach file, $(SOURCES2:.ml=.cmo), ${COMPILE}/${file}}
OPTOBJS  = ${foreach file, $(SOURCES2:.ml=.cmx), ${COMPILE}/${file}}
REMOVE   = find . -name $(var) -exec rm -vf {} \;
DUMP = sed -e 's/\\/\\\\/g' -e 's/\"/\\"/g' $(var) >> $@

${EXEC}: ${CMI} ${OBJS} .depend
	@${ECHO} "\033[1;33m${CMI} ${OBJS} → ${EXEC}\033[0;0m"
	@${CAMLC} ${INCLUDE} -o ${EXEC} ${LIBS} ${OBJS}

${EXEC}.opt: ${CMI} ${OPTOBJS} .depend 
	@${ECHO} "\033[1;33m${OPTOBJS} → ${EXEC}.opt\033[0;0m"
	@$(CAMLOPT) $(INCLUDE) -o $(EXEC).opt $(LIBS:.cma=.cmxa) $(OPTOBJS)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx .mll .mly

${COMPILE}/%.cmo: ${SRC}/*/%.ml
	@${ECHO} "\033[1;36m$*.ml → $*.cmo\033[0;0m"
	@${CAMLC} ${INCLUDE} -c $<
	@mv ${SRC}/*/$*.cmo ${COMPILE}/
	@if [ -e ${SRC}/*/$*.cmi ]; then mv ${SRC}/*/$*.cmi ${COMPILE}/; fi

${COMPILE}/%.cmi: ${SRC}/*/%.mli
	@${ECHO} "\033[1;36m$*.mli → $*.cmi\033[0;0m"
	@${CAMLC} ${INCLUDE} -c $<
	@mv ${SRC}/*/$*.cmi ${COMPILE}/

${COMPILE}/%.cmx: ${SRC}/*/%.ml
	@${ECHO} "\033[1;36m$*.ml → $*.cmx\033[0;0m"
	@${CAMLOPT} ${INCLUDE} -c $<
	@mv ${SRC}/*/$*.cmx ${SRC}/*/$*.o ${COMPILE}/
	@if [ -f ${SRC}/*/$*.cmi ]; then mv ${SRC}/*/$*.cmi ${COMPILE}/; fi

${COMPILE}/%.cmo: ${SRC}/*/%.mll
	@${CAMLLEX} $<
	@mv ${<:.mll=.ml} ${COMPILE}/
	@${ECHO} "\033[1;36m$*.mll → $*.cmo\033[0;0m"
	@${CAMLC} ${INCLUDE} -c ${COMPILE}/$*.ml

${COMPILE}/%.cmx: ${SRC}/*/%.mll
	@${CAMLLEX} $<
	@mv ${<:.mll=.ml} ${COMPILE}/
	@${ECHO} "\033[1;36m$*.mll → $*.cmx\033[0;0m"
	@${CAMLOPT} ${INCLUDE} -c ${COMPILE}/$*.ml

${COMPILE}/%.cmo: ${SRC}/*/%.mly
	@${CAMLYACC} $<
	@mv ${SRC}/*/$*.mli ${COMPILE}/
	@mv ${SRC}/*/$*.ml ${COMPILE}/
	@${ECHO} "\033[1;36m$*.mly → $*.mli\033[0;0m"
	@$(CAMLC) ${INCLUDE} -c ${COMPILE}/$*.mli
	@${ECHO} "\033[1;36m$*.mly → $*.cmo\033[0;0m"
	@$(CAMLC) $(INCLUDE) -c ${COMPILE}/$*.ml

${COMPILE}/%.cmx: ${SRC}/*/%.mly
	@${CAMLYACC} $<
	@mv ${SRC}/*/$*.mli ${COMPILE}/
	@mv ${SRC}/*/$*.ml ${COMPILE}/
	@${ECHO} "\033[1;36m$*.mly → $*.mli\033[0;0m"
	@${CAMLOPT} ${INCLUDE} -c ${COMPILE}/$*.mli
	@${ECHO} "\033[1;36m$*.mly → $*.cmx\033[0;0m"
	@${CAMLOPT} ${INCLUDE} -c ${COMPILE}/$*.ml

${COMPILE}/%.cmi: ${SRC}/*/%.mly
	@${CAMLYACC} $<
	@mv ${SRC}/*/$*.mli
	@${ECHO} "\033[1;36m$*.mly → $*.cmi\033[0;0m"
	@${CAMLC} ${INCLUDE} -c $*.mli
	@mv ${SRC}/*/$*.cmi ${COMPILE}/

${COMPILE}/%.ml: ${SRC}/*/%.mll
	@${CAMLLEX} $<
	@mv ${SRC}/*/$*.ml ${COMPILE}/

${COMPILE}/%.ml: ${SRC}/*/%.mly
	@${CAMLYACC} $<
	@mv ${SRC}/*/$*.ml ${COMPILE}/

fixme:
	@grep -is FIXME ${SRC}/*/*.ml ${SRC}/*/*.mli ${SRC}/*/*.mll ${SRC}/*/*.mly ; true

clean:
	@rm ${COMPILE}/*

DEPENDFILES = ${foreach file, ${FILES}, ${SRC}/*/${file}} \
			  ${foreach file, ${filter %.mll, ${FILES}}, ${COMPILE}/${file:.mll=.ml}} \
			  ${foreach file, ${filter %.mly, ${FILES}}, ${COMPILE}/${file:.mly=.ml}}

.depend: ${DEPENDFILES} Makefile
	@${CAMLDEP} ${INCLUDE} ${DEPENDFILES} > .depend.tmp
	@sed "s/${SRC}\/[^\/]*\/\([a-zA-Z0-9_]*\).cm\(.\)/${COMPILE}\/\1.cm\2/g" .depend.tmp > .depend
	@rm .depend.tmp

-include .depend

# These lines are human-generated ;-) because ocamldep does not parse mll and mly files…

##############################################################
################### Creating documentation ###################
##############################################################

documentation: ${DOC}
	

.SUFFIXES: .tex .pdf

.tex.pdf:
	@${ECHO} "\033[33m$(<F) → $@\033[0m"
	@find . -name $(<F) -execdir ${PDFLATEX} {} 2> /dev/null \;
	@mv ${DOCPATH}/$@ .


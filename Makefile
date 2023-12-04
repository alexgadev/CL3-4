##########################################################
#							 							 #
#						Compiladors						 #
#					Alex Garcia Amezcua					 #
#						 Makefile						 #
#							 							 #
##########################################################

# General defines
CC = cc
LEX = flex
BIS = bison

# "Libraries"
CFLAGS = -lfl -lm -std=gnu99 		# -lm is for math function
									# -std=gnu99 enables the usage of asprintf
SYMTAB = include/symtab/symtab.c
FUNC = source/compiler.c	

# Flex and bison sources
LEXSRC = source/lex.l
BISSRC = source/parse.y


# Compile generated
LEXGEN = gen/lex.yy.c
BISHDR = gen/parse.tab.h
BISGEN = gen/parse.tab.c

# Executable filename
BIN = calculadora

##########################################################

all : $(LEXSRC) $(BISSRC) $(SYMTAB)
	$(LEX) -o $(LEXGEN) $(LEXSRC)
	$(BIS) -o $(BISGEN) -d $(BISSRC)
	$(CC) -o $(BIN) $(LEXGEN) $(BISGEN) $(SYMTAB) $(FUNC) $(CFLAGS)

clean :
	rm -f $(BIN) $(LEXGEN) $(BISGEN) $(BISHDR)
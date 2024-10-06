 # -------------------------------------------------------------------
 #            Arquivo: Makefile
 # -------------------------------------------------------------------
 #              Autor: Bruno Müller Junior
 #               Data: 08/2007
 #      Atualizado em: [09/08/2020, 19h:01m]
 #
 # -------------------------------------------------------------------

$DEPURA=1

compilador: lex.yy.c compilador.tab.c compilador.o symbol_table.o compilador.h
	gcc lex.yy.c compilador.tab.c compilador.o symbol_table.o -o compilador -ll -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

compilador.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c
	gcc -c compiladorF.c -o compilador.o

symbol_table.o: symbol_table.h symbol_table.c
	gcc -c symbol_table.c -o symbol_table.o

clean :
	rm -f compilador.tab.* lex.yy.c compilador.o symbol_table.o compilador

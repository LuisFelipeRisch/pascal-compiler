
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "symbol_table.h"
#include "int_stack.h"

char mepa_command[10];
int num_vars, dmem_num_vars;
SymbolTable* symbol_table;
IntStack* amem_stack;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token PROCEDURE FUNCTION IF THEN ELSE WHILE DO
%token OR DIV AND LABEL TYPE ARRAY OF NOT

%%

programa: { geraCodigo (NULL, "INPP"); nivel_lexico = 0; }
   PROGRAM IDENT ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
   bloco PONTO { geraCodigo (NULL, "PARA"); }
;

bloco: { num_vars = 0; desloc = 0; }
   parte_declara_vars 
   {
      if (num_vars > 0) {
         sprintf(mepa_command, "AMEM %d", num_vars);
         geraCodigo(NULL, mepa_command);
      }

      push_int_stack(amem_stack, num_vars);
   }
   comando_composto
   {
      dmem_num_vars = pop_int_stack(amem_stack); 
      if (dmem_num_vars > 0) {
         remove_n_latest_nodes_from_symbol_table(symbol_table, dmem_num_vars);
         sprintf(mepa_command, "DMEM %d", dmem_num_vars);
         geraCodigo(NULL, mepa_command);
      }
   }
;

parte_declara_vars:  var
;


var: { } 
   VAR declara_vars
   |
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var: { }
            lista_id_var DOIS_PONTOS
            tipo { update_latest_nodes_with_variable_type(symbol_table, INTEGER); }
            PONTO_E_VIRGULA
;

tipo: IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT
              { insert_simple_variable_in_symbol_table(symbol_table, token, nivel_lexico, desloc++); num_vars++; }
            | IDENT { insert_simple_variable_in_symbol_table(symbol_table, token, nivel_lexico, desloc++); num_vars++; }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END

comandos:
;


%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }

   amem_stack = create_int_stack();
   symbol_table = create_symbol_table();

   yyin=fp;
   yyparse();

   free_int_stack(amem_stack);
   free_symbol_table(symbol_table);

   return 0;
}

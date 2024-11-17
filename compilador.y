
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
#include "pass_by_types.h"
#include "variable_types.h"

char mepa_label[100], mepa_command[100], error_command[100], 
     current_procedure_token[TAM_TOKEN];
int num_vars, dmem_num_vars, current_label_number = 0, current_formal_params_count;
SymbolTable* symbol_table;
IntStack *amem_stack, *label_stack;
SymbolTableNode *left_node, *current_procedure_node;
enum PassByTypes current_formal_parameters_pass_by_type;
enum VariableTypes current_formal_parameters_variable_type;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO ATRIBUICAO
%token PROCEDURE_TOKEN FUNCTION_TOKEN IF THEN ELSE WHILE DO INTEGER_TOKEN
%token OR DIV AND LABEL TYPE ARRAY OF NOT
%token IGUAL DIFERENTE MENOR MENOR_IGUAL MAIOR MAIOR_IGUAL
%token MAIS MENOS MULT READ WRITE

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%union {
   char *str;
   int int_val;
}

%type <str> relacao
%type <str> mult_ou_div_ou_and
%type <str> mais_ou_menos_ou_or
%type <str> mais_ou_menos
%type <int_val> termo
%type <int_val> fator
%type <int_val> expressao
%type <int_val> expressao_simples
%type <int_val> atribuicao

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
   declaracao_subrotinas
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

declaracao_subrotinas: declaracao_subrotinas declaracao_subrotina
                       | 
;

declaracao_subrotina: declaracao_procedimento
;

declaracao_procedimento: PROCEDURE_TOKEN IDENT
                         {
                           nivel_lexico++; 

                           sprintf(mepa_command, "DSVS R%02d", current_label_number);
                           push_int_stack(label_stack, current_label_number++);
                           geraCodigo(NULL, mepa_command);

                           sprintf(mepa_label, "R%02d", current_label_number); 
                           current_procedure_node = insert_procedure_in_symbol_table(symbol_table, token, nivel_lexico, current_label_number++);

                           sprintf(mepa_command, "ENPR %d", nivel_lexico); 
                           geraCodigo(mepa_label, mepa_command);

                           current_formal_params_count = 0;
                         }
                         declaracao_parametros_formais PONTO_E_VIRGULA bloco
                         {
                           remove_subroutines_from_symbol_table_in_lexical_level(symbol_table, nivel_lexico + 1); 
                           remove_formal_parameters_from_symbol_table(symbol_table);

                           current_procedure_node = symbol_table->top; 
                           ProcedureAttributes* procedure_attributes = (ProcedureAttributes *) current_procedure_node->attributes;

                           sprintf(mepa_command, "RTPR %d,%d", current_procedure_node->lexical_level, procedure_attributes->formal_params_count);
                           geraCodigo(NULL, mepa_command); 

                           sprintf(mepa_label, "R%02d", pop_int_stack(label_stack));
                           geraCodigo(mepa_label, "NADA");
                         }
                         PONTO_E_VIRGULA

;

declaracao_parametros_formais: ABRE_PARENTESES parametros_formais FECHA_PARENTESES
                               {
                                 update_procedure_and_formal_parameters(symbol_table, current_procedure_node, current_formal_params_count, current_formal_parameters_variable_type);
                               }
                               |
;

parametros_formais: parametros_formais PONTO_E_VIRGULA declaracao_parametro_formal
                    | declaracao_parametro_formal
;

declaracao_parametro_formal: VAR { current_formal_parameters_pass_by_type = REFERENCE; } lista_parametros_formais DOIS_PONTOS tipo_parametros_formais
                             | { current_formal_parameters_pass_by_type = VALUE; } lista_parametros_formais DOIS_PONTOS tipo_parametros_formais
;

lista_parametros_formais: lista_parametros_formais VIRGULA IDENT 
                          { 
                           insert_formal_parameter_in_symbol_table(symbol_table, token, nivel_lexico, current_formal_parameters_pass_by_type); 
                           current_formal_params_count++; 
                          }
                          | IDENT 
                            { 
                              insert_formal_parameter_in_symbol_table(symbol_table, token, nivel_lexico, current_formal_parameters_pass_by_type);
                              current_formal_params_count++;
                            }
;

tipo_parametros_formais: INTEGER_TOKEN { current_formal_parameters_variable_type = INTEGER; } 
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

tipo: INTEGER_TOKEN
;

lista_id_var: lista_id_var VIRGULA IDENT
              { insert_simple_variable_in_symbol_table(symbol_table, token, nivel_lexico, desloc++); num_vars++; }
            | IDENT { insert_simple_variable_in_symbol_table(symbol_table, token, nivel_lexico, desloc++); num_vars++; }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END
;

comandos: comandos PONTO_E_VIRGULA comando_sem_rotulo
          | comando_sem_rotulo
;

comando_sem_rotulo: comando_composto
                    | read_comando
                    | write_comando
                    | atribuicao_comando
                    | while_comando
                    | if_comando
                    |
;

if_comando: if_then cond_else
            {
               sprintf(mepa_command, "R%02d", pop_int_stack(label_stack)); 
               geraCodigo(mepa_command, "NADA");
            }
;

if_then: IF expressao
         {
            if($2 == BOOLEAN) {
               sprintf(mepa_command, "DSVF R%02d", current_label_number); 
               push_int_stack(label_stack, current_label_number++); 
               geraCodigo(NULL, mepa_command);
            } else 
               imprimeErro("Tipos Incompatíveis!");
         }
         THEN comando_sem_rotulo
         {
            sprintf(mepa_command, "DSVS R%02d", current_label_number); 
            geraCodigo(NULL, mepa_command);

            sprintf(mepa_command, "R%02d", pop_int_stack(label_stack)); 
            geraCodigo(mepa_command, "NADA");

            push_int_stack(label_stack, current_label_number++); 
         }
;

cond_else: ELSE comando_sem_rotulo
           | %prec LOWER_THAN_ELSE
;

read_comando: READ ABRE_PARENTESES read_idents FECHA_PARENTESES
;

write_comando: WRITE ABRE_PARENTESES write_idents FECHA_PARENTESES
;

write_idents: write_idents VIRGULA write_ident
              | write_ident
;

write_ident: IDENT
             {
               left_node = find_node_from_symbol_table_by_identifier(symbol_table, token); 
               if (!left_node){
                  sprintf(error_command, "Não foi possível encontrar a variável '%s' na tabela de símbolos!", token); 
                  imprimeErro(error_command);
               }

               if(left_node->identifier_category == SIMPLE_VARIABLE){
                  SimpleVariableAttributes* attributes = (SimpleVariableAttributes *) left_node->attributes;

                  sprintf(mepa_command, "CRVL %d,%d", left_node->lexical_level, attributes->offset);
                  geraCodigo(NULL, mepa_command);
               }

               geraCodigo(NULL, "IMPR");
             }

read_idents: read_idents VIRGULA read_ident
             | read_ident
; 

read_ident: IDENT 
            {
               left_node = find_node_from_symbol_table_by_identifier(symbol_table, token); 
               if (!left_node){
                  sprintf(error_command, "Não foi possível encontrar a variável '%s' na tabela de símbolos!", token); 
                  imprimeErro(error_command);
               }

               geraCodigo(NULL, "LEIT");
               
               if(left_node->identifier_category == SIMPLE_VARIABLE){
                  SimpleVariableAttributes* attributes = (SimpleVariableAttributes *) left_node->attributes;

                  sprintf(mepa_command, "ARMZ %d,%d", left_node->lexical_level, attributes->offset);
                  geraCodigo(NULL, mepa_command);
               }
            }
;

while_comando: WHILE
               {
                  sprintf(mepa_command, "R%02d", current_label_number); 
                  push_int_stack(label_stack, current_label_number++); 
                  geraCodigo(mepa_command, "NADA");
               }
               expressao
               {
                  if ($3 == BOOLEAN) {
                     sprintf(mepa_command, "DSVF R%02d", current_label_number); 
                     push_int_stack(label_stack, current_label_number++); 
                     geraCodigo(NULL, mepa_command);
                  } else
                     imprimeErro("Tipos Incompatíveis!");
               }
               DO comando_sem_rotulo
               {
                  int while_exit_label_number = pop_int_stack(label_stack); 

                  sprintf(mepa_command, "DSVS R%02d", pop_int_stack(label_stack)); 
                  geraCodigo(NULL, mepa_command); 

                  sprintf(mepa_command, "R%02d", while_exit_label_number); 
                  geraCodigo(mepa_command, "NADA");
               }
;

atribuicao_comando: IDENT 
                    { 
                       left_node = find_node_from_symbol_table_by_identifier(symbol_table, token);
                       if(!left_node){
                          sprintf(error_command, "Não foi possível encontrar a variável '%s' na tabela de símbolos!", token); 
                          imprimeErro(error_command);
                       }
                    }
                    atribuicao
;

atribuicao: ATRIBUICAO logica_atribuicao
;

logica_atribuicao: expressao
                   {
                     if(left_node->identifier_category == SIMPLE_VARIABLE){
                        SimpleVariableAttributes* attributes = (SimpleVariableAttributes *) left_node->attributes;
                        if(attributes->variable_type != $1) imprimeErro("Tipos Incompatíveis!");;

                        sprintf(mepa_command, "ARMZ %d,%d", left_node->lexical_level, attributes->offset);
                        geraCodigo(NULL, mepa_command);
                     }
                   }
;

expressao: expressao_simples relacao expressao_simples
           {
            if((!strcmp("CMIG", $2) || !strcmp("CMDG", $2)  || 
                !strcmp("CMME", $2) || !strcmp("CMEG", $2)  ||
                !strcmp("CMMA", $2) || !strcmp("CMAG", $2)) && 
                $1 == INTEGER && $3 == INTEGER) {
               geraCodigo(NULL, $2);
               $$ = BOOLEAN;
            } else
               imprimeErro("Tipos Incompatíveis!");;
           }
           | expressao_simples 
             { 
               $$ = $1;
             }
;

relacao: IGUAL { $$ = "CMIG"; }        
         | DIFERENTE { $$ = "CMDG"; }  
         | MENOR { $$ = "CMME"; }      
         | MENOR_IGUAL { $$ = "CMEG"; }
         | MAIOR { $$ = "CMMA"; }      
         | MAIOR_IGUAL { $$ = "CMAG"; }
;

expressao_simples: expressao_simples mais_ou_menos_ou_or termo
                   {
                     if ((!strcmp("SOMA", $2) || !strcmp("SUBT", $2)) && $1 == INTEGER && $3 == INTEGER){
                        sprintf(mepa_command, "%s", $2);
                        geraCodigo(NULL, $2); 
                        $$ = INTEGER;
                     } else if (!strcmp("DISJ", $2) && $1 == BOOLEAN && $3 == BOOLEAN){
                        sprintf(mepa_command, "%s", $2); 
                        geraCodigo(NULL, mepa_command); 
                        $$ = BOOLEAN;
                     } else
                        imprimeErro("Tipos Incompatíveis!");;
                   }
                   | mais_ou_menos termo
                     {
                        $$ = $2;
                     }
;

mais_ou_menos_ou_or: MAIS { $$ = "SOMA"; }
                     | MENOS { $$ = "SUBT"; }
                     | OR { $$ = "DISJ"; }
;

mais_ou_menos: MAIS { $$ = "SOMA"; }
               | MENOS { $$ = "SUBT"; }
               | { $$ = "NADA"; }
;

termo: termo mult_ou_div_ou_and fator
       {
         if ((!strcmp("MULT", $2) || !strcmp("DIVI", $2)) && $1 == INTEGER && $3 == INTEGER){
            sprintf(mepa_command, "%s", $2); 
            geraCodigo(NULL, mepa_command); 
            $$ = INTEGER;
         } else if (!strcmp("CONJ", $2) && $1 == BOOLEAN && $3 == BOOLEAN){
            sprintf(mepa_command, "%s", $2); 
            geraCodigo(NULL, mepa_command); 
            $$ = BOOLEAN;
         } else
            imprimeErro("Tipos Incompatíveis!");;
       }
       | fator { $$ = $1; }
;

mult_ou_div_ou_and: MULT { $$ = "MULT"; }
                    | DIV { $$ = "DIVI"; } 
                    | AND { $$ = "CONJ"; }
;

fator: IDENT
       {
         SymbolTableNode* node = find_node_from_symbol_table_by_identifier(symbol_table, token);
         if(!node){
            sprintf(error_command, "Não foi possível encontrar a variável '%s' na tabela de símbolos!", token); 
            imprimeErro(error_command);
         }

         if(node->identifier_category == SIMPLE_VARIABLE){
            SimpleVariableAttributes* attributes = (SimpleVariableAttributes *) node->attributes;

            sprintf(mepa_command, "CRVL %d,%d", node->lexical_level, attributes->offset);
            $$ = attributes->variable_type;
         }

         geraCodigo(NULL, mepa_command);
       }
       | NUMERO 
         { 
            sprintf(mepa_command, "CRCT %s", token);
            geraCodigo(NULL, mepa_command);
            $$ = INTEGER;
         }
       | ABRE_PARENTESES expressao FECHA_PARENTESES
         {
            $$ = $2;
         }
       | NOT fator
         {
            if ($2 == BOOLEAN){
               geraCodigo(NULL, "NEGA");
               $$ = BOOLEAN;
            } else
               imprimeErro("Tipos Incompatíveis!");;
         }
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
   label_stack = create_int_stack();

   yyin=fp;
   yyparse();

   free_int_stack(amem_stack);
   free_symbol_table(symbol_table);
   free_int_stack(label_stack);

   return 0;
}
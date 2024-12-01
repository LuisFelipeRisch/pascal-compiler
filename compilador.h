/* -------------------------------------------------------------------
 *            Arquivo: compilador.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [09/08/2020, 19h:01m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e variáveis globais do compilador (via extern)
 *
 * ------------------------------------------------------------------- */

#include "pass_by_types.h"

#define TAM_TOKEN 16

typedef enum simbolos {
  simb_program, simb_var, simb_begin, simb_end,
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses,
  simb_procedure, simb_function, simb_if, simb_then, simb_else, 
  simb_while, simb_do, simb_or, simb_div, simb_and, simb_label, 
  simb_type, simb_array, simb_of, simb_not, simb_igual, simb_diferente, 
  simb_menor, simb_menor_igual, simb_maior, simb_maior_igual, 
  simb_mais, simb_menos, simb_mult, simb_read, simb_write, simb_integer,
} simbolos;



/* -------------------------------------------------------------------
 * variáveis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern unsigned int nivel_lexico;
extern unsigned int desloc;
extern unsigned int nl;

/* -------------------------------------------------------------------
 * prototipos globais
 * ------------------------------------------------------------------- */

void geraCodigo (char*, char*);
int yylex();
void yyerror(const char *s);
int imprimeErro ( const char* erro );
char* fetch_load_command(enum PassByTypes ident_pass_type, enum PassByTypes param_pass_type);
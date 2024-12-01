
/* -------------------------------------------------------------------
 *            Aquivo: compilador.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [09/08/2020, 19h:01m]
 *
 * -------------------------------------------------------------------
 *
 * Funções auxiliares ao compilador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "pass_by_types.h"


/* -------------------------------------------------------------------
 *  variáveis globais
 * ------------------------------------------------------------------- */

simbolos simbolo, relacao;
char token[TAM_TOKEN];

FILE* fp=NULL;
void geraCodigo (char* rot, char* comando) {

  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }

  if ( rot == NULL ) {
    fprintf(fp, "     %s\n", comando); fflush(fp);
  } else {
    fprintf(fp, "%s: %s \n", rot, comando); fflush(fp);
  }
}

int imprimeErro ( const char* erro ) {
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}

char* fetch_load_command(enum PassByTypes ident_pass_type, enum PassByTypes param_pass_type) {
   if (ident_pass_type == VALUE && param_pass_type == VALUE)
      return "CRVL"; 
   else if (ident_pass_type == VALUE && param_pass_type == REFERENCE)
      return "CREN";
   else if (ident_pass_type == REFERENCE && param_pass_type == VALUE)
      return "CRVI";
   else if (ident_pass_type == REFERENCE && param_pass_type == REFERENCE)
      return "CRVL";
}

void yyerror(const char *s) {
  imprimeErro(s);
}
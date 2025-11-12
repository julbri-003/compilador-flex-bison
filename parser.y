%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

int comparar_cadenas(const char *a, const char *b) {
    return strcmp(a, b);
}

int condicion_verdadera = 0;
%}

%union {
    char *str;
    int   boolean;
}

/* tokens */
%token KW_BUEN_DIA KW_BUENAS_NOCHES KW_LEER KW_MOSTRAR
%token KW_CUMPLE KW_PASA KW_EN_CAMBIO KW_PUNTO
%token MAYOR MENOR IGUAL MAS GUION
%token <str> CADENA

/* <-- importante: declarar el tipo de 'expresion' */
%type <str> expresion

%%

programa:
    KW_BUEN_DIA sentencias KW_BUENAS_NOCHES
    ;

sentencias:
    sentencia
  | sentencias sentencia
    ;

sentencia:
    KW_LEER CADENA GUION
  | expresion GUION
  | instruccion_condicional
  | KW_MOSTRAR CADENA GUION { printf("%s\n", $2); }
    ;

instruccion_condicional:
    KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales KW_PUNTO
    ;

resto_condicionales:
    /* puede haber más en_cambio */
    | KW_EN_CAMBIO instruccion_condicional
    | KW_EN_CAMBIO KW_MOSTRAR CADENA GUION
      {
          if (!condicion_verdadera)
              printf("%s\n", $3);
      }
    ;

bloque_condicionales:
    KW_MOSTRAR CADENA GUION
      {
          if (condicion_verdadera)
              printf("%s\n", $2);
      }
    ;

expresion_comparacion:
    CADENA MAYOR CADENA
      { condicion_verdadera = (comparar_cadenas($1, $3) > 0);
        printf("[DEBUG] Comparo '%s' > '%s' => %d\n", $1, $3, condicion_verdadera);
      }
  | CADENA MENOR CADENA
      { condicion_verdadera = (comparar_cadenas($1, $3) < 0);
        printf("[DEBUG] Comparo '%s' < '%s' => %d\n", $1, $3, condicion_verdadera);
      }
  | CADENA IGUAL CADENA
      { condicion_verdadera = (strcmp($1, $3) == 0);
        printf("[DEBUG] Comparo '%s' == '%s' => %d\n", $1, $3, condicion_verdadera);
      }
    ;

expresion:
    CADENA
      {
        /* devolvemos una copia para que $$ tenga ownership propio */
        $$ = strdup($1);
      }
  | CADENA MAS CADENA
    {
        $$ = malloc(strlen($1) + strlen($3) + 1);
        if ($$ == NULL) { yyerror("malloc failed"); YYABORT; }
        strcpy($$, $1);
        strcat($$, $3);
        printf("[DEBUG] Concateno '%s' + '%s' => '%s'\n", $1, $3, $$);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico: %s\n", s);
}


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

// tabla de símbolos simple (una variable y su valor)
char variable[256] = "";
char valor_variable[1024] = "";

int comparar_cadenas(const char *a, const char *b) {
    return strcmp(a, b);
}

int condicion_verdadera = 0;
%}

/* union y tipos */
%union {
    char *str;
}

/* tokens */
%token KW_BUEN_DIA KW_BUENAS_NOCHES KW_LEER KW_MOSTRAR
%token KW_CUMPLE KW_PASA KW_EN_CAMBIO KW_PUNTO
%token MAYOR MENOR COMPARADOR MAS GUION ASIGNACION
%token <str> CADENA

/* indicamos que 'expresion' devuelve <str> */
%type <str> expresion expresion_comparacion asignacion

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
  | asignacion GUION
  | expresion_comparacion GUION
  | instruccion_condicional
  | KW_MOSTRAR CADENA GUION   { printf("%s\n", $2); }
    ;

/* ---------------- ASIGNACIÓN: CADENA == expresion ---------------- */
asignacion:
    CADENA ASIGNACION expresion
      {
          strncpy(variable, $1, sizeof(variable)-1);
          variable[sizeof(variable)-1] = '\0';
          strncpy(valor_variable, $3, sizeof(valor_variable)-1);
          valor_variable[sizeof(valor_variable)-1] = '\0';
          printf("[DEBUG] Asigno a %s el valor '%s'\n", $1, $3);
      }
    ;

/* ---------------- CONDICIONALES ---------------- */
instruccion_condicional:
    KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales KW_PUNTO
    ;

/*
 * resto_condicionales puede tener:
 * - nada (solo un bloque cumple)
 * - uno o más en_cambio (con o sin cumple)
 */
resto_condicionales:
      /* vacío */
    | KW_EN_CAMBIO KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales
    | KW_EN_CAMBIO bloque_condicionales
    ;

/* bloque que se ejecuta si la condición es verdadera */
bloque_condicionales:
    KW_MOSTRAR CADENA GUION
      {
          if (condicion_verdadera)
              printf("%s\n", $2);
      }
    ;

/* ---------------- EXPRESIONES / COMPARACIONES ---------------- */
expresion_comparacion:
    expresion MAYOR expresion
      {
          condicion_verdadera = (comparar_cadenas($1, $3) > 0);
          printf("[DEBUG] Comparo '%s' > '%s' => %d\n", $1, $3, condicion_verdadera);
      }
  | expresion MENOR expresion
      {
          condicion_verdadera = (comparar_cadenas($1, $3) < 0);
          printf("[DEBUG] Comparo '%s' < '%s' => %d\n", $1, $3, condicion_verdadera);
      }
  | expresion COMPARADOR expresion
      {
          condicion_verdadera = (strcmp($1, $3) == 0);
          printf("[DEBUG] Comparo '%s' $ '%s' => %d\n", $1, $3, condicion_verdadera);
      }
    ;

/* expresion: cadena simple o concatenación */
expresion:
    CADENA
      { $$ = strdup($1); }
  | expresion MAS CADENA
    {
        size_t len = strlen($1) + strlen($3) + 1;
        $$ = malloc(len);
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

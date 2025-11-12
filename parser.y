%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

// variables globales simples
char variable[256] = "";
char valor_variable[1024] = "";

// funciones auxiliares
int comparar_cadenas(const char *a, const char *b) {
    return strcmp(a, b);
}

// banderas de control
int condicion_verdadera = 0;
int condicion_cumplida = 0;
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

/* tipos de retorno */
%type <str> expresion expresion_comparacion asignacion

%%

programa:
    KW_BUEN_DIA sentencias KW_BUENAS_NOCHES
    { printf("\nAnálisis sintáctico completado correctamente.\n"); }
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

/* BLOQUE CONDICIONAL */
instruccion_condicional:
    {
        // Reiniciar banderas al entrar en una nueva estructura condicional
        condicion_cumplida = 0;
        condicion_verdadera = 0;
    }
    KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales KW_PUNTO
    {
        // Fin de la estructura condicional
    }
    ;

/* else-if y else */
resto_condicionales:
      /* vacío */
    | KW_EN_CAMBIO KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales
    | KW_EN_CAMBIO bloque_condicional_else
    ;

/* bloque de acciones cuando hay condición (cumple...) */
bloque_condicionales:
    KW_MOSTRAR CADENA GUION
      {
          if (!condicion_cumplida && condicion_verdadera) {
              printf("%s\n", $2);
              condicion_cumplida = 1;
          }
      }
    ;

/* bloque de acciones para el else (en_cambio sin cumple) */
bloque_condicional_else:
    KW_MOSTRAR CADENA GUION
      {
          if (!condicion_cumplida) {
              printf("%s\n", $2);
              condicion_cumplida = 1;
          }
      }
    ;

/* expresiones de comparación */
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
          printf("[DEBUG] Comparo '%s' == '%s' => %d\n", $1, $3, condicion_verdadera);
      }
    ;

/* expresiones con concatenación */
expresion:
    CADENA
      { $$ = strdup($1); }
  | expresion MAS CADENA
    {
        size_t len = strlen($1) + strlen($3) + 1;
        $$ = malloc(len);
        strcpy($$, $1);
        strcat($$, $3);
        printf("[DEBUG] Concateno '%s' + '%s' => '%s'\n", $1, $3, $$);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico: %s\n", s);
}

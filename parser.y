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

// banderas de control de condicionales
int condicion_verdadera = 0;
int condicion_cumplida = 0; // <-- nueva variable para manejar el "else if / else"
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

/* PROGRAMA PRINCIPAL */
programa:
    KW_BUEN_DIA sentencias KW_BUENAS_NOCHES
    { printf("\nAnálisis sintáctico completado correctamente.\n"); }
    ;

/* Lista de sentencias */
sentencias:
    sentencia
  | sentencias sentencia
    ;

/* Sentencias posibles */
sentencia:
    KW_LEER CADENA GUION
  | asignacion GUION
  | expresion_comparacion GUION
  | instruccion_condicional
  | KW_MOSTRAR CADENA GUION   { printf("%s\n", $2); }
    ;

/* ASIGNACIÓN */
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

/* CONDICIONAL COMPLETO */
instruccion_condicional:
    KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales KW_PUNTO
    {
        condicion_cumplida = 0; // reinicia el estado al comenzar cada bloque condicional
    }
    ;

/* ELSE IF / ELSE */
resto_condicionales:
      /* vacío */
    | KW_EN_CAMBIO KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales
    | KW_EN_CAMBIO bloque_condicionales
    ;

/* BLOQUE DE ACCIONES (solo mostrar por ahora) */
bloque_condicionales:
    KW_MOSTRAR CADENA GUION
      {
          if (!condicion_cumplida && condicion_verdadera) {
              printf("%s\n", $2);
              condicion_cumplida = 1; // ya se ejecutó un bloque
          }
      }
    ;

/* EXPRESIONES DE COMPARACIÓN */
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

/* EXPRESIONES (concatenación recursiva) */
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

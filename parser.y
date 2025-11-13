%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//mostrar linea y token
extern int yylineno;   // contador de lineas del lexer
extern char *yytext;   // token actual

int yylex(void);
void yyerror(const char *s);

// variables para asignaciones
char variable[256] = "";
char valor_variable[1024] = "";

// comparación de cadenas
int comparar_cadenas(const char *a, const char *b) {
    return strcmp(a, b);
}

// flags para if
int condicion_verdadera = 0;
int condicion_cumplida = 0;

%}

%define parse.error verbose 

/* solo usamos cadenas */
%union {
    char *str; 
}

/* tokens */
%token BUEN_DIA BUENAS_NOCHES LEER MOSTRAR
%token CUMPLE PASA EN_CAMBIO PUNTO
%token MAYOR MENOR COMPARADOR MAS GUION ASIGNACION
%token <str> CADENA

/* para poder usar cadenas adentro de las estructuras */
%type <str> expresion expresion_comparacion asignacion

%%

programa:
    BUEN_DIA sentencias BUENAS_NOCHES
    ;

sentencias:
    sentencia
  | sentencias sentencia
    ;

sentencia:
    LEER CADENA GUION 
      {
          printf("Leo el valor '%s'\n", $2);
      }
  | asignacion GUION
  | expresion_comparacion GUION
  | instruccion_condicional
  | MOSTRAR CADENA GUION   { printf("%s\n", $2); }
    ;

asignacion:
    CADENA ASIGNACION expresion
      {
          strncpy(variable, $1, sizeof(variable)-1);
          variable[sizeof(variable)-1] = '\0';
          strncpy(valor_variable, $3, sizeof(valor_variable)-1);
          valor_variable[sizeof(valor_variable)-1] = '\0';
          printf("Asigno a %s el valor '%s'\n", $1, $3);
      }
    ;

//condicionales
instruccion_condicional:
    {
        // reinicio cuando empieza otro if
        condicion_cumplida = 0;
        condicion_verdadera = 0;
    }
    CUMPLE expresion_comparacion PASA bloque_condicionales resto_condicionales PUNTO
    {
        // termina el if
    }
    ;

resto_condicionales:
      //vacio
    | EN_CAMBIO CUMPLE expresion_comparacion PASA bloque_condicionales resto_condicionales
    | EN_CAMBIO bloque_condicional_else
    ;

//cuando hay condicion
bloque_condicionales:
    MOSTRAR CADENA GUION
      {
          if (!condicion_cumplida && condicion_verdadera) {
              printf("%s\n", $2);
              condicion_cumplida = 1;
          }
      }
    ;

//else
bloque_condicional_else:
    MOSTRAR CADENA GUION
      {
          if (!condicion_cumplida) {
              printf("%s\n", $2);
              condicion_cumplida = 1;
          }
      }
    ;

//comparación 
expresion_comparacion:
    expresion MAYOR expresion
      {
          condicion_verdadera = (comparar_cadenas($1, $3) > 0);
      }
  | expresion MENOR expresion
      {
          condicion_verdadera = (comparar_cadenas($1, $3) < 0);
      }
  | expresion COMPARADOR expresion
      {
          condicion_verdadera = (strcmp($1, $3) == 0);
      }
    ;

// concatenación 
expresion:
    CADENA
      { $$ = strdup($1); }
  | expresion MAS CADENA
    {
        size_t len = strlen($1) + strlen($3) + 1;
        $$ = malloc(len);
        strcpy($$, $1);
        strcat($$, $3);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en linea %d cerca de '%s': %s\n", yylineno, yytext, s);
}
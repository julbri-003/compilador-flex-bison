%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico: %s\n", s);
}
%}

%union {
    char *str;
    int num;
}

/* Tokens */
%token BUEN_DIA BUENAS_NOCHES LEER MOSTRAR
%token CUMPLE PASA EN_CAMBIO PUNTO
%token ASIGNAR SUMAR PESOS MENOR MAYOR FIN
%token <str> IDENT STRING
%token <num> NUMERO

%%

Programa:
      BUEN_DIA ListaDeSentencias BUENAS_NOCHES
      { printf("Programa sintácticamente válido\n"); }
    ;

ListaDeSentencias:
      Sentencia
    | Sentencia ListaDeSentencias
    ;

Sentencia:
      SentenciaAsignacion
    | SentenciaLectura
    | SentenciaEscritura
    | SentenciaComparacion
    | SentenciaIf
    ;

SentenciaAsignacion:
      IDENT ASIGNAR Expresion FIN
    { printf("Asignación detectada: %s == ... (ok)\n", $1); }
    ;

SentenciaLectura:
      LEER IDENT FIN
    { printf("Lectura detectada: leer %s\n", $2); }
    ;

SentenciaEscritura:
      MOSTRAR Expresion FIN
    { printf("Mostrar detectado\n"); }
    ;

SentenciaComparacion:
      Expresion PESOS Expresion FIN
    { printf("Comparación (PESOS) detectada\n"); }
    ;


//if anidados
SentenciaIf:
      BloqueIf PUNTO
    { printf("Estructura cumple/pasa/en_cambio/punto correcta\n"); }
    ;

BloqueIf:
      CUMPLE Expresion PASA ListaDeSentencias
      { printf("Bloque IF principal\n"); }
    | CUMPLE Expresion PASA ListaDeSentencias ListaElseIf
    ;

ListaElseIf:
      EN_CAMBIO CUMPLE Expresion PASA ListaDeSentencias
      | EN_CAMBIO CUMPLE Expresion PASA ListaDeSentencias ListaElseIf
      | EN_CAMBIO ListaDeSentencias
    ;

Expresion:
      Expresion SUMAR Termino     { $$ = 0; }
    | Expresion MENOR Termino     { $$ = 0; }
    | Expresion MAYOR Termino     { $$ = 0; }
    | Termino
    ;

Termino:
      IDENT                       { $$ = 0; }
    | NUMERO                      { $$ = $1; }
    | STRING                      { $$ = 0; }
    | '(' Expresion ')'           { $$ = 0; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico: %s\n", s);
}

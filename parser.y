%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int argc_global;
extern char **argv_global;

int yylex(void);
void yyerror(const char *s) { fprintf(stderr, "Error sintáctico: %s\n", s); }

typedef struct {
    char *str;
    int num;
} YYSTYPE_UNION;

#define YYSTYPE YYSTYPE_UNION
%}

%token BUEN_DIA BUENAS_NOCHES LEER MOSTRAR ASIGNAR SUMAR PESOS MENOR MAYOR FIN
%token <str> IDENT STRING
%token <num> NUMERO

%%

Programa:
    BUEN_DIA ListaDeSentencias BUENAS_NOCHES { printf("Programa válido ✅\n"); }
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
;

SentenciaAsignacion:
    IDENT ASIGNAR Expresion FIN { printf("Asigno %s := ...\n", $1); }
;

SentenciaLectura:
    LEER IDENT FIN { printf("Leo variable %s\n", $2); }
;

SentenciaEscritura:
    MOSTRAR Expresion FIN { printf("Muestro algo\n"); }
;

SentenciaComparacion:
    Expresion PESOS Expresion FIN {
        if (strcmp($1.str, $3.str) == 0)
            printf("Comparación: %s == %s → iguales \n", $1.str, $3.str);
        else
            printf("Comparación: %s == %s → distintas \n", $1.str, $3.str);
    }
;

Expresion:
    Expresion SUMAR Termino { printf("Concateno cadenas\n"); }
  | Expresion MENOR Termino { printf("Comparo si menor\n"); }
  | Expresion MAYOR Termino { printf("Comparo si mayor\n"); }
  | Termino
;

Termino:
    IDENT
  | NUMERO
  | STRING
;

%%


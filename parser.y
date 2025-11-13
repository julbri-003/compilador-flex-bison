%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

// variables para asignaciones
char variable[256] = "";
char valor_variable[1024] = "";


int comparar_cadenas(const char *a, const char *b) {
    return strcmp(a, b);
}

// flags para if
int condicion_verdadera = 0;
int condicion_cumplida = 0;
%} 

/* solo usamos cadenas */
%union {
    char *str; 
}

/* tokens */
%token KW_BUEN_DIA KW_BUENAS_NOCHES KW_LEER KW_MOSTRAR
%token KW_CUMPLE KW_PASA KW_EN_CAMBIO KW_PUNTO
%token MAYOR MENOR COMPARADOR MAS GUION ASIGNACION
%token <str> CADENA

/* para poder usar cadenas adentro de las estructuras */
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
      {
          printf("Leo el valor '%s'\n", $2);
      }
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
          printf("Asigno a %s el valor '%s'\n", $1, $3);
      }
    ;

/* condicionales */
instruccion_condicional:
    {
        // reinicio cuando empieza otro if
        condicion_cumplida = 0;
        condicion_verdadera = 0;
    }
    KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales KW_PUNTO
    {
        // termina el if
    }
    ;


resto_condicionales:
      /* vacío */
    | KW_EN_CAMBIO KW_CUMPLE expresion_comparacion KW_PASA bloque_condicionales resto_condicionales
    | KW_EN_CAMBIO bloque_condicional_else
    ;

/* cuando hay condición */
bloque_condicionales:
    KW_MOSTRAR CADENA GUION
      {
          if (!condicion_cumplida && condicion_verdadera) {
              printf("%s\n", $2);
              condicion_cumplida = 1;
          }
      }
    ;

/*  else  */
bloque_condicional_else:
    KW_MOSTRAR CADENA GUION
      {
          if (!condicion_cumplida) {
              printf("%s\n", $2);
              condicion_cumplida = 1;
          }
      }
    ;

/* comparación */
expresion_comparacion:
    expresion MAYOR expresion
      {
          condicion_verdadera = (comparar_cadenas($1, $3) > 0);
          //("Comparo '%s' > '%s' => %d\n", $1, $3, condicion_verdadera);
      }
  | expresion MENOR expresion
      {
          condicion_verdadera = (comparar_cadenas($1, $3) < 0);
          //("Comparo '%s' < '%s' => %d\n", $1, $3, condicion_verdadera);
      }
  | expresion COMPARADOR expresion
      {
          condicion_verdadera = (strcmp($1, $3) == 0);
          //("Comparo '%s' == '%s' => %d\n", $1, $3, condicion_verdadera);
      }
    ;

/* concatenación */
expresion:
    CADENA
      { $$ = strdup($1); }
  | expresion MAS CADENA
    {
        size_t len = strlen($1) + strlen($3) + 1;
        $$ = malloc(len);
        strcpy($$, $1);
        strcat($$, $3);
        //printf("Concateno '%s' + '%s' => '%s'\n", $1, $3, $$);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico: %s\n", s);
}

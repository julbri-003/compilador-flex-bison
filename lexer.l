%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"

extern int argc_global;
extern char **argv_global;
%}

%%

"buen_dia"              { return KW_BUEN_DIA; }
"buenas_noches"         { return KW_BUENAS_NOCHES; }
"leer"                  { return KW_LEER; }
"mostrar"               { return KW_MOSTRAR; }

"cumple"                { return KW_CUMPLE; }
"pasa"                  { return KW_PASA; }
"en_cambio"             { return KW_EN_CAMBIO; }
"punto"                 { return KW_PUNTO; }

">"                     { return MAYOR; }
"<"                     { return MENOR; }
"=="                    { return IGUAL; }
"+"                     { return MAS; }
"-"                     { return GUION; }

:\)[A-Za-z0-9]{1,14}    {
                            if (argc_global > 2) {
                                yylval.str = strdup(argv_global[2]);
                                printf("[LEXER] Sustituyo :)Evento con valor: '%s'\n", argv_global[2]);
                            } else {
                                yylval.str = strdup(yytext);
                                printf("[LEXER] Identificador '%s' sin valor pasado\n", yytext);
                            }
                            return CADENA;
                        }

\"[^\"]*\"              {
                            yylval.str = strdup(yytext);
                            // eliminar comillas
                            size_t len = strlen(yylval.str);
                            if (len >= 2) {
                                memmove(yylval.str, yylval.str + 1, len - 2);
                                yylval.str[len - 2] = '\0';
                            }
                            return CADENA;
                        }

[ \t\r\n]+              ; // Ignorar espacios y saltos de línea
.                       { printf("[LEXER] Carácter inesperado: %s\n", yytext); }

%%

int yywrap(void) { return 1; }

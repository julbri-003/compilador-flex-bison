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


"=="                    { return ASIGNACION; }     
"\$"                    { return COMPARADOR; }   
">"                     { return MAYOR; }
"<"                     { return MENOR; }
"+"                     { return MAS; }
"-"                     { return GUION; }


\:\)[A-Za-z0-9]{1,14}    {
                            if (argc_global > 2) {
                                yylval.str = strdup(argv_global[2]);
                                //printf("Lexer: Sustituyo :)Evento con valor: '%s'\n", argv_global[2]);
                            } else {
                                const char *raw = yytext;
                                const char *name = raw;
                                if (strncmp(raw, ":)", 2) == 0) name = raw + 2;
                                yylval.str = strdup(name);
                                printf("Lexer: Identificador '%s' sin valor pasado\n", name);
                            }
                            return CADENA;
                        }


\"[^\"]*\"              {
                            size_t len = strlen(yytext);
                            if (len >= 2) {
                                yylval.str = malloc(len - 1); /* pongo 1 para el \0 */
                                memcpy(yylval.str, yytext + 1, len - 2);
                                yylval.str[len - 2] = '\0';
                            } else {
                                yylval.str = strdup(""); /* cadena vacía */
                            }
                            return CADENA;
                        }


[ \t\r\n]+              ;


.                       {printf("Error lexico: caracter no reconocido '%s'\n", yytext);
                            exit(1);
                        }

%%

int yywrap(void) { return 1; }

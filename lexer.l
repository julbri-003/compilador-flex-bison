%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"
extern int yylineno;

extern int argc_global;
extern char **argv_global;
%}


%%

"buen_dia"              { return BUEN_DIA; }
"buenas_noches"         { return BUENAS_NOCHES; }
"leer"                  { return LEER; }
"mostrar"               { return MOSTRAR; }

"cumple"                { return CUMPLE; }
"pasa"                  { return PASA; }
"en_cambio"             { return EN_CAMBIO; }
"punto"                 { return PUNTO; }


"=="                    { return ASIGNACION; }     
"\$"                    { return COMPARADOR; }   
">"                     { return MAYOR; }
"<"                     { return MENOR; }
"+"                     { return MAS; }
"-"                     { return GUION; }


\n                      { yylineno++; }

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


[ \t\r]+              ;

.                       {printf("Error lexico: caracter no reconocido '%s'\n", yytext);
                            exit(1);
                        }

%%

int yywrap(void) { return 1; }

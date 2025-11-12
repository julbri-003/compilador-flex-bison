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


"=="                    { return ASIGNACION; }     /* asignación (==) */
"\$"                    { return COMPARADOR; }     /* comparación ($) */
">"                     { return MAYOR; }
"<"                     { return MENOR; }
"+"                     { return MAS; }
"-"                     { return GUION; }


\:\)[A-Za-z0-9]{1,14}    {
                            if (argc_global > 2) {
                                yylval.str = strdup(argv_global[2]);
                                printf("[LEXER] Sustituyo :)Evento con valor: '%s'\n", argv_global[2]);
                            } else {
                                const char *raw = yytext;
                                const char *name = raw;
                                if (strncmp(raw, ":)", 2) == 0) name = raw + 2;
                                yylval.str = strdup(name);
                                printf("[LEXER] Identificador '%s' sin valor pasado\n", name);
                            }
                            return CADENA;
                        }


\"[^\"]*\"              {
                            size_t len = strlen(yytext);
                            if (len >= 2) {
                                yylval.str = malloc(len - 1); /* len-2 chars + '\0' */
                                memcpy(yylval.str, yytext + 1, len - 2);
                                yylval.str[len - 2] = '\0';
                            } else {
                                yylval.str = strdup("");
                            }
                            return CADENA;
                        }


[ \t\r\n]+              ;


.                       { printf("[LEXER] Carácter inesperado: %s\n", yytext); }

%%

int yywrap(void) { return 1; }

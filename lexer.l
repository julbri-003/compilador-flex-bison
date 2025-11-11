%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

buen_dia             { return BUEN_DIA; }
buenas_noches        { return BUENAS_NOCHES; }
leer                 { return LEER; }
mostrar              { return MOSTRAR; }

cumple               { return CUMPLE; }
pasa                 { return PASA; }
en_cambio            { return EN_CAMBIO; }
punto                { return PUNTO; }

"=="                 { return ASIGNAR; }
"+"                  { return SUMAR; }
"$"                  { return PESOS; }
"<"                  { return MENOR; }
">"                  { return MAYOR; }
"-"                  { return FIN; }

":\)[A-Za-z0-9]{1,14}"   { yylval.str = strdup(yytext); return IDENT; }
[0-9]+                   { yylval.num = atoi(yytext); return NUMERO; }
\"[A-Za-z0-9 ]*\"        { yylval.str = strdup(yytext); return STRING; }

[ \t\r\n]+               ;
.                        { printf("Caracter desconocido: %s\n", yytext); }

%%

int yywrap(void) { return 1; }

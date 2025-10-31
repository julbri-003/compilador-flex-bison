%{
#include "parser.tab.h"
#include <string.h>
%}

%%

buen_dia             { return BUEN_DIA; }
buenas_noches        { return BUENAS_NOCHES; }
leer                 { return LEER; }
mostrar              { return MOSTRAR; }
"=="                 { return ASIGNAR; }
"+"                  { return SUMAR; }
"$"                  { return PESOS; }
"<"                  { return MENOR; }
">"                  { return MAYOR; }
"-"                  { return FIN; }

/:\)[A-Za-z0-9]{1,14}/   { yylval.str = strdup(yytext); return IDENT; }
[0-9]+                   { yylval.num = atoi(yytext); return NUMERO; }
\"[A-Za-z0-9 ]*\"        { yylval.str = strdup(yytext); return STRING; }

[ \t\r\n]+               ; // ignorar espacios y saltos de línea
.                        { printf("Caracter desconocido: %s\n", yytext); }

%%

int yywrap() { return 1; }

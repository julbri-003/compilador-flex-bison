#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
extern FILE *yyin;

// Variables globales accesibles por Bison/Flex
int argc_global;
char **argv_global;

int main(int argc, char **argv) {
    argc_global = argc;
    argv_global = argv;

    if (argc < 2) {
        printf("Uso: %s <archivo_programa> [eventos...]\n", argv[0]);
        printf("Ejemplo: %s programa.txt eventoA eventoB\n", argv[0]);
        return 1;
    }

    // Abrimos el archivo fuente del lenguaje
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("No se pudo abrir el archivo fuente");
        return 1;
    }

    // Ejecutamos el parser
    yyparse();

    fclose(yyin);
    return 0;
}

//./mi_lenguaje programa.txt eventoA eventoB eventoC

//flex lexer.l
//bison -d parser.y
//gcc main.c lex.yy.c parser.tab.c -o mi_lenguaje

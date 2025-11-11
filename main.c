#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
extern FILE *yyin;

// Variables globales para pasar parámetros a Flex/Bison
int argc_global;
char **argv_global;

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <archivo_programa> [parametros...]\n", argv[0]);
        return 1;
    }

    argc_global = argc;
    argv_global = argv;

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("No se pudo abrir el archivo fuente");
        return 1;
    }

    printf("Analizando '%s'...\n", argv[1]);
    if (argc > 2) {
        printf("Parámetros recibidos:\n");
        for (int i = 2; i < argc; i++) {
            printf("  :)Evento%d = %s\n", i - 1, argv[i]);
        }
        printf("\n");
    }

    int result = yyparse();

    if (result == 0)
        printf("\n Análisis sintáctico completado correctamente.\n");
    else
        printf("\n Se encontraron errores sintácticos.\n");

    fclose(yyin);
    return 0;
}




//./interprete programa.txt eventoA eventoB eventoC

//bison -d parser.y
//flex lexer.l
//gcc parser.tab.c lex.yy.c main.c -o interprete

//./interprete programa.txt


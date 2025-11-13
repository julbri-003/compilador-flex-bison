#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
extern FILE *yyin;
extern int yylineno;   // declarado por Flex

// Variables globales para pasar parámetros a Flex/Bison
int argc_global;
char **argv_global;

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <archivo_programa> [parametro...]\n", argv[0]);
        return 1;
    }

    // Guardar los parámetros globales para que el lexer/parser puedan usarlos
    argc_global = argc;
    argv_global = argv;

    // Inicializar el número de línea antes de empezar el análisis
    yylineno = 1;

    // Abrir el archivo fuente
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("No se pudo abrir el archivo fuente");
        return 1;
    }

    printf("Analizando y ejecutando '%s'...\n\n", argv[1]);

    // Llamada al parser
    int result = yyparse();

    if (result == 0)
        printf("\nAnalisis sintactico completado correctamente.\n");
    else
        printf("\nSe encontraron errores sintacticos.\n");

    fclose(yyin);
    return 0;
}




//para ejecutar

// win_bison -d parser.y
// win_flex lexer.l
//gcc parser.tab.c lex.yy.c main.c -o interprete

//evento interno
//./interprete programa.txt evento1 

//evento externo
//./interprete programa.txt eventoT

//evento no reconocido
//./interprete programa.txt eventoJ
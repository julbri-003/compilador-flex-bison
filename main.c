#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
extern FILE *yyin;
extern int yylineno;   

int argc_global;
char **argv_global;

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Espero: %s <archivo_programa> <parametro>\n", argv[0]);
        return 1;
    }

    // parámetros globales para que el lexer/parser puedan usarlos
    argc_global = argc;
    argv_global = argv;

    // contador de líneas para el lexer
    yylineno = 1;

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("No se pudo abrir el archivo");
        return 1;
    }

    printf("Ejecutando '%s'\n\n", argv[1]);

    // Llamo al parser
    int result = yyparse();

    if (result == 0)
        printf("\nAnalisis sintactico completado correctamente\n");
    else
        printf("\nSe encontraron errores sintacticos\n");

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
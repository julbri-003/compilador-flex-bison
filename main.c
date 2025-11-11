
#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
extern FILE *yyin;

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <archivo_fuente>\n", argv[0]);
        fprintf(stderr, "Ejemplo: %s programa.txt\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("No se pudo abrir el archivo fuente");
        return 1;
    }

    printf("Analizando el programa '%s'...\n\n", argv[1]);

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


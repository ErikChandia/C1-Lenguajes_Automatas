%{
/* Incluir el archivo de encabezado generado por Bison */
#include "ac_asimetrico.tab.h"
%}

/* Definición de patrones en Flex */
%%
"//".*               ; /* Ignorar comentarios al estilo C++ */
crear_automata       { return CREAR_AUTOMATA; }
crear_celda          { return CREAR_CELDA; }
definir_vecino       { return DEFINIR_VECINO; }
conectar_automatas   { return CONECTAR_AUTOMATAS; }
ajustar_tasas        { return AJUSTAR_TASAS; }
avanzar_paso         { return AVANZAR_PASO; }
[0-9]+               { yylval.entero = atoi(yytext); return NUMERO; }
[0-9]+\.[0-9]+       { yylval.real = atof(yytext); return REAL; }
";"                  { return ';'; }  /* Definir punto y coma */
[ \t\n]+             ;  /* Ignorar espacios, tabs y nuevas líneas */
.                    { printf("Caracter desconocido: %s\n", yytext); }

%%

/* Función principal para Flex */
int yywrap() {
    return 1;
}

/* ac_asimetrico.y */
%{
/* Incluir librerías necesarias */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* Declaración de la función de Flex */
int yylex(void);
void yyerror(const char *s);

/* Declaración de las funciones que se utilizan en las reglas de Bison */
void crear_automata(int id);
void crear_celda(int id, int x, int y, int inicial);
void definir_vecino(int id, int x1, int y1, int x2, int y2);
void conectar_automatas(int id1, int id2, int x1, int y1, int x2, int y2);
void ajustar_tasas(float contagio, float recuperacion);
void avanzar_paso(int pasos, int permitir_transito);
int contar_estado(int estado);  // Declarar la función contar_estado
void guardar_estado(); // Nueva función para guardar el estado

/* Definir estados del modelo SEIR */
#define S 0  // Susceptible
#define E 1  // Expuesto
#define I 2  // Infectado
#define R 3  // Recuperado

/* Definir parámetros globales */
float tasa_contagio = 0.5;
float tasa_recuperacion = 0.3;

/* Definir estructuras de datos */
typedef struct Celda {
    int x, y;  // Coordenadas de la celda
    int estado; // Estado de la celda (S, E, I, R)
    int tiempo_expuesto; // Contador de tiempo expuesto (si aplica)
} Celda;

typedef struct Vecino {
    Celda *celda1;
    Celda *celda2;
} Vecino;

typedef struct Automata {
    int id;
    Celda celdas[100]; // Lista simple de celdas (puedes ajustar el tamaño)
    int celda_count;
    Vecino vecinos[100]; // Lista simple de vecinos (puedes ajustar el tamaño)
    int vecino_count;
} Automata;

/* Variables globales para almacenar autómatas */
Automata automatas[10]; // Lista simple de automatas (puedes ajustar el tamaño)
int automata_count = 0;

/* Tipo de datos para los tokens que usaremos */
%}

%union {
    int entero;
    float real;
}

%token CREAR_AUTOMATA CREAR_CELDA DEFINIR_VECINO CONECTAR_AUTOMATAS AJUSTAR_TASAS AVANZAR_PASO
%token <entero> NUMERO
%token <real> REAL

/* Sección de reglas de Bison */
%%
programa:
    instruccion ';' programa
    | instruccion ';'
    ;

instruccion:
    CREAR_AUTOMATA NUMERO {
        crear_automata($2);
    }
    | CREAR_CELDA NUMERO NUMERO NUMERO NUMERO {
        crear_celda($2, $3, $4, $5);
    }
    | DEFINIR_VECINO NUMERO NUMERO NUMERO NUMERO NUMERO {
        definir_vecino($2, $3, $4, $5, $6);
    }
    | CONECTAR_AUTOMATAS NUMERO NUMERO NUMERO NUMERO NUMERO NUMERO {
        conectar_automatas($2, $3, $4, $5, $6, $7);
    }
    | AJUSTAR_TASAS REAL REAL {
        ajustar_tasas($2, $3);
    }
    | AVANZAR_PASO NUMERO NUMERO {
        avanzar_paso($2, $3);
    }
    ;

%%

/* Función principal */
int main() {
    srand(time(NULL)); // Inicializar la semilla para aleatoriedad
    printf("Iniciando el análisis...\n");
    yyparse();
    guardar_estado(); // Llamar a la función para guardar el estado al final
    return 0;
}

/* Función para manejar errores */
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

/* Implementación de las funciones */

void crear_automata(int id) {
    automatas[automata_count].id = id;
    automatas[automata_count].celda_count = 0;
    automatas[automata_count].vecino_count = 0;
    printf("Creado automata con ID %d\n", id);
    automata_count++;
}

void crear_celda(int id, int x, int y, int inicial) {
    // Buscar el autómata con el ID especificado
    Automata *auto_ptr = NULL;
    for (int i = 0; i < automata_count; i++) {
        if (automatas[i].id == id) {
            auto_ptr = &automatas[i];
            break;
        }
    }
    if (auto_ptr == NULL) {
        printf("Error: Automata no encontrado\n");
        return;
    }

    // Crear una celda y agregarla al autómata
    auto_ptr->celdas[auto_ptr->celda_count].x = x;
    auto_ptr->celdas[auto_ptr->celda_count].y = y;
    auto_ptr->celdas[auto_ptr->celda_count].estado = inicial;
    auto_ptr->celdas[auto_ptr->celda_count].tiempo_expuesto = 0;
    printf("Crear celda en automata %d en (%d, %d) con estado %d\n", id, x, y, inicial);
    auto_ptr->celda_count++;
}

void definir_vecino(int id, int x1, int y1, int x2, int y2) {
    Automata *auto_ptr = NULL;
    for (int i = 0; i < automata_count; i++) {
        if (automatas[i].id == id) {
            auto_ptr = &automatas[i];
            break;
        }
    }
    if (auto_ptr == NULL) {
        printf("Error: Automata no encontrado\n");
        return;
    }

    // Buscar las celdas y definir la conexión como vecinos
    Celda *c1 = NULL, *c2 = NULL;
    for (int i = 0; i < auto_ptr->celda_count; i++) {
        if (auto_ptr->celdas[i].x == x1 && auto_ptr->celdas[i].y == y1) c1 = &auto_ptr->celdas[i];
        if (auto_ptr->celdas[i].x == x2 && auto_ptr->celdas[i].y == y2) c2 = &auto_ptr->celdas[i];
    }
    if (c1 && c2) {
        auto_ptr->vecinos[auto_ptr->vecino_count].celda1 = c1;
        auto_ptr->vecinos[auto_ptr->vecino_count].celda2 = c2;
        auto_ptr->vecino_count++;
        printf("Definir vecino en automata %d entre (%d, %d) y (%d, %d)\n", id, x1, y1, x2, y2);
    } else {
        printf("Error: No se encontraron ambas celdas especificadas para el autómata %d\n", id);
    }
}

void conectar_automatas(int id1, int id2, int x1, int y1, int x2, int y2) {
    Automata *auto1 = NULL, *auto2 = NULL;
    for (int i = 0; i < automata_count; i++) {
        if (automatas[i].id == id1) auto1 = &automatas[i];
        if (automatas[i].id == id2) auto2 = &automatas[i];
    }
    if (!auto1 || !auto2) {
        printf("Error: No se encontraron los autómatas especificados\n");
        return;
    }

    Celda *c1 = NULL, *c2 = NULL;
    for (int i = 0; i < auto1->celda_count; i++) {
        if (auto1->celdas[i].x == x1 && auto1->celdas[i].y == y1) c1 = &auto1->celdas[i];
    }
    for (int i = 0; i < auto2->celda_count; i++) {
        if (auto2->celdas[i].x == x2 && auto2->celdas[i].y == y2) c2 = &auto2->celdas[i];
    }
    if (c1 && c2) {
        printf("Conectar autómatas %d y %d en (%d, %d) y (%d, %d)\n", id1, id2, x1, y1, x2, y2);
        // Agregar la conexión al JSON
        auto1->vecinos[auto1->vecino_count].celda1 = c1;
        auto1->vecinos[auto1->vecino_count].celda2 = c2;
        auto1->vecino_count++;
    } else {
        printf("Error: No se encontraron las celdas especificadas para conectar los autómatas\n");
    }
}

void ajustar_tasas(float contagio, float recuperacion) {
    tasa_contagio = contagio;
    tasa_recuperacion = recuperacion;
    printf("Ajustar tasas: Contagio = %.2f, Recuperación = %.2f\n", tasa_contagio, tasa_recuperacion);
}

void avanzar_paso(int pasos, int permitir_transito) {
    for (int p = 0; p < pasos; p++) {
        // Iterar sobre todos los autómatas y todas sus celdas
        for (int i = 0; i < automata_count; i++) {
            Automata *auto_ptr = &automatas[i];
            for (int j = 0; j < auto_ptr->celda_count; j++) {
                Celda *c = &auto_ptr->celdas[j];

                // Lógica básica de transición SEIR
                if (c->estado == I && rand() / (float)RAND_MAX < tasa_recuperacion) {
                    c->estado = R;
                    printf("Celda en (%d, %d) se vuelve Recuperada\n", c->x, c->y);
                }

                else if (c->estado == E && c->tiempo_expuesto >= 1) {  // Ajustar la condición
                    c->estado = I;
                    printf("Celda en (%d, %d) se vuelve Infectada\n", c->x, c->y);
                } else if (c->estado == E) {
                    c->tiempo_expuesto++;  // Incrementar tiempo expuesto
                }

                // Contagio
                if (c->estado == S) {
                    // Verificar si algún vecino está infectado
                    for (int k = 0; k < auto_ptr->vecino_count; k++) {
                        Vecino *v = &auto_ptr->vecinos[k];
                        if ((v->celda1 == c && v->celda2->estado == I) || (v->celda2 == c && v->celda1->estado == I)) {
                            if (rand() / (float)RAND_MAX < tasa_contagio) {
                                c->estado = E;
                                c->tiempo_expuesto = 1;
                                printf("Celda en (%d, %d) se expone por infección de su vecino\n", c->x, c->y);
                            }
                        }
                    }
                }
            }
        }
        // Mostrar estadísticas después de cada paso
        printf("Estadísticas del paso %d:\n", p + 1);
        printf("Susceptibles: %d\n", contar_estado(S));
        printf("Expuestos: %d\n", contar_estado(E));
        printf("Infectados: %d\n", contar_estado(I));
        printf("Recuperados: %d\n", contar_estado(R));
    }
}

int contar_estado(int estado) {
    int count = 0;
    for (int i = 0; i < automata_count; i++) {
        for (int j = 0; j < automatas[i].celda_count; j++) {
            if (automatas[i].celdas[j].estado == estado) count++;
        }
    }
    return count;
}

void guardar_estado() {
    FILE *file = fopen("estado_automata.json", "w");
    if (!file) {
        printf("Error al abrir el archivo de salida.\n");
        return;
    }

    fprintf(file, "[\n");
    for (int i = 0; i < automata_count; i++) {
        fprintf(file, "{\n\"id\": %d,\n\"celdas\": [\n", automatas[i].id);
        for (int j = 0; j < automatas[i].celda_count; j++) {
            Celda *c = &automatas[i].celdas[j];
            fprintf(file, "{\"x\": %d, \"y\": %d, \"estado\": %d}", c->x, c->y, c->estado);
            if (j < automatas[i].celda_count - 1) fprintf(file, ",");
            fprintf(file, "\n");
        }
        
        // Guardar conexiones (vecinos) del autómata
        fprintf(file, "],\n\"conexiones\": [\n");
        for (int k = 0; k < automatas[i].vecino_count; k++) {
            Vecino *v = &automatas[i].vecinos[k];
            fprintf(file, "{\"inicio\": [%d, %d], \"fin\": [%d, %d]}", 
                    v->celda1->x, v->celda1->y, v->celda2->x, v->celda2->y);
            if (k < automatas[i].vecino_count - 1) fprintf(file, ",");
            fprintf(file, "\n");
        }
        fprintf(file, "]\n}");

        if (i < automata_count - 1) fprintf(file, ",");
        fprintf(file, "\n");
    }
    fprintf(file, "]\n");

    fclose(file);
    printf("Estado guardado en estado_automata.json\n");
}

# README

## Proyecto de Simulación de Autómata Celular Asimétrico

### Descripción

Este proyecto implementa una simulación de un **autómata celular asimétrico** basado en el modelo SEIR. Utiliza **Flex y Bison** para definir la lógica y estructura de un autómata celular que simula la propagación de una infección. Además, el proyecto incluye una visualización en **Python** utilizando **matplotlib** para mostrar los resultados de la simulación.

### Funcionalidades

- **Creación de Autómatas**: Permite crear múltiples autómatas que representan diferentes regiones o grupos.
- **Definición de Celdas**: Cada autómata puede contener varias celdas que representan elementos individuales dentro de la simulación.
- **Definición de Vecinos y Conexiones**: Se pueden definir vecinos y conectar celdas entre diferentes autómatas para crear una estructura más compleja.
- **Ajuste de Parámetros**: La simulación permite ajustar la tasa de contagio y la tasa de recuperación para reflejar diferentes escenarios de propagación.
- **Visualización**: Se genera un gráfico que muestra las diferentes vecindades, celdas y sus conexiones, coloreadas según el estado de cada celda.

### Requisitos

- **Flex**
- **Bison**
- **GCC**
- **Python 3.8+**
- **Librerías de Python**: 
  - `matplotlib`
  - `json`

### Instrucciones de Ejecución

1. **Preparar el Código de Flex y Bison**

   - Navegar al directorio del proyecto donde se encuentran los archivos `.l` y `.y`.
   - Ejecutar los siguientes comandos en la terminal (MSYS2 Mingw64):

     
     flex ac_asimetrico.l
     bison -d ac_asimetrico.y
     gcc -o ac_asimetrico ac_asimetrico.tab.c lex.yy.c
     

2. **Crear el Archivo de Input**

   - Crear un archivo llamado `input.txt` que contenga los comandos para la creación de los autómatas, celdas, vecinos y conexiones, así como los parámetros de la simulación.

3. **Ejecutar la Simulación**

   - Ejecutar el siguiente comando para iniciar la simulación:

     
     ./ac_asimetrico < input.txt
     

   - Esto generará un archivo JSON llamado `estado_automata.json` con los resultados de la simulación.

4. **Visualización**

   - Asegúrese de tener instalado Python y las librerías necesarias (`matplotlib` y `json`).
   - Ejecute el script de visualización con el siguiente comando:

     
     python visualizacion.py
     

   - Esto generará una visualización de los autómatas, mostrando las vecindades y conexiones de las celdas, así como los estados de cada celda (Susceptible, Expuesto, Infectado, Recuperado).

### Estructura del Proyecto

- **ac_asimetrico.l**: Código Flex para el análisis léxico.
- **ac_asimetrico.y**: Código Bison para la lógica y estructura de la simulación.
- **visualizacion.py**: Script en Python para la visualización del estado del autómata celular.
- **input.txt**: Archivo de entrada con los comandos para la simulación.
- **estado_automata.json**: Archivo generado con los resultados de la simulación.

### Autores

- Joaquín Quintanilla
- Erick Chandia


import matplotlib.pyplot as plt
import matplotlib.patches as patches
import json

def visualizar_automata():
    # Cargar el archivo JSON
    with open('estado_automata.json', 'r') as file:
        data = json.load(file)

    fig, ax = plt.subplots()

    # Colores para las diferentes vecindades de autómatas
    region_colors = ['lightblue', 'lightgreen', 'lightcoral', 'lightsalmon', 'lightyellow', 'lightgrey', 'lightpink', 'lightcyan']


    # Colores para los estados de las celdas
    cell_colors = {0: 'blue', 1: 'orange', 2: 'red', 3: 'green'}

    # Dibujar las regiones de los autómatas con cajas de colores
    for i, automata in enumerate(data):
        # Obtener los límites de cada autómata (celdas)
        x_coords = [celda['x'] for celda in automata['celdas']]
        y_coords = [celda['y'] for celda in automata['celdas']]
        
        # Determinar el rectángulo que delimita la región
        min_x, max_x = min(x_coords) - 0.3, max(x_coords) + 0.3
        min_y, max_y = min(y_coords) - 0.3, max(y_coords) + 0.3
        
        # Añadir un rectángulo de fondo para la región
        rect = patches.Rectangle(
            (min_x, min_y), max_x - min_x, max_y - min_y,
            linewidth=1, edgecolor='black', facecolor=region_colors[i], linestyle='--'
        )
        ax.add_patch(rect)

        # Dibujar las celdas y sus estados
        for celda in automata['celdas']:
            x, y = celda['x'], celda['y']
            estado = celda['estado']
            ax.add_patch(patches.Circle((x, y), 0.2, color=cell_colors[estado]))

        # Dibujar las conexiones
        for conexion in automata.get('conexiones', []):
            inicio, fin = conexion['inicio'], conexion['fin']
            ax.annotate(
                "", xy=(fin[0], fin[1]), xytext=(inicio[0], inicio[1]),
                arrowprops=dict(facecolor='black', shrink=0.05, width=1.5, headwidth=5)
            )

    # Configurar la visualización
    ax.set_xlim(-0.5, 10)
    ax.set_ylim(-0.5, 10)
    ax.set_aspect('equal')
    ax.set_title("Visualización Mejorada de Autómatas Celulares Asimétricos")

    # Leyenda para los estados
    estados = ['Susceptible', 'Expuesto', 'Infectado', 'Recuperado']
    colores_estados = ['blue', 'orange', 'red', 'green']
    patches_legend = [patches.Patch(color=colores_estados[i], label=estados[i]) for i in range(4)]
    ax.legend(handles=patches_legend, loc='upper right')

    # Mostrar el gráfico
    plt.show()

visualizar_automata()

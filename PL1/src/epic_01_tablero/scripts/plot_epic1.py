import csv
import os
from pathlib import Path

import matplotlib.pyplot as plt


BASE_DIR = Path(__file__).resolve().parent.parent
RESULTADOS_DIR = BASE_DIR / "resultados"


def leer_csv_dict(ruta):
    with open(ruta, "r", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def plot_barras(x, y, titulo, xlabel, ylabel, salida_png):
    plt.figure(figsize=(10, 5))
    plt.bar(x, y)
    plt.title(titulo)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(salida_png, dpi=150)
    plt.close()


def generar_grafica_tipos():
    ruta = RESULTADOS_DIR / "conteo_tipos.csv"
    filas = leer_csv_dict(ruta)
    tipos = [fila["tipo"] for fila in filas]
    cantidades = [int(fila["cantidad"]) for fila in filas]

    salida = RESULTADOS_DIR / "grafica_tipos.png"
    plot_barras(
        tipos,
        cantidades,
        "Épica 1 - Conteo de casillas por tipo",
        "Tipo de casilla",
        "Cantidad",
        salida,
    )
    print(f"Generada: {salida}")


def generar_grafica_colores():
    ruta = RESULTADOS_DIR / "conteo_colores.csv"
    filas = leer_csv_dict(ruta)
    colores = [fila["color"] for fila in filas]
    cantidades = [int(fila["cantidad"]) for fila in filas]

    salida = RESULTADOS_DIR / "grafica_colores.png"
    plot_barras(
        colores,
        cantidades,
        "Épica 1 - Conteo de propiedades por color",
        "Color",
        "Cantidad",
        salida,
    )
    print(f"Generada: {salida}")


def generar_grafica_resumen():
    ruta = RESULTADOS_DIR / "resumen_tablero.csv"
    filas = leer_csv_dict(ruta)

    metricas = [fila["metrica"] for fila in filas]
    valores = [int(fila["valor"]) for fila in filas]

    salida = RESULTADOS_DIR / "grafica_resumen.png"
    plot_barras(
        metricas,
        valores,
        "Épica 1 - Resumen estructural del tablero",
        "Métrica",
        "Valor",
        salida,
    )
    print(f"Generada: {salida}")


def main():
    os.makedirs(RESULTADOS_DIR, exist_ok=True)
    generar_grafica_tipos()
    generar_grafica_colores()
    generar_grafica_resumen()
    print("Todas las gráficas de la épica 1 se han generado correctamente.")


if __name__ == "__main__":
    main()

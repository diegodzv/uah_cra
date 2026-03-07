import csv
import os
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt


BASE_DIR = Path(__file__).resolve().parent.parent
RESULTADOS_DIR = BASE_DIR / "resultados"


def leer_csv_dict(ruta):
    with open(ruta, "r", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def plot_barras(x, y, titulo, xlabel, ylabel, salida_png, rotacion=45):
    plt.figure(figsize=(12, 6))
    plt.bar(x, y)
    plt.title(titulo)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.xticks(rotation=rotacion, ha="right")
    plt.tight_layout()
    plt.savefig(salida_png, dpi=150)
    plt.close()


def plot_lineas(series, titulo, xlabel, ylabel, salida_png):
    plt.figure(figsize=(12, 6))
    hay_series = False
    for nombre, pares in series.items():
        xs = [x for x, _ in pares]
        ys = [y for _, y in pares]
        if xs and ys:
            plt.plot(xs, ys, label=nombre)
            hay_series = True
    plt.title(titulo)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    if hay_series:
        plt.legend()
    plt.tight_layout()
    plt.savefig(salida_png, dpi=150)
    plt.close()


def generar_grafica_compras_por_turno(nombre):
    ruta = RESULTADOS_DIR / f"{nombre}_compras_por_turno.csv"
    if not ruta.exists():
        return
    filas = leer_csv_dict(ruta)
    turnos = [int(f["turno"]) for f in filas]
    compras = [int(f["compras_en_turno"]) for f in filas]
    salida = RESULTADOS_DIR / f"{nombre}_grafica_compras_por_turno.png"
    plot_barras(turnos, compras, f"{nombre} - Compras por turno", "Turno", "Compras", salida, rotacion=0)


def generar_grafica_compras_acumuladas(nombre):
    ruta = RESULTADOS_DIR / f"{nombre}_compras_acumuladas.csv"
    if not ruta.exists():
        return
    filas = leer_csv_dict(ruta)
    turnos = [int(f["turno"]) for f in filas]
    compras = [int(f["compras_acumuladas"]) for f in filas]
    salida = RESULTADOS_DIR / f"{nombre}_grafica_compras_acumuladas.png"
    plot_lineas({"compras_acumuladas": list(zip(turnos, compras))},
                f"{nombre} - Compras acumuladas", "Turno", "Compras acumuladas", salida)


def generar_grafica_dinero_por_turno(nombre):
    ruta = RESULTADOS_DIR / f"{nombre}_dinero_por_turno.csv"
    if not ruta.exists():
        return
    filas = leer_csv_dict(ruta)
    series = defaultdict(list)
    for fila in filas:
        series[fila["jugador"]].append((int(fila["turno"]), float(fila["dinero_despues"])))
    salida = RESULTADOS_DIR / f"{nombre}_grafica_dinero_por_turno.png"
    plot_lineas(series, f"{nombre} - Dinero por turno", "Turno", "Dinero", salida)


def generar_grafica_propiedades_por_turno(nombre):
    ruta = RESULTADOS_DIR / f"{nombre}_propiedades_por_turno.csv"
    if not ruta.exists():
        return
    filas = leer_csv_dict(ruta)
    series = defaultdict(list)
    for fila in filas:
        series[fila["jugador"]].append((int(fila["turno"]), int(fila["propiedades_despues"])))
    salida = RESULTADOS_DIR / f"{nombre}_grafica_propiedades_por_turno.png"
    plot_lineas(series, f"{nombre} - Propiedades acumuladas por jugador", "Turno", "Propiedades", salida)


def generar_grafica_propiedades_finales(nombre):
    ruta = RESULTADOS_DIR / f"{nombre}_propiedades_finales.csv"
    if not ruta.exists():
        return
    filas = leer_csv_dict(ruta)
    jugadores = [f["jugador"] for f in filas]
    props = [int(f["propiedades_finales"]) for f in filas]
    salida = RESULTADOS_DIR / f"{nombre}_grafica_propiedades_finales.png"
    plot_barras(jugadores, props, f"{nombre} - Propiedades finales por jugador", "Jugador", "Propiedades finales", salida)


def generar_grafica_dinero_final(nombre):
    ruta = RESULTADOS_DIR / f"{nombre}_propiedades_finales.csv"
    if not ruta.exists():
        return
    filas = leer_csv_dict(ruta)
    jugadores = [f["jugador"] for f in filas]
    dinero = [float(f["dinero_final"]) for f in filas]
    salida = RESULTADOS_DIR / f"{nombre}_grafica_dinero_final.png"
    plot_barras(jugadores, dinero, f"{nombre} - Dinero final por jugador", "Jugador", "Dinero final", salida)


def escenarios_detectados():
    escenarios = set()
    for fichero in RESULTADOS_DIR.glob("*_resumen.csv"):
        escenarios.add(fichero.name.replace("_resumen.csv", ""))
    return sorted(escenarios)


def main():
    os.makedirs(RESULTADOS_DIR, exist_ok=True)
    escenarios = escenarios_detectados()

    if not escenarios:
        print("No se han encontrado CSV. Ejecuta export_all_csv en Prolog primero.")
        return

    for nombre in escenarios:
        generar_grafica_compras_por_turno(nombre)
        generar_grafica_compras_acumuladas(nombre)
        generar_grafica_dinero_por_turno(nombre)
        generar_grafica_propiedades_por_turno(nombre)
        generar_grafica_propiedades_finales(nombre)
        generar_grafica_dinero_final(nombre)
        print(f"Graficas generadas para: {nombre}")

    print("Todas las graficas de la epica 3 se han generado correctamente.")


if __name__ == "__main__":
    main()

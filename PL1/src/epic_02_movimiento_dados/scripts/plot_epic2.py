import csv
import os
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


def generar_grafica_visitas_globales(nombre_escenario):
    ruta = RESULTADOS_DIR / f"{nombre_escenario}_visitas_globales.csv"
    if not ruta.exists():
        return

    filas = leer_csv_dict(ruta)
    posiciones = [fila["posicion"] for fila in filas]
    visitas = [int(fila["visitas"]) for fila in filas]

    salida = RESULTADOS_DIR / f"{nombre_escenario}_grafica_visitas_globales.png"
    plot_barras(
        posiciones,
        visitas,
        f"{nombre_escenario} - Frecuencia global de visita por casilla",
        "Posición del tablero",
        "Número de visitas",
        salida,
        rotacion=0,
    )
    print(f"Generada: {salida}")


def generar_grafica_sumas_dados(nombre_escenario):
    ruta = RESULTADOS_DIR / f"{nombre_escenario}_sumas_dados.csv"
    if not ruta.exists():
        return

    filas = leer_csv_dict(ruta)
    sumas = [fila["suma"] for fila in filas]
    frecuencias = [int(fila["frecuencia"]) for fila in filas]

    salida = RESULTADOS_DIR / f"{nombre_escenario}_grafica_sumas_dados.png"
    plot_barras(
        sumas,
        frecuencias,
        f"{nombre_escenario} - Frecuencia de sumas de dados",
        "Suma de los dos dados",
        "Frecuencia",
        salida,
        rotacion=0,
    )
    print(f"Generada: {salida}")


def generar_grafica_pasos_salida(nombre_escenario):
    ruta = RESULTADOS_DIR / f"{nombre_escenario}_pasos_salida.csv"
    if not ruta.exists():
        return

    filas = leer_csv_dict(ruta)
    jugadores = [fila["jugador"] for fila in filas]
    pasos = [int(fila["pasos_salida"]) for fila in filas]

    salida = RESULTADOS_DIR / f"{nombre_escenario}_grafica_pasos_salida.png"
    plot_barras(
        jugadores,
        pasos,
        f"{nombre_escenario} - Pasos por salida por jugador",
        "Jugador",
        "Pasos por salida",
        salida,
    )
    print(f"Generada: {salida}")


def generar_grafica_resumen(nombre_escenario):
    ruta = RESULTADOS_DIR / f"{nombre_escenario}_resumen.csv"
    if not ruta.exists():
        return

    filas = leer_csv_dict(ruta)
    metricas = [fila["metrica"] for fila in filas]
    valores = [float(fila["valor"]) for fila in filas]

    salida = RESULTADOS_DIR / f"{nombre_escenario}_grafica_resumen.png"
    plot_barras(
        metricas,
        valores,
        f"{nombre_escenario} - Resumen de simulación",
        "Métrica",
        "Valor",
        salida,
    )
    print(f"Generada: {salida}")


def generar_grafica_visitas_por_jugador(nombre_escenario):
    ruta = RESULTADOS_DIR / f"{nombre_escenario}_visitas_por_jugador.csv"
    if not ruta.exists():
        return

    filas = leer_csv_dict(ruta)
    jugadores = sorted(set(fila["jugador"] for fila in filas))

    for jugador in jugadores:
        filas_jugador = [fila for fila in filas if fila["jugador"] == jugador]
        posiciones = [fila["posicion"] for fila in filas_jugador]
        visitas = [int(fila["visitas"]) for fila in filas_jugador]

        salida = RESULTADOS_DIR / f"{nombre_escenario}_grafica_visitas_{jugador}.png"
        plot_barras(
            posiciones,
            visitas,
            f"{nombre_escenario} - Visitas por casilla de {jugador}",
            "Posición del tablero",
            "Número de visitas",
            salida,
            rotacion=0,
        )
        print(f"Generada: {salida}")


def escenarios_detectados():
    escenarios = set()
    for fichero in RESULTADOS_DIR.glob("*_resumen.csv"):
        nombre = fichero.name.replace("_resumen.csv", "")
        escenarios.add(nombre)
    return sorted(escenarios)


def main():
    os.makedirs(RESULTADOS_DIR, exist_ok=True)
    escenarios = escenarios_detectados()

    if not escenarios:
        print("No se han encontrado CSV de escenarios en la carpeta resultados/.")
        print("Primero ejecuta en Prolog: export_all_csv.")
        return

    for escenario in escenarios:
        generar_grafica_visitas_globales(escenario)
        generar_grafica_sumas_dados(escenario)
        generar_grafica_pasos_salida(escenario)
        generar_grafica_resumen(escenario)
        generar_grafica_visitas_por_jugador(escenario)

    print("Todas las gráficas de la épica 2 se han generado correctamente.")


if __name__ == "__main__":
    main()

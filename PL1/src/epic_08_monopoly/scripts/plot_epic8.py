from pathlib import Path
import csv
import matplotlib.pyplot as plt

BASE_DIR = Path(__file__).resolve().parent.parent
RESULTADOS = BASE_DIR / "resultados"

def leer_csv(ruta):
    with open(ruta, "r", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def graficar_resumen(prefijo, resumen_rows):
    metricas = [r["metrica"] for r in resumen_rows]
    valores = []
    for r in resumen_rows:
        try:
            valores.append(float(r["valor"]))
        except ValueError:
            valores.append(0.0)

    plt.figure(figsize=(14, 6))
    plt.bar(metricas, valores)
    plt.xticks(rotation=45, ha="right")
    plt.title(f"Resumen métricas - {prefijo}")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_resumen.png")
    plt.close()

def graficar_monopoly(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    casas = [int(r["casas_compradas"]) for r in rows]
    costes = [int(r["coste_total"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, casas, marker="o")
    plt.title(f"Casas compradas por evento Monopoly - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Casas compradas")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_monopoly_casas.png")
    plt.close()

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, costes, marker="o")
    plt.title(f"Coste de casas por evento Monopoly - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Coste total")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_monopoly_coste.png")
    plt.close()

def graficar_parking(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    premios = [int(r["premio"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, premios, marker="o")
    plt.title(f"Cobros de parking - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Premio")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_parking.png")
    plt.close()

def graficar_alquileres(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    pagos = [int(r["pago_real"]) for r in rows]
    casas = [int(r["num_casas"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, pagos, marker="o")
    plt.title(f"Pagos de alquiler - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Pago real")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_alquileres.png")
    plt.close()

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, casas, marker="o")
    plt.title(f"Casas en propiedades alquiladas - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Número de casas")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_alquileres_casas.png")
    plt.close()

def main():
    resumen_files = sorted(RESULTADOS.glob("*_resumen.csv"))
    if not resumen_files:
        print("No se han encontrado CSV. Ejecuta export_all_csv en Prolog primero.")
        return

    for resumen_file in resumen_files:
        prefijo = resumen_file.name.replace("_resumen.csv", "")
        resumen_rows = leer_csv(resumen_file)
        graficar_resumen(prefijo, resumen_rows)

        monopoly_file = RESULTADOS / f"{prefijo}_orden_monopoly.csv"
        if monopoly_file.exists():
            graficar_monopoly(prefijo, leer_csv(monopoly_file))

        parking_file = RESULTADOS / f"{prefijo}_orden_parking.csv"
        if parking_file.exists():
            graficar_parking(prefijo, leer_csv(parking_file))

        alquileres_file = RESULTADOS / f"{prefijo}_orden_alquileres.csv"
        if alquileres_file.exists():
            graficar_alquileres(prefijo, leer_csv(alquileres_file))

        print(f"Graficas generadas para: {prefijo}")

    print("Todas las graficas de la epica 8 se han generado correctamente.")

if __name__ == "__main__":
    main()

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

    plt.figure(figsize=(13, 6))
    plt.bar(metricas, valores)
    plt.xticks(rotation=45, ha="right")
    plt.title(f"Resumen métricas - {prefijo}")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_resumen.png")
    plt.close()


def graficar_impuestos_y_caja(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    importes = [float(r["importe"]) for r in rows]
    caja_despues = [float(r["caja_despues"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, importes, marker="o")
    plt.title(f"Importes de impuestos - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Importe")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_impuestos.png")
    plt.close()

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, caja_despues, marker="o")
    plt.title(f"Evolución de caja parking tras impuestos - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Caja parking")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_caja_parking_impuestos.png")
    plt.close()


def graficar_premios_parking(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    premios = [float(r["premio"]) for r in rows]
    caja_despues = [float(r["caja_despues"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.bar(turnos, premios)
    plt.title(f"Premios cobrados en parking - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Premio")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_premios_parking.png")
    plt.close()

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, caja_despues, marker="o")
    plt.title(f"Caja parking tras cobros - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Caja parking")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_caja_parking_cobros.png")
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

        impuestos_file = RESULTADOS / f"{prefijo}_orden_impuestos.csv"
        if impuestos_file.exists():
            graficar_impuestos_y_caja(prefijo, leer_csv(impuestos_file))

        parking_file = RESULTADOS / f"{prefijo}_orden_parking.csv"
        if parking_file.exists():
            graficar_premios_parking(prefijo, leer_csv(parking_file))

        print(f"Graficas generadas para: {prefijo}")

    print("Todas las graficas de la epica 7 se han generado correctamente.")


if __name__ == "__main__":
    main()

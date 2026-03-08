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

    plt.figure(figsize=(12, 6))
    plt.bar(metricas, valores)
    plt.xticks(rotation=45, ha="right")
    plt.title(f"Resumen métricas - {prefijo}")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_resumen.png")
    plt.close()


def graficar_impuestos(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    importes = [float(r["importe"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, importes, marker="o")
    plt.title(f"Importes de impuestos por turno - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Importe")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_impuestos.png")
    plt.close()


def graficar_carcel(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    perdidos = [1 if r["turno_perdido_carcel"] == "si" else 0 for r in rows]

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, perdidos, marker="o")
    plt.title(f"Turnos perdidos por cárcel - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Perdido por cárcel (0/1)")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_turnos_perdidos_carcel.png")
    plt.close()


def graficar_bancarrotas(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    valores_liquidacion = [float(r["valor_liquidacion"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.bar(turnos, valores_liquidacion)
    plt.title(f"Valor de liquidación en bancarrotas - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Valor liquidación")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_bancarrotas.png")
    plt.close()


def graficar_alquileres(prefijo, rows):
    if not rows:
        return

    turnos = [int(r["turno"]) for r in rows]
    pagos = [float(r["pago_real"]) for r in rows]

    plt.figure(figsize=(12, 5))
    plt.plot(turnos, pagos, marker="o")
    plt.title(f"Pagos de alquiler por turno - {prefijo}")
    plt.xlabel("Turno")
    plt.ylabel("Pago real")
    plt.tight_layout()
    plt.savefig(RESULTADOS / f"{prefijo}_grafica_alquileres.png")
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
            graficar_impuestos(prefijo, leer_csv(impuestos_file))

        carcel_file = RESULTADOS / f"{prefijo}_orden_carcel.csv"
        if carcel_file.exists():
            graficar_carcel(prefijo, leer_csv(carcel_file))

        bancarrota_file = RESULTADOS / f"{prefijo}_orden_bancarrotas.csv"
        if bancarrota_file.exists():
            graficar_bancarrotas(prefijo, leer_csv(bancarrota_file))

        alquileres_file = RESULTADOS / f"{prefijo}_orden_alquileres.csv"
        if alquileres_file.exists():
            graficar_alquileres(prefijo, leer_csv(alquileres_file))

        print(f"Graficas generadas para: {prefijo}")

    print("Todas las graficas de la epica 6 se han generado correctamente.")


if __name__ == "__main__":
    main()

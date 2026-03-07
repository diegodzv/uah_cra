% =========================
% metricas.pl
% Epica 4: metricas de compras y alquileres
% =========================

:- module(metricas, [
    resumen_simulacion/3,
    imprimir_resumen_simulacion/1,
    exportar_eventos_csv/2,
    exportar_compras_por_turno_csv/2,
    exportar_compras_acumuladas_csv/2,
    exportar_alquileres_por_turno_csv/2,
    exportar_alquileres_acumulados_csv/2,
    exportar_dinero_por_turno_csv/2,
    exportar_propiedades_por_turno_csv/2,
    exportar_propiedades_finales_csv/2,
    exportar_resumen_csv/2,
    exportar_orden_compras_csv/2,
    exportar_orden_alquileres_csv/2,
    exportar_balance_alquileres_por_jugador_csv/2
]).

resumen_simulacion(PartidaFinal, Eventos, resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores(TotalJugadores),
    total_compras(TotalCompras),
    total_alquileres(TotalAlquileres),
    importe_total_alquileres(ImporteTotalAlquileres),
    total_activos_restantes_banco(ActivosBanco),
    turno_agotamiento_banco(TurnoAgotamientoBanco),
    dinero_final_jugadores(DineroFinales),
    propiedades_finales_jugadores(PropsFinales)
)) :-
    length(Eventos, TotalTurnos),
    PartidaFinal = partida(_, banco(_, Activos, _, _), Jugadores, _, _, _, _, _),
    length(Jugadores, TotalJugadores),
    contar_compras(Eventos, TotalCompras),
    contar_alquileres(Eventos, TotalAlquileres),
    sumar_importe_alquileres(Eventos, ImporteTotalAlquileres),
    length(Activos, ActivosBanco),
    turno_agotamiento_banco(Eventos, TurnoAgotamientoBanco),
    dinero_finales(Jugadores, DineroFinales),
    props_finales(Jugadores, PropsFinales).

imprimir_resumen_simulacion(resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores(TotalJugadores),
    total_compras(TotalCompras),
    total_alquileres(TotalAlquileres),
    importe_total_alquileres(ImporteTotalAlquileres),
    total_activos_restantes_banco(ActivosBanco),
    turno_agotamiento_banco(TurnoAgotamientoBanco),
    dinero_final_jugadores(DineroFinales),
    propiedades_finales_jugadores(PropsFinales)
)) :-
    write('Total de turnos: '), write(TotalTurnos), nl,
    write('Total de jugadores: '), write(TotalJugadores), nl,
    write('Total de compras realizadas: '), write(TotalCompras), nl,
    write('Total de alquileres ejecutados: '), write(TotalAlquileres), nl,
    write('Importe total transferido por alquileres: '), write(ImporteTotalAlquileres), nl,
    write('Activos restantes en el banco: '), write(ActivosBanco), nl,
    write('Turno de agotamiento del banco: '), write(TurnoAgotamientoBanco), nl,
    write('Dinero final por jugador: '), write(DineroFinales), nl,
    write('Propiedades finales por jugador: '), write(PropsFinales), nl.

contar_compras(Eventos, TotalCompras) :-
    include(es_compra, Eventos, Compras),
    length(Compras, TotalCompras).

es_compra(evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, si, _, _, _, _, _, _, _, _, _)).

contar_alquileres(Eventos, TotalAlquileres) :-
    include(es_alquiler, Eventos, Alqs),
    length(Alqs, TotalAlquileres).

es_alquiler(evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, si, _, _, _, _, _, _, _)).

sumar_importe_alquileres(Eventos, Total) :-
    sumar_importe_alquileres_aux(Eventos, 0, Total).

sumar_importe_alquileres_aux([], Acc, Acc).
sumar_importe_alquileres_aux(
    [evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, AlquilerRealizado, _, _, PagoReal, _, _, _, _)|R],
    Acc,
    Total
) :-
    ( AlquilerRealizado = si -> Acc2 is Acc + PagoReal ; Acc2 = Acc ),
    sumar_importe_alquileres_aux(R, Acc2, Total).

turno_agotamiento_banco(Eventos, Turno) :-
    compras_acumuladas_por_turno(Eventos, Pares),
    member(turno_compra(Turno, 26), Pares), !.
turno_agotamiento_banco(_, no_agotado).

compras_acumuladas_por_turno(Eventos, Pares) :-
    compras_por_turno_lista(Eventos, 0, Pares).

compras_por_turno_lista([], _, []).
compras_por_turno_lista(
    [evento_turno(Turno, _, _, _, _, _, _, _, _, _, _, _, _, Compra, _, _, _, _, _, _, _, _, _)|R],
    Acum,
    [turno_compra(Turno, Acum2)|RP]
) :-
    ( Compra = si -> Acum2 is Acum + 1 ; Acum2 = Acum ),
    compras_por_turno_lista(R, Acum2, RP).

dinero_finales([], []).
dinero_finales([jugador(N, _, D, _, _)|R], [dinero_final(N, D)|R2]) :-
    dinero_finales(R, R2).

props_finales([], []).
props_finales([jugador(N, _, _, Props, _)|R], [propiedades_finales(N, Num)|R2]) :-
    length(Props, Num),
    props_finales(R, R2).

exportar_eventos_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,indice_jugador,jugador,dado1,dado2,suma,posicion_anterior,posicion_nueva,paso_salida,nombre_casilla,tipo_casilla,precio_casilla,color_casilla,compra_realizada,alquiler_realizado,alquiler_teorico,pago_real,dinero_inicial_turno,dinero_final_turno,propiedades_antes,propiedades_despues\n'),
            exportar_eventos_csv_aux(Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_eventos_csv_aux([], _).
exportar_eventos_csv_aux(
    [evento_turno(Turno, IndiceJugador, Jugador, D1, D2, Suma, PosAnterior, PosNueva, PasoSalida, NombreCasilla, TipoCasilla, PrecioCasilla, ColorCasilla, CompraRealizada, _EventoCompra, AlquilerRealizado, _EventoAlquiler, AlquilerTeorico, PagoReal, DineroInicialTurno, DineroFinalTurno, PropsAntes, PropsDespues)|R],
    Stream
) :-
    format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
        [Turno, IndiceJugador, Jugador, D1, D2, Suma, PosAnterior, PosNueva, PasoSalida, NombreCasilla, TipoCasilla, PrecioCasilla, ColorCasilla, CompraRealizada, AlquilerRealizado, AlquilerTeorico, PagoReal, DineroInicialTurno, DineroFinalTurno, PropsAntes, PropsDespues]),
    exportar_eventos_csv_aux(R, Stream).

exportar_compras_por_turno_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,compras_en_turno\n'),
            exportar_compras_por_turno_aux(1, Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_compras_por_turno_aux(Turno, Eventos, _) :-
    length(Eventos, N),
    Turno > N, !.
exportar_compras_por_turno_aux(Turno, Eventos, Stream) :-
    contar_compras_turno(Eventos, Turno, C),
    format(Stream, '~w,~w\n', [Turno, C]),
    Turno2 is Turno + 1,
    exportar_compras_por_turno_aux(Turno2, Eventos, Stream).

contar_compras_turno(Eventos, Turno, Total) :-
    include(es_compra_turno(Turno), Eventos, L),
    length(L, Total).

es_compra_turno(Turno, evento_turno(Turno, _, _, _, _, _, _, _, _, _, _, _, _, si, _, _, _, _, _, _, _, _, _)).

exportar_compras_acumuladas_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,compras_acumuladas\n'),
            exportar_compras_acumuladas_aux(1, Eventos, 0, Stream)
        ),
        close(Stream)
    ).

exportar_compras_acumuladas_aux(Turno, Eventos, _, _) :-
    length(Eventos, N),
    Turno > N, !.
exportar_compras_acumuladas_aux(Turno, Eventos, Acum, Stream) :-
    contar_compras_turno(Eventos, Turno, C),
    Acum2 is Acum + C,
    format(Stream, '~w,~w\n', [Turno, Acum2]),
    Turno2 is Turno + 1,
    exportar_compras_acumuladas_aux(Turno2, Eventos, Acum2, Stream).

exportar_alquileres_por_turno_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,alquileres_en_turno,importe_en_turno\n'),
            exportar_alquileres_por_turno_aux(1, Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_alquileres_por_turno_aux(Turno, Eventos, _) :-
    length(Eventos, N),
    Turno > N, !.
exportar_alquileres_por_turno_aux(Turno, Eventos, Stream) :-
    contar_alquileres_turno(Eventos, Turno, Cantidad, Importe),
    format(Stream, '~w,~w,~w\n', [Turno, Cantidad, Importe]),
    Turno2 is Turno + 1,
    exportar_alquileres_por_turno_aux(Turno2, Eventos, Stream).

contar_alquileres_turno(Eventos, Turno, Cantidad, Importe) :-
    include(es_alquiler_turno(Turno), Eventos, L),
    length(L, Cantidad),
    sumar_pago_real_lista(L, 0, Importe).

es_alquiler_turno(Turno, evento_turno(Turno, _, _, _, _, _, _, _, _, _, _, _, _, _, _, si, _, _, _, _, _, _, _)).

sumar_pago_real_lista([], Acc, Acc).
sumar_pago_real_lista([evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, PagoReal, _, _, _, _)|R], Acc, Total) :-
    Acc2 is Acc + PagoReal,
    sumar_pago_real_lista(R, Acc2, Total).

exportar_alquileres_acumulados_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,alquileres_acumulados,importe_acumulado\n'),
            exportar_alquileres_acumulados_aux(1, Eventos, 0, 0, Stream)
        ),
        close(Stream)
    ).

exportar_alquileres_acumulados_aux(Turno, Eventos, _, _, _) :-
    length(Eventos, N),
    Turno > N, !.
exportar_alquileres_acumulados_aux(Turno, Eventos, AcumCantidad, AcumImporte, Stream) :-
    contar_alquileres_turno(Eventos, Turno, CantidadTurno, ImporteTurno),
    AcumCantidad2 is AcumCantidad + CantidadTurno,
    AcumImporte2 is AcumImporte + ImporteTurno,
    format(Stream, '~w,~w,~w\n', [Turno, AcumCantidad2, AcumImporte2]),
    Turno2 is Turno + 1,
    exportar_alquileres_acumulados_aux(Turno2, Eventos, AcumCantidad2, AcumImporte2, Stream).

exportar_dinero_por_turno_csv(Ruta, Eventos) :-
    jugadores_distintos(Eventos, Jugadores),
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,jugador,dinero_final_turno\n'),
            exportar_dinero_por_turno_jugadores(Jugadores, Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_dinero_por_turno_jugadores([], _, _).
exportar_dinero_por_turno_jugadores([J|R], Eventos, Stream) :-
    exportar_dinero_por_turno_jugador(J, Eventos, Stream),
    exportar_dinero_por_turno_jugadores(R, Eventos, Stream).

exportar_dinero_por_turno_jugador(Jugador, Eventos, Stream) :-
    exportar_dinero_por_turno_jugador_aux(Eventos, Jugador, Stream).

exportar_dinero_por_turno_jugador_aux([], _, _).
exportar_dinero_por_turno_jugador_aux(
    [evento_turno(Turno, _, Jugador, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, DineroFinalTurno, _, _)|R],
    Jugador,
    Stream
) :-
    format(Stream, '~w,~w,~w\n', [Turno, Jugador, DineroFinalTurno]),
    exportar_dinero_por_turno_jugador_aux(R, Jugador, Stream).
exportar_dinero_por_turno_jugador_aux([_|R], Jugador, Stream) :-
    exportar_dinero_por_turno_jugador_aux(R, Jugador, Stream).

exportar_propiedades_por_turno_csv(Ruta, Eventos) :-
    jugadores_distintos(Eventos, Jugadores),
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,jugador,propiedades_despues\n'),
            exportar_propiedades_por_turno_jugadores(Jugadores, Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_propiedades_por_turno_jugadores([], _, _).
exportar_propiedades_por_turno_jugadores([J|R], Eventos, Stream) :-
    exportar_propiedades_por_turno_jugador(J, Eventos, Stream),
    exportar_propiedades_por_turno_jugadores(R, Eventos, Stream).

exportar_propiedades_por_turno_jugador(Jugador, Eventos, Stream) :-
    exportar_propiedades_por_turno_jugador_aux(Eventos, Jugador, Stream).

exportar_propiedades_por_turno_jugador_aux([], _, _).
exportar_propiedades_por_turno_jugador_aux(
    [evento_turno(Turno, _, Jugador, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, PropsDespues)|R],
    Jugador,
    Stream
) :-
    format(Stream, '~w,~w,~w\n', [Turno, Jugador, PropsDespues]),
    exportar_propiedades_por_turno_jugador_aux(R, Jugador, Stream).
exportar_propiedades_por_turno_jugador_aux([_|R], Jugador, Stream) :-
    exportar_propiedades_por_turno_jugador_aux(R, Jugador, Stream).

exportar_propiedades_finales_csv(Ruta, PartidaFinal) :-
    PartidaFinal = partida(_, _, Jugadores, _, _, _, _, _),
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'jugador,propiedades_finales,dinero_final\n'),
            exportar_propiedades_finales_aux(Jugadores, Stream)
        ),
        close(Stream)
    ).

exportar_propiedades_finales_aux([], _).
exportar_propiedades_finales_aux([jugador(N, _, D, Props, _)|R], Stream) :-
    length(Props, Num),
    format(Stream, '~w,~w,~w\n', [N, Num, D]),
    exportar_propiedades_finales_aux(R, Stream).

exportar_resumen_csv(Ruta, Resumen) :-
    Resumen = resumen_simulacion(
        total_turnos(TotalTurnos),
        total_jugadores(TotalJugadores),
        total_compras(TotalCompras),
        total_alquileres(TotalAlquileres),
        importe_total_alquileres(ImporteTotalAlquileres),
        total_activos_restantes_banco(ActivosBanco),
        turno_agotamiento_banco(TurnoAgotamientoBanco),
        _,
        _
    ),
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'metrica,valor\n'),
            format(Stream, 'total_turnos,~w\n', [TotalTurnos]),
            format(Stream, 'total_jugadores,~w\n', [TotalJugadores]),
            format(Stream, 'total_compras,~w\n', [TotalCompras]),
            format(Stream, 'total_alquileres,~w\n', [TotalAlquileres]),
            format(Stream, 'importe_total_alquileres,~w\n', [ImporteTotalAlquileres]),
            format(Stream, 'activos_restantes_banco,~w\n', [ActivosBanco]),
            format(Stream, 'turno_agotamiento_banco,~w\n', [TurnoAgotamientoBanco])
        ),
        close(Stream)
    ).

exportar_orden_compras_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,jugador,propiedad,tipo,color,precio\n'),
            exportar_orden_compras_aux(Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_orden_compras_aux([], _).
exportar_orden_compras_aux([evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, no, _, _, _, _, _, _, _, _, _)|R], Stream) :-
    exportar_orden_compras_aux(R, Stream).
exportar_orden_compras_aux(
    [evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, si,
        evento_compra(Turno, Jugador, _, Nombre, Tipo, Color, Precio, _, _),
        _, _, _, _, _, _, _, _)|R],
    Stream
) :-
    format(Stream, '~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, Nombre, Tipo, Color, Precio]),
    exportar_orden_compras_aux(R, Stream).

exportar_orden_alquileres_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,pagador,cobrador,propiedad,tipo,color,precio_casilla,alquiler_teorico,pago_real,dinero_pagador_antes,dinero_pagador_despues,dinero_cobrador_antes,dinero_cobrador_despues\n'),
            exportar_orden_alquileres_aux(Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_orden_alquileres_aux([], _).
exportar_orden_alquileres_aux([evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, no, _, _, _, _, _, _, _)|R], Stream) :-
    exportar_orden_alquileres_aux(R, Stream).
exportar_orden_alquileres_aux(
    [evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, si,
        evento_alquiler(Turno, Pagador, Cobrador, NombreCasilla, TipoCasilla, ColorCasilla, PrecioCasilla, AlquilerTeorico, PagoReal, DineroPagadorAntes, DineroPagadorDespues, DineroCobradorAntes, DineroCobradorDespues),
        _, _, _, _, _, _)|R],
    Stream
) :-
    format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
        [Turno, Pagador, Cobrador, NombreCasilla, TipoCasilla, ColorCasilla, PrecioCasilla, AlquilerTeorico, PagoReal, DineroPagadorAntes, DineroPagadorDespues, DineroCobradorAntes, DineroCobradorDespues]),
    exportar_orden_alquileres_aux(R, Stream).

exportar_balance_alquileres_por_jugador_csv(Ruta, Eventos) :-
    jugadores_distintos(Eventos, Jugadores),
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'jugador,total_pagado_alquiler,total_cobrado_alquiler,balance_alquiler\n'),
            exportar_balance_alquileres_aux(Jugadores, Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_balance_alquileres_aux([], _, _).
exportar_balance_alquileres_aux([J|R], Eventos, Stream) :-
    total_pagado_por_jugador(Eventos, J, Pagado),
    total_cobrado_por_jugador(Eventos, J, Cobrado),
    Balance is Cobrado - Pagado,
    format(Stream, '~w,~w,~w,~w\n', [J, Pagado, Cobrado, Balance]),
    exportar_balance_alquileres_aux(R, Eventos, Stream).

total_pagado_por_jugador([], _, 0).
total_pagado_por_jugador(
    [evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, si,
        evento_alquiler(_, Jugador, _, _, _, _, _, _, PagoReal, _, _, _, _),
        _, _, _, _, _, _)|R],
    Jugador,
    Total
) :-
    total_pagado_por_jugador(R, Jugador, Resto),
    Total is Resto + PagoReal.
total_pagado_por_jugador([_|R], Jugador, Total) :-
    total_pagado_por_jugador(R, Jugador, Total).

total_cobrado_por_jugador([], _, 0).
total_cobrado_por_jugador(
    [evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, si,
        evento_alquiler(_, _, Jugador, _, _, _, _, _, PagoReal, _, _, _, _),
        _, _, _, _, _, _)|R],
    Jugador,
    Total
) :-
    total_cobrado_por_jugador(R, Jugador, Resto),
    Total is Resto + PagoReal.
total_cobrado_por_jugador([_|R], Jugador, Total) :-
    total_cobrado_por_jugador(R, Jugador, Total).

jugadores_distintos(Eventos, Jugadores) :-
    findall(J, member(evento_turno(_, _, J, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _), Eventos), L),
    sort(L, Jugadores).

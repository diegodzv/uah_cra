% =========================
% metricas.pl
% Epica 6: metricas de compras, alquileres, impuestos, carcel y bancarrota
% =========================

:- module(metricas, [
    resumen_simulacion/3,
    imprimir_resumen_simulacion/1,
    exportar_eventos_csv/2,
    exportar_resumen_csv/2,
    exportar_orden_compras_csv/2,
    exportar_orden_alquileres_csv/2,
    exportar_orden_carcel_csv/2,
    exportar_orden_impuestos_csv/2,
    exportar_orden_bancarrotas_csv/2
]).

resumen_simulacion(PartidaFinal, Eventos, resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores_restantes(TotalJugadoresRestantes),
    total_compras(TotalCompras),
    total_alquileres(TotalAlquileres),
    importe_total_alquileres(ImporteTotalAlquileres),
    total_impuestos(TotalImpuestos),
    importe_total_impuestos(ImporteTotalImpuestos),
    entradas_carcel(EntradasCarcel),
    salidas_pagando(SalidasPagando),
    salidas_dobles(SalidasDobles),
    liberaciones_automaticas(LiberacionesAutomaticas),
    turnos_perdidos_carcel(TurnosPerdidosCarcel),
    bancarrotas(TotalBancarrotas),
    jugadores_eliminados(TotalEliminados),
    jugadores_superan_bancarrota(TotalSupervivencias),
    valor_total_liquidado(ValorTotalLiquidado),
    total_activos_restantes_banco(ActivosBanco),
    dinero_final_jugadores(DineroFinales),
    propiedades_finales_jugadores(PropsFinales)
)) :-
    length(Eventos, TotalTurnos),
    PartidaFinal = partida(_, banco(_, Activos, _, _), Jugadores, _, _, _, _, _, _),
    length(Jugadores, TotalJugadoresRestantes),
    contar_compras(Eventos, TotalCompras),
    contar_alquileres(Eventos, TotalAlquileres),
    sumar_importe_alquileres(Eventos, ImporteTotalAlquileres),
    contar_impuestos(Eventos, TotalImpuestos),
    sumar_importe_impuestos(Eventos, ImporteTotalImpuestos),
    contar_entradas_carcel(Eventos, EntradasCarcel),
    contar_salidas_pagando(Eventos, SalidasPagando),
    contar_salidas_dobles(Eventos, SalidasDobles),
    contar_liberaciones_automaticas(Eventos, LiberacionesAutomaticas),
    contar_turnos_perdidos_carcel(Eventos, TurnosPerdidosCarcel),
    contar_bancarrotas(Eventos, TotalBancarrotas),
    contar_eliminados(Eventos, TotalEliminados),
    contar_supervivencias_bancarrota(Eventos, TotalSupervivencias),
    sumar_valor_liquidado(Eventos, ValorTotalLiquidado),
    length(Activos, ActivosBanco),
    dinero_finales(Jugadores, DineroFinales),
    props_finales(Jugadores, PropsFinales).

imprimir_resumen_simulacion(resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores_restantes(TotalJugadoresRestantes),
    total_compras(TotalCompras),
    total_alquileres(TotalAlquileres),
    importe_total_alquileres(ImporteTotalAlquileres),
    total_impuestos(TotalImpuestos),
    importe_total_impuestos(ImporteTotalImpuestos),
    entradas_carcel(EntradasCarcel),
    salidas_pagando(SalidasPagando),
    salidas_dobles(SalidasDobles),
    liberaciones_automaticas(LiberacionesAutomaticas),
    turnos_perdidos_carcel(TurnosPerdidosCarcel),
    bancarrotas(TotalBancarrotas),
    jugadores_eliminados(TotalEliminados),
    jugadores_superan_bancarrota(TotalSupervivencias),
    valor_total_liquidado(ValorTotalLiquidado),
    total_activos_restantes_banco(ActivosBanco),
    dinero_final_jugadores(DineroFinales),
    propiedades_finales_jugadores(PropsFinales)
)) :-
    write('Total de turnos: '), write(TotalTurnos), nl,
    write('Jugadores restantes: '), write(TotalJugadoresRestantes), nl,
    write('Total de compras realizadas: '), write(TotalCompras), nl,
    write('Total de alquileres ejecutados: '), write(TotalAlquileres), nl,
    write('Importe total transferido por alquileres: '), write(ImporteTotalAlquileres), nl,
    write('Total de impuestos aplicados: '), write(TotalImpuestos), nl,
    write('Importe total pagado en impuestos: '), write(ImporteTotalImpuestos), nl,
    write('Entradas en carcel: '), write(EntradasCarcel), nl,
    write('Salidas pagando: '), write(SalidasPagando), nl,
    write('Salidas por dobles: '), write(SalidasDobles), nl,
    write('Liberaciones automaticas: '), write(LiberacionesAutomaticas), nl,
    write('Turnos perdidos por carcel: '), write(TurnosPerdidosCarcel), nl,
    write('Bancarrotas: '), write(TotalBancarrotas), nl,
    write('Jugadores eliminados: '), write(TotalEliminados), nl,
    write('Jugadores que sobreviven tras liquidar: '), write(TotalSupervivencias), nl,
    write('Valor total liquidado por el banco: '), write(ValorTotalLiquidado), nl,
    write('Activos restantes en el banco: '), write(ActivosBanco), nl,
    write('Dinero final por jugador: '), write(DineroFinales), nl,
    write('Propiedades finales por jugador: '), write(PropsFinales), nl.

contar_compras([], 0).
contar_compras([E|R], T) :-
    contar_compras(R, T1),
    ( arg(18, E, si) -> T is T1 + 1 ; T = T1 ).

contar_alquileres([], 0).
contar_alquileres([E|R], T) :-
    contar_alquileres(R, T1),
    ( arg(20, E, si) -> T is T1 + 1 ; T = T1 ).

sumar_importe_alquileres([], 0).
sumar_importe_alquileres([E|R], T) :-
    sumar_importe_alquileres(R, T1),
    ( arg(20, E, si) ->
        arg(34, E, PagoReal),
        T is T1 + PagoReal
    ;   T = T1 ).

contar_impuestos([], 0).
contar_impuestos([E|R], T) :-
    contar_impuestos(R, T1),
    ( arg(22, E, si) -> T is T1 + 1 ; T = T1 ).

sumar_importe_impuestos([], 0).
sumar_importe_impuestos([E|R], T) :-
    sumar_importe_impuestos(R, T1),
    ( arg(22, E, si) ->
        arg(23, E, evento_impuesto(_, _, _, Importe, _, _)),
        T is T1 + Importe
    ;   T = T1 ).

contar_entradas_carcel([], 0).
contar_entradas_carcel([E|R], T) :-
    contar_entradas_carcel(R, T1),
    ( arg(7, E, evento_carcel(entrada, _, _)) -> T is T1 + 1 ; T = T1 ).

contar_salidas_pagando([], 0).
contar_salidas_pagando([E|R], T) :-
    contar_salidas_pagando(R, T1),
    ( arg(6, E, evento_carcel(sale_pagando, _, _)) -> T is T1 + 1 ; T = T1 ).

contar_salidas_dobles([], 0).
contar_salidas_dobles([E|R], T) :-
    contar_salidas_dobles(R, T1),
    ( arg(6, E, evento_carcel(sale_por_dobles, _, _, _)) -> T is T1 + 1 ; T = T1 ).

contar_liberaciones_automaticas([], 0).
contar_liberaciones_automaticas([E|R], T) :-
    contar_liberaciones_automaticas(R, T1),
    ( arg(6, E, evento_carcel(liberacion_automatica, _)) -> T is T1 + 1 ; T = T1 ).

contar_turnos_perdidos_carcel([], 0).
contar_turnos_perdidos_carcel([E|R], T) :-
    contar_turnos_perdidos_carcel(R, T1),
    ( arg(31, E, si) -> T is T1 + 1 ; T = T1 ).

contar_bancarrotas([], 0).
contar_bancarrotas([E|R], T) :-
    contar_bancarrotas(R, T1),
    ( arg(24, E, si) -> T is T1 + 1 ; T = T1 ).

contar_eliminados([], 0).
contar_eliminados([E|R], T) :-
    contar_eliminados(R, T1),
    ( arg(25, E, evento_bancarrota(_, _, _, _, _, _, _, eliminado)) -> T is T1 + 1 ; T = T1 ).

contar_supervivencias_bancarrota([], 0).
contar_supervivencias_bancarrota([E|R], T) :-
    contar_supervivencias_bancarrota(R, T1),
    ( arg(25, E, evento_bancarrota(_, _, _, _, _, _, _, sobrevive)) -> T is T1 + 1 ; T = T1 ).

sumar_valor_liquidado([], 0).
sumar_valor_liquidado([E|R], T) :-
    sumar_valor_liquidado(R, T1),
    ( arg(25, E, evento_bancarrota(_, _, _, _, ValorLiquidacion, _, _, _)) ->
        T is T1 + ValorLiquidacion
    ;   T = T1 ).

dinero_finales([], []).
dinero_finales([jugador(N, _, D, _, _)|R], [dinero_final(N, D)|R2]) :-
    dinero_finales(R, R2).

props_finales([], []).
props_finales([jugador(N, _, _, Props, _)|R], [propiedades_finales(N, Num)|R2]) :-
    length(Props, Num),
    props_finales(R, R2).

exportar_eventos_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,nombre_casilla,tipo_casilla,compra,alquiler,impuesto,bancarrota,eliminado,dinero_inicial,dinero_tras_carcel,dinero_final,props_antes,props_despues\n'),
    exportar_eventos_csv_aux(Eventos, Stream),
    close(Stream).

exportar_eventos_csv_aux([], _).
exportar_eventos_csv_aux([E|R], Stream) :-
    arg(1, E, Turno),
    arg(3, E, Jugador),
    arg(14, E, NombreCasilla),
    arg(15, E, TipoCasilla),
    arg(18, E, CompraRealizada),
    arg(20, E, AlquilerRealizado),
    arg(22, E, ImpuestoRealizado),
    arg(24, E, BancarrotaRealizada),
    arg(32, E, Eliminado),
    arg(26, E, DineroInicial),
    arg(27, E, DineroTrasCarcel),
    arg(28, E, DineroFinal),
    arg(29, E, PropsAntes),
    arg(30, E, PropsDespues),
    format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
        [Turno, Jugador, NombreCasilla, TipoCasilla, CompraRealizada, AlquilerRealizado, ImpuestoRealizado, BancarrotaRealizada, Eliminado, DineroInicial, DineroTrasCarcel, DineroFinal, PropsAntes, PropsDespues]),
    exportar_eventos_csv_aux(R, Stream).

exportar_resumen_csv(Ruta, Resumen) :-
    open(Ruta, write, Stream),
    write(Stream, 'metrica,valor\n'),
    Resumen = resumen_simulacion(
        total_turnos(TotalTurnos),
        total_jugadores_restantes(TotalJugadoresRestantes),
        total_compras(TotalCompras),
        total_alquileres(TotalAlquileres),
        importe_total_alquileres(ImporteTotalAlquileres),
        total_impuestos(TotalImpuestos),
        importe_total_impuestos(ImporteTotalImpuestos),
        entradas_carcel(EntradasCarcel),
        salidas_pagando(SalidasPagando),
        salidas_dobles(SalidasDobles),
        liberaciones_automaticas(LiberacionesAutomaticas),
        turnos_perdidos_carcel(TurnosPerdidosCarcel),
        bancarrotas(TotalBancarrotas),
        jugadores_eliminados(TotalEliminados),
        jugadores_superan_bancarrota(TotalSupervivencias),
        valor_total_liquidado(ValorTotalLiquidado),
        total_activos_restantes_banco(ActivosBanco),
        _,
        _
    ),
    format(Stream, 'total_turnos,~w\n', [TotalTurnos]),
    format(Stream, 'jugadores_restantes,~w\n', [TotalJugadoresRestantes]),
    format(Stream, 'total_compras,~w\n', [TotalCompras]),
    format(Stream, 'total_alquileres,~w\n', [TotalAlquileres]),
    format(Stream, 'importe_total_alquileres,~w\n', [ImporteTotalAlquileres]),
    format(Stream, 'total_impuestos,~w\n', [TotalImpuestos]),
    format(Stream, 'importe_total_impuestos,~w\n', [ImporteTotalImpuestos]),
    format(Stream, 'entradas_carcel,~w\n', [EntradasCarcel]),
    format(Stream, 'salidas_pagando,~w\n', [SalidasPagando]),
    format(Stream, 'salidas_dobles,~w\n', [SalidasDobles]),
    format(Stream, 'liberaciones_automaticas,~w\n', [LiberacionesAutomaticas]),
    format(Stream, 'turnos_perdidos_carcel,~w\n', [TurnosPerdidosCarcel]),
    format(Stream, 'bancarrotas,~w\n', [TotalBancarrotas]),
    format(Stream, 'jugadores_eliminados,~w\n', [TotalEliminados]),
    format(Stream, 'jugadores_superan_bancarrota,~w\n', [TotalSupervivencias]),
    format(Stream, 'valor_total_liquidado,~w\n', [ValorTotalLiquidado]),
    format(Stream, 'activos_restantes_banco,~w\n', [ActivosBanco]),
    close(Stream).

exportar_orden_compras_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,propiedad,tipo,color,precio\n'),
    exportar_orden_compras_aux(Eventos, Stream),
    close(Stream).

exportar_orden_compras_aux([], _).
exportar_orden_compras_aux([E|R], Stream) :-
    ( arg(18, E, si) ->
        arg(19, E, evento_compra(Turno, Jugador, _, Nombre, Tipo, Color, Precio, _, _)),
        format(Stream, '~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, Nombre, Tipo, Color, Precio])
    ; true ),
    exportar_orden_compras_aux(R, Stream).

exportar_orden_alquileres_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,pagador,cobrador,propiedad,tipo,color,precio_casilla,alquiler_teorico,pago_real\n'),
    exportar_orden_alquileres_aux(Eventos, Stream),
    close(Stream).

exportar_orden_alquileres_aux([], _).
exportar_orden_alquileres_aux([E|R], Stream) :-
    ( arg(20, E, si) ->
        arg(21, E, evento_alquiler(Turno, Pagador, Cobrador, Casilla, Tipo, Color, PrecioCasilla, AlquilerTeorico, PagoReal, _, _, _, _)),
        format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
            [Turno, Pagador, Cobrador, Casilla, Tipo, Color, PrecioCasilla, AlquilerTeorico, PagoReal])
    ; true ),
    exportar_orden_alquileres_aux(R, Stream).

exportar_orden_carcel_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,estado_carcel_antes,decision_carcel,evento_carcel_inicio,evento_carcel_fin,turno_perdido_carcel\n'),
    exportar_orden_carcel_aux(Eventos, Stream),
    close(Stream).

exportar_orden_carcel_aux([], _).
exportar_orden_carcel_aux([E|R], Stream) :-
    arg(5, E, DecisionCarcel),
    arg(6, E, EventoInicio),
    arg(7, E, EventoFin),
    arg(31, E, Perdido),
    ( DecisionCarcel \== no_aplica ; EventoInicio \== no_aplica ; EventoFin \== no_aplica ->
        arg(1, E, Turno),
        arg(3, E, Jugador),
        arg(4, E, EstadoCarcelAntes),
        format(Stream, '~w,~w,~w,~w,~w,~w,~w\n',
            [Turno, Jugador, EstadoCarcelAntes, DecisionCarcel, EventoInicio, EventoFin, Perdido])
    ; true ),
    exportar_orden_carcel_aux(R, Stream).

exportar_orden_impuestos_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,casilla,importe,dinero_antes,dinero_despues\n'),
    exportar_orden_impuestos_aux(Eventos, Stream),
    close(Stream).

exportar_orden_impuestos_aux([], _).
exportar_orden_impuestos_aux([E|R], Stream) :-
    ( arg(22, E, si) ->
        arg(23, E, evento_impuesto(Turno, Jugador, Casilla, Importe, DinAntes, DinDespues)),
        format(Stream, '~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, Casilla, Importe, DinAntes, DinDespues])
    ; true ),
    exportar_orden_impuestos_aux(R, Stream).

exportar_orden_bancarrotas_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,causa,dinero_antes,valor_liquidacion,dinero_despues,propiedades_liquidadas,resultado\n'),
    exportar_orden_bancarrotas_aux(Eventos, Stream),
    close(Stream).

exportar_orden_bancarrotas_aux([], _).
exportar_orden_bancarrotas_aux([E|R], Stream) :-
    ( arg(24, E, si) ->
        arg(25, E, evento_bancarrota(Turno, Jugador, Causa, DinAntes, ValorLiquidacion, DinDespues, NumProps, Resultado)),
        format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w\n',
            [Turno, Jugador, Causa, DinAntes, ValorLiquidacion, DinDespues, NumProps, Resultado])
    ; true ),
    exportar_orden_bancarrotas_aux(R, Stream).

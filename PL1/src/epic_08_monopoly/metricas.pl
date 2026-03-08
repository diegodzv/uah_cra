% =========================
% metricas.pl
% Epica 8: metricas de monopoly, parking, compras, alquileres, impuestos, carcel y bancarrota
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
    exportar_orden_parking_csv/2,
    exportar_orden_bancarrotas_csv/2,
    exportar_orden_monopoly_csv/2
]).

resumen_simulacion(PartidaFinal, Eventos, resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores_restantes(TotalJugadoresRestantes),
    total_compras(TotalCompras),
    total_alquileres(TotalAlquileres),
    importe_total_alquileres(ImporteTotalAlquileres),
    total_impuestos(TotalImpuestos),
    importe_total_impuestos(ImporteTotalImpuestos),
    premios_parking(TotalPremiosParking),
    importe_total_parking(ImporteTotalParking),
    caja_parking_final(CajaParkingFinal),
    eventos_monopoly(TotalEventosMonopoly),
    casas_compradas_total(TotalCasasCompradas),
    coste_total_casas(CosteTotalCasas),
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
    PartidaFinal = partida(_, banco(_, Activos, _, _, CajaParkingFinal), Jugadores, _, _, _, _, _, _),
    length(Jugadores, TotalJugadoresRestantes),
    contar_compras(Eventos, TotalCompras),
    contar_alquileres(Eventos, TotalAlquileres),
    sumar_importe_alquileres(Eventos, ImporteTotalAlquileres),
    contar_impuestos(Eventos, TotalImpuestos),
    sumar_importe_impuestos(Eventos, ImporteTotalImpuestos),
    contar_premios_parking(Eventos, TotalPremiosParking),
    sumar_importe_parking(Eventos, ImporteTotalParking),
    contar_eventos_monopoly(Eventos, TotalEventosMonopoly),
    sumar_casas_compradas(Eventos, TotalCasasCompradas),
    sumar_coste_casas(Eventos, CosteTotalCasas),
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
    premios_parking(TotalPremiosParking),
    importe_total_parking(ImporteTotalParking),
    caja_parking_final(CajaParkingFinal),
    eventos_monopoly(TotalEventosMonopoly),
    casas_compradas_total(TotalCasasCompradas),
    coste_total_casas(CosteTotalCasas),
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
    write('Premios de parking cobrados: '), write(TotalPremiosParking), nl,
    write('Importe total cobrado desde parking: '), write(ImporteTotalParking), nl,
    write('Caja de parking final: '), write(CajaParkingFinal), nl,
    write('Eventos de monopoly: '), write(TotalEventosMonopoly), nl,
    write('Casas compradas en total: '), write(TotalCasasCompradas), nl,
    write('Coste total en casas: '), write(CosteTotalCasas), nl,
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
    arg(22, E, Compra),
    contar_compras(R, T1),
    (Compra == si -> T is T1 + 1 ; T = T1).

contar_alquileres([], 0).
contar_alquileres([E|R], T) :-
    arg(24, E, Alquiler),
    contar_alquileres(R, T1),
    (Alquiler == si -> T is T1 + 1 ; T = T1).

sumar_importe_alquileres([], 0).
sumar_importe_alquileres([E|R], T) :-
    arg(41, E, PagoReal),
    sumar_importe_alquileres(R, T1),
    T is T1 + PagoReal.

contar_impuestos([], 0).
contar_impuestos([E|R], T) :-
    arg(26, E, Impuesto),
    contar_impuestos(R, T1),
    (Impuesto == si -> T is T1 + 1 ; T = T1).

sumar_importe_impuestos([], 0).
sumar_importe_impuestos([E|R], T) :-
    arg(27, E, EventoImpuesto),
    sumar_importe_impuestos(R, T1),
    ( EventoImpuesto = evento_impuesto(_, _, _, Importe, _, _, _, _) ->
        T is T1 + Importe
    ;   T = T1
    ).

contar_premios_parking([], 0).
contar_premios_parking([E|R], T) :-
    arg(28, E, Parking),
    contar_premios_parking(R, T1),
    (Parking == si -> T is T1 + 1 ; T = T1).

sumar_importe_parking([], 0).
sumar_importe_parking([E|R], T) :-
    arg(29, E, EventoParking),
    sumar_importe_parking(R, T1),
    ( EventoParking = evento_parking(_, _, _, Premio, _, _, _) ->
        T is T1 + Premio
    ;   T = T1
    ).

contar_eventos_monopoly([], 0).
contar_eventos_monopoly([E|R], T) :-
    arg(5, E, Monopoly),
    contar_eventos_monopoly(R, T1),
    (Monopoly == si -> T is T1 + 1 ; T = T1).

sumar_casas_compradas([], 0).
sumar_casas_compradas([E|R], T) :-
    arg(7, E, Casas),
    sumar_casas_compradas(R, T1),
    T is T1 + Casas.

sumar_coste_casas([], 0).
sumar_coste_casas([E|R], T) :-
    arg(8, E, Coste),
    sumar_coste_casas(R, T1),
    T is T1 + Coste.

contar_entradas_carcel([], 0).
contar_entradas_carcel([E|R], T) :-
    arg(11, E, EventoFin),
    contar_entradas_carcel(R, T1),
    ( EventoFin = evento_carcel(entrada, _, _) -> T is T1 + 1 ; T = T1 ).

contar_salidas_pagando([], 0).
contar_salidas_pagando([E|R], T) :-
    arg(10, E, EventoInicio),
    contar_salidas_pagando(R, T1),
    ( EventoInicio = evento_carcel(sale_pagando, _, _) -> T is T1 + 1 ; T = T1 ).

contar_salidas_dobles([], 0).
contar_salidas_dobles([E|R], T) :-
    arg(10, E, EventoInicio),
    contar_salidas_dobles(R, T1),
    ( EventoInicio = evento_carcel(sale_por_dobles, _, _, _) -> T is T1 + 1 ; T = T1 ).

contar_liberaciones_automaticas([], 0).
contar_liberaciones_automaticas([E|R], T) :-
    arg(9, E, Decision),
    contar_liberaciones_automaticas(R, T1),
    ( Decision == liberacion_automatica -> T is T1 + 1 ; T = T1 ).

contar_turnos_perdidos_carcel([], 0).
contar_turnos_perdidos_carcel([E|R], T) :-
    arg(38, E, Perdido),
    contar_turnos_perdidos_carcel(R, T1),
    ( Perdido == si -> T is T1 + 1 ; T = T1 ).

contar_bancarrotas([], 0).
contar_bancarrotas([E|R], T) :-
    arg(30, E, B),
    contar_bancarrotas(R, T1),
    (B == si -> T is T1 + 1 ; T = T1).

contar_eliminados([], 0).
contar_eliminados([E|R], T) :-
    arg(39, E, Eliminado),
    contar_eliminados(R, T1),
    (Eliminado == si -> T is T1 + 1 ; T = T1).

contar_supervivencias_bancarrota([], 0).
contar_supervivencias_bancarrota([E|R], T) :-
    arg(31, E, EventoBancarrota),
    contar_supervivencias_bancarrota(R, T1),
    ( EventoBancarrota = evento_bancarrota(_, _, _, _, _, _, _, sobrevive) -> T is T1 + 1 ; T = T1 ).

sumar_valor_liquidado([], 0).
sumar_valor_liquidado([E|R], T) :-
    arg(31, E, EventoBancarrota),
    sumar_valor_liquidado(R, T1),
    ( EventoBancarrota = evento_bancarrota(_, _, _, _, Valor, _, _, _) -> T is T1 + Valor ; T = T1 ).

dinero_finales([], []).
dinero_finales([jugador(N, _, D, _, _)|R], [dinero_final(N, D)|R2]) :-
    dinero_finales(R, R2).

props_finales([], []).
props_finales([jugador(N, _, _, Props, _)|R], [propiedades_finales(N, Num)|R2]) :-
    length(Props, Num),
    props_finales(R, R2).

exportar_eventos_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,monopoly,casas_compradas,coste_casas,nombre_casilla,tipo_casilla,compra,alquiler,impuesto,parking,bancarrota,eliminado,dinero_inicial,dinero_tras_monopoly,dinero_tras_carcel,dinero_final,props_antes,props_despues\n'),
    exportar_eventos_csv_aux(Eventos, Stream),
    close(Stream).

exportar_eventos_csv_aux([], _).
exportar_eventos_csv_aux([E|R], Stream) :-
    arg(1, E, Turno),
    arg(3, E, Jugador),
    arg(5, E, Monopoly),
    arg(7, E, CasasCompradas),
    arg(8, E, CosteCasas),
    arg(18, E, NombreCasilla),
    arg(19, E, TipoCasilla),
    arg(22, E, Compra),
    arg(24, E, Alquiler),
    arg(26, E, Impuesto),
    arg(28, E, Parking),
    arg(30, E, Bancarrota),
    arg(39, E, Eliminado),
    arg(32, E, DineroInicial),
    arg(33, E, DineroTrasMonopoly),
    arg(34, E, DineroTrasCarcel),
    arg(35, E, DineroFinal),
    arg(36, E, PropsAntes),
    arg(37, E, PropsDespues),
    format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
        [Turno, Jugador, Monopoly, CasasCompradas, CosteCasas, NombreCasilla, TipoCasilla, Compra, Alquiler, Impuesto, Parking, Bancarrota, Eliminado, DineroInicial, DineroTrasMonopoly, DineroTrasCarcel, DineroFinal, PropsAntes, PropsDespues]),
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
        premios_parking(TotalPremiosParking),
        importe_total_parking(ImporteTotalParking),
        caja_parking_final(CajaParkingFinal),
        eventos_monopoly(TotalEventosMonopoly),
        casas_compradas_total(TotalCasasCompradas),
        coste_total_casas(CosteTotalCasas),
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
    format(Stream, 'premios_parking,~w\n', [TotalPremiosParking]),
    format(Stream, 'importe_total_parking,~w\n', [ImporteTotalParking]),
    format(Stream, 'caja_parking_final,~w\n', [CajaParkingFinal]),
    format(Stream, 'eventos_monopoly,~w\n', [TotalEventosMonopoly]),
    format(Stream, 'casas_compradas_total,~w\n', [TotalCasasCompradas]),
    format(Stream, 'coste_total_casas,~w\n', [CosteTotalCasas]),
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
    arg(23, E, EventoCompra),
    ( EventoCompra = evento_compra(Turno, Jugador, _, Nombre, Tipo, Color, Precio, _, _) ->
        format(Stream, '~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, Nombre, Tipo, Color, Precio])
    ; true ),
    exportar_orden_compras_aux(R, Stream).

exportar_orden_alquileres_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,pagador,cobrador,propiedad,tipo,color,precio_casilla,num_casas,alquiler_teorico,pago_real\n'),
    exportar_orden_alquileres_aux(Eventos, Stream),
    close(Stream).

exportar_orden_alquileres_aux([], _).
exportar_orden_alquileres_aux([E|R], Stream) :-
    arg(25, E, EventoAlquiler),
    ( EventoAlquiler = evento_alquiler(Turno, Pagador, Cobrador, Casilla, Tipo, Color, PrecioCasilla, NumCasas, AlquilerTeorico, PagoReal, _, _, _, _) ->
        format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
            [Turno, Pagador, Cobrador, Casilla, Tipo, Color, PrecioCasilla, NumCasas, AlquilerTeorico, PagoReal])
    ; true ),
    exportar_orden_alquileres_aux(R, Stream).

exportar_orden_carcel_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,estado_carcel_antes,decision_carcel,evento_carcel_inicio,evento_carcel_fin,turno_perdido_carcel\n'),
    exportar_orden_carcel_aux(Eventos, Stream),
    close(Stream).

exportar_orden_carcel_aux([], _).
exportar_orden_carcel_aux([E|R], Stream) :-
    arg(1, E, Turno),
    arg(3, E, Jugador),
    arg(4, E, EstadoCarcelAntes),
    arg(9, E, DecisionCarcel),
    arg(10, E, EventoInicio),
    arg(11, E, EventoFin),
    arg(38, E, Perdido),
    ( DecisionCarcel \== no_aplica ; EventoInicio \== no_aplica ; EventoFin \== no_aplica ->
        format(Stream, '~w,~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, EstadoCarcelAntes, DecisionCarcel, EventoInicio, EventoFin, Perdido])
    ; true ),
    exportar_orden_carcel_aux(R, Stream).

exportar_orden_impuestos_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,casilla,importe,dinero_antes,dinero_despues,caja_antes,caja_despues\n'),
    exportar_orden_impuestos_aux(Eventos, Stream),
    close(Stream).

exportar_orden_impuestos_aux([], _).
exportar_orden_impuestos_aux([E|R], Stream) :-
    arg(27, E, EventoImpuesto),
    ( EventoImpuesto = evento_impuesto(Turno, Jugador, Casilla, Importe, DinAntes, DinDespues, CajaAntes, CajaDespues) ->
        format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, Casilla, Importe, DinAntes, DinDespues, CajaAntes, CajaDespues])
    ; true ),
    exportar_orden_impuestos_aux(R, Stream).

exportar_orden_parking_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,caja_antes,premio,caja_despues,dinero_antes,dinero_despues\n'),
    exportar_orden_parking_aux(Eventos, Stream),
    close(Stream).

exportar_orden_parking_aux([], _).
exportar_orden_parking_aux([E|R], Stream) :-
    arg(29, E, EventoParking),
    ( EventoParking = evento_parking(Turno, Jugador, CajaAntes, Premio, CajaDespues, DinAntes, DinDespues) ->
        format(Stream, '~w,~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, CajaAntes, Premio, CajaDespues, DinAntes, DinDespues])
    ; true ),
    exportar_orden_parking_aux(R, Stream).

exportar_orden_bancarrotas_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,causa,dinero_antes,valor_liquidacion,dinero_despues,propiedades_liquidadas,resultado\n'),
    exportar_orden_bancarrotas_aux(Eventos, Stream),
    close(Stream).

exportar_orden_bancarrotas_aux([], _).
exportar_orden_bancarrotas_aux([E|R], Stream) :-
    arg(31, E, EventoBancarrota),
    ( EventoBancarrota = evento_bancarrota(Turno, Jugador, Causa, DinAntes, ValorLiquidacion, DinDespues, NumProps, Resultado) ->
        format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, Causa, DinAntes, ValorLiquidacion, DinDespues, NumProps, Resultado])
    ; true ),
    exportar_orden_bancarrotas_aux(R, Stream).

exportar_orden_monopoly_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,jugador,colores_monopolio,casas_compradas,coste_total,dinero_antes,dinero_despues\n'),
    exportar_orden_monopoly_aux(Eventos, Stream),
    close(Stream).

exportar_orden_monopoly_aux([], _).
exportar_orden_monopoly_aux([E|R], Stream) :-
    arg(6, E, EventoMonopoly),
    ( EventoMonopoly = evento_monopoly(Turno, Jugador, Colores, Casas, Coste, DinAntes, DinDespues) ->
        format(Stream, '~w,~w,"~w",~w,~w,~w,~w\n', [Turno, Jugador, Colores, Casas, Coste, DinAntes, DinDespues])
    ; true ),
    exportar_orden_monopoly_aux(R, Stream).

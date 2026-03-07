% =========================
% metricas.pl
% Epica 5: metricas de compras, alquileres y carcel
% =========================

:- module(metricas, [
    resumen_simulacion/3,
    imprimir_resumen_simulacion/1,
    exportar_eventos_csv/2,
    exportar_resumen_csv/2,
    exportar_orden_compras_csv/2,
    exportar_orden_alquileres_csv/2,
    exportar_orden_carcel_csv/2,
    exportar_balance_alquileres_por_jugador_csv/2
]).

resumen_simulacion(PartidaFinal, Eventos, resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores(TotalJugadores),
    total_compras(TotalCompras),
    total_alquileres(TotalAlquileres),
    importe_total_alquileres(ImporteTotalAlquileres),
    entradas_carcel(EntradasCarcel),
    salidas_pagando(SalidasPagando),
    salidas_dobles(SalidasDobles),
    liberaciones_automaticas(LiberacionesAutomaticas),
    turnos_perdidos_carcel(TurnosPerdidosCarcel),
    total_activos_restantes_banco(ActivosBanco),
    dinero_final_jugadores(DineroFinales),
    propiedades_finales_jugadores(PropsFinales)
)) :-
    length(Eventos, TotalTurnos),
    PartidaFinal = partida(_, banco(_, Activos, _, _), Jugadores, _, _, _, _, _, _),
    length(Jugadores, TotalJugadores),
    contar_compras(Eventos, TotalCompras),
    contar_alquileres(Eventos, TotalAlquileres),
    sumar_importe_alquileres(Eventos, ImporteTotalAlquileres),
    contar_entradas_carcel(Eventos, EntradasCarcel),
    contar_salidas_pagando(Eventos, SalidasPagando),
    contar_salidas_dobles(Eventos, SalidasDobles),
    contar_liberaciones_automaticas(Eventos, LiberacionesAutomaticas),
    contar_turnos_perdidos_carcel(Eventos, TurnosPerdidosCarcel),
    length(Activos, ActivosBanco),
    dinero_finales(Jugadores, DineroFinales),
    props_finales(Jugadores, PropsFinales).

imprimir_resumen_simulacion(resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores(TotalJugadores),
    total_compras(TotalCompras),
    total_alquileres(TotalAlquileres),
    importe_total_alquileres(ImporteTotalAlquileres),
    entradas_carcel(EntradasCarcel),
    salidas_pagando(SalidasPagando),
    salidas_dobles(SalidasDobles),
    liberaciones_automaticas(LiberacionesAutomaticas),
    turnos_perdidos_carcel(TurnosPerdidosCarcel),
    total_activos_restantes_banco(ActivosBanco),
    dinero_final_jugadores(DineroFinales),
    propiedades_finales_jugadores(PropsFinales)
)) :-
    write('Total de turnos: '), write(TotalTurnos), nl,
    write('Total de jugadores: '), write(TotalJugadores), nl,
    write('Total de compras realizadas: '), write(TotalCompras), nl,
    write('Total de alquileres ejecutados: '), write(TotalAlquileres), nl,
    write('Importe total transferido por alquileres: '), write(ImporteTotalAlquileres), nl,
    write('Entradas en carcel: '), write(EntradasCarcel), nl,
    write('Salidas pagando: '), write(SalidasPagando), nl,
    write('Salidas por dobles: '), write(SalidasDobles), nl,
    write('Liberaciones automaticas: '), write(LiberacionesAutomaticas), nl,
    write('Turnos perdidos por carcel: '), write(TurnosPerdidosCarcel), nl,
    write('Activos restantes en el banco: '), write(ActivosBanco), nl,
    write('Dinero final por jugador: '), write(DineroFinales), nl,
    write('Propiedades finales por jugador: '), write(PropsFinales), nl.

% =========================================================
% Contadores
% =========================================================

contar_compras([], 0).
contar_compras([Ev|R], Total) :-
    contar_compras(R, Parcial),
    arg(18, Ev, CompraRealizada),
    ( CompraRealizada == si ->
        Total is Parcial + 1
    ;   Total = Parcial
    ).

contar_alquileres([], 0).
contar_alquileres([Ev|R], Total) :-
    contar_alquileres(R, Parcial),
    arg(20, Ev, AlquilerRealizado),
    ( AlquilerRealizado == si ->
        Total is Parcial + 1
    ;   Total = Parcial
    ).

sumar_importe_alquileres([], 0).
sumar_importe_alquileres([Ev|R], Total) :-
    sumar_importe_alquileres(R, Parcial),
    arg(20, Ev, AlquilerRealizado),
    ( AlquilerRealizado == si ->
        arg(23, Ev, PagoReal),
        number(PagoReal),
        Total is Parcial + PagoReal
    ;   Total = Parcial
    ).

contar_entradas_carcel([], 0).
contar_entradas_carcel([Ev|R], Total) :-
    contar_entradas_carcel(R, Parcial),
    ( tiene_evento_entrada_carcel(Ev) ->
        Total is Parcial + 1
    ;   Total = Parcial
    ).

tiene_evento_entrada_carcel(Ev) :-
    arg(6, Ev, EventoInicio),
    EventoInicio \== no_aplica,
    es_evento_entrada_carcel(EventoInicio), !.
tiene_evento_entrada_carcel(Ev) :-
    arg(7, Ev, EventoFin),
    EventoFin \== no_aplica,
    es_evento_entrada_carcel(EventoFin).

es_evento_entrada_carcel(evento_carcel(entrada, _, _)).

contar_salidas_pagando([], 0).
contar_salidas_pagando([Ev|R], Total) :-
    contar_salidas_pagando(R, Parcial),
    ( tiene_salida_pagando(Ev) ->
        Total is Parcial + 1
    ;   Total = Parcial
    ).

tiene_salida_pagando(Ev) :-
    arg(6, Ev, Evento),
    Evento = evento_carcel(sale_pagando, _, _).

contar_salidas_dobles([], 0).
contar_salidas_dobles([Ev|R], Total) :-
    contar_salidas_dobles(R, Parcial),
    ( tiene_salida_dobles(Ev) ->
        Total is Parcial + 1
    ;   Total = Parcial
    ).

tiene_salida_dobles(Ev) :-
    arg(6, Ev, Evento),
    Evento = evento_carcel(sale_por_dobles, _, _, _).

contar_liberaciones_automaticas([], 0).
contar_liberaciones_automaticas([Ev|R], Total) :-
    contar_liberaciones_automaticas(R, Parcial),
    ( tiene_liberacion_automatica(Ev) ->
        Total is Parcial + 1
    ;   Total = Parcial
    ).

tiene_liberacion_automatica(Ev) :-
    arg(6, Ev, Evento),
    Evento = evento_carcel(liberacion_automatica, _).

contar_turnos_perdidos_carcel([], 0).
contar_turnos_perdidos_carcel([Ev|R], Total) :-
    contar_turnos_perdidos_carcel(R, Parcial),
    arg(29, Ev, Perdido),
    ( Perdido == si ->
        Total is Parcial + 1
    ;   Total = Parcial
    ).

% =========================================================
% Datos finales
% =========================================================

dinero_finales([], []).
dinero_finales([jugador(N, _, D, _, _)|R], [dinero_final(N, D)|R2]) :-
    dinero_finales(R, R2).

props_finales([], []).
props_finales([jugador(N, _, _, Props, _)|R], [propiedades_finales(N, Num)|R2]) :-
    length(Props, Num),
    props_finales(R, R2).

% =========================================================
% Export CSV
% =========================================================

exportar_eventos_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,indice_jugador,jugador,estado_carcel_antes,decision_carcel,dado1,dado2,suma,posicion_anterior,posicion_nueva,paso_salida,nombre_casilla,tipo_casilla,precio_casilla,color_casilla,compra_realizada,alquiler_realizado,alquiler_teorico,pago_real,dinero_inicial_turno,dinero_tras_carcel,dinero_final_turno,propiedades_antes,propiedades_despues,turno_perdido_carcel\n'),
            exportar_eventos_csv_aux(Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_eventos_csv_aux([], _).
exportar_eventos_csv_aux([Ev|R], Stream) :-
    arg(1, Ev, Turno),
    arg(2, Ev, IndiceJugador),
    arg(3, Ev, Jugador),
    arg(4, Ev, EstadoCarcelAntes),
    arg(5, Ev, DecisionCarcel),
    arg(8, Ev, D1),
    arg(9, Ev, D2),
    arg(10, Ev, Suma),
    arg(11, Ev, PosAnterior),
    arg(12, Ev, PosNueva),
    arg(13, Ev, PasoSalida),
    arg(14, Ev, NombreCasilla),
    arg(15, Ev, TipoCasilla),
    arg(16, Ev, PrecioCasilla),
    arg(17, Ev, ColorCasilla),
    arg(18, Ev, CompraRealizada),
    arg(20, Ev, AlquilerRealizado),
    arg(22, Ev, AlquilerTeorico),
    arg(23, Ev, PagoReal),
    arg(24, Ev, DineroInicialTurno),
    arg(25, Ev, DineroTrasCarcel),
    arg(26, Ev, DineroFinalTurno),
    arg(27, Ev, PropsAntes),
    arg(28, Ev, PropsDespues),
    arg(29, Ev, PerdidoPorCarcel),
    format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
        [Turno, IndiceJugador, Jugador, EstadoCarcelAntes, DecisionCarcel, D1, D2, Suma, PosAnterior, PosNueva, PasoSalida,
         NombreCasilla, TipoCasilla, PrecioCasilla, ColorCasilla, CompraRealizada, AlquilerRealizado, AlquilerTeorico, PagoReal,
         DineroInicialTurno, DineroTrasCarcel, DineroFinalTurno, PropsAntes, PropsDespues, PerdidoPorCarcel]),
    exportar_eventos_csv_aux(R, Stream).

exportar_resumen_csv(Ruta, Resumen) :-
    Resumen = resumen_simulacion(
        total_turnos(TotalTurnos),
        total_jugadores(TotalJugadores),
        total_compras(TotalCompras),
        total_alquileres(TotalAlquileres),
        importe_total_alquileres(ImporteTotalAlquileres),
        entradas_carcel(EntradasCarcel),
        salidas_pagando(SalidasPagando),
        salidas_dobles(SalidasDobles),
        liberaciones_automaticas(LiberacionesAutomaticas),
        turnos_perdidos_carcel(TurnosPerdidosCarcel),
        total_activos_restantes_banco(ActivosBanco),
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
            format(Stream, 'entradas_carcel,~w\n', [EntradasCarcel]),
            format(Stream, 'salidas_pagando,~w\n', [SalidasPagando]),
            format(Stream, 'salidas_dobles,~w\n', [SalidasDobles]),
            format(Stream, 'liberaciones_automaticas,~w\n', [LiberacionesAutomaticas]),
            format(Stream, 'turnos_perdidos_carcel,~w\n', [TurnosPerdidosCarcel]),
            format(Stream, 'activos_restantes_banco,~w\n', [ActivosBanco])
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
exportar_orden_compras_aux([Ev|R], Stream) :-
    arg(18, Ev, CompraRealizada),
    ( CompraRealizada == si ->
        arg(19, Ev, evento_compra(Turno, Jugador, _, Nombre, Tipo, Color, Precio, _, _)),
        format(Stream, '~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, Nombre, Tipo, Color, Precio])
    ; true ),
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
exportar_orden_alquileres_aux([Ev|R], Stream) :-
    arg(20, Ev, AlquilerRealizado),
    ( AlquilerRealizado == si ->
        arg(21, Ev, evento_alquiler(Turno, Pagador, Cobrador, NombreCasilla, TipoCasilla, ColorCasilla, PrecioCasilla, AlquilerTeorico, PagoReal, DinPagAntes, DinPagDespues, DinCobAntes, DinCobDespues)),
        format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
            [Turno, Pagador, Cobrador, NombreCasilla, TipoCasilla, ColorCasilla, PrecioCasilla, AlquilerTeorico, PagoReal, DinPagAntes, DinPagDespues, DinCobAntes, DinCobDespues])
    ; true ),
    exportar_orden_alquileres_aux(R, Stream).

exportar_orden_carcel_csv(Ruta, Eventos) :-
    setup_call_cleanup(
        open(Ruta, write, Stream),
        (
            write(Stream, 'turno,jugador,estado_carcel_antes,decision_carcel,evento_carcel_inicio,evento_carcel_fin,turno_perdido_carcel\n'),
            exportar_orden_carcel_aux(Eventos, Stream)
        ),
        close(Stream)
    ).

exportar_orden_carcel_aux([], _).
exportar_orden_carcel_aux([Ev|R], Stream) :-
    arg(1, Ev, Turno),
    arg(3, Ev, Jugador),
    arg(4, Ev, EstadoCarcelAntes),
    arg(5, Ev, DecisionCarcel),
    arg(6, Ev, EventoInicio),
    arg(7, Ev, EventoFin),
    arg(29, Ev, Perdido),
    ( DecisionCarcel \== no_aplica ; EventoInicio \== no_aplica ; EventoFin \== no_aplica ->
        format(Stream, '~w,~w,~w,~w,~w,~w,~w\n', [Turno, Jugador, EstadoCarcelAntes, DecisionCarcel, EventoInicio, EventoFin, Perdido])
    ; true ),
    exportar_orden_carcel_aux(R, Stream).

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
total_pagado_por_jugador([Ev|R], Jugador, Total) :-
    total_pagado_por_jugador(R, Jugador, Parcial),
    arg(20, Ev, AlquilerRealizado),
    ( AlquilerRealizado == si,
      arg(21, Ev, evento_alquiler(_, Jugador, _, _, _, _, _, _, PagoReal, _, _, _, _)),
      number(PagoReal) ->
        Total is Parcial + PagoReal
    ;   Total = Parcial
    ).

total_cobrado_por_jugador([], _, 0).
total_cobrado_por_jugador([Ev|R], Jugador, Total) :-
    total_cobrado_por_jugador(R, Jugador, Parcial),
    arg(20, Ev, AlquilerRealizado),
    ( AlquilerRealizado == si,
      arg(21, Ev, evento_alquiler(_, _, Jugador, _, _, _, _, _, PagoReal, _, _, _, _)),
      number(PagoReal) ->
        Total is Parcial + PagoReal
    ;   Total = Parcial
    ).

jugadores_distintos(Eventos, Jugadores) :-
    findall(J, (
        member(Ev, Eventos),
        functor(Ev, evento_turno, 29),
        arg(3, Ev, J)
    ), L),
    sort(L, Jugadores).

% =========================
% main.pl
% Epica 7: parking gratuito con caja comun
% =========================

:- initialization(banner).

:- use_module(tablero).
:- use_module(dados).
:- use_module(compras).
:- use_module(alquileres).
:- use_module(impuestos).
:- use_module(parking).
:- use_module(carcel).
:- use_module(bancarrota).
:- use_module(simulacion).
:- use_module(escenarios).
:- use_module(metricas).

banner :-
    nl,
    write('========================================================'), nl,
    write(' MONOPOLY PROLOG - EPICA 7: PARKING GRATUITO            '), nl,
    write('========================================================'), nl,
    nl,
    write('Predicados disponibles:'), nl,
    write('  - list_scenarios.'), nl,
    write('  - run_scenario(Nombre).'), nl,
    write('  - run_all_scenarios.'), nl,
    write('  - export_scenario_csv(Nombre).'), nl,
    write('  - export_all_csv.'), nl,
    write('  - validar_tablero.'), nl,
    nl.

list_scenarios :-
    escenarios:nombres_escenarios(Nombres),
    write('Escenarios disponibles:'), nl,
    imprimir_lista(Nombres).

imprimir_lista([]).
imprimir_lista([X|R]) :-
    write(' - '), write(X), nl,
    imprimir_lista(R).

validar_tablero :-
    ( tablero:tablero_valido ->
        write('OK: el tablero es valido.'), nl
    ;   write('ERROR: el tablero NO es valido.'), nl
    ).

run_scenario(Nombre) :-
    escenarios:escenario(Nombre, escenario(NombreEscenario, Objetivo, PartidaInicial)),
    simulacion:simular_partida(PartidaInicial, PartidaFinal, Eventos),
    metricas:resumen_simulacion(PartidaFinal, Eventos, Resumen),
    nl,
    write('=== ESCENARIO ==='), nl,
    write('Nombre: '), write(NombreEscenario), nl,
    write('Objetivo: '), write(Objetivo), nl, nl,
    mostrar_configuracion_inicial(PartidaInicial),
    nl,
    write('--- RESUMEN DE SIMULACION ---'), nl,
    metricas:imprimir_resumen_simulacion(Resumen), nl,
    write('--- JUGADORES FINALES ---'), nl,
    mostrar_jugadores_finales(PartidaFinal), nl,
    write('--- PRIMEROS 10 EVENTOS DE CARCEL ---'), nl,
    mostrar_primeros_eventos_carcel(Eventos, 10), nl,
    write('--- PRIMERAS 10 COMPRAS ---'), nl,
    mostrar_primeras_compras(Eventos, 10), nl,
    write('--- PRIMEROS 10 ALQUILERES ---'), nl,
    mostrar_primeros_alquileres(Eventos, 10), nl,
    write('--- PRIMEROS 10 IMPUESTOS ---'), nl,
    mostrar_primeros_impuestos(Eventos, 10), nl,
    write('--- PRIMEROS 10 COBROS DE PARKING ---'), nl,
    mostrar_primeros_parkings(Eventos, 10), nl,
    write('--- PRIMEROS 10 EVENTOS DE BANCARROTA ---'), nl,
    mostrar_primeras_bancarrotas(Eventos, 10).

run_all_scenarios :-
    escenarios:nombres_escenarios(Nombres),
    run_all_scenarios_aux(Nombres).

run_all_scenarios_aux([]).
run_all_scenarios_aux([N|R]) :-
    run_scenario(N),
    nl,
    write('--------------------------------------------------------'), nl,
    run_all_scenarios_aux(R).

mostrar_configuracion_inicial(
    partida(_, banco(_, _, _, _, CajaParking), Jugadores, TurnoActual, MaxTurnos, estado_dados(Semilla, _, _), PoliticaCompra, PoliticaCarcel, historial(Etiqueta, _))
) :-
    write('--- CONFIGURACION INICIAL ---'), nl,
    write('Etiqueta: '), write(Etiqueta), nl,
    write('Turno actual inicial: '), write(TurnoActual), nl,
    write('Maximo de turnos: '), write(MaxTurnos), nl,
    write('Semilla de dados: '), write(Semilla), nl,
    write('Politica de compra: '), write(PoliticaCompra), nl,
    write('Politica de carcel: '), write(PoliticaCarcel), nl,
    write('Caja parking inicial: '), write(CajaParking), nl,
    write('Jugadores:'), nl,
    mostrar_jugadores_iniciales(Jugadores).

mostrar_jugadores_iniciales([]).
mostrar_jugadores_iniciales([jugador(N, P, D, Props, EstadoCarcel)|R]) :-
    length(Props, Num),
    write(' - '), write(N),
    write(' | Posicion inicial: '), write(P),
    write(' | Dinero: '), write(D),
    write(' | Propiedades: '), write(Num),
    write(' | Estado carcel: '), write(EstadoCarcel), nl,
    mostrar_jugadores_iniciales(R).

mostrar_jugadores_finales(partida(_, banco(_, ActivosBanco, _, _, CajaParking), Jugadores, _, _, _, _, _, _)) :-
    mostrar_jugadores_finales_aux(Jugadores),
    length(ActivosBanco, Restantes),
    write('Activos restantes en banco: '), write(Restantes), nl,
    write('Caja parking final: '), write(CajaParking), nl.

mostrar_jugadores_finales_aux([]).
mostrar_jugadores_finales_aux([jugador(N, P, D, Props, EstadoCarcel)|R]) :-
    length(Props, Num),
    write(' - '), write(N),
    write(' | Posicion final: '), write(P),
    write(' | Dinero final: '), write(D),
    write(' | Propiedades finales: '), write(Num),
    write(' | Estado carcel: '), write(EstadoCarcel), nl,
    mostrar_jugadores_finales_aux(R).

mostrar_primeros_eventos_carcel(Eventos, N) :-
    include(es_evento_carcel, Eventos, Filtrados),
    primeros_n(Filtrados, N, Seleccion),
    mostrar_eventos_carcel_seleccion(Seleccion).

es_evento_carcel(E) :-
    arg(5, E, Decision),
    arg(6, E, EventoInicio),
    arg(7, E, EventoFin),
    (Decision \== no_aplica ; EventoInicio \== no_aplica ; EventoFin \== no_aplica).

mostrar_eventos_carcel_seleccion([]) :-
    write(' (ninguno)'), nl.
mostrar_eventos_carcel_seleccion([E|R]) :-
    arg(1, E, Turno),
    arg(3, E, Jugador),
    arg(4, E, EstadoAntes),
    arg(5, E, Decision),
    arg(6, E, EventoInicio),
    arg(7, E, EventoFin),
    arg(11, E, PosAnterior),
    arg(12, E, PosNueva),
    arg(28, E, DineroInicial),
    arg(29, E, DineroTrasCarcel),
    arg(33, E, Perdido),
    write('Turno '), write(Turno),
    write(' | Jugador='), write(Jugador),
    write(' | Estado antes='), write(EstadoAntes),
    write(' | Decision='), write(Decision),
    write(' | Evento inicio='), write(EventoInicio),
    write(' | Evento fin='), write(EventoFin),
    write(' | Pos '), write(PosAnterior), write(' -> '), write(PosNueva),
    write(' | Dinero '), write(DineroInicial), write(' -> '), write(DineroTrasCarcel),
    write(' | Turno perdido='), write(Perdido), nl,
    mostrar_eventos_carcel_seleccion(R).

mostrar_primeras_compras(Eventos, N) :-
    include(es_evento_compra, Eventos, Filtrados),
    primeros_n(Filtrados, N, Seleccion),
    mostrar_eventos_compra_seleccion(Seleccion).

es_evento_compra(E) :-
    arg(18, E, si).

mostrar_eventos_compra_seleccion([]) :-
    write(' (ninguna)'), nl.
mostrar_eventos_compra_seleccion([E|R]) :-
    arg(19, E, evento_compra(Turno, Jugador, Pos, Nombre, Tipo, Color, Precio, DinAntes, DinDespues)),
    write('Turno '), write(Turno),
    write(' | Jugador='), write(Jugador),
    write(' | Pos='), write(Pos),
    write(' | Compra='), write(Nombre),
    write(' | Tipo='), write(Tipo),
    write(' | Color='), write(Color),
    write(' | Precio='), write(Precio),
    write(' | Dinero '), write(DinAntes), write(' -> '), write(DinDespues), nl,
    mostrar_eventos_compra_seleccion(R).

mostrar_primeros_alquileres(Eventos, N) :-
    include(es_evento_alquiler, Eventos, Filtrados),
    primeros_n(Filtrados, N, Seleccion),
    mostrar_eventos_alquiler_seleccion(Seleccion).

es_evento_alquiler(E) :-
    arg(20, E, si).

mostrar_eventos_alquiler_seleccion([]) :-
    write(' (ninguno)'), nl.
mostrar_eventos_alquiler_seleccion([E|R]) :-
    arg(21, E, evento_alquiler(Turno, Pagador, Cobrador, Casilla, Tipo, Color, PrecioCasilla, AlquilerTeorico, PagoReal, DinPagAntes, DinPagDespues, DinCobAntes, DinCobDespues)),
    write('Turno '), write(Turno),
    write(' | Pagador='), write(Pagador),
    write(' | Cobrador='), write(Cobrador),
    write(' | Casilla='), write(Casilla),
    write(' | Tipo='), write(Tipo),
    write(' | Color='), write(Color),
    write(' | Precio='), write(PrecioCasilla),
    write(' | Alquiler teorico='), write(AlquilerTeorico),
    write(' | Pago real='), write(PagoReal),
    write(' | Pagador '), write(DinPagAntes), write(' -> '), write(DinPagDespues),
    write(' | Cobrador '), write(DinCobAntes), write(' -> '), write(DinCobDespues), nl,
    mostrar_eventos_alquiler_seleccion(R).

mostrar_primeros_impuestos(Eventos, N) :-
    include(es_evento_impuesto, Eventos, Filtrados),
    primeros_n(Filtrados, N, Seleccion),
    mostrar_eventos_impuesto_seleccion(Seleccion).

es_evento_impuesto(E) :-
    arg(22, E, si).

mostrar_eventos_impuesto_seleccion([]) :-
    write(' (ninguno)'), nl.
mostrar_eventos_impuesto_seleccion([E|R]) :-
    arg(23, E, evento_impuesto(Turno, Jugador, Casilla, Importe, DinAntes, DinDespues, CajaAntes, CajaDespues)),
    write('Turno '), write(Turno),
    write(' | Jugador='), write(Jugador),
    write(' | Casilla='), write(Casilla),
    write(' | Importe='), write(Importe),
    write(' | Dinero '), write(DinAntes), write(' -> '), write(DinDespues),
    write(' | Caja parking '), write(CajaAntes), write(' -> '), write(CajaDespues), nl,
    mostrar_eventos_impuesto_seleccion(R).

mostrar_primeros_parkings(Eventos, N) :-
    include(es_evento_parking, Eventos, Filtrados),
    primeros_n(Filtrados, N, Seleccion),
    mostrar_eventos_parking_seleccion(Seleccion).

es_evento_parking(E) :-
    arg(24, E, si).

mostrar_eventos_parking_seleccion([]) :-
    write(' (ninguno)'), nl.
mostrar_eventos_parking_seleccion([E|R]) :-
    arg(25, E, evento_parking(Turno, Jugador, CajaAntes, Premio, CajaDespues, DinAntes, DinDespues)),
    write('Turno '), write(Turno),
    write(' | Jugador='), write(Jugador),
    write(' | Caja antes='), write(CajaAntes),
    write(' | Premio='), write(Premio),
    write(' | Caja despues='), write(CajaDespues),
    write(' | Dinero '), write(DinAntes), write(' -> '), write(DinDespues), nl,
    mostrar_eventos_parking_seleccion(R).

mostrar_primeras_bancarrotas(Eventos, N) :-
    include(es_evento_bancarrota, Eventos, Filtrados),
    primeros_n(Filtrados, N, Seleccion),
    mostrar_eventos_bancarrota_seleccion(Seleccion).

es_evento_bancarrota(E) :-
    arg(26, E, si).

mostrar_eventos_bancarrota_seleccion([]) :-
    write(' (ninguna)'), nl.
mostrar_eventos_bancarrota_seleccion([E|R]) :-
    arg(27, E, evento_bancarrota(Turno, Jugador, Causa, DinAntes, ValorLiquidacion, DinDespues, NumProps, Resultado)),
    write('Turno '), write(Turno),
    write(' | Jugador='), write(Jugador),
    write(' | Causa='), write(Causa),
    write(' | Dinero antes='), write(DinAntes),
    write(' | Liquidacion='), write(ValorLiquidacion),
    write(' | Dinero despues='), write(DinDespues),
    write(' | Propiedades liquidadas='), write(NumProps),
    write(' | Resultado='), write(Resultado), nl,
    mostrar_eventos_bancarrota_seleccion(R).

primeros_n(_, 0, []) :- !.
primeros_n([], _, []) :- !.
primeros_n([X|R], N, [X|R2]) :-
    N > 0,
    N2 is N - 1,
    primeros_n(R, N2, R2).

export_scenario_csv(Nombre) :-
    escenarios:escenario(Nombre, escenario(_, _, PartidaInicial)),
    simulacion:simular_partida(PartidaInicial, PartidaFinal, Eventos),
    metricas:resumen_simulacion(PartidaFinal, Eventos, Resumen),
    construir_rutas_csv(Nombre, RutaEventos, RutaResumen, RutaCompras, RutaAlquileres, RutaCarcel, RutaImpuestos, RutaParking, RutaBancarrotas),
    metricas:exportar_eventos_csv(RutaEventos, Eventos),
    metricas:exportar_resumen_csv(RutaResumen, Resumen),
    metricas:exportar_orden_compras_csv(RutaCompras, Eventos),
    metricas:exportar_orden_alquileres_csv(RutaAlquileres, Eventos),
    metricas:exportar_orden_carcel_csv(RutaCarcel, Eventos),
    metricas:exportar_orden_impuestos_csv(RutaImpuestos, Eventos),
    metricas:exportar_orden_parking_csv(RutaParking, Eventos),
    metricas:exportar_orden_bancarrotas_csv(RutaBancarrotas, Eventos),
    nl,
    write('CSV exportados para escenario: '), write(Nombre), nl.

export_all_csv :-
    escenarios:nombres_escenarios(Nombres),
    export_all_csv_aux(Nombres).

export_all_csv_aux([]).
export_all_csv_aux([N|R]) :-
    export_scenario_csv(N),
    export_all_csv_aux(R).

construir_rutas_csv(Nombre, RutaEventos, RutaResumen, RutaCompras, RutaAlquileres, RutaCarcel, RutaImpuestos, RutaParking, RutaBancarrotas) :-
    atomic_list_concat(['resultados/', Nombre, '_eventos.csv'], RutaEventos),
    atomic_list_concat(['resultados/', Nombre, '_resumen.csv'], RutaResumen),
    atomic_list_concat(['resultados/', Nombre, '_orden_compras.csv'], RutaCompras),
    atomic_list_concat(['resultados/', Nombre, '_orden_alquileres.csv'], RutaAlquileres),
    atomic_list_concat(['resultados/', Nombre, '_orden_carcel.csv'], RutaCarcel),
    atomic_list_concat(['resultados/', Nombre, '_orden_impuestos.csv'], RutaImpuestos),
    atomic_list_concat(['resultados/', Nombre, '_orden_parking.csv'], RutaParking),
    atomic_list_concat(['resultados/', Nombre, '_orden_bancarrotas.csv'], RutaBancarrotas).

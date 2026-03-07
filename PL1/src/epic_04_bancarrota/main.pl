% =========================
% main.pl
% Epica 4: alquileres
% =========================

:- initialization(banner).

:- use_module(tablero).
:- use_module(dados).
:- use_module(compras).
:- use_module(alquileres).
:- use_module(simulacion).
:- use_module(escenarios).
:- use_module(metricas).

banner :-
    nl,
    write('========================================================'), nl,
    write(' MONOPOLY PROLOG - EPICA 4: COMPRA Y ALQUILERES         '), nl,
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
    write('--- PRIMERAS 10 COMPRAS ---'), nl,
    mostrar_primeras_compras(Eventos, 10), nl,
    write('--- PRIMEROS 10 ALQUILERES ---'), nl,
    mostrar_primeros_alquileres(Eventos, 10).

run_all_scenarios :-
    escenarios:nombres_escenarios(Nombres),
    run_all_scenarios_aux(Nombres).

run_all_scenarios_aux([]).
run_all_scenarios_aux([N|R]) :-
    run_scenario(N),
    nl,
    write('--------------------------------------------------------'), nl,
    run_all_scenarios_aux(R).

mostrar_configuracion_inicial(partida(_, _, Jugadores, TurnoActual, MaxTurnos, estado_dados(Semilla, _, _), PoliticaCompra, historial(Etiqueta, _))) :-
    write('--- CONFIGURACION INICIAL ---'), nl,
    write('Etiqueta: '), write(Etiqueta), nl,
    write('Turno actual inicial: '), write(TurnoActual), nl,
    write('Maximo de turnos: '), write(MaxTurnos), nl,
    write('Semilla de dados: '), write(Semilla), nl,
    write('Politica de compra: '), write(PoliticaCompra), nl,
    write('Jugadores:'), nl,
    mostrar_jugadores_iniciales(Jugadores).

mostrar_jugadores_iniciales([]).
mostrar_jugadores_iniciales([jugador(N, P, D, Props, C)|R]) :-
    length(Props, Num),
    write(' - '), write(N),
    write(' | Posicion inicial: '), write(P),
    write(' | Dinero: '), write(D),
    write(' | Propiedades: '), write(Num),
    write(' | En carcel: '), write(C), nl,
    mostrar_jugadores_iniciales(R).

mostrar_jugadores_finales(partida(_, banco(_, ActivosBanco, _, _), Jugadores, _, _, _, _, _)) :-
    mostrar_jugadores_finales_aux(Jugadores),
    length(ActivosBanco, Restantes),
    write('Activos restantes en banco: '), write(Restantes), nl.

mostrar_jugadores_finales_aux([]).
mostrar_jugadores_finales_aux([jugador(N, P, D, Props, C)|R]) :-
    length(Props, Num),
    write(' - '), write(N),
    write(' | Posicion final: '), write(P),
    write(' | Dinero final: '), write(D),
    write(' | Propiedades finales: '), write(Num),
    write(' | En carcel: '), write(C), nl,
    mostrar_jugadores_finales_aux(R).

mostrar_primeras_compras(_, 0) :- !.
mostrar_primeras_compras([], _) :- !.
mostrar_primeras_compras([evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, no, _, _, _, _, _, _, _, _, _)|R], N) :-
    mostrar_primeras_compras(R, N).
mostrar_primeras_compras([evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, si,
    evento_compra(Turno, Jugador, Pos, Nombre, Tipo, Color, Precio, DinAntes, DinDespues),
    _, _, _, _, _, _, _, _)|R], N) :-
    write('Turno '), write(Turno),
    write(' | Jugador='), write(Jugador),
    write(' | Pos='), write(Pos),
    write(' | Compra='), write(Nombre),
    write(' | Tipo='), write(Tipo),
    write(' | Color='), write(Color),
    write(' | Precio='), write(Precio),
    write(' | Dinero '), write(DinAntes), write(' -> '), write(DinDespues), nl,
    N2 is N - 1,
    mostrar_primeras_compras(R, N2).

mostrar_primeros_alquileres(_, 0) :- !.
mostrar_primeros_alquileres([], _) :- !.
mostrar_primeros_alquileres([evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, no, _, _, _, _, _, _, _)|R], N) :-
    mostrar_primeros_alquileres(R, N).
mostrar_primeros_alquileres([evento_turno(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, si,
    evento_alquiler(Turno, Pagador, Cobrador, Casilla, Tipo, Color, PrecioCasilla, AlquilerTeorico, PagoReal, DinPagAntes, DinPagDespues, DinCobAntes, DinCobDespues),
    _, _, _, _, _, _)|R], N) :-
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
    N2 is N - 1,
    mostrar_primeros_alquileres(R, N2).

export_scenario_csv(Nombre) :-
    escenarios:escenario(Nombre, escenario(_, _, PartidaInicial)),
    simulacion:simular_partida(PartidaInicial, PartidaFinal, Eventos),
    metricas:resumen_simulacion(PartidaFinal, Eventos, Resumen),
    construir_rutas_csv(Nombre, RutaEventos, RutaComprasTurno, RutaComprasAcum, RutaAlqsTurno, RutaAlqsAcum, RutaDineroTurno, RutaPropsTurno, RutaPropsFinales, RutaResumen, RutaOrdenCompras, RutaOrdenAlquileres, RutaBalanceAlqsJugador),
    metricas:exportar_eventos_csv(RutaEventos, Eventos),
    metricas:exportar_compras_por_turno_csv(RutaComprasTurno, Eventos),
    metricas:exportar_compras_acumuladas_csv(RutaComprasAcum, Eventos),
    metricas:exportar_alquileres_por_turno_csv(RutaAlqsTurno, Eventos),
    metricas:exportar_alquileres_acumulados_csv(RutaAlqsAcum, Eventos),
    metricas:exportar_dinero_por_turno_csv(RutaDineroTurno, Eventos),
    metricas:exportar_propiedades_por_turno_csv(RutaPropsTurno, Eventos),
    metricas:exportar_propiedades_finales_csv(RutaPropsFinales, PartidaFinal),
    metricas:exportar_resumen_csv(RutaResumen, Resumen),
    metricas:exportar_orden_compras_csv(RutaOrdenCompras, Eventos),
    metricas:exportar_orden_alquileres_csv(RutaOrdenAlquileres, Eventos),
    metricas:exportar_balance_alquileres_por_jugador_csv(RutaBalanceAlqsJugador, Eventos),
    nl,
    write('CSV exportados para escenario: '), write(Nombre), nl.

export_all_csv :-
    escenarios:nombres_escenarios(Nombres),
    export_all_csv_aux(Nombres).

export_all_csv_aux([]).
export_all_csv_aux([N|R]) :-
    export_scenario_csv(N),
    export_all_csv_aux(R).

construir_rutas_csv(Nombre, RutaEventos, RutaComprasTurno, RutaComprasAcum, RutaAlqsTurno, RutaAlqsAcum, RutaDineroTurno, RutaPropsTurno, RutaPropsFinales, RutaResumen, RutaOrdenCompras, RutaOrdenAlquileres, RutaBalanceAlqsJugador) :-
    atomic_list_concat(['resultados/', Nombre, '_eventos.csv'], RutaEventos),
    atomic_list_concat(['resultados/', Nombre, '_compras_por_turno.csv'], RutaComprasTurno),
    atomic_list_concat(['resultados/', Nombre, '_compras_acumuladas.csv'], RutaComprasAcum),
    atomic_list_concat(['resultados/', Nombre, '_alquileres_por_turno.csv'], RutaAlqsTurno),
    atomic_list_concat(['resultados/', Nombre, '_alquileres_acumulados.csv'], RutaAlqsAcum),
    atomic_list_concat(['resultados/', Nombre, '_dinero_por_turno.csv'], RutaDineroTurno),
    atomic_list_concat(['resultados/', Nombre, '_propiedades_por_turno.csv'], RutaPropsTurno),
    atomic_list_concat(['resultados/', Nombre, '_propiedades_finales.csv'], RutaPropsFinales),
    atomic_list_concat(['resultados/', Nombre, '_resumen.csv'], RutaResumen),
    atomic_list_concat(['resultados/', Nombre, '_orden_compras.csv'], RutaOrdenCompras),
    atomic_list_concat(['resultados/', Nombre, '_orden_alquileres.csv'], RutaOrdenAlquileres),
    atomic_list_concat(['resultados/', Nombre, '_balance_alquileres_por_jugador.csv'], RutaBalanceAlqsJugador).

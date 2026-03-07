% =========================
% main.pl
% Epica 5: carcel
% =========================

:- initialization(banner).

:- use_module(tablero).
:- use_module(dados).
:- use_module(compras).
:- use_module(alquileres).
:- use_module(carcel).
:- use_module(simulacion).
:- use_module(escenarios).
:- use_module(metricas).

banner :-
    nl,
    write('========================================================'), nl,
    write(' MONOPOLY PROLOG - EPICA 5: CARCEL                      '), nl,
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

mostrar_configuracion_inicial(partida(_, _, Jugadores, TurnoActual, MaxTurnos, estado_dados(Semilla, _, _), PoliticaCompra, PoliticaCarcel, historial(Etiqueta, _))) :-
    write('--- CONFIGURACION INICIAL ---'), nl,
    write('Etiqueta: '), write(Etiqueta), nl,
    write('Turno actual inicial: '), write(TurnoActual), nl,
    write('Maximo de turnos: '), write(MaxTurnos), nl,
    write('Semilla de dados: '), write(Semilla), nl,
    write('Politica de compra: '), write(PoliticaCompra), nl,
    write('Politica de carcel: '), write(PoliticaCarcel), nl,
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

mostrar_jugadores_finales(partida(_, banco(_, ActivosBanco, _, _), Jugadores, _, _, _, _, _, _)) :-
    mostrar_jugadores_finales_aux(Jugadores),
    length(ActivosBanco, Restantes),
    write('Activos restantes en banco: '), write(Restantes), nl.

mostrar_jugadores_finales_aux([]).
mostrar_jugadores_finales_aux([jugador(N, P, D, Props, EstadoCarcel)|R]) :-
    length(Props, Num),
    write(' - '), write(N),
    write(' | Posicion final: '), write(P),
    write(' | Dinero final: '), write(D),
    write(' | Propiedades finales: '), write(Num),
    write(' | Estado carcel: '), write(EstadoCarcel), nl,
    mostrar_jugadores_finales_aux(R).

mostrar_primeros_eventos_carcel(_, 0) :- !.
mostrar_primeros_eventos_carcel([], _) :- !.
mostrar_primeros_eventos_carcel([Ev|R], N) :-
    arg(5, Ev, Decision),
    arg(6, Ev, EventoInicio),
    arg(7, Ev, EventoFin),
    ( Decision == no_aplica,
      EventoInicio == no_aplica,
      EventoFin == no_aplica ->
        mostrar_primeros_eventos_carcel(R, N)
    ;
        arg(1, Ev, Turno),
        arg(3, Ev, Jugador),
        arg(4, Ev, EstadoAntes),
        arg(11, Ev, PosAnterior),
        arg(12, Ev, PosNueva),
        arg(24, Ev, DineroInicial),
        arg(25, Ev, DineroTrasCarcel),
        arg(26, Ev, DineroFinal),
        arg(29, Ev, Perdido),
        write('Turno '), write(Turno),
        write(' | Jugador='), write(Jugador),
        write(' | Estado antes='), write(EstadoAntes),
        write(' | Decision='), write(Decision),
        write(' | Evento inicio='), write(EventoInicio),
        write(' | Evento fin='), write(EventoFin),
        write(' | Pos '), write(PosAnterior), write(' -> '), write(PosNueva),
        write(' | Dinero '), write(DineroInicial), write(' -> '), write(DineroTrasCarcel), write(' -> '), write(DineroFinal),
        write(' | Turno perdido='), write(Perdido), nl,
        N2 is N - 1,
        mostrar_primeros_eventos_carcel(R, N2)
    ).

mostrar_primeras_compras(_, 0) :- !.
mostrar_primeras_compras([], _) :- !.
mostrar_primeras_compras([Ev|R], N) :-
    arg(18, Ev, CompraRealizada),
    ( CompraRealizada == si ->
        arg(19, Ev, evento_compra(Turno, Jugador, Pos, Nombre, Tipo, Color, Precio, DinAntes, DinDespues)),
        write('Turno '), write(Turno),
        write(' | Jugador='), write(Jugador),
        write(' | Pos='), write(Pos),
        write(' | Compra='), write(Nombre),
        write(' | Tipo='), write(Tipo),
        write(' | Color='), write(Color),
        write(' | Precio='), write(Precio),
        write(' | Dinero '), write(DinAntes), write(' -> '), write(DinDespues), nl,
        N2 is N - 1,
        mostrar_primeras_compras(R, N2)
    ;
        mostrar_primeras_compras(R, N)
    ).

mostrar_primeros_alquileres(_, 0) :- !.
mostrar_primeros_alquileres([], _) :- !.
mostrar_primeros_alquileres([Ev|R], N) :-
    arg(20, Ev, AlquilerRealizado),
    ( AlquilerRealizado == si ->
        arg(21, Ev, evento_alquiler(Turno, Pagador, Cobrador, Casilla, Tipo, Color, PrecioCasilla, AlquilerTeorico, PagoReal, DinPagAntes, DinPagDespues, DinCobAntes, DinCobDespues)),
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
        mostrar_primeros_alquileres(R, N2)
    ;
        mostrar_primeros_alquileres(R, N)
    ).

export_scenario_csv(Nombre) :-
    escenarios:escenario(Nombre, escenario(_, _, PartidaInicial)),
    simulacion:simular_partida(PartidaInicial, PartidaFinal, Eventos),
    metricas:resumen_simulacion(PartidaFinal, Eventos, Resumen),
    construir_rutas_csv(Nombre, RutaEventos, RutaResumen, RutaCompras, RutaAlquileres, RutaCarcel, RutaBalance),
    metricas:exportar_eventos_csv(RutaEventos, Eventos),
    metricas:exportar_resumen_csv(RutaResumen, Resumen),
    metricas:exportar_orden_compras_csv(RutaCompras, Eventos),
    metricas:exportar_orden_alquileres_csv(RutaAlquileres, Eventos),
    metricas:exportar_orden_carcel_csv(RutaCarcel, Eventos),
    metricas:exportar_balance_alquileres_por_jugador_csv(RutaBalance, Eventos),
    nl,
    write('CSV exportados para escenario: '), write(Nombre), nl.

export_all_csv :-
    escenarios:nombres_escenarios(Nombres),
    export_all_csv_aux(Nombres).

export_all_csv_aux([]).
export_all_csv_aux([N|R]) :-
    export_scenario_csv(N),
    export_all_csv_aux(R).

construir_rutas_csv(Nombre, RutaEventos, RutaResumen, RutaCompras, RutaAlquileres, RutaCarcel, RutaBalance) :-
    atomic_list_concat(['resultados/', Nombre, '_eventos.csv'], RutaEventos),
    atomic_list_concat(['resultados/', Nombre, '_resumen.csv'], RutaResumen),
    atomic_list_concat(['resultados/', Nombre, '_orden_compras.csv'], RutaCompras),
    atomic_list_concat(['resultados/', Nombre, '_orden_alquileres.csv'], RutaAlquileres),
    atomic_list_concat(['resultados/', Nombre, '_orden_carcel.csv'], RutaCarcel),
    atomic_list_concat(['resultados/', Nombre, '_balance_alquileres_por_jugador.csv'], RutaBalance).

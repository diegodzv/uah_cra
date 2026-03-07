% =========================
% main.pl
% Epica 2: dados pseudoaleatorios y movimiento
% =========================

:- initialization(banner).

:- use_module(tablero).
:- use_module(dados).
:- use_module(movimiento).
:- use_module(escenarios).
:- use_module(metricas).

banner :-
    nl,
    write('=========================================================='), nl,
    write(' MONOPOLY PROLOG - EPICA 2: DADOS Y MOVIMIENTO CIRCULAR '), nl,
    write('=========================================================='), nl,
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
    nl,
    write('Escenarios disponibles:'), nl,
    imprimir_lista(Nombres).

imprimir_lista([]).
imprimir_lista([X | R]) :-
    write(' - '), write(X), nl,
    imprimir_lista(R).

run_scenario(Nombre) :-
    escenarios:escenario(Nombre, escenario(NombreEscenario, Objetivo, PartidaInicial)),
    movimiento:simular_partida(PartidaInicial, PartidaFinal, Eventos),
    metricas:resumen_simulacion(PartidaFinal, Eventos, Resumen),
    nl,
    write('=== ESCENARIO ==='), nl,
    write('Nombre: '), write(NombreEscenario), nl,
    write('Objetivo: '), write(Objetivo), nl, nl,
    mostrar_resumen_escenario(PartidaInicial, PartidaFinal, Eventos, Resumen).

run_all_scenarios :-
    escenarios:nombres_escenarios(Nombres),
    run_all_scenarios_aux(Nombres).

run_all_scenarios_aux([]).
run_all_scenarios_aux([Nombre | Resto]) :-
    run_scenario(Nombre),
    nl,
    write('----------------------------------------------------------'), nl,
    run_all_scenarios_aux(Resto).

validar_tablero :-
    ( tablero:tablero_valido ->
        write('OK: el tablero es valido.'), nl
    ;   write('ERROR: el tablero NO es valido.'), nl
    ).

mostrar_resumen_escenario(PartidaInicial, PartidaFinal, Eventos, Resumen) :-
    write('--- CONFIGURACION INICIAL ---'), nl,
    mostrar_partida_inicial(PartidaInicial), nl,

    write('--- RESUMEN DE SIMULACION ---'), nl,
    metricas:imprimir_resumen_simulacion(Resumen), nl,

    write('--- POSICIONES FINALES ---'), nl,
    mostrar_jugadores_finales(PartidaFinal), nl,

    write('--- PRIMEROS 10 EVENTOS ---'), nl,
    mostrar_primeros_eventos(Eventos, 10), nl,

    write('--- ULTIMOS 10 EVENTOS ---'), nl,
    reverse(Eventos, EventosRev),
    mostrar_primeros_eventos(EventosRev, 10), nl,

    write('--- FRECUENCIAS GLOBALES POR CASILLA ---'), nl,
    mostrar_frecuencias_globales(Eventos), nl,

    write('--- FRECUENCIAS DE SUMA DE DADOS ---'), nl,
    mostrar_frecuencias_sumas(Eventos), nl,

    write('--- PASOS POR SALIDA POR JUGADOR ---'), nl,
    mostrar_pasos_salida(Eventos).

mostrar_partida_inicial(partida(_, _, Jugadores, TurnoActual, MaxTurnos, estado_dados(Semilla, _, _), historial(Etiqueta, _))) :-    write('Etiqueta: '), write(Etiqueta), nl,
    write('Turno actual inicial: '), write(TurnoActual), nl,
    write('Maximo de turnos: '), write(MaxTurnos), nl,
    write('Semilla de dados: '), write(Semilla), nl,
    write('Jugadores: '), nl,
    mostrar_jugadores_iniciales(Jugadores).

mostrar_jugadores_iniciales([]).
mostrar_jugadores_iniciales([jugador(Nombre, Posicion, Dinero, Propiedades, EnCarcel) | Resto]) :-
    length(Propiedades, NumProps),
    write(' - '), write(Nombre),
    write(' | Posicion inicial: '), write(Posicion),
    write(' | Dinero: '), write(Dinero),
    write(' | Propiedades: '), write(NumProps),
    write(' | En carcel: '), write(EnCarcel), nl,
    mostrar_jugadores_iniciales(Resto).

mostrar_jugadores_finales(partida(_, _, Jugadores, _, _, _, _)) :-
    mostrar_jugadores_finales_aux(Jugadores).

mostrar_jugadores_finales_aux([]).
mostrar_jugadores_finales_aux([jugador(Nombre, Posicion, Dinero, Propiedades, EnCarcel) | Resto]) :-
    length(Propiedades, NumProps),
    write(' - '), write(Nombre),
    write(' | Posicion final: '), write(Posicion),
    write(' | Dinero: '), write(Dinero),
    write(' | Propiedades: '), write(NumProps),
    write(' | En carcel: '), write(EnCarcel), nl,
    mostrar_jugadores_finales_aux(Resto).

mostrar_primeros_eventos(_, 0) :- !.
mostrar_primeros_eventos([], _) :- !.
mostrar_primeros_eventos([evento_turno(Turno, _, Jugador, D1, D2, Suma, PosAnterior, PosNueva, PasoSalida, CasillaDestino, NombreCasilla) | Resto], N) :-
    write('Turno '), write(Turno),
    write(' | Jugador='), write(Jugador),
    write(' | Dados='), write(D1), write('+'), write(D2),
    write(' | Suma='), write(Suma),
    write(' | '), write(PosAnterior), write(' -> '), write(PosNueva),
    write(' | PasoSalida='), write(PasoSalida),
    write(' | Casilla='), write(CasillaDestino), write(' ('), write(NombreCasilla), write(')'), nl,
    N2 is N - 1,
    mostrar_primeros_eventos(Resto, N2).

mostrar_frecuencias_globales(Eventos) :-
    mostrar_frecuencias_globales_aux(1, 40, Eventos).

mostrar_frecuencias_globales_aux(Pos, Max, _) :-
    Pos > Max, !.
mostrar_frecuencias_globales_aux(Pos, Max, Eventos) :-
    tablero:tablero(Tablero),
    tablero:casilla_en_posicion(Pos, Tablero, casilla(_, _, NombreCasilla, _, _)),
    contar_visitas_posicion(Eventos, Pos, Visitas),
    write(' - ['), write(Pos), write('] '), write(NombreCasilla), write(': '), write(Visitas), nl,
    Pos2 is Pos + 1,
    mostrar_frecuencias_globales_aux(Pos2, Max, Eventos).

contar_visitas_posicion(Eventos, Posicion, Total) :-
    include(visita_a_posicion(Posicion), Eventos, Filtrados),
    length(Filtrados, Total).

visita_a_posicion(Posicion, evento_turno(_, _, _, _, _, _, _, Posicion, _, _, _)).

mostrar_frecuencias_sumas(Eventos) :-
    mostrar_frecuencias_sumas_aux(2, 12, Eventos).

mostrar_frecuencias_sumas_aux(Suma, Max, _) :-
    Suma > Max, !.
mostrar_frecuencias_sumas_aux(Suma, Max, Eventos) :-
    contar_suma(Eventos, Suma, Frecuencia),
    write(' - Suma '), write(Suma), write(': '), write(Frecuencia), nl,
    Suma2 is Suma + 1,
    mostrar_frecuencias_sumas_aux(Suma2, Max, Eventos).

contar_suma(Eventos, Suma, Total) :-
    include(es_suma(Suma), Eventos, Filtrados),
    length(Filtrados, Total).

es_suma(Suma, evento_turno(_, _, _, _, _, Suma, _, _, _, _, _)).

mostrar_pasos_salida(Eventos) :-
    jugadores_distintos(Eventos, Jugadores),
    mostrar_pasos_salida_aux(Jugadores, Eventos).

mostrar_pasos_salida_aux([], _).
mostrar_pasos_salida_aux([Jugador | Resto], Eventos) :-
    contar_pasos_salida_jugador(Eventos, Jugador, Total),
    write(' - '), write(Jugador), write(': '), write(Total), nl,
    mostrar_pasos_salida_aux(Resto, Eventos).

jugadores_distintos(Eventos, Jugadores) :-
    findall(Jugador, member(evento_turno(_, _, Jugador, _, _, _, _, _, _, _, _), Eventos), Lista),
    sort(Lista, Jugadores).

contar_pasos_salida_jugador(Eventos, Jugador, Total) :-
    include(es_paso_salida_jugador(Jugador), Eventos, Filtrados),
    length(Filtrados, Total).

es_paso_salida_jugador(Jugador, evento_turno(_, _, Jugador, _, _, _, _, _, si, _, _)).

export_scenario_csv(Nombre) :-
    escenarios:escenario(Nombre, escenario(_, _, PartidaInicial)),
    movimiento:simular_partida(PartidaInicial, PartidaFinal, Eventos),
    metricas:resumen_simulacion(PartidaFinal, Eventos, Resumen),
    construir_rutas_csv(Nombre, RutaEventos, RutaVisitasGlobales, RutaVisitasJugador, RutaSumas, RutaSalida, RutaResumen),
    metricas:exportar_eventos_csv(RutaEventos, Eventos),
    metricas:exportar_visitas_globales_csv(RutaVisitasGlobales, Eventos),
    metricas:exportar_visitas_por_jugador_csv(RutaVisitasJugador, Eventos),
    metricas:exportar_sumas_dados_csv(RutaSumas, Eventos),
    metricas:exportar_pasos_salida_csv(RutaSalida, Eventos),
    metricas:exportar_resumen_csv(RutaResumen, Resumen),
    nl,
    write('CSV exportados para escenario: '), write(Nombre), nl.

export_all_csv :-
    escenarios:nombres_escenarios(Nombres),
    export_all_csv_aux(Nombres).

export_all_csv_aux([]).
export_all_csv_aux([Nombre | Resto]) :-
    export_scenario_csv(Nombre),
    export_all_csv_aux(Resto).

construir_rutas_csv(Nombre, RutaEventos, RutaVisitasGlobales, RutaVisitasJugador, RutaSumas, RutaSalida, RutaResumen) :-
    atomic_list_concat(['resultados/', Nombre, '_eventos.csv'], RutaEventos),
    atomic_list_concat(['resultados/', Nombre, '_visitas_globales.csv'], RutaVisitasGlobales),
    atomic_list_concat(['resultados/', Nombre, '_visitas_por_jugador.csv'], RutaVisitasJugador),
    atomic_list_concat(['resultados/', Nombre, '_sumas_dados.csv'], RutaSumas),
    atomic_list_concat(['resultados/', Nombre, '_pasos_salida.csv'], RutaSalida),
    atomic_list_concat(['resultados/', Nombre, '_resumen.csv'], RutaResumen).

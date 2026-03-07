% =========================
% escenarios.pl
% Epica 4: escenarios con compra automatica y alquileres
% =========================

:- module(escenarios, [
    escenario/2,
    nombres_escenarios/1
]).

:- use_module(tablero).
:- use_module(dados).

dinero_inicial_epica4(10000).
politica_compra_base(comprar_si_tiene_fondos).

escenario(alquiler_2j_50t_semilla_3,
    escenario(
        alquiler_2j_50t_semilla_3,
        '2 jugadores, 50 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], Dinero, 50, alquiler_2j_50t_semilla_3, EstadoDados, Politica, Partida).

escenario(alquiler_2j_100t_semilla_3,
    escenario(
        alquiler_2j_100t_semilla_3,
        '2 jugadores, 100 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], Dinero, 100, alquiler_2j_100t_semilla_3, EstadoDados, Politica, Partida).

escenario(alquiler_2j_200t_semilla_3,
    escenario(
        alquiler_2j_200t_semilla_3,
        '2 jugadores, 200 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], Dinero, 200, alquiler_2j_200t_semilla_3, EstadoDados, Politica, Partida).

escenario(alquiler_4j_60t_semilla_7,
    escenario(
        alquiler_4j_60t_semilla_7,
        '4 jugadores, 60 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], Dinero, 60, alquiler_4j_60t_semilla_7, EstadoDados, Politica, Partida).

escenario(alquiler_4j_200t_semilla_7,
    escenario(
        alquiler_4j_200t_semilla_7,
        '4 jugadores, 200 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], Dinero, 200, alquiler_4j_200t_semilla_7, EstadoDados, Politica, Partida).

escenario(alquiler_4j_400t_semilla_7,
    escenario(
        alquiler_4j_400t_semilla_7,
        '4 jugadores, 400 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], Dinero, 400, alquiler_4j_400t_semilla_7, EstadoDados, Politica, Partida).

escenario(alquiler_10j_100t_semilla_11,
    escenario(
        alquiler_10j_100t_semilla_11,
        '10 jugadores, 100 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial([ana,bob,carla,diego,elena,fernando,gema,hugo,irene,javier], Dinero, 100, alquiler_10j_100t_semilla_11, EstadoDados, Politica, Partida).

escenario(alquiler_10j_200t_semilla_11,
    escenario(
        alquiler_10j_200t_semilla_11,
        '10 jugadores, 200 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial([ana,bob,carla,diego,elena,fernando,gema,hugo,irene,javier], Dinero, 200, alquiler_10j_200t_semilla_11, EstadoDados, Politica, Partida).

escenario(alquiler_10j_1000t_semilla_11,
    escenario(
        alquiler_10j_1000t_semilla_11,
        '10 jugadores, 1000 turnos, compra automatica y alquileres.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial([ana,bob,carla,diego,elena,fernando,gema,hugo,irene,javier], Dinero, 1000, alquiler_10j_1000t_semilla_11, EstadoDados, Politica, Partida).

escenario(alquiler_2j_200t_semilla_19,
    escenario(
        alquiler_2j_200t_semilla_19,
        '2 jugadores, 200 turnos, compra automatica y alquileres, semilla alternativa.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(19, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], Dinero, 200, alquiler_2j_200t_semilla_19, EstadoDados, Politica, Partida).

escenario(alquiler_4j_400t_semilla_19,
    escenario(
        alquiler_4j_400t_semilla_19,
        '4 jugadores, 400 turnos, compra automatica y alquileres, semilla alternativa.',
        Partida
    )
) :-
    dinero_inicial_epica4(Dinero),
    politica_compra_base(Politica),
    dados:crear_estado_dados(19, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], Dinero, 400, alquiler_4j_400t_semilla_19, EstadoDados, Politica, Partida).

nombres_escenarios([
    alquiler_2j_50t_semilla_3,
    alquiler_2j_100t_semilla_3,
    alquiler_2j_200t_semilla_3,
    alquiler_4j_60t_semilla_7,
    alquiler_4j_200t_semilla_7,
    alquiler_4j_400t_semilla_7,
    alquiler_10j_100t_semilla_11,
    alquiler_10j_200t_semilla_11,
    alquiler_10j_1000t_semilla_11,
    alquiler_2j_200t_semilla_19,
    alquiler_4j_400t_semilla_19
]).

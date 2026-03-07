% =========================
% escenarios.pl
% Epica 2: escenarios de simulacion de dados y movimiento
% =========================

:- module(escenarios, [
    escenario/2,
    nombres_escenarios/1,
    describir_escenario/2
]).

:- use_module(tablero).
:- use_module(dados).

% escenario(
%   Nombre,
%   Objetivo,
%   PartidaInicial
% )

escenario(validacion_basica_2j_10t,
    escenario(
        validacion_basica_2j_10t,
        'Valida el movimiento basico con 2 jugadores durante 10 turnos y una semilla simple.',
        Partida
    )
) :-
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], 10, validacion_basica_2j_10t, EstadoDados, Partida).

escenario(cobertura_2j_100t_semilla_3,
    escenario(
        cobertura_2j_100t_semilla_3,
        'Mide cobertura y frecuencia de visita por casilla con 2 jugadores y 100 turnos.',
        Partida
    )
) :-
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], 100, cobertura_2j_100t_semilla_3, EstadoDados, Partida).

escenario(cobertura_8j_1000t_semilla_7,
    escenario(
        cobertura_8j_1000t_semilla_7,
        'Mide cobertura global del tablero y estabilidad del movimiento con 8 jugadores y 1000 turnos.',
        Partida
    )
) :-
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego, elena, fernando, gema, hugo], 1000, cobertura_8j_1000t_semilla_7, EstadoDados, Partida).

escenario(comparativa_4j_100t_semilla_11,
    escenario(
        comparativa_4j_100t_semilla_11,
        'Primera partida de comparacion: 4 jugadores y 100 turnos con semilla 11.',
        Partida
    )
) :-
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], 100, comparativa_4j_100t_semilla_11, EstadoDados, Partida).

escenario(comparativa_4j_100t_semilla_29,
    escenario(
        comparativa_4j_100t_semilla_29,
        'Segunda partida de comparacion: 4 jugadores y 100 turnos con semilla 29.',
        Partida
    )
) :-
    dados:crear_estado_dados(29, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], 100, comparativa_4j_100t_semilla_29, EstadoDados, Partida).

escenario(paso_salida_forzado,
    escenario(
        paso_salida_forzado,
        'Valida explicitamente el movimiento circular y el paso por salida con una semilla que genera recorridos largos.',
        Partida
    )
) :-
    dados:crear_estado_dados(41, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], 30, paso_salida_forzado, EstadoDados, Partida).

escenario(cobertura_6j_2000t_semilla_17,
    escenario(
        cobertura_6j_2000t_semilla_17,
        'Mide cobertura intensiva del tablero con 6 jugadores y 2000 turnos, incluyendo frecuencia de visita por casilla y frecuencia de sumas de dados.',
        Partida
    )
) :-
    dados:crear_estado_dados(17, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego, elena, fernando], 2000, cobertura_6j_2000t_semilla_17, EstadoDados, Partida).

nombres_escenarios([
    validacion_basica_2j_10t,
    cobertura_2j_100t_semilla_3,
    cobertura_8j_1000t_semilla_7,
    cobertura_6j_2000t_semilla_17,
    comparativa_4j_100t_semilla_11,
    comparativa_4j_100t_semilla_29,
    paso_salida_forzado
]).

describir_escenario(Nombre, Descripcion) :-
    escenario(Nombre, escenario(_, Descripcion, _)).

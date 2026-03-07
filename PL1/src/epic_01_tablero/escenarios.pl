% =========================
% escenarios.pl
% Epica 1: escenarios de validacion del modelo
% =========================

:- module(escenarios, [
    escenario/2,
    nombres_escenarios/1,
    describir_escenario/2
]).

:- use_module(tablero).

% ------------------------------------------------------------------
% Cada escenario devuelve una estructura:
%
% escenario(
%   NombreEscenario,
%   Objetivo,
%   Partida
% )
% ------------------------------------------------------------------

escenario(tablero_base,
    escenario(
        tablero_base,
        'Valida la representacion base del tablero de 40 casillas y una partida vacia de referencia.',
        Partida
    )
) :-
    tablero:crear_partida_inicial([ana, bob], 0, tablero_base, Partida).

escenario(dos_jugadores_inicio,
    escenario(
        dos_jugadores_inicio,
        'Estado inicial minimo con dos jugadores y el banco como propietario de todos los activos.',
        Partida
    )
) :-
    tablero:crear_partida_inicial([ana, bob], 20, dos_jugadores_inicio, Partida).

escenario(cuatro_jugadores_inicio,
    escenario(
        cuatro_jugadores_inicio,
        'Estado inicial con cuatro jugadores para validar escalabilidad basica de la representacion.',
        Partida
    )
) :-
    tablero:crear_partida_inicial([ana, bob, carla, diego], 50, cuatro_jugadores_inicio, Partida).

escenario(ocho_jugadores_inicio,
    escenario(
        ocho_jugadores_inicio,
        'Estado inicial con ocho jugadores para comprobar que la estructura soporta partidas mas grandes.',
        Partida
    )
) :-
    tablero:crear_partida_inicial([ana, bob, carla, diego, elena, fernando, gema, hugo], 100, ocho_jugadores_inicio, Partida).

escenario(validacion_estructura,
    escenario(
        validacion_estructura,
        'Escenario orientado a comprobar integridad: 40 casillas, indices consecutivos y casillas especiales clave.',
        Partida
    )
) :-
    tablero:crear_partida_inicial([ana, bob], 1, validacion_estructura, Partida).

nombres_escenarios([
    tablero_base,
    dos_jugadores_inicio,
    cuatro_jugadores_inicio,
    ocho_jugadores_inicio,
    validacion_estructura
]).

describir_escenario(Nombre, Descripcion) :-
    escenario(Nombre, escenario(_, Descripcion, _)).

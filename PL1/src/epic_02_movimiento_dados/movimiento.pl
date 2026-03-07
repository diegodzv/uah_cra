% =========================
% movimiento.pl
% Epica 2: simulacion de turnos y movimiento
% =========================

:- module(movimiento, [
    simular_partida/3,
    simular_turno/3,
    mover_jugador/8
]).

:- use_module(tablero).
:- use_module(dados).

% ------------------------------------------------------------------
% simular_partida(+PartidaInicial, -PartidaFinal, -Eventos)
% Ejecuta MaxTurnos turnos totales.
% Cada turno mueve a un solo jugador, en orden circular.
% ------------------------------------------------------------------

simular_partida(PartidaInicial, PartidaFinal, Eventos) :-
    PartidaInicial = partida(_, _, _, _, MaxTurnos, _, _),
    simular_n_turnos(PartidaInicial, MaxTurnos, 1, PartidaFinal, [], EventosRev),
    reverse(EventosRev, Eventos).

simular_n_turnos(Partida, MaxTurnos, TurnoActual, Partida, EventosAcc, EventosAcc) :-
    TurnoActual > MaxTurnos, !.
simular_n_turnos(Partida0, MaxTurnos, TurnoActual, PartidaFinal, EventosAcc, EventosFinal) :-
    simular_turno(Partida0, Partida1, Evento),
    TurnoSiguiente is TurnoActual + 1,
    simular_n_turnos(Partida1, MaxTurnos, TurnoSiguiente, PartidaFinal, [Evento|EventosAcc], EventosFinal).

% ------------------------------------------------------------------
% simular_turno(+Partida0, -Partida1, -Evento)
% ------------------------------------------------------------------

simular_turno(
    partida(Tablero, Banco, Jugadores0, TurnoActual, MaxTurnos, EstadoDados0, historial(Etiqueta, Historial0)),
    partida(Tablero, Banco, Jugadores1, TurnoSiguiente, MaxTurnos, EstadoDados1, historial(Etiqueta, [Evento|Historial0])),
    Evento
) :-
    length(Jugadores0, NumJugadores),
    NumJugadores > 0,
    IndiceJugador is ((TurnoActual - 1) mod NumJugadores) + 1,
    nth1(IndiceJugador, Jugadores0, JugadorActual, RestoJugadores),
    JugadorActual = jugador(Nombre, PosAnterior, Dinero, Props, EnCarcel),

    dados:tirar_dos_dados(EstadoDados0, D1, D2, EstadoDados1),
    Suma is D1 + D2,

    mover_jugador(Nombre, PosAnterior, Suma, Tablero, PosNueva, PasoSalida, CasillaDestino, NombreCasilla),

    JugadorActualizado = jugador(Nombre, PosNueva, Dinero, Props, EnCarcel),
    nth1(IndiceJugador, Jugadores1, JugadorActualizado, RestoJugadores),

    Evento = evento_turno(
        TurnoActual,
        IndiceJugador,
        Nombre,
        D1,
        D2,
        Suma,
        PosAnterior,
        PosNueva,
        PasoSalida,
        CasillaDestino,
        NombreCasilla
    ),

    TurnoSiguiente is TurnoActual + 1.

% ------------------------------------------------------------------
% mover_jugador(
%   +NombreJugador,
%   +PosAnterior,
%   +SumaDados,
%   +Tablero,
%   -PosNueva,
%   -PasoSalida,
%   -IndiceCasillaDestino,
%   -NombreCasillaDestino
% )
% ------------------------------------------------------------------

mover_jugador(_NombreJugador, PosAnterior, SumaDados, Tablero, PosNueva, PasoSalida, PosNueva, NombreCasilla) :-
    tablero:tablero_size(Tam),
    PosBase is PosAnterior - 1,
    PosNueva is ((PosBase + SumaDados) mod Tam) + 1,
    (
        PosAnterior + SumaDados > Tam
        -> PasoSalida = si
        ;  PasoSalida = no
    ),
    tablero:casilla_en_posicion(PosNueva, Tablero, casilla(_, _, NombreCasilla, _, _)).

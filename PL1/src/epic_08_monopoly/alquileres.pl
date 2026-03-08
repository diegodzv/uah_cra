% =========================
% alquileres.pl
% Epica 8: logica de alquileres con casas
% =========================

:- module(alquileres, [
    aplicar_alquiler_si_procede/9
]).

:- use_module(tablero).

aplicar_alquiler_si_procede(_Turno, _NombreJugador, Casilla, JugadoresIn, JugadoresIn, no, sin_alquiler, 0, 0) :-
    \+ tablero:es_casilla_comprable(Casilla), !.

aplicar_alquiler_si_procede(_Turno, NombreJugador, casilla(_, _, NombreCasilla, _, _), JugadoresIn, JugadoresIn, no, sin_alquiler, 0, 0) :-
    propietario_de_casilla(JugadoresIn, NombreCasilla, NombreJugador, _), !.

aplicar_alquiler_si_procede(_Turno, _NombreJugador, casilla(_, _, NombreCasilla, _, _), JugadoresIn, JugadoresIn, no, sin_alquiler, 0, 0) :-
    \+ propietario_de_casilla(JugadoresIn, NombreCasilla, _, _), !.

aplicar_alquiler_si_procede(Turno, NombreJugador, casilla(_, Tipo, NombreCasilla, PrecioCasilla, Color), JugadoresIn, JugadoresOut, si, EventoAlquiler, AlquilerTeorico, PagoReal) :-
    propietario_de_casilla(JugadoresIn, NombreCasilla, NombrePropietario, JugadorPropietario),
    NombrePropietario \== NombreJugador,
    jugador_por_nombre(JugadoresIn, NombreJugador, JugadorPagador),

    JugadorPagador = jugador(NombreJugador, PosPag, DinPagAntes, PropsPag, EstadoPag),
    JugadorPropietario = jugador(NombrePropietario, PosCob, DinCobAntes, PropsCob, EstadoCob),

    casas_propiedad(PropsCob, NombreCasilla, NumCasas),
    AlquilerBase is PrecioCasilla // 5,
    IncrementoCasas is NumCasas * 20,
    AlquilerTeorico is AlquilerBase + IncrementoCasas,
    PagoReal = AlquilerTeorico,

    DinPagDespues is DinPagAntes - PagoReal,
    DinCobDespues is DinCobAntes + PagoReal,

    JugadorPagador2 = jugador(NombreJugador, PosPag, DinPagDespues, PropsPag, EstadoPag),
    JugadorPropietario2 = jugador(NombrePropietario, PosCob, DinCobDespues, PropsCob, EstadoCob),

    reemplazar_jugador_por_nombre(JugadoresIn, NombreJugador, JugadorPagador2, JugadoresTmp),
    reemplazar_jugador_por_nombre(JugadoresTmp, NombrePropietario, JugadorPropietario2, JugadoresOut),

    EventoAlquiler = evento_alquiler(
        Turno,
        NombreJugador,
        NombrePropietario,
        NombreCasilla,
        Tipo,
        Color,
        PrecioCasilla,
        NumCasas,
        AlquilerTeorico,
        PagoReal,
        DinPagAntes,
        DinPagDespues,
        DinCobAntes,
        DinCobDespues
    ).

casas_propiedad([prop(NombreCasilla, _, _, _, Casas)|_], NombreCasilla, Casas) :- !.
casas_propiedad([_|R], NombreCasilla, Casas) :-
    casas_propiedad(R, NombreCasilla, Casas).
casas_propiedad([], _, 0).

propietario_de_casilla([Jugador|_], NombreCasilla, Nombre, Jugador) :-
    Jugador = jugador(Nombre, _, _, Props, _),
    tiene_propiedad(Props, NombreCasilla), !.
propietario_de_casilla([_|R], NombreCasilla, Nombre, Jugador) :-
    propietario_de_casilla(R, NombreCasilla, Nombre, Jugador).

tiene_propiedad([prop(NombreCasilla, _, _, _, _)|_], NombreCasilla) :- !.
tiene_propiedad([_|R], NombreCasilla) :-
    tiene_propiedad(R, NombreCasilla).

jugador_por_nombre([jugador(Nombre, Pos, Din, Props, Estado)|_], Nombre, jugador(Nombre, Pos, Din, Props, Estado)) :- !.
jugador_por_nombre([_|R], Nombre, Jugador) :-
    jugador_por_nombre(R, Nombre, Jugador).

reemplazar_jugador_por_nombre([], _, _, []).
reemplazar_jugador_por_nombre([jugador(Nombre, _, _, _, _)|R], Nombre, JugadorNuevo, [JugadorNuevo|R]) :- !.
reemplazar_jugador_por_nombre([X|R], Nombre, JugadorNuevo, [X|R2]) :-
    reemplazar_jugador_por_nombre(R, Nombre, JugadorNuevo, R2).

% =========================
% alquileres.pl
% Epica 4: logica de alquileres
% =========================

:- module(alquileres, [
    resolver_alquiler_si_procede/12,
    alquiler_teorico_casilla/2
]).

:- use_module(tablero).

% resolver_alquiler_si_procede(
%   +Turno,
%   +CompraRealizada,
%   +Casilla,
%   +JugadorActualIn,
%   +OtrosJugadoresIn,
%   -JugadorActualOut,
%   -OtrosJugadoresOut,
%   -AlquilerRealizado,
%   -EventoAlquiler,
%   -AlquilerTeorico,
%   -PagoReal,
%   -DineroFinalJugador
% )

resolver_alquiler_si_procede(_Turno, si, _Casilla, JugadorIn, OtrosIn,
    JugadorIn, OtrosIn, no, sin_alquiler, 0, 0, DineroFinal) :-
    JugadorIn = jugador(_, _, DineroFinal, _, _), !.

resolver_alquiler_si_procede(_Turno, _CompraRealizada, Casilla, JugadorIn, OtrosIn,
    JugadorIn, OtrosIn, no, sin_alquiler, 0, 0, DineroFinal) :-
    \+ tablero:es_casilla_comprable(Casilla),
    JugadorIn = jugador(_, _, DineroFinal, _, _), !.

resolver_alquiler_si_procede(Turno, _CompraRealizada, Casilla, JugadorIn, OtrosIn,
    JugadorOut, OtrosOut, AlquilerRealizado, EventoAlquiler, AlquilerTeorico, PagoReal, DineroFinalJugador) :-
    JugadorIn = jugador(NombrePagador, Pos, DineroAntes, PropsPagador, EnCarcel),
    Casilla = casilla(_, TipoCasilla, NombreCasilla, PrecioCasilla, ColorCasilla),
    ( buscar_duenio_activo(OtrosIn, NombreCasilla, Duenio, OtrosSinDuenio, IndiceDuenio) ->
        alquiler_teorico_casilla(Casilla, AlquilerTeorico),
        PagoReal is min(DineroAntes, AlquilerTeorico),
        DineroFinalJugador is DineroAntes - PagoReal,
        JugadorOut = jugador(NombrePagador, Pos, DineroFinalJugador, PropsPagador, EnCarcel),

        Duenio = jugador(NombreDuenio, PosDuenio, DineroDuenioAntes, PropsDuenio, CarcelDuenio),
        DineroDuenioDespues is DineroDuenioAntes + PagoReal,
        DuenioActualizado = jugador(NombreDuenio, PosDuenio, DineroDuenioDespues, PropsDuenio, CarcelDuenio),
        reinsertar_en_indice(OtrosSinDuenio, IndiceDuenio, DuenioActualizado, OtrosOut),

        AlquilerRealizado = si,
        EventoAlquiler = evento_alquiler(
            Turno,
            NombrePagador,
            NombreDuenio,
            NombreCasilla,
            TipoCasilla,
            ColorCasilla,
            PrecioCasilla,
            AlquilerTeorico,
            PagoReal,
            DineroAntes,
            DineroFinalJugador,
            DineroDuenioAntes,
            DineroDuenioDespues
        )
    ;   JugadorOut = JugadorIn,
        OtrosOut = OtrosIn,
        AlquilerRealizado = no,
        EventoAlquiler = sin_alquiler,
        AlquilerTeorico = 0,
        PagoReal = 0,
        DineroFinalJugador = DineroAntes
    ).

alquiler_teorico_casilla(casilla(_, propiedad, _, Precio, _), Alquiler) :-
    Alquiler is Precio // 5.
alquiler_teorico_casilla(casilla(_, estacion, _, Precio, _), Alquiler) :-
    Alquiler is Precio // 5.

buscar_duenio_activo(Jugadores, NombreActivo, Duenio, RestoSinDuenio, Indice) :-
    buscar_duenio_activo_aux(Jugadores, NombreActivo, 1, Duenio, RestoSinDuenio, Indice).

buscar_duenio_activo_aux([], _, _, _, _, _) :- fail.
buscar_duenio_activo_aux([J|R], NombreActivo, I, J, R, I) :-
    jugador_posee_activo(J, NombreActivo), !.
buscar_duenio_activo_aux([J|R], NombreActivo, I, Duenio, [J|R2], Indice) :-
    I2 is I + 1,
    buscar_duenio_activo_aux(R, NombreActivo, I2, Duenio, R2, Indice).

jugador_posee_activo(jugador(_, _, _, Props, _), NombreActivo) :-
    member(prop(NombreActivo, _, _, _, _), Props).

reinsertar_en_indice(Lista, 1, Elem, [Elem|Lista]) :- !.
reinsertar_en_indice([X|R], Indice, Elem, [X|R2]) :-
    Indice > 1,
    I2 is Indice - 1,
    reinsertar_en_indice(R, I2, Elem, R2).

% =========================
% parking.pl
% Epica 7: cobro del parking gratuito
% =========================

:- module(parking, [
    aplicar_parking_si_procede/8
]).

aplicar_parking_si_procede(_Turno, JugadorIn, casilla(_, Tipo, _, _, _), BancoIn,
    JugadorIn, BancoIn, no, sin_parking) :-
    Tipo \== parking, !.

aplicar_parking_si_procede(Turno,
    jugador(Nombre, Pos, DineroAntes, Props, EstadoCarcel),
    casilla(_, parking, parking, _, _),
    banco(DinBanco, Activos, Casas, Hoteles, CajaAntes),
    jugador(Nombre, Pos, DineroDespues, Props, EstadoCarcel),
    banco(DinBanco, Activos, Casas, Hoteles, CajaDespues),
    si,
    evento_parking(Turno, Nombre, CajaAntes, Premio, CajaDespues, DineroAntes, DineroDespues)
) :-
    Premio is CajaAntes // 2,
    CajaDespues is CajaAntes - Premio,
    DineroDespues is DineroAntes + Premio.

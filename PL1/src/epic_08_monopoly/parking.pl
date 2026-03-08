% =========================
% parking.pl
% Epica 8: parking gratuito
% =========================

:- module(parking, [
    aplicar_parking_si_procede/8
]).

aplicar_parking_si_procede(
    _Turno,
    BancoIn,
    JugadorIn,
    casilla(_, Tipo, _, _, _),
    BancoIn,
    JugadorIn,
    no,
    sin_parking
) :-
    Tipo \== parking, !.

aplicar_parking_si_procede(
    Turno,
    banco(DinBanco, Activos, CasasBanco, HotelesBanco, CajaAntes),
    jugador(Nombre, Pos, DineroAntes, Props, EstadoCarcel),
    casilla(_, parking, parking, _, _),
    banco(DinBanco, Activos, CasasBanco, HotelesBanco, CajaDespues),
    jugador(Nombre, Pos, DineroDespues, Props, EstadoCarcel),
    si,
    evento_parking(Turno, Nombre, CajaAntes, Premio, CajaDespues, DineroAntes, DineroDespues)
) :-
    Premio is CajaAntes // 2,
    CajaDespues is CajaAntes - Premio,
    DineroDespues is DineroAntes + Premio.

% =========================
% impuestos.pl
% Epica 7: impuestos que alimentan la caja del parking
% =========================

:- module(impuestos, [
    aplicar_impuesto_si_procede/8
]).

aplicar_impuesto_si_procede(_Turno, JugadorIn, casilla(_, Tipo, _, _, _), BancoIn,
    JugadorIn, BancoIn, no, sin_impuesto) :-
    Tipo \== impuesto, !.

aplicar_impuesto_si_procede(Turno,
    jugador(Nombre, Pos, DineroAntes, Props, EstadoCarcel),
    casilla(_, impuesto, NombreCasilla, Importe, _),
    banco(DinBanco, Activos, Casas, Hoteles, CajaAntes),
    jugador(Nombre, Pos, DineroDespues, Props, EstadoCarcel),
    banco(DinBanco, Activos, Casas, Hoteles, CajaDespues),
    si,
    evento_impuesto(Turno, Nombre, NombreCasilla, Importe, DineroAntes, DineroDespues, CajaAntes, CajaDespues)
) :-
    DineroDespues is DineroAntes - Importe,
    CajaDespues is CajaAntes + Importe.

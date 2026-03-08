% =========================
% impuestos.pl
% Epica 8: logica de impuestos con caja de parking
% =========================

:- module(impuestos, [
    aplicar_impuesto_si_procede/8
]).

aplicar_impuesto_si_procede(
    _Turno,
    BancoIn,
    JugadorIn,
    casilla(_, Tipo, _, _, _),
    BancoIn,
    JugadorIn,
    no,
    sin_impuesto
) :-
    Tipo \== impuesto, !.

aplicar_impuesto_si_procede(
    Turno,
    banco(DinBanco, Activos, CasasBanco, HotelesBanco, CajaAntes),
    jugador(Nombre, Pos, DineroAntes, Props, EstadoCarcel),
    casilla(_, impuesto, NombreCasilla, Importe, _),
    banco(DinBanco, Activos, CasasBanco, HotelesBanco, CajaDespues),
    jugador(Nombre, Pos, DineroDespues, Props, EstadoCarcel),
    si,
    evento_impuesto(Turno, Nombre, NombreCasilla, Importe, DineroAntes, DineroDespues, CajaAntes, CajaDespues)
) :-
    DineroDespues is DineroAntes - Importe,
    CajaDespues is CajaAntes + Importe.

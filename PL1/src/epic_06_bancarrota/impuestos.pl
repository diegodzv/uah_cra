% =========================
% impuestos.pl
% Epica 6: logica basica de impuestos
% =========================

:- module(impuestos, [
    aplicar_impuesto_si_procede/6
]).

aplicar_impuesto_si_procede(_Turno, JugadorIn, casilla(_, Tipo, _, _, _), JugadorIn, no, sin_impuesto) :-
    Tipo \== impuesto, !.

aplicar_impuesto_si_procede(
    Turno,
    jugador(Nombre, Pos, DineroAntes, Props, EstadoCarcel),
    casilla(_, impuesto, NombreCasilla, Importe, _),
    jugador(Nombre, Pos, DineroDespues, Props, EstadoCarcel),
    si,
    evento_impuesto(Turno, Nombre, NombreCasilla, Importe, DineroAntes, DineroDespues)
) :-
    DineroDespues is DineroAntes - Importe.

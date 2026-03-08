% =========================
% compras.pl
% Epica 7: logica de compra automatica
% =========================

:- module(compras, [
    aplicar_compra_si_procede/11
]).

:- use_module(tablero).

aplicar_compra_si_procede(_Turno, _PoliticaCompra, JugadorIn, Casilla, BancoIn,
    JugadorIn, BancoIn, no, sin_compra, Dinero, Dinero) :-
    JugadorIn = jugador(_, _, Dinero, _, _),
    \+ tablero:es_casilla_comprable(Casilla), !.

aplicar_compra_si_procede(_Turno, _PoliticaCompra, JugadorIn, _Casilla, BancoIn,
    JugadorIn, BancoIn, no, sin_compra, Dinero, Dinero) :-
    JugadorIn = jugador(_, _, Dinero, _, _),
    BancoIn = banco(_, [], _, _, _), !.

aplicar_compra_si_procede(Turno, comprar_si_tiene_fondos, JugadorIn, casilla(Pos, Tipo, Nombre, Precio, Color), BancoIn,
    JugadorOut, BancoOut, CompraRealizada, EventoCompra, DineroAntes, DineroDespues) :-
    JugadorIn = jugador(NombreJugador, PosJug, DineroAntes, Props, EstadoCarcel),
    ( banco_posee_activo(BancoIn, Nombre, Activo) ->
        ( DineroAntes >= Precio ->
            quitar_activo_banco(BancoIn, Nombre, BancoTmp),
            agregar_propiedad_jugador(Props, Activo, Props2),
            DineroDespues is DineroAntes - Precio,
            JugadorOut = jugador(NombreJugador, PosJug, DineroDespues, Props2, EstadoCarcel),
            BancoOut = BancoTmp,
            CompraRealizada = si,
            EventoCompra = evento_compra(Turno, NombreJugador, Pos, Nombre, Tipo, Color, Precio, DineroAntes, DineroDespues)
        ;   JugadorOut = JugadorIn,
            BancoOut = BancoIn,
            CompraRealizada = no,
            EventoCompra = sin_compra,
            DineroDespues = DineroAntes
        )
    ;   JugadorOut = JugadorIn,
        BancoOut = BancoIn,
        CompraRealizada = no,
        EventoCompra = sin_compra,
        DineroDespues = DineroAntes
    ).

banco_posee_activo(banco(_, Activos, _, _, _), Nombre, Activo) :-
    member(Activo, Activos),
    Activo = activo(Nombre, _, _, _, _).

quitar_activo_banco(banco(Dinero, Activos, Casas, Hoteles, CajaParking), Nombre, banco(Dinero, Activos2, Casas, Hoteles, CajaParking)) :-
    quitar_activo_lista(Activos, Nombre, Activos2).

quitar_activo_lista([], _, []).
quitar_activo_lista([activo(Nombre, _, _, _, _)|R], Nombre, R) :- !.
quitar_activo_lista([X|R], Nombre, [X|R2]) :-
    quitar_activo_lista(R, Nombre, R2).

agregar_propiedad_jugador(Props, activo(Nombre, Tipo, Precio, Color, Casas), [prop(Nombre, Tipo, Precio, Color, Casas)|Props]).

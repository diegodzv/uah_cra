% =========================
% bancarrota.pl
% Epica 7: logica de bancarrota y eliminacion
% =========================

:- module(bancarrota, [
    resolver_bancarrota_si_procede/10
]).

resolver_bancarrota_si_procede(_Turno, _Causa, NombreJugador, JugadoresIn, BancoIn, JugadoresIn, BancoIn, no, sin_bancarrota, no) :-
    jugador_por_nombre(JugadoresIn, NombreJugador, jugador(_, _, Dinero, _, _)),
    nonvar(Dinero),
    Dinero >= 0, !.

resolver_bancarrota_si_procede(Turno, Causa, NombreJugador, JugadoresIn, BancoIn, JugadoresOut, BancoOut, si, EventoBancarrota, JugadorEliminado) :-
    jugador_por_nombre(JugadoresIn, NombreJugador, Jugador),
    Jugador = jugador(NombreJugador, Pos, DineroAntes, Props, EstadoCarcel),
    nonvar(DineroAntes),
    DineroAntes < 0,
    liquidar_propiedades(Props, ValorLiquidacion, PropsBanco, NumProps),
    DineroDespues is DineroAntes + ValorLiquidacion,
    anexar_props_banco(BancoIn, PropsBanco, BancoTmp),
    ( DineroDespues >= 0 ->
        JugadorNuevo = jugador(NombreJugador, Pos, DineroDespues, [], EstadoCarcel),
        reemplazar_jugador_por_nombre(JugadoresIn, NombreJugador, JugadorNuevo, JugadoresOut),
        BancoOut = BancoTmp,
        JugadorEliminado = no,
        EventoBancarrota = evento_bancarrota(Turno, NombreJugador, Causa, DineroAntes, ValorLiquidacion, DineroDespues, NumProps, sobrevive)
    ;   eliminar_jugador_por_nombre(JugadoresIn, NombreJugador, JugadoresOut),
        BancoOut = BancoTmp,
        JugadorEliminado = si,
        EventoBancarrota = evento_bancarrota(Turno, NombreJugador, Causa, DineroAntes, ValorLiquidacion, DineroDespues, NumProps, eliminado)
    ).

liquidar_propiedades([], 0, [], 0).
liquidar_propiedades([prop(Nombre, Tipo, Precio, Color, Casas)|R], ValorTotal, [activo(Nombre, Tipo, Precio, Color, Casas)|RBanco], NumProps) :-
    liquidar_propiedades(R, ValorResto, RBanco, NumResto),
    ValorProp is Precio // 2,
    ValorTotal is ValorResto + ValorProp,
    NumProps is NumResto + 1.

anexar_props_banco(banco(Dinero, Activos, Casas, Hoteles, CajaParking), NuevosActivos, banco(Dinero, ActivosOut, Casas, Hoteles, CajaParking)) :-
    append(NuevosActivos, Activos, ActivosOut).

jugador_por_nombre([jugador(Nombre, Pos, Din, Props, Estado)|_], Nombre, jugador(Nombre, Pos, Din, Props, Estado)) :- !.
jugador_por_nombre([_|R], Nombre, Jugador) :-
    jugador_por_nombre(R, Nombre, Jugador).

reemplazar_jugador_por_nombre([], _, _, []).
reemplazar_jugador_por_nombre([jugador(Nombre, _, _, _, _)|R], Nombre, JugadorNuevo, [JugadorNuevo|R]) :- !.
reemplazar_jugador_por_nombre([X|R], Nombre, JugadorNuevo, [X|R2]) :-
    reemplazar_jugador_por_nombre(R, Nombre, JugadorNuevo, R2).

eliminar_jugador_por_nombre([], _, []).
eliminar_jugador_por_nombre([jugador(Nombre, _, _, _, _)|R], Nombre, R) :- !.
eliminar_jugador_por_nombre([X|R], Nombre, [X|R2]) :-
    eliminar_jugador_por_nombre(R, Nombre, R2).

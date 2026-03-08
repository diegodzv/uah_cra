% =========================
% monopoly.pl
% Epica 8: deteccion de monopolios y compra automatica de casas
% =========================

:- module(monopoly, [
    aplicar_compra_casas_si_procede/7
]).

aplicar_compra_casas_si_procede(_Turno, jugador(N, P, D, Props, Estado), jugador(N, P, D, Props, Estado), no, sin_monopoly, 0, 0) :-
    \+ tiene_algun_monopolio(Props), !.

aplicar_compra_casas_si_procede(Turno, jugador(N, P, D, Props, Estado), JugadorOut, CompraRealizada, EventoMonopoly, CasasCompradas, CosteTotal) :-
    colores_monopolio(Props, ColoresMonopolio),
    comprar_una_ronda_de_casas(ColoresMonopolio, Props, D, PropsFinal, DFinal, CasasCompradas, CosteTotal),
    (
        CasasCompradas > 0 ->
        CompraRealizada = si,
        JugadorOut = jugador(N, P, DFinal, PropsFinal, Estado),
        EventoMonopoly = evento_monopoly(Turno, N, ColoresMonopolio, CasasCompradas, CosteTotal, D, DFinal)
    ;
        CompraRealizada = no,
        JugadorOut = jugador(N, P, D, Props, Estado),
        EventoMonopoly = sin_monopoly
    ).

tiene_algun_monopolio(Props) :-
    colores_monopolio(Props, Colores),
    Colores \== [].

colores_monopolio(Props, ColoresMonopolio) :-
    findall(Color, monopolio_color(Props, Color), ColoresDup),
    sort(ColoresDup, ColoresMonopolio).

monopolio_color(Props, morado) :-
    tiene_propiedad(Props, morado1),
    tiene_propiedad(Props, morado2).
monopolio_color(Props, gris) :-
    tiene_propiedad(Props, gris1),
    tiene_propiedad(Props, gris2),
    tiene_propiedad(Props, gris3).
monopolio_color(Props, rosa) :-
    tiene_propiedad(Props, rosa1),
    tiene_propiedad(Props, rosa2),
    tiene_propiedad(Props, rosa3).
monopolio_color(Props, naranja) :-
    tiene_propiedad(Props, naranja1),
    tiene_propiedad(Props, naranja2),
    tiene_propiedad(Props, naranja3).
monopolio_color(Props, rojo) :-
    tiene_propiedad(Props, rojo1),
    tiene_propiedad(Props, rojo2),
    tiene_propiedad(Props, rojo3).
monopolio_color(Props, amarillo) :-
    tiene_propiedad(Props, amarillo1),
    tiene_propiedad(Props, amarillo2),
    tiene_propiedad(Props, amarillo3).
monopolio_color(Props, verde) :-
    tiene_propiedad(Props, verde1),
    tiene_propiedad(Props, verde2),
    tiene_propiedad(Props, verde3).
monopolio_color(Props, azul) :-
    tiene_propiedad(Props, azul1),
    tiene_propiedad(Props, azul2).

tiene_propiedad([prop(Nombre, _, _, _, _)|_], Nombre) :- !.
tiene_propiedad([_|R], Nombre) :-
    tiene_propiedad(R, Nombre).
tiene_propiedad([], _) :-
    fail.

comprar_una_ronda_de_casas([], Props, Dinero, Props, Dinero, 0, 0).
comprar_una_ronda_de_casas([Color|R], PropsIn, DineroIn, PropsOut, DineroOut, CasasTotal, CosteTotal) :-
    comprar_una_casa_en_cada_propiedad_color(Color, PropsIn, DineroIn, PropsTmp, DineroTmp, CasasColor, CosteColor),
    comprar_una_ronda_de_casas(R, PropsTmp, DineroTmp, PropsOut, DineroOut, CasasResto, CosteResto),
    CasasTotal is CasasColor + CasasResto,
    CosteTotal is CosteColor + CosteResto.

comprar_una_casa_en_cada_propiedad_color(_Color, [], Dinero, [], Dinero, 0, 0).

comprar_una_casa_en_cada_propiedad_color(Color, [prop(Nombre, Tipo, Precio, Color, Casas)|R], DineroIn, [prop(Nombre, Tipo, Precio, Color, Casas2)|R2], DineroOut, CasasTotal, CosteTotal) :-
    !,
    (
        Casas < 3,
        DineroIn >= 100 ->
        Casas2 is Casas + 1,
        DineroTmp is DineroIn - 100,
        CasasCompradasAqui = 1,
        CosteAqui = 100
    ;
        Casas2 = Casas,
        DineroTmp = DineroIn,
        CasasCompradasAqui = 0,
        CosteAqui = 0
    ),
    comprar_una_casa_en_cada_propiedad_color(Color, R, DineroTmp, R2, DineroOut, CasasResto, CosteResto),
    CasasTotal is CasasCompradasAqui + CasasResto,
    CosteTotal is CosteAqui + CosteResto.

comprar_una_casa_en_cada_propiedad_color(Color, [Prop|R], DineroIn, [Prop|R2], DineroOut, CasasTotal, CosteTotal) :-
    comprar_una_casa_en_cada_propiedad_color(Color, R, DineroIn, R2, DineroOut, CasasTotal, CosteTotal).

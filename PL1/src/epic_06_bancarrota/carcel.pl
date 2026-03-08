% =========================
% carcel.pl
% Epica 6: logica de carcel
% =========================

:- module(carcel, [
    entrar_en_carcel/3,
    resolver_turno_carcel/10
]).

:- use_module(dados).

entrar_en_carcel(
    jugador(Nombre, _Pos, Dinero, Props, _EstadoAnterior),
    jugador(Nombre, 11, Dinero, Props, encarcelado(0)),
    evento_carcel(entrada, carcel, visita_carcel)
).

resolver_turno_carcel(
    _Politica,
    EstadoDados,
    jugador(N, P, D, Props, libre),
    jugador(N, P, D, Props, libre),
    EstadoDados,
    no_aplica,
    no_aplica,
    no,
    D,
    D
) :- !.

resolver_turno_carcel(
    _Politica,
    EstadoDados,
    jugador(N, P, D, Props, encarcelado(3)),
    jugador(N, P, D, Props, libre),
    EstadoDados,
    liberacion_automatica,
    evento_carcel(liberacion_automatica, 3),
    no,
    D,
    D
) :- !.

resolver_turno_carcel(
    Politica,
    EstadoDados0,
    jugador(N, P, D, Props, encarcelado(IntentosAntes)),
    JugadorOut,
    EstadoDadosOut,
    Decision,
    EventoCarcel,
    si,
    D,
    DineroDespues
) :-
    integer(IntentosAntes),
    IntentosAntes >= 0,
    IntentosAntes < 3,
    decidir_politica_carcel(Politica, D, DecisionElegida),
    resolver_decision_carcel(
        DecisionElegida,
        EstadoDados0,
        jugador(N, P, D, Props, encarcelado(IntentosAntes)),
        JugadorOut,
        EstadoDadosOut,
        Decision,
        EventoCarcel,
        DineroDespues
    ),
    !.

resolver_turno_carcel(
    _Politica,
    EstadoDados,
    jugador(N, P, D, Props, Estado),
    jugador(N, P, D, Props, Estado),
    EstadoDados,
    no_aplica,
    no_aplica,
    no,
    D,
    D
).

decidir_politica_carcel(pagar_siempre, Dinero, pagar) :-
    number(Dinero),
    Dinero >= 200, !.
decidir_politica_carcel(pagar_siempre, _Dinero, tirar) :- !.

decidir_politica_carcel(tirar_siempre, _Dinero, tirar) :- !.

decidir_politica_carcel(mixta_umbral(Umbral), Dinero, pagar) :-
    number(Umbral),
    number(Dinero),
    Dinero >= Umbral,
    Dinero >= 200,
    !.
decidir_politica_carcel(mixta_umbral(_Umbral), _Dinero, tirar) :- !.

decidir_politica_carcel(_OtraPolitica, _Dinero, tirar).

resolver_decision_carcel(
    pagar,
    EstadoDados,
    jugador(N, P, D, Props, encarcelado(IntentosAntes)),
    jugador(N, P, D2, Props, libre),
    EstadoDados,
    pagar,
    evento_carcel(sale_pagando, 200, IntentosAntes),
    D2
) :-
    D >= 200,
    D2 is D - 200,
    !.

resolver_decision_carcel(
    tirar,
    EstadoDados0,
    jugador(N, P, D, Props, encarcelado(IntentosAntes)),
    JugadorOut,
    EstadoDadosOut,
    tirar,
    EventoCarcel,
    D
) :-
    dados:tirar_dos_dados(EstadoDados0, D1, D2, EstadoDadosOut),
    (
        D1 =:= D2 ->
            JugadorOut = jugador(N, P, D, Props, libre),
            EventoCarcel = evento_carcel(sale_por_dobles, D1, D2, IntentosAntes)
    ;
        IntentosDespues is IntentosAntes + 1,
        JugadorOut = jugador(N, P, D, Props, encarcelado(IntentosDespues)),
        EventoCarcel = evento_carcel(fallo_intento, D1, D2, IntentosAntes, IntentosDespues)
    ),
    !.

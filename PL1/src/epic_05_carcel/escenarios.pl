% =========================
% escenarios.pl
% Epica 5: escenarios de carcel
% =========================

:- module(escenarios, [
    escenario/2,
    nombres_escenarios/1
]).

:- use_module(tablero).
:- use_module(dados).

dinero_inicial_epica5(10000).
politica_compra_base(comprar_si_tiene_fondos).

% Politicas de carcel usadas:
% - pagar_siempre
% - tirar_siempre
% - mixta_umbral(9500)

escenario(carcel_1j_caida_directa,
    escenario(
        carcel_1j_caida_directa,
        'Jugador colocado de forma que en su primer turno cae en carcel y es trasladado a visita_carcel.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(3, EstadoDados), % primer tiro = 4+3 = 7
    tablero:tablero(Tablero),
    tablero:crear_banco_inicial(Banco),
    J1 = jugador(ana, 24, 10000, [], libre), % 24 + 7 = 31 -> carcel
    Partida = partida(Tablero, Banco, [J1], 1, 1, EstadoDados, PoliticaCompra, tirar_siempre, historial(carcel_1j_caida_directa, [])).

escenario(carcel_1j_sale_pagando,
    escenario(
        carcel_1j_sale_pagando,
        'Jugador ya encarcelado que paga 200 en su siguiente turno para salir; el turno termina.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(5, EstadoDados),
    tablero:tablero(Tablero),
    tablero:crear_banco_inicial(Banco),
    J1 = jugador(ana, 11, 10000, [], encarcelado(0)),
    Partida = partida(Tablero, Banco, [J1], 1, 2, EstadoDados, PoliticaCompra, pagar_siempre, historial(carcel_1j_sale_pagando, [])).

escenario(carcel_1j_sale_por_dobles,
    escenario(
        carcel_1j_sale_por_dobles,
        'Jugador ya encarcelado que intenta salir tirando y obtiene dobles; sale y su turno termina.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(0, EstadoDados), % primer tiro = 1+1
    tablero:tablero(Tablero),
    tablero:crear_banco_inicial(Banco),
    J1 = jugador(ana, 11, 10000, [], encarcelado(0)),
    Partida = partida(Tablero, Banco, [J1], 1, 2, EstadoDados, PoliticaCompra, tirar_siempre, historial(carcel_1j_sale_por_dobles, [])).

escenario(carcel_1j_tres_intentos_fallidos,
    escenario(
        carcel_1j_tres_intentos_fallidos,
        'Jugador ya encarcelado que falla tres intentos seguidos y en el turno siguiente sale automaticamente y juega normal.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(3, EstadoDados), % 4+3, 5+6, 6+2 => tres no dobles
    tablero:tablero(Tablero),
    tablero:crear_banco_inicial(Banco),
    J1 = jugador(ana, 11, 10000, [], encarcelado(0)),
    Partida = partida(Tablero, Banco, [J1], 1, 4, EstadoDados, PoliticaCompra, tirar_siempre, historial(carcel_1j_tres_intentos_fallidos, [])).

escenario(carcel_2j_decisiones_mixtas,
    escenario(
        carcel_2j_decisiones_mixtas,
        'Escenario corto con 2 jugadores y politica mixta de carcel para observar pagos y/o intentos de dobles.',
        Partida
    )
) :-
    dinero_inicial_epica5(Dinero),
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(19, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], Dinero, 120, carcel_2j_decisiones_mixtas, EstadoDados, PoliticaCompra, mixta_umbral(9500), Partida).

escenario(carcel_2j_100t_semilla_3,
    escenario(
        carcel_2j_100t_semilla_3,
        '2 jugadores, 100 turnos, compras, alquileres y carcel.',
        Partida
    )
) :-
    dinero_inicial_epica5(Dinero),
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], Dinero, 100, carcel_2j_100t_semilla_3, EstadoDados, PoliticaCompra, mixta_umbral(9500), Partida).

escenario(carcel_4j_200t_semilla_7,
    escenario(
        carcel_4j_200t_semilla_7,
        '4 jugadores, 200 turnos, compras, alquileres y carcel.',
        Partida
    )
) :-
    dinero_inicial_epica5(Dinero),
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], Dinero, 200, carcel_4j_200t_semilla_7, EstadoDados, PoliticaCompra, mixta_umbral(9500), Partida).

escenario(carcel_10j_500t_semilla_11,
    escenario(
        carcel_10j_500t_semilla_11,
        '10 jugadores, 500 turnos, compras, alquileres y carcel.',
        Partida
    )
) :-
    dinero_inicial_epica5(Dinero),
    politica_compra_base(PoliticaCompra),
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial([ana,bob,carla,diego,elena,fernando,gema,hugo,irene,javier], Dinero, 500, carcel_10j_500t_semilla_11, EstadoDados, PoliticaCompra, mixta_umbral(9500), Partida).

nombres_escenarios([
    carcel_1j_caida_directa,
    carcel_1j_sale_pagando,
    carcel_1j_sale_por_dobles,
    carcel_1j_tres_intentos_fallidos,
    carcel_2j_decisiones_mixtas,
    carcel_2j_100t_semilla_3,
    carcel_4j_200t_semilla_7,
    carcel_10j_500t_semilla_11
]).

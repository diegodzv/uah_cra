% =========================
% escenarios.pl
% Epica 7: escenarios de parking gratuito
% =========================

:- module(escenarios, [
    escenario/2,
    nombres_escenarios/1
]).

:- use_module(tablero).
:- use_module(dados).

politica_compra_base(comprar_si_tiene_fondos).
politica_carcel_base(mixta_umbral(9500)).

escenario(parking_1j_impuesto_acumula,
    escenario(
        parking_1j_impuesto_acumula,
        'Un jugador cae en impuesto y el dinero pagado se acumula en la caja del parking.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(0, EstadoDados),      % 1 + 1 = 2
    tablero:tablero(Tablero),
    tablero:crear_banco_inicial(Banco0),
    Banco0 = banco(DinBanco, Activos, Casas, Hoteles, _),
    Banco = banco(DinBanco, Activos, Casas, Hoteles, 0),
    J1 = jugador(ana, 11, 500, [], libre),         % 11 + 2 = 13 => impuesto2 (150)
    Partida = partida(Tablero, Banco, [J1], 1, 1, EstadoDados, PoliticaCompra, PoliticaCarcel, historial(parking_1j_impuesto_acumula, [])).

escenario(parking_1j_cobra_desde_caja,
    escenario(
        parking_1j_cobra_desde_caja,
        'Un jugador cae en parking y cobra la mitad de la caja acumulada.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(0, EstadoDados),      % 1 + 1 = 2
    tablero:tablero(Tablero),
    Banco = banco(0, [], 32, 12, 300),
    J1 = jugador(ana, 19, 500, [], libre),         % 19 + 2 = 21 => parking, cobra 150
    Partida = partida(Tablero, Banco, [J1], 1, 1, EstadoDados, PoliticaCompra, PoliticaCarcel, historial(parking_1j_cobra_desde_caja, [])).

escenario(parking_2j_impuesto_y_premio,
    escenario(
        parking_2j_impuesto_y_premio,
        'Dos jugadores: el primero mete dinero en la caja con un impuesto y el segundo cobra en parking.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(0, EstadoDados),      % turno1: 1+1=2 ; turno2: 5+4=9
    tablero:tablero(Tablero),
    Banco = banco(0, [], 32, 12, 0),
    J1 = jugador(ana, 11, 500, [], libre),         % 11 + 2 = 13 => impuesto2
    J2 = jugador(bob, 12, 500, [], libre),         % 12 + 9 = 21 => parking
    Partida = partida(Tablero, Banco, [J1, J2], 1, 2, EstadoDados, PoliticaCompra, PoliticaCarcel, historial(parking_2j_impuesto_y_premio, [])).

escenario(parking_2j_100t_semilla_3,
    escenario(
        parking_2j_100t_semilla_3,
        '2 jugadores, 100 turnos, compras, alquileres, impuestos, parking, carcel y bancarrota.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], 1500, 100, parking_2j_100t_semilla_3, EstadoDados, PoliticaCompra, PoliticaCarcel, Partida).

escenario(parking_4j_200t_semilla_7,
    escenario(
        parking_4j_200t_semilla_7,
        '4 jugadores, 200 turnos, compras, alquileres, impuestos, parking, carcel y bancarrota.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], 1500, 200, parking_4j_200t_semilla_7, EstadoDados, PoliticaCompra, PoliticaCarcel, Partida).

escenario(parking_10j_500t_semilla_11,
    escenario(
        parking_10j_500t_semilla_11,
        '10 jugadores, 500 turnos, compras, alquileres, impuestos, parking, carcel y bancarrota.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial([ana,bob,carla,diego,elena,fernando,gema,hugo,irene,javier], 1500, 500, parking_10j_500t_semilla_11, EstadoDados, PoliticaCompra, PoliticaCarcel, Partida).

nombres_escenarios([
    parking_1j_impuesto_acumula,
    parking_1j_cobra_desde_caja,
    parking_2j_impuesto_y_premio,
    parking_2j_100t_semilla_3,
    parking_4j_200t_semilla_7,
    parking_10j_500t_semilla_11
]).

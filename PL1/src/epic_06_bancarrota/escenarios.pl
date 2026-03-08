% =========================
% escenarios.pl
% Epica 6: escenarios de bancarrota
% =========================

:- module(escenarios, [
    escenario/2,
    nombres_escenarios/1
]).

:- use_module(tablero).
:- use_module(dados).

politica_compra_base(comprar_si_tiene_fondos).
politica_carcel_base(mixta_umbral(9500)).

escenario(bancarrota_1j_impuesto_sin_propiedades,
    escenario(
        bancarrota_1j_impuesto_sin_propiedades,
        'Jugador con poco dinero cae en impuesto, no tiene propiedades y es eliminado.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:tablero(Tablero),
    tablero:crear_banco_inicial(Banco),
    J1 = jugador(ana, 6, 100, [], libre),
    Partida = partida(
        Tablero, Banco, [J1], 1, 1, EstadoDados,
        PoliticaCompra, PoliticaCarcel,
        historial(bancarrota_1j_impuesto_sin_propiedades, [])
    ).

escenario(bancarrota_1j_impuesto_con_liquidacion,
    escenario(
        bancarrota_1j_impuesto_con_liquidacion,
        'Jugador con una propiedad sobrevive a un impuesto tras liquidar activos al 50 por ciento.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:tablero(Tablero),
    Banco = banco(0, [], 32, 12),
    Props = [prop(azul2, propiedad, 400, azul, 0)],
    J1 = jugador(ana, 6, 100, Props, libre),
    Partida = partida(
        Tablero, Banco, [J1], 1, 1, EstadoDados,
        PoliticaCompra, PoliticaCarcel,
        historial(bancarrota_1j_impuesto_con_liquidacion, [])
    ).

escenario(bancarrota_2j_alquiler_supera_con_liquidacion,
    escenario(
        bancarrota_2j_alquiler_supera_con_liquidacion,
        'Un jugador cae en propiedad ajena, entra en negativo y sobrevive tras liquidar una propiedad.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(0, EstadoDados),   % 1 + 1 = 2
    tablero:tablero(Tablero),
    Banco = banco(0, [], 32, 12),
    PropsAna = [prop(azul2, propiedad, 400, azul, 0)],
    J1 = jugador(ana, 10, 10, PropsAna, libre), % 10 -> 12
    PropsBob = [prop(rosa1, propiedad, 140, rosa, 0)],
    J2 = jugador(bob, 20, 1000, PropsBob, libre),
    Partida = partida(
        Tablero, Banco, [J1, J2], 1, 1, EstadoDados,
        PoliticaCompra, PoliticaCarcel,
        historial(bancarrota_2j_alquiler_supera_con_liquidacion, [])
    ).

escenario(bancarrota_2j_100t_semilla_3,
    escenario(
        bancarrota_2j_100t_semilla_3,
        '2 jugadores, 100 turnos, compras, alquileres, impuestos, carcel y bancarrota.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial(
        [ana, bob], 1500, 100, bancarrota_2j_100t_semilla_3,
        EstadoDados, PoliticaCompra, PoliticaCarcel, Partida
    ).

escenario(bancarrota_4j_200t_semilla_7,
    escenario(
        bancarrota_4j_200t_semilla_7,
        '4 jugadores, 200 turnos, compras, alquileres, impuestos, carcel y bancarrota.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial(
        [ana, bob, carla, diego], 1500, 200, bancarrota_4j_200t_semilla_7,
        EstadoDados, PoliticaCompra, PoliticaCarcel, Partida
    ).

escenario(bancarrota_10j_500t_semilla_11,
    escenario(
        bancarrota_10j_500t_semilla_11,
        '10 jugadores, 500 turnos, compras, alquileres, impuestos, carcel y bancarrota.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial(
        [ana,bob,carla,diego,elena,fernando,gema,hugo,irene,javier],
        1500, 500, bancarrota_10j_500t_semilla_11,
        EstadoDados, PoliticaCompra, PoliticaCarcel, Partida
    ).

nombres_escenarios([
    bancarrota_1j_impuesto_sin_propiedades,
    bancarrota_1j_impuesto_con_liquidacion,
    bancarrota_2j_alquiler_supera_con_liquidacion,
    bancarrota_2j_100t_semilla_3,
    bancarrota_4j_200t_semilla_7,
    bancarrota_10j_500t_semilla_11
]).

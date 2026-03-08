% =========================
% escenarios.pl
% Epica 8: escenarios de monopoly y casas
% =========================

:- module(escenarios, [
    escenario/2,
    nombres_escenarios/1
]).

:- use_module(tablero).
:- use_module(dados).

politica_compra_base(comprar_si_tiene_fondos).
politica_carcel_base(mixta_umbral(9500)).
dinero_inicial_monopoly(10000).

escenario(monopoly_1j_compra_casas_morado,
    escenario(
        monopoly_1j_compra_casas_morado,
        'Jugador con monopolio morado compra automaticamente una casa en cada propiedad del color al inicio del turno.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(0, EstadoDados),
    tablero:tablero(Tablero),
    Banco = banco(0, [], 32, 12, 0),
    Props = [
        prop(morado1, propiedad, 60, morado, 0),
        prop(morado2, propiedad, 60, morado, 0)
    ],
    J1 = jugador(ana, 1, 500, Props, libre),
    Partida = partida(Tablero, Banco, [J1], 1, 1, EstadoDados, PoliticaCompra, PoliticaCarcel, historial(monopoly_1j_compra_casas_morado, [])).

escenario(monopoly_1j_maximo_3_casas,
    escenario(
        monopoly_1j_maximo_3_casas,
        'Jugador con monopolio ya al maximo no compra mas casas.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(0, EstadoDados),
    tablero:tablero(Tablero),
    Banco = banco(0, [], 32, 12, 0),
    Props = [
        prop(morado1, propiedad, 60, morado, 3),
        prop(morado2, propiedad, 60, morado, 3)
    ],
    J1 = jugador(ana, 1, 1000, Props, libre),
    Partida = partida(Tablero, Banco, [J1], 1, 1, EstadoDados, PoliticaCompra, PoliticaCarcel, historial(monopoly_1j_maximo_3_casas, [])).

escenario(monopoly_2j_alquiler_con_casas,
    escenario(
        monopoly_2j_alquiler_con_casas,
        'Un jugador con monopolio rosa compra casas y otro cae despues en una de esas propiedades pagando alquiler aumentado.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dados:crear_estado_dados(0, EstadoDados),   % turno 1: 1+1=2, turno 2: 5+4=9
    tablero:tablero(Tablero),
    Banco = banco(0, [], 32, 12, 0),
    PropsAna = [
        prop(rosa1, propiedad, 140, rosa, 0),
        prop(rosa2, propiedad, 140, rosa, 0),
        prop(rosa3, propiedad, 160, rosa, 0)
    ],
    J1 = jugador(ana, 1, 1000, PropsAna, libre), % compra 3 casas (una por propiedad), luego mueve
    J2 = jugador(bob, 3, 1000, [], libre),        % 3 + 9 = 12 => rosa1
    Partida = partida(Tablero, Banco, [J1, J2], 1, 2, EstadoDados, PoliticaCompra, PoliticaCarcel, historial(monopoly_2j_alquiler_con_casas, [])).

escenario(monopoly_2j_100t_semilla_3,
    escenario(
        monopoly_2j_100t_semilla_3,
        '2 jugadores, 100 turnos, dinero alto para favorecer monopolios y compra automatica de casas.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dinero_inicial_monopoly(Dinero),
    dados:crear_estado_dados(3, EstadoDados),
    tablero:crear_partida_inicial([ana, bob], Dinero, 100, monopoly_2j_100t_semilla_3, EstadoDados, PoliticaCompra, PoliticaCarcel, Partida).

escenario(monopoly_4j_200t_semilla_7,
    escenario(
        monopoly_4j_200t_semilla_7,
        '4 jugadores, 200 turnos, dinero alto para favorecer monopolios y compra automatica de casas.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dinero_inicial_monopoly(Dinero),
    dados:crear_estado_dados(7, EstadoDados),
    tablero:crear_partida_inicial([ana, bob, carla, diego], Dinero, 200, monopoly_4j_200t_semilla_7, EstadoDados, PoliticaCompra, PoliticaCarcel, Partida).

escenario(monopoly_10j_500t_semilla_11,
    escenario(
        monopoly_10j_500t_semilla_11,
        '10 jugadores, 500 turnos, dinero alto para favorecer monopolios y compra automatica de casas.',
        Partida
    )
) :-
    politica_compra_base(PoliticaCompra),
    politica_carcel_base(PoliticaCarcel),
    dinero_inicial_monopoly(Dinero),
    dados:crear_estado_dados(11, EstadoDados),
    tablero:crear_partida_inicial([ana,bob,carla,diego,elena,fernando,gema,hugo,irene,javier], Dinero, 500, monopoly_10j_500t_semilla_11, EstadoDados, PoliticaCompra, PoliticaCarcel, Partida).

nombres_escenarios([
    monopoly_1j_compra_casas_morado,
    monopoly_1j_maximo_3_casas,
    monopoly_2j_alquiler_con_casas,
    monopoly_2j_100t_semilla_3,
    monopoly_4j_200t_semilla_7,
    monopoly_10j_500t_semilla_11
]).

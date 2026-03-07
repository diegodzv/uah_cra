% =========================
% tablero.pl
% Epica 5: tablero, banco, jugadores y partida
% =========================

:- module(tablero, [
    tablero/1,
    tablero_size/1,
    casilla_en_posicion/3,
    tablero_valido/0,
    crear_banco_inicial/1,
    crear_jugador_inicial/3,
    crear_jugadores_iniciales/3,
    crear_partida_inicial/8,
    tipos_casilla/1,
    colores_propiedad/1,
    es_comprable/1,
    es_casilla_comprable/1
]).

tablero([
    casilla(1,  salida,        salida,         0,   ninguno),
    casilla(2,  propiedad,     morado1,       60,   morado),
    casilla(3,  suerte,        suerte1,        0,   ninguno),
    casilla(4,  propiedad,     morado2,       60,   morado),
    casilla(5,  impuesto,      impuesto1,    200,   ninguno),
    casilla(6,  estacion,      estacion1,    200,   estacion),
    casilla(7,  propiedad,     gris1,        100,   gris),
    casilla(8,  suerte,        suerte2,        0,   ninguno),
    casilla(9,  propiedad,     gris2,        100,   gris),
    casilla(10, propiedad,     gris3,        120,   gris),
    casilla(11, visita_carcel, visita_carcel,  0,   ninguno),
    casilla(12, propiedad,     rosa1,        140,   rosa),
    casilla(13, impuesto,      impuesto2,    150,   ninguno),
    casilla(14, propiedad,     rosa2,        140,   rosa),
    casilla(15, propiedad,     rosa3,        160,   rosa),
    casilla(16, estacion,      estacion2,    200,   estacion),
    casilla(17, propiedad,     naranja1,     180,   naranja),
    casilla(18, suerte,        suerte3,        0,   ninguno),
    casilla(19, propiedad,     naranja2,     180,   naranja),
    casilla(20, propiedad,     naranja3,     200,   naranja),
    casilla(21, parking,       parking,        0,   ninguno),
    casilla(22, propiedad,     rojo1,        220,   rojo),
    casilla(23, suerte,        suerte4,        0,   ninguno),
    casilla(24, propiedad,     rojo2,        220,   rojo),
    casilla(25, propiedad,     rojo3,        240,   rojo),
    casilla(26, estacion,      estacion3,    200,   estacion),
    casilla(27, propiedad,     amarillo1,    260,   amarillo),
    casilla(28, propiedad,     amarillo2,    260,   amarillo),
    casilla(29, impuesto,      impuesto3,    100,   ninguno),
    casilla(30, propiedad,     amarillo3,    280,   amarillo),
    casilla(31, carcel,        carcel,         0,   ninguno),
    casilla(32, propiedad,     verde1,       300,   verde),
    casilla(33, propiedad,     verde2,       300,   verde),
    casilla(34, suerte,        suerte5,        0,   ninguno),
    casilla(35, propiedad,     verde3,       320,   verde),
    casilla(36, estacion,      estacion4,    200,   estacion),
    casilla(37, suerte,        suerte6,        0,   ninguno),
    casilla(38, propiedad,     azul1,        350,   azul),
    casilla(39, impuesto,      impuesto4,    100,   ninguno),
    casilla(40, propiedad,     azul2,        400,   azul)
]).

tablero_size(40).

casilla_en_posicion(Pos, Tablero, Casilla) :-
    nth1(Pos, Tablero, Casilla).

tipos_casilla([salida, propiedad, estacion, suerte, impuesto, visita_carcel, carcel, parking]).
colores_propiedad([morado, gris, rosa, naranja, rojo, amarillo, verde, azul, estacion]).

es_comprable(casilla(_, propiedad, _, _, _)).
es_comprable(casilla(_, estacion, _, _, _)).

es_casilla_comprable(casilla(_, Tipo, _, _, _)) :-
    (Tipo = propiedad ; Tipo = estacion).

crear_banco_inicial(banco(0, Activos, 32, 12)) :-
    tablero(Tablero),
    findall(
        activo(Nombre, Tipo, Precio, Color, 0),
        (
            member(casilla(_, Tipo, Nombre, Precio, Color), Tablero),
            (Tipo = propiedad ; Tipo = estacion)
        ),
        Activos
    ).

crear_jugador_inicial(Nombre, DineroInicial, jugador(Nombre, 1, DineroInicial, [], libre)).

crear_jugadores_iniciales([], _, []).
crear_jugadores_iniciales([Nombre|R], DineroInicial, [J|R2]) :-
    crear_jugador_inicial(Nombre, DineroInicial, J),
    crear_jugadores_iniciales(R, DineroInicial, R2).

% partida(Tablero, Banco, Jugadores, TurnoActual, MaxTurnos, EstadoDados, PoliticaCompra, PoliticaCarcel, Historial)
crear_partida_inicial(NombresJugadores, DineroInicial, MaxTurnos, Etiqueta, EstadoDados, PoliticaCompra, PoliticaCarcel,
    partida(Tablero, Banco, Jugadores, 1, MaxTurnos, EstadoDados, PoliticaCompra, PoliticaCarcel, historial(Etiqueta, []))) :-
    tablero(Tablero),
    crear_banco_inicial(Banco),
    crear_jugadores_iniciales(NombresJugadores, DineroInicial, Jugadores).

tablero_valido :-
    tablero(Tablero),
    length(Tablero, 40),
    indices_consecutivos(Tablero, 1),
    member(casilla(1, salida, salida, 0, ninguno), Tablero),
    member(casilla(11, visita_carcel, visita_carcel, 0, ninguno), Tablero),
    member(casilla(21, parking, parking, 0, ninguno), Tablero),
    member(casilla(31, carcel, carcel, 0, ninguno), Tablero).

indices_consecutivos([], _).
indices_consecutivos([casilla(I, _, _, _, _)|R], I) :-
    I2 is I + 1,
    indices_consecutivos(R, I2).

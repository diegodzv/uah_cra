% =========================
% metricas.pl
% Epica 1: metricas estructurales + exportacion CSV
% =========================

:- module(metricas, [
    resumen_tablero/1,
    contar_por_tipo/2,
    contar_por_color/2,
    total_casillas_comprables/1,
    total_propiedades_sin_estaciones/1,
    total_estaciones/1,
    valor_total_activos_tablero/1,
    exportar_resumen_tablero_csv/1,
    exportar_tipos_csv/1,
    exportar_colores_csv/1,
    exportar_jugadores_csv/2
]).

:- use_module(tablero).

% ------------------------------------------------------------------
% Resumen global del tablero
% ------------------------------------------------------------------

resumen_tablero(resumen(
    total_casillas(TotalCasillas),
    total_comprables(TotalComprables),
    total_propiedades(TotalPropiedades),
    total_estaciones(TotalEstaciones),
    valor_total_activos(ValorTotal)
)) :-
    tablero:tablero(Tablero),
    length(Tablero, TotalCasillas),
    total_casillas_comprables(TotalComprables),
    total_propiedades_sin_estaciones(TotalPropiedades),
    total_estaciones(TotalEstaciones),
    valor_total_activos_tablero(ValorTotal).

contar_por_tipo(Tipo, Cantidad) :-
    tablero:tablero(Tablero),
    include(es_del_tipo(Tipo), Tablero, Filtradas),
    length(Filtradas, Cantidad).

es_del_tipo(Tipo, casilla(_, Tipo, _, _, _)).

contar_por_color(Color, Cantidad) :-
    tablero:tablero(Tablero),
    include(es_del_color(Color), Tablero, Filtradas),
    length(Filtradas, Cantidad).

es_del_color(Color, casilla(_, propiedad, _, _, Color)).
es_del_color(estacion, casilla(_, estacion, _, _, estacion)).

total_casillas_comprables(Cantidad) :-
    tablero:tablero(Tablero),
    include(tablero:es_comprable, Tablero, Comprables),
    length(Comprables, Cantidad).

total_propiedades_sin_estaciones(Cantidad) :-
    tablero:tablero(Tablero),
    include(es_propiedad_normal, Tablero, Props),
    length(Props, Cantidad).

es_propiedad_normal(casilla(_, propiedad, _, _, _)).

total_estaciones(Cantidad) :-
    tablero:tablero(Tablero),
    include(es_estacion, Tablero, Estaciones),
    length(Estaciones, Cantidad).

es_estacion(casilla(_, estacion, _, _, _)).

valor_total_activos_tablero(ValorTotal) :-
    tablero:tablero(Tablero),
    findall(
        Precio,
        (
            member(casilla(_, Tipo, _, Precio, _), Tablero),
            (Tipo = propiedad ; Tipo = estacion)
        ),
        Precios
    ),
    sum_list(Precios, ValorTotal).

% ------------------------------------------------------------------
% Exportacion CSV
% ------------------------------------------------------------------

exportar_resumen_tablero_csv(Ruta) :-
    resumen_tablero(resumen(
        total_casillas(TotalCasillas),
        total_comprables(TotalComprables),
        total_propiedades(TotalPropiedades),
        total_estaciones(TotalEstaciones),
        valor_total_activos(ValorTotal)
    )),
    open(Ruta, write, Stream),
    write(Stream, 'metrica,valor\n'),
    format(Stream, 'total_casillas,~w\n', [TotalCasillas]),
    format(Stream, 'total_comprables,~w\n', [TotalComprables]),
    format(Stream, 'total_propiedades,~w\n', [TotalPropiedades]),
    format(Stream, 'total_estaciones,~w\n', [TotalEstaciones]),
    format(Stream, 'valor_total_activos,~w\n', [ValorTotal]),
    close(Stream).

exportar_tipos_csv(Ruta) :-
    tablero:tipos_casilla(Tipos),
    open(Ruta, write, Stream),
    write(Stream, 'tipo,cantidad\n'),
    exportar_tipos_csv_aux(Tipos, Stream),
    close(Stream).

exportar_tipos_csv_aux([], _).
exportar_tipos_csv_aux([Tipo | Resto], Stream) :-
    contar_por_tipo(Tipo, Cantidad),
    format(Stream, '~w,~w\n', [Tipo, Cantidad]),
    exportar_tipos_csv_aux(Resto, Stream).

exportar_colores_csv(Ruta) :-
    tablero:colores_propiedad(Colores),
    open(Ruta, write, Stream),
    write(Stream, 'color,cantidad\n'),
    exportar_colores_csv_aux(Colores, Stream),
    close(Stream).

exportar_colores_csv_aux([], _).
exportar_colores_csv_aux([Color | Resto], Stream) :-
    contar_por_color(Color, Cantidad),
    format(Stream, '~w,~w\n', [Color, Cantidad]),
    exportar_colores_csv_aux(Resto, Stream).

exportar_jugadores_csv(Ruta, Jugadores) :-
    open(Ruta, write, Stream),
    write(Stream, 'nombre,posicion,dinero,numero_propiedades,en_carcel\n'),
    exportar_jugadores_csv_aux(Jugadores, Stream),
    close(Stream).

exportar_jugadores_csv_aux([], _).
exportar_jugadores_csv_aux([jugador(Nombre, Posicion, Dinero, Propiedades, EnCarcel) | Resto], Stream) :-
    length(Propiedades, NumProps),
    format(Stream, '~w,~w,~w,~w,~w\n', [Nombre, Posicion, Dinero, NumProps, EnCarcel]),
    exportar_jugadores_csv_aux(Resto, Stream).

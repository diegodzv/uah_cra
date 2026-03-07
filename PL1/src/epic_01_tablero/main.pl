% =========================
% main.pl
% Epica 1: ejecucion de escenarios y exportacion
% =========================

:- initialization(banner).

:- use_module(tablero).
:- use_module(metricas).
:- use_module(escenarios).

banner :-
    nl,
    write('=============================================='), nl,
    write(' MONOPOLY PROLOG - EPICA 1: TABLERO Y ESTADO '), nl,
    write('=============================================='), nl,
    nl,
    write('Predicados disponibles:'), nl,
    write('  - list_scenarios.'), nl,
    write('  - run_scenario(Nombre).'), nl,
    write('  - run_all_scenarios.'), nl,
    write('  - export_all_csv.'), nl,
    write('  - validar_tablero.'), nl,
    nl.

% ------------------------------------------------------------------
% Utilidades de ejecucion
% ------------------------------------------------------------------

list_scenarios :-
    escenarios:nombres_escenarios(Nombres),
    nl,
    write('Escenarios disponibles:'), nl,
    imprimir_lista(Nombres).

imprimir_lista([]).
imprimir_lista([X | R]) :-
    write(' - '), write(X), nl,
    imprimir_lista(R).

run_scenario(Nombre) :-
    escenarios:escenario(Nombre, escenario(NombreEscenario, Objetivo, Partida)),
    nl,
    write('=== ESCENARIO ==='), nl,
    write('Nombre: '), write(NombreEscenario), nl,
    write('Objetivo: '), write(Objetivo), nl, nl,
    mostrar_partida(Partida),
    mostrar_metricas_estructura.

run_all_scenarios :-
    escenarios:nombres_escenarios(Nombres),
    run_all_scenarios_aux(Nombres).

run_all_scenarios_aux([]).
run_all_scenarios_aux([Nombre | Resto]) :-
    run_scenario(Nombre),
    nl,
    write('----------------------------------------------'), nl,
    run_all_scenarios_aux(Resto).

validar_tablero :-
    ( tablero:tablero_valido ->
        write('OK: el tablero es valido.'), nl
    ;   write('ERROR: el tablero NO es valido.'), nl
    ).

mostrar_partida(partida(Tablero, Banco, Jugadores, TurnoActual, MaxTurnos, historial(Etiqueta, Historial))) :-
    write('Etiqueta: '), write(Etiqueta), nl,
    write('Turno actual: '), write(TurnoActual), nl,
    write('Maximo de turnos: '), write(MaxTurnos), nl,
    length(Historial, TamHistorial),
    write('Eventos en historial: '), write(TamHistorial), nl, nl,

    write('--- BANCO ---'), nl,
    mostrar_banco(Banco), nl,

    write('--- JUGADORES ---'), nl,
    mostrar_jugadores(Jugadores), nl,

    write('--- TABLERO ---'), nl,
    mostrar_tablero(Tablero), nl.

mostrar_banco(banco(Dinero, Propiedades, CasasDisponibles, HotelesDisponibles)) :-
    length(Propiedades, NumPropiedades),
    write('Dinero: '), write(Dinero), nl,
    write('Activos en posesion: '), write(NumPropiedades), nl,
    write('Casas disponibles: '), write(CasasDisponibles), nl,
    write('Hoteles disponibles: '), write(HotelesDisponibles), nl.

mostrar_jugadores([]).
mostrar_jugadores([jugador(Nombre, Posicion, Dinero, Propiedades, EnCarcel) | Resto]) :-
    length(Propiedades, NumProps),
    write('Jugador: '), write(Nombre),
    write(' | Posicion: '), write(Posicion),
    write(' | Dinero: '), write(Dinero),
    write(' | Propiedades: '), write(NumProps),
    write(' | En carcel: '), write(EnCarcel), nl,
    mostrar_jugadores(Resto).

mostrar_tablero([]).
mostrar_tablero([casilla(Indice, Tipo, Nombre, Precio, Color) | Resto]) :-
    write('['), write(Indice), write('] '),
    write(Nombre),
    write(' | tipo='), write(Tipo),
    write(' | precio='), write(Precio),
    write(' | color='), write(Color), nl,
    mostrar_tablero(Resto).

mostrar_metricas_estructura :-
    nl,
    write('--- METRICAS DE ESTRUCTURA ---'), nl,
    metricas:resumen_tablero(Resumen),
    mostrar_resumen(Resumen),
    nl,
    mostrar_conteo_tipos,
    nl,
    mostrar_conteo_colores.

mostrar_resumen(resumen(
    total_casillas(TotalCasillas),
    total_comprables(TotalComprables),
    total_propiedades(TotalPropiedades),
    total_estaciones(TotalEstaciones),
    valor_total_activos(ValorTotal)
)) :-
    write('Total de casillas: '), write(TotalCasillas), nl,
    write('Total de casillas comprables: '), write(TotalComprables), nl,
    write('Total de propiedades: '), write(TotalPropiedades), nl,
    write('Total de estaciones: '), write(TotalEstaciones), nl,
    write('Valor total de activos comprables: '), write(ValorTotal), nl.

mostrar_conteo_tipos :-
    write('Conteo por tipo:'), nl,
    tablero:tipos_casilla(Tipos),
    mostrar_conteo_tipos_aux(Tipos).

mostrar_conteo_tipos_aux([]).
mostrar_conteo_tipos_aux([Tipo | Resto]) :-
    metricas:contar_por_tipo(Tipo, Cantidad),
    write(' - '), write(Tipo), write(': '), write(Cantidad), nl,
    mostrar_conteo_tipos_aux(Resto).

mostrar_conteo_colores :-
    write('Conteo por color:'), nl,
    tablero:colores_propiedad(Colores),
    mostrar_conteo_colores_aux(Colores).

mostrar_conteo_colores_aux([]).
mostrar_conteo_colores_aux([Color | Resto]) :-
    metricas:contar_por_color(Color, Cantidad),
    write(' - '), write(Color), write(': '), write(Cantidad), nl,
    mostrar_conteo_colores_aux(Resto).

% ------------------------------------------------------------------
% Exportacion
% ------------------------------------------------------------------

export_all_csv :-
    metricas:exportar_resumen_tablero_csv('resultados/resumen_tablero.csv'),
    metricas:exportar_tipos_csv('resultados/conteo_tipos.csv'),
    metricas:exportar_colores_csv('resultados/conteo_colores.csv'),
    exportar_jugadores_escenarios,
    nl,
    write('CSV exportados en la carpeta resultados/'), nl.

exportar_jugadores_escenarios :-
    exportar_jugadores_de_escenario(tablero_base, 'resultados/jugadores_tablero_base.csv'),
    exportar_jugadores_de_escenario(dos_jugadores_inicio, 'resultados/jugadores_dos_jugadores_inicio.csv'),
    exportar_jugadores_de_escenario(cuatro_jugadores_inicio, 'resultados/jugadores_cuatro_jugadores_inicio.csv'),
    exportar_jugadores_de_escenario(ocho_jugadores_inicio, 'resultados/jugadores_ocho_jugadores_inicio.csv'),
    exportar_jugadores_de_escenario(validacion_estructura, 'resultados/jugadores_validacion_estructura.csv').

exportar_jugadores_de_escenario(NombreEscenario, Ruta) :-
    escenarios:escenario(NombreEscenario, escenario(_, _, partida(_, _, Jugadores, _, _, _))),
    metricas:exportar_jugadores_csv(Ruta, Jugadores).

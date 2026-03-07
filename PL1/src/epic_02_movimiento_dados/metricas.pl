% =========================
% metricas.pl
% Epica 2: metricas de movimiento + exportacion CSV
% =========================

:- module(metricas, [
    resumen_simulacion/3,
    imprimir_resumen_simulacion/1,
    exportar_eventos_csv/2,
    exportar_visitas_globales_csv/2,
    exportar_visitas_por_jugador_csv/2,
    exportar_sumas_dados_csv/2,
    exportar_pasos_salida_csv/2,
    exportar_resumen_csv/2
]).

:- use_module(tablero).

% ------------------------------------------------------------------
% Resumen principal
% ------------------------------------------------------------------

resumen_simulacion(PartidaFinal, Eventos, resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores(TotalJugadores),
    casillas_unicas_visitadas(CasillasUnicasVisitadas),
    cobertura_tablero(Cobertura),
    pasos_por_salida(TotalPasosSalida),
    suma_dados_media(MediaSuma),
    posicion_final_jugadores(PosicionesFinales)
)) :-
    length(Eventos, TotalTurnos),
    PartidaFinal = partida(_, _, Jugadores, _, _, _, _),
    length(Jugadores, TotalJugadores),
    casillas_unicas_visitadas(Eventos, CasillasUnicasVisitadas),
    Cobertura is CasillasUnicasVisitadas / 40,
    pasos_por_salida(Eventos, TotalPasosSalida),
    suma_media_dados(Eventos, MediaSuma),
    posiciones_finales(Jugadores, PosicionesFinales).

imprimir_resumen_simulacion(resumen_simulacion(
    total_turnos(TotalTurnos),
    total_jugadores(TotalJugadores),
    casillas_unicas_visitadas(CasillasUnicasVisitadas),
    cobertura_tablero(Cobertura),
    pasos_por_salida(TotalPasosSalida),
    suma_dados_media(MediaSuma),
    posicion_final_jugadores(PosicionesFinales)
)) :-
    write('Total de turnos simulados: '), write(TotalTurnos), nl,
    write('Total de jugadores: '), write(TotalJugadores), nl,
    write('Casillas unicas visitadas: '), write(CasillasUnicasVisitadas), write(' de 40'), nl,
    write('Cobertura del tablero: '), write(Cobertura), nl,
    write('Pasos por salida: '), write(TotalPasosSalida), nl,
    write('Media de suma de dados: '), write(MediaSuma), nl,
    write('Posiciones finales: '), write(PosicionesFinales), nl.

casillas_unicas_visitadas(Eventos, TotalUnicas) :-
    findall(PosNueva, member(evento_turno(_, _, _, _, _, _, _, PosNueva, _, _, _), Eventos), Posiciones),
    sort(Posiciones, Unicas),
    length(Unicas, TotalUnicas).

pasos_por_salida(Eventos, Total) :-
    include(es_paso_salida, Eventos, Filtrados),
    length(Filtrados, Total).

es_paso_salida(evento_turno(_, _, _, _, _, _, _, _, si, _, _)).

suma_media_dados([], 0).
suma_media_dados(Eventos, Media) :-
    findall(Suma, member(evento_turno(_, _, _, _, _, Suma, _, _, _, _, _), Eventos), Sumas),
    sum_list(Sumas, Total),
    length(Sumas, N),
    N > 0,
    Media is Total / N.

posiciones_finales([], []).
posiciones_finales([jugador(Nombre, Posicion, _, _, _) | R], [posicion_final(Nombre, Posicion) | R2]) :-
    posiciones_finales(R, R2).

% ------------------------------------------------------------------
% Exportacion de eventos
% ------------------------------------------------------------------

exportar_eventos_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'turno,indice_jugador,jugador,dado1,dado2,suma,posicion_anterior,posicion_nueva,paso_salida,casilla_destino,nombre_casilla\n'),
    exportar_eventos_csv_aux(Eventos, Stream),
    close(Stream).

exportar_eventos_csv_aux([], _).
exportar_eventos_csv_aux([evento_turno(Turno, IndiceJugador, Jugador, D1, D2, Suma, PosAnterior, PosNueva, PasoSalida, CasillaDestino, NombreCasilla) | R], Stream) :-
    format(Stream, '~w,~w,~w,~w,~w,~w,~w,~w,~w,~w,~w\n',
        [Turno, IndiceJugador, Jugador, D1, D2, Suma, PosAnterior, PosNueva, PasoSalida, CasillaDestino, NombreCasilla]),
    exportar_eventos_csv_aux(R, Stream).

% ------------------------------------------------------------------
% Exportacion de visitas globales por casilla
% ------------------------------------------------------------------

exportar_visitas_globales_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'posicion,nombre_casilla,visitas\n'),
    tablero:tablero(Tablero),
    exportar_visitas_globales_csv_aux(1, 40, Tablero, Eventos, Stream),
    close(Stream).

exportar_visitas_globales_csv_aux(Pos, Max, _, _, _) :-
    Pos > Max, !.
exportar_visitas_globales_csv_aux(Pos, Max, Tablero, Eventos, Stream) :-
    tablero:casilla_en_posicion(Pos, Tablero, casilla(_, _, NombreCasilla, _, _)),
    contar_visitas_posicion(Eventos, Pos, Visitas),
    format(Stream, '~w,~w,~w\n', [Pos, NombreCasilla, Visitas]),
    Pos2 is Pos + 1,
    exportar_visitas_globales_csv_aux(Pos2, Max, Tablero, Eventos, Stream).

contar_visitas_posicion(Eventos, Posicion, Total) :-
    include(visita_a_posicion(Posicion), Eventos, Filtrados),
    length(Filtrados, Total).

visita_a_posicion(Posicion, evento_turno(_, _, _, _, _, _, _, Posicion, _, _, _)).

% ------------------------------------------------------------------
% Exportacion de visitas por jugador y casilla
% ------------------------------------------------------------------

exportar_visitas_por_jugador_csv(Ruta, Eventos) :-
    jugadores_distintos(Eventos, Jugadores),
    open(Ruta, write, Stream),
    write(Stream, 'jugador,posicion,nombre_casilla,visitas\n'),
    exportar_visitas_por_jugador_csv_jugadores(Jugadores, Eventos, Stream),
    close(Stream).

exportar_visitas_por_jugador_csv_jugadores([], _, _).
exportar_visitas_por_jugador_csv_jugadores([Jugador | Resto], Eventos, Stream) :-
    tablero:tablero(Tablero),
    exportar_visitas_por_jugador_posiciones(Jugador, 1, 40, Tablero, Eventos, Stream),
    exportar_visitas_por_jugador_csv_jugadores(Resto, Eventos, Stream).

exportar_visitas_por_jugador_posiciones(_, Pos, Max, _, _, _) :-
    Pos > Max, !.
exportar_visitas_por_jugador_posiciones(Jugador, Pos, Max, Tablero, Eventos, Stream) :-
    tablero:casilla_en_posicion(Pos, Tablero, casilla(_, _, NombreCasilla, _, _)),
    contar_visitas_jugador_posicion(Eventos, Jugador, Pos, Visitas),
    format(Stream, '~w,~w,~w,~w\n', [Jugador, Pos, NombreCasilla, Visitas]),
    Pos2 is Pos + 1,
    exportar_visitas_por_jugador_posiciones(Jugador, Pos2, Max, Tablero, Eventos, Stream).

contar_visitas_jugador_posicion(Eventos, Jugador, Posicion, Total) :-
    include(visita_jugador_posicion(Jugador, Posicion), Eventos, Filtrados),
    length(Filtrados, Total).

visita_jugador_posicion(Jugador, Posicion, evento_turno(_, _, Jugador, _, _, _, _, Posicion, _, _, _)).

jugadores_distintos(Eventos, Jugadores) :-
    findall(Jugador, member(evento_turno(_, _, Jugador, _, _, _, _, _, _, _, _), Eventos), Lista),
    sort(Lista, Jugadores).

% ------------------------------------------------------------------
% Exportacion de frecuencia de sumas de dados
% ------------------------------------------------------------------

exportar_sumas_dados_csv(Ruta, Eventos) :-
    open(Ruta, write, Stream),
    write(Stream, 'suma,frecuencia\n'),
    exportar_sumas_dados_csv_aux(2, 12, Eventos, Stream),
    close(Stream).

exportar_sumas_dados_csv_aux(Suma, Max, _, _) :-
    Suma > Max, !.
exportar_sumas_dados_csv_aux(Suma, Max, Eventos, Stream) :-
    contar_suma(Eventos, Suma, Frecuencia),
    format(Stream, '~w,~w\n', [Suma, Frecuencia]),
    Suma2 is Suma + 1,
    exportar_sumas_dados_csv_aux(Suma2, Max, Eventos, Stream).

contar_suma(Eventos, Suma, Total) :-
    include(es_suma(Suma), Eventos, Filtrados),
    length(Filtrados, Total).

es_suma(Suma, evento_turno(_, _, _, _, _, Suma, _, _, _, _, _)).

% ------------------------------------------------------------------
% Exportacion de pasos por salida por jugador
% ------------------------------------------------------------------

exportar_pasos_salida_csv(Ruta, Eventos) :-
    jugadores_distintos(Eventos, Jugadores),
    open(Ruta, write, Stream),
    write(Stream, 'jugador,pasos_salida\n'),
    exportar_pasos_salida_csv_aux(Jugadores, Eventos, Stream),
    close(Stream).

exportar_pasos_salida_csv_aux([], _, _).
exportar_pasos_salida_csv_aux([Jugador | Resto], Eventos, Stream) :-
    contar_pasos_salida_jugador(Eventos, Jugador, Total),
    format(Stream, '~w,~w\n', [Jugador, Total]),
    exportar_pasos_salida_csv_aux(Resto, Eventos, Stream).

contar_pasos_salida_jugador(Eventos, Jugador, Total) :-
    include(es_paso_salida_jugador(Jugador), Eventos, Filtrados),
    length(Filtrados, Total).

es_paso_salida_jugador(Jugador, evento_turno(_, _, Jugador, _, _, _, _, _, si, _, _)).

% ------------------------------------------------------------------
% Exportacion de resumen
% ------------------------------------------------------------------

exportar_resumen_csv(Ruta, Resumen) :-
    Resumen = resumen_simulacion(
        total_turnos(TotalTurnos),
        total_jugadores(TotalJugadores),
        casillas_unicas_visitadas(CasillasUnicasVisitadas),
        cobertura_tablero(Cobertura),
        pasos_por_salida(TotalPasosSalida),
        suma_dados_media(MediaSuma),
        _
    ),
    open(Ruta, write, Stream),
    write(Stream, 'metrica,valor\n'),
    format(Stream, 'total_turnos,~w\n', [TotalTurnos]),
    format(Stream, 'total_jugadores,~w\n', [TotalJugadores]),
    format(Stream, 'casillas_unicas_visitadas,~w\n', [CasillasUnicasVisitadas]),
    format(Stream, 'cobertura_tablero,~w\n', [Cobertura]),
    format(Stream, 'pasos_por_salida,~w\n', [TotalPasosSalida]),
    format(Stream, 'suma_dados_media,~w\n', [MediaSuma]),
    close(Stream).

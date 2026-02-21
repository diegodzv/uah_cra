% =========================
% main.pl
% Entrada + bucle de juego
% =========================

:- consult('regla1.pl').
:- consult('metricas.pl').

start :-
    nl,
    write('=== MONOPOLY (Prolog) - Juego por terminal ==='), nl,
    read_int_min('Numero de jugadores (sin contar BANCO) (>=2): ', 2, N),
    read_int_min('Maximo de turnos (>=1). Si no quieres limite, pon grande (p.ej. 1000): ', 1, MaxT),
    crear_partida_interactiva(N, MaxT, Partida0),
    nl, write('Partida creada. Comienza el juego.'), nl,
    jugar(Partida0, _PartidaFinal).

jugar(Partida, PartidaFinal) :-
    (   partida_terminada(Partida, Motivo)
    ->  nl, write('=== FIN DE LA PARTIDA ==='), nl,
        write('Motivo: '), write(Motivo), nl,
        mostrar_resumen_final(Partida),
        PartidaFinal = Partida
    ;   turno_interactivo(Partida, PartidaSiguiente),
        jugar(PartidaSiguiente, PartidaFinal)
    ).

run_escenario(N) :-
    escenario(N, Partida0),
    nl, write('=== Ejecutando escenario '), write(N), write(' (INTERACTIVO) ==='), nl,
    jugar(Partida0, _).

mostrar_resumen_final(Partida) :-
    mostrar_estado(Partida),
    ranking_jugadores(Partida, Ranking),
    nl, write('--- Ranking (dinero desc) ---'), nl,
    imprimir_ranking(Ranking).

imprimir_ranking([]).
imprimir_ranking([item(Nombre, Dinero)|R]) :-
    write(Nombre), write(' -> '), write(Dinero), nl,
    imprimir_ranking(R).
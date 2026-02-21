% =========================
% main.pl
% Entrada + bucle de juego
% =========================

:- consult('regla1.pl').
:- consult('metricas.pl').

% ---------- Entrada principal ----------
start :-
    nl,
    write('=== MONOPOLY (Prolog) - Juego por terminal ==='), nl,
    write('Numero de jugadores (sin contar el BANCO) (>=2): '), nl,
    read(N),
    (   integer(N), N >= 2
    ->  true
    ;   write('Entrada invalida. Debe ser un entero >= 2.'), nl, fail
    ),
    write('Maximo de turnos (entero >=1). Si no quieres limite, pon un numero grande (p.ej. 1000): '), nl,
    read(MaxT),
    (   integer(MaxT), MaxT >= 1
    ->  true
    ;   write('Entrada invalida. Debe ser un entero >= 1.'), nl, fail
    ),
    crear_partida_interactiva(N, MaxT, Partida0),
    nl, write('Partida creada. Comienza el juego.'), nl,
    jugar(Partida0, _PartidaFinal).

% Bucle de juego (interactivo)
jugar(Partida, PartidaFinal) :-
    (   partida_terminada(Partida, Motivo)
    ->  nl, write('=== FIN DE LA PARTIDA ==='), nl,
        write('Motivo: '), write(Motivo), nl,
        mostrar_resumen_final(Partida),
        PartidaFinal = Partida
    ;   turno_interactivo(Partida, PartidaSiguiente),
        jugar(PartidaSiguiente, PartidaFinal)
    ).

% ---------- Escenarios ----------
run_escenario(N) :-
    escenario(N, Partida0),
    nl, write('=== Ejecutando escenario '), write(N), write(' (INTERACTIVO) ==='), nl,
    jugar(Partida0, _).

% ---------- Resumen final ----------
mostrar_resumen_final(Partida) :-
    mostrar_estado(Partida),
    ranking_jugadores(Partida, Ranking),
    nl, write('--- Ranking (dinero desc) ---'), nl,
    imprimir_ranking(Ranking).

imprimir_ranking([]).
imprimir_ranking([item(Nombre, Dinero)|R]) :-
    write(Nombre), write(' -> '), write(Dinero), nl,
    imprimir_ranking(R).

:- module(mejoras, [
    normalizar_tokens/2,
    tokenizar_basico/2
]).

/*
    Este módulo queda reservado para mejoras.
    De momento incluyo dos utilidades sencillas:
    - normalización básica
    - tokenización muy simple
*/

normalizar_tokens([], []).
normalizar_tokens([X | Resto], [X | Normalizados]) :-
    atom(X),
    normalizar_tokens(Resto, Normalizados).

tokenizar_basico(Texto, Tokens) :-
    atomic_list_concat(Partes, ' ', Texto),
    maplist(downcase_atom, Partes, Tokens).

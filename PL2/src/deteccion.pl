:- module(deteccion, [
    clasificar_oracion/4,
    ambiguedad_lexica/2,
    incoherencia_semantica/2,
    uso_no_literal/2
]).

:- use_module(semantico).

clasificar_oracion(Tokens, _Arbol, ambigua, Advertencias) :-
    findall(A, ambiguedad_lexica(Tokens, A), As),
    As \= [],
    Advertencias = As,
    !.

clasificar_oracion(Tokens, _Arbol, problematica, Advertencias) :-
    findall(I, incoherencia_semantica(Tokens, I), Is),
    findall(M, uso_no_literal(Tokens, M), Ms),
    append(Is, Ms, Advertencias),
    Advertencias \= [],
    !.

clasificar_oracion(_Tokens, _Arbol, correcta, []).

/* =========================================================
   AMBIGÜEDAD LÉXICA
   ========================================================= */

ambiguedad_lexica(Tokens, ambiguedad_lexica(Palabra)) :-
    member(Palabra, Tokens),
    semantico:palabra_ambigua(Palabra).

/* =========================================================
   INCOHERENCIA SEMÁNTICA
   Versión inicial muy simple.
   ========================================================= */

incoherencia_semantica([Det, Sujeto, Verbo | _], incoherencia_semantica(Sujeto, Verbo)) :-
    member(Det, [el, la, los, las, un, una]),
    Verbo = come,
    semantico:tipo(Sujeto, fenomeno_economico).

/* =========================================================
   USO NO LITERAL
   ========================================================= */

uso_no_literal([Det, Sujeto, Verbo | _], uso_no_literal(Sujeto, Verbo)) :-
    member(Det, [el, la]),
    Sujeto = mercado,
    Verbo = desplomo.

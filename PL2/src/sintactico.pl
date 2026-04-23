:- module(sintactico, [
    analizar_sintactico/2,
    simplificar_arbol/2,
    oracion//1,
    oracion_simple//1,
    grupo_nominal//1,
    grupo_verbal//1,
    grupo_adjetival//1,
    grupo_adverbial//1,
    grupo_preposicional//1
]).

:- use_module(draw).

/*
    Estructuras principales:
    - o(...)   : oración simple
    - oc(...)  : oración coordinada
    - or(...)  : oración de relativo
    - ocm(...) : oración compuesta (se puede introducir más adelante)

    Sintagmas:
    - gn(...)
    - gv(...)
    - gp(...)
    - gadj(...)
    - gadv(...)
*/

analizar_sintactico(Tokens, Arbol) :-
    phrase(oracion(Arbol), Tokens).

/* =========================================================
   REGLAS DE ORACIÓN
   ========================================================= */

oracion(Arbol) -->
    oracion_coordinada(Arbol).
oracion(Arbol) -->
    oracion_simple(Arbol).

oracion_coordinada(oc(O1, Conj, O2)) -->
    oracion_simple(O1),
    conjuncion(Conj),
    oracion_simple(O2).

oracion_simple(o(GN, GV)) -->
    grupo_nominal(GN),
    grupo_verbal(GV).

/* =========================================================
   GRUPOS SINTÁCTICOS
   ========================================================= */

grupo_nominal(gn(N)) -->
    nombre(N).

grupo_nominal(gn(Det, N)) -->
    determinante(Det),
    nombre(N).

grupo_nominal(gn(Det, N, GAdj)) -->
    determinante(Det),
    nombre(N),
    grupo_adjetival(GAdj).

grupo_nominal(gn(N, GAdj)) -->
    nombre(N),
    grupo_adjetival(GAdj).

grupo_verbal(gv(V)) -->
    verbo(V).

grupo_verbal(gv(V, GN)) -->
    verbo(V),
    grupo_nominal(GN).

grupo_verbal(gv(V, GAdj)) -->
    verbo(V),
    grupo_adjetival(GAdj).

grupo_verbal(gv(V, GP)) -->
    verbo(V),
    grupo_preposicional(GP).

grupo_verbal(gv(V, GN, GP)) -->
    verbo(V),
    grupo_nominal(GN),
    grupo_preposicional(GP).

grupo_verbal(gv(V, GAdv)) -->
    verbo(V),
    grupo_adverbial(GAdv).

grupo_verbal(gv(V, GN, GAdv)) -->
    verbo(V),
    grupo_nominal(GN),
    grupo_adverbial(GAdv).

grupo_adjetival(gadj(Adj)) -->
    adjetivo(Adj).

grupo_adjetival(gadj(Adv, Adj)) -->
    adverbio(Adv),
    adjetivo(Adj).

grupo_adverbial(gadv(Adv)) -->
    adverbio(Adv).

grupo_preposicional(gp(Prep, GN)) -->
    preposicion(Prep),
    grupo_nominal(GN).

/* =========================================================
   TERMINALES
   ========================================================= */

determinante(det(X)) --> [X], { det(X) }.
nombre(n(X))         --> [X], { n(X) }.
verbo(v(X))          --> [X], { v(X) }.
adjetivo(adj(X))     --> [X], { adj(X) }.
adverbio(adv(X))     --> [X], { adv(X) }.
preposicion(prep(X)) --> [X], { prep(X) }.
conjuncion(conj(X))  --> [X], { conj(X) }.

/* =========================================================
   LÉXICO INICIAL
   ========================================================= */

det(el).
det(la).
det(los).
det(las).
det(un).
det(una).

n(banco).
n(mercado).
n(inflacion).
n(acciones).
n(ahorros).
n(jose).
n(maria).

v(subio).
v(compro).
v(estudia).
v(come).
v(es).
v(tiene).
v(lee).

adj(alto).
adj(alta).
adj(rubio).
adj(rubia).
adj(financiero).
adj(fisico).

adv(muy).
adv(bien).

prep(de).
prep(con).
prep(en).
prep(a).
prep(por).

conj(y).
conj(pero).
conj(mientras).

/* =========================================================
   SIMPLIFICACIÓN
   ========================================================= */

simplificar_arbol(o(GN, GV), [o(GN, GV)]).
simplificar_arbol(oc(O1, _Conj, O2), Simples) :-
    simplificar_arbol(O1, S1),
    simplificar_arbol(O2, S2),
    append(S1, S2, Simples).

/*
    Más adelante:
    - relativo
    - compuestas
    - propagación del antecedente
*/

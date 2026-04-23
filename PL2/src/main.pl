:- consult(draw).

/* =========================================================
   PREDICADOS DE USO
   ========================================================= */

analizar(Tokens, Arbol) :-
    phrase(oracion(Arbol), Tokens).

dibujar(Tokens) :-
    analizar(Tokens, Arbol),
    draw(Arbol).

simplificar(Tokens, Simples) :-
    analizar(Tokens, Arbol),
    simplificar_arbol(Arbol, Simples).


/* =========================================================
   ORACIONES
   ========================================================= */

oracion(Arbol) -->
    oracion_compuesta(Arbol).
oracion(Arbol) -->
    oracion_coordinada(Arbol).
oracion(Arbol) -->
    oracion_relativo(Arbol).
oracion(Arbol) -->
    oracion_simple(Arbol).

oracion_simple(o(GN, GV)) -->
    grupo_nominal(GN),
    grupo_verbal(GV).

oracion_coordinada(oc(O1, Conj, O2)) -->
    oracion_simple(O1),
    conjuncion(Conj),
    oracion_simple(O2).

oracion_relativo(or(GN, Rel, GV)) -->
    grupo_nominal_base(GN),
    subordinada_relativo(Rel),
    grupo_verbal(GV).

subordinada_relativo(rel(Rel, GV)) -->
    relativo(Rel),
    grupo_verbal(GV).

oracion_compuesta(ocm(OR, Conj, O2)) -->
    oracion_relativo(OR),
    conjuncion(Conj),
    oracion_simple(O2).


/* =========================================================
   GRUPOS SINTÁCTICOS
   ========================================================= */

grupo_nominal(GN) -->
    grupo_nominal_base(GN).
grupo_nominal(gn(GNBase, GP)) -->
    grupo_nominal_base(GNBase),
    grupo_preposicional(GP).

grupo_nominal_base(gn(N)) -->
    nombre(N).
grupo_nominal_base(gn(Det, N)) -->
    determinante(Det),
    nombre(N).
grupo_nominal_base(gn(Det, N, GAdj)) -->
    determinante(Det),
    nombre(N),
    grupo_adjetival(GAdj).
grupo_nominal_base(gn(N, GAdj)) -->
    nombre(N),
    grupo_adjetival(GAdj).

grupo_verbal(gv(V)) -->
    verbo(V).

grupo_verbal(gv(V, GN)) -->
    verbo(V),
    grupo_nominal(GN).

grupo_verbal(gv(V, GP)) -->
    verbo(V),
    grupo_preposicional(GP).

grupo_verbal(gv(V, GN, GP)) -->
    verbo(V),
    grupo_nominal(GN),
    grupo_preposicional(GP).

grupo_verbal(gv(V, GAdj)) -->
    verbo(V),
    grupo_adjetival(GAdj).

grupo_verbal(gv(V, GAdv)) -->
    verbo(V),
    grupo_adverbial(GAdv).

grupo_verbal(gv(V, GAdj, GP)) -->
    verbo(V),
    grupo_adjetival(GAdj),
    grupo_preposicional(GP).

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
conjuncion(conj(X))  --> [X], { conj(X) }.
preposicion(prep(X)) --> [X], { prep(X) }.
relativo(rel(X))     --> [X], { rel(X) }.


/* =========================================================
   LÉXICO
   ========================================================= */

det(el).
det(la).
det(los).
det(las).
det(un).
det(una).
det(cada).

n(transformer).
n(modelo).
n(arquitectura).
n(atencion).
n(mecanismo).
n(mecanismos).
n(autoatencion).
n(codificador).
n(decodificador).
n(capa).
n(capas).
n(conexion).
n(red).
n(secuencia).
n(secuencias).
n(recurrencia).
n(convolucion).
n(representacion).
n(representaciones).
n(dimensión).
n(calidad).
n(traduccion).
n(orden).
n(pesos).
n(matriz).
n(codificaciones).
n(posiciones).

v(usa).
v(usan).
v(propone).
v(elimina).
v(contiene).
v(contienen).
v(aplica).
v(aplican).
v(produce).
v(producen).
v(relaciona).
v(relacionan).
v(mejora).
v(mejora).
v(permite).
v(permiten).
v(comparte).
v(representa).
v(representan).

adj(simple).
adj(simples).
adj(residual).
adj(residuales).
adj(continuas).
adj(continua).
adj(posicionales).
adj(paralela).
adj(paralelas).
adj(global).
adj(globales).

adv(solo).
adv(significativamente).
adv(tambien).

conj(y).
conj(pero).

prep(de).
prep(con).
prep(sin).
prep(en).
prep(para).

rel(que).


/* =========================================================
   SIMPLIFICACIÓN
   ========================================================= */

simplificar_arbol(o(GN, GV), [o(GN, GV)]).

simplificar_arbol(oc(O1, _Conj, O2), Simples) :-
    simplificar_arbol(O1, S1),
    simplificar_arbol(O2, S2),
    append(S1, S2, Simples).

simplificar_arbol(or(GN, rel(_Rel, GV1), GV2), [o(GN, GV1), o(GN, GV2)]).

simplificar_arbol(ocm(O1, _Conj, O2), Simples) :-
    simplificar_arbol(O1, S1),
    simplificar_arbol(O2, S2),
    append(S1, S2, Simples).

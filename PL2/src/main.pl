:- encoding(utf8).
:- consult(draw).

/* =========================================================
   CORPUS DE LA MINUTA 1
   dominio: tecnologia
   fuente: Vaswani et al., "Attention Is All You Need" (2017)
   ========================================================= */

frase(1, o,
    'El transformer usa mecanismos de atención.',
    [el, transformer, usa, mecanismos, de, atencion]).

frase(2, o,
    'El modelo elimina la recurrencia.',
    [el, modelo, elimina, la, recurrencia]).

frase(3, o,
    'El codificador contiene seis capas.',
    [el, codificador, contiene, seis, capas]).

frase(4, o,
    'El decodificador contiene seis capas.',
    [el, decodificador, contiene, seis, capas]).

frase(5, o,
    'Cada capa usa una conexión residual.',
    [cada, capa, usa, una, conexion, residual]).

frase(6, o,
    'El modelo produce representaciones continuas.',
    [el, modelo, produce, representaciones, continuas]).

frase(7, o,
    'La autoatención relaciona posiciones de una secuencia.',
    [la, autoatencion, relaciona, posiciones, de, una, secuencia]).

frase(8, o,
    'El modelo comparte la matriz de pesos.',
    [el, modelo, comparte, la, matriz, de, pesos]).

frase(9, o,
    'Las codificaciones posicionales usan funciones sinusoidales.',
    [las, codificaciones, posicionales, usan, funciones, sinusoidales]).

frase(10, o,
    'El transformer mejora la calidad de traducción.',
    [el, transformer, mejora, la, calidad, de, traduccion]).

frase(11, o,
    'El modelo permite paralelización.',
    [el, modelo, permite, paralelizacion]).

frase(12, o,
    'La atención calcula una suma ponderada.',
    [la, atencion, calcula, una, suma, ponderada]).

frase(13, o,
    'La red aplica softmax.',
    [la, red, aplica, softmax]).

frase(14, o,
    'El decodificador genera una secuencia de salida.',
    [el, decodificador, genera, una, secuencia, de, salida]).

frase(15, o,
    'La codificación posicional representa el orden de la secuencia.',
    [la, codificacion, posicional, representa, el, orden, de, la, secuencia]).

frase(16, o,
    'El transformer generaliza bien.',
    [el, transformer, generaliza, bien]).

frase(17, oc,
    'El modelo mejora la calidad y permite paralelización.',
    [el, modelo, mejora, la, calidad, y, permite, paralelizacion]).

frase(18, oc,
    'El codificador usa autoatención y aplica una red feed-forward.',
    [el, codificador, usa, autoatencion, y, aplica, una, red, feed_forward]).

frase(19, oc,
    'El modelo elimina la recurrencia pero mantiene la atención.',
    [el, modelo, elimina, la, recurrencia, pero, mantiene, la, atencion]).

frase(20, oc,
    'El decodificador usa autoatención y genera una secuencia de salida.',
    [el, decodificador, usa, autoatencion, y, genera, una, secuencia, de, salida]).

frase(21, oc,
    'Las capas producen representaciones continuas y usan conexiones residuales.',
    [las, capas, producen, representaciones, continuas, y, usan, conexiones, residuales]).

frase(22, oc,
    'El modelo usa embeddings y comparte la matriz de pesos.',
    [el, modelo, usa, embeddings, y, comparte, la, matriz, de, pesos]).

frase(23, or,
    'El transformer es un modelo que usa mecanismos de atención.',
    [el, transformer, es, un, modelo, que, usa, mecanismos, de, atencion]).

frase(24, or,
    'La autoatención es un mecanismo que relaciona posiciones de una secuencia.',
    [la, autoatencion, es, un, mecanismo, que, relaciona, posiciones, de, una, secuencia]).

frase(25, or,
    'El codificador contiene capas que producen representaciones continuas.',
    [el, codificador, contiene, capas, que, producen, representaciones, continuas]).

frase(26, or,
    'El modelo usa codificaciones posicionales que representan el orden de la secuencia.',
    [el, modelo, usa, codificaciones, posicionales, que, representan, el, orden, de, la, secuencia]).

frase(27, ocm,
    'El transformer es un modelo que usa mecanismos de atención y mejora la calidad de traducción.',
    [el, transformer, es, un, modelo, que, usa, mecanismos, de, atencion, y, mejora, la, calidad, de, traduccion]).

frase(28, ocm,
    'El codificador contiene capas que producen representaciones continuas y usa conexiones residuales.',
    [el, codificador, contiene, capas, que, producen, representaciones, continuas, y, usa, conexiones, residuales]).

frase(29, ocm,
    'El decodificador es un módulo que usa autoatención y genera una secuencia de salida.',
    [el, decodificador, es, un, modulo, que, usa, autoatencion, y, genera, una, secuencia, de, salida]).

frase(30, ocm,
    'El modelo usa codificaciones posicionales que representan el orden de la secuencia y comparte la matriz de pesos.',
    [el, modelo, usa, codificaciones, posicionales, que, representan, el, orden, de, la, secuencia, y, comparte, la, matriz, de, pesos]).

/* =========================================================
   PREDICADOS DE USO
   ========================================================= */

analizar(Tokens, Arbol) :-
    phrase(oracion(Arbol), Tokens).

analizar_frase(Id, Arbol) :-
    frase(Id, _Tipo, _Texto, Tokens),
    analizar(Tokens, Arbol).

dibujar(Tokens) :-
    analizar(Tokens, Arbol),
    draw(Arbol).

dibujar_frase(Id) :-
    analizar_frase(Id, Arbol),
    draw(Arbol).

simplificar(Tokens, Simples) :-
    analizar(Tokens, Arbol),
    simplificar_arbol(Arbol, Simples).

simplificar_frase(Id, Simples) :-
    analizar_frase(Id, Arbol),
    simplificar_arbol(Arbol, Simples).

probar_frase(Id) :-
    frase(Id, Tipo, Texto, Tokens),
    write('['), write(Id), write('] '), write(Tipo), write(' -> '), writeln(Texto),
    (   analizar(Tokens, Arbol)
    ->  write('  OK: '), writeln(Arbol)
    ;   writeln('  ERROR: no analizable con la gramática actual')
    ),
    nl.

probar_corpus :-
    forall(
        frase(Id, _Tipo, _Texto, _Tokens),
        probar_frase(Id)
    ).

/* =========================================================
   GRAMATICA PRINCIPAL
   ========================================================= */

oracion(Arbol) --> oracion_compuesta(Arbol).
oracion(Arbol) --> oracion_relativo(Arbol).
oracion(Arbol) --> oracion_coordinada(Arbol).
oracion(Arbol) --> oracion_simple(Arbol).

oracion_simple(o(GN, GV)) -->
    grupo_nominal(GN),
    grupo_verbal_simple(GV).

oracion_coordinada(oc(o(GN, GV1), Conj, o(GN, GV2))) -->
    grupo_nominal(GN),
    grupo_verbal_simple(GV1),
    conjuncion(Conj),
    grupo_verbal_simple(GV2).

oracion_relativo(
    or(
        o(GNSuj, gv(VMain, gn_rel(GNAnte, RelClause)))
    )
) -->
    grupo_nominal(GNSuj),
    verbo(VMain),
    grupo_nominal_base(GNAnte),
    subordinada_relativo(RelClause).

subordinada_relativo(or_rel(Rel, GV)) -->
    relativo(Rel),
    grupo_verbal_simple(GV).

oracion_compuesta(
    ocm(
        or(o(GNSuj, gv(VMain, gn_rel(GNAnte, RelClause)))),
        Conj,
        o(GNSuj, GV2)
    )
) -->
    grupo_nominal(GNSuj),
    verbo(VMain),
    grupo_nominal_base(GNAnte),
    subordinada_relativo(RelClause),
    conjuncion(Conj),
    grupo_verbal_simple(GV2).

/* =========================================================
   GRUPOS SINTACTICOS
   ========================================================= */

grupo_nominal(GN) -->
    grupo_nominal_base(GN).

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

grupo_nominal_base(gn(N, GP)) -->
    nombre(N),
    grupo_preposicional(GP).

grupo_nominal_base(gn(Det, N, GP)) -->
    determinante(Det),
    nombre(N),
    grupo_preposicional(GP).

grupo_nominal_base(gn(N, GAdj, GP)) -->
    nombre(N),
    grupo_adjetival(GAdj),
    grupo_preposicional(GP).

grupo_nominal_base(gn(Det, N, GAdj, GP)) -->
    determinante(Det),
    nombre(N),
    grupo_adjetival(GAdj),
    grupo_preposicional(GP).

grupo_verbal_simple(gv(V)) -->
    verbo(V).

grupo_verbal_simple(gv(V, GN)) -->
    verbo(V),
    grupo_nominal_base(GN).

grupo_verbal_simple(gv(V, GP)) -->
    verbo(V),
    grupo_preposicional(GP).

grupo_verbal_simple(gv(V, GAdj)) -->
    verbo(V),
    grupo_adjetival(GAdj).

grupo_verbal_simple(gv(V, GAdv)) -->
    verbo(V),
    grupo_adverbial(GAdv).

grupo_verbal_simple(gv(V, GN, GP)) -->
    verbo(V),
    grupo_nominal_base(GN),
    grupo_preposicional(GP).

grupo_verbal_simple(gv(V, GAdj, GP)) -->
    verbo(V),
    grupo_adjetival(GAdj),
    grupo_preposicional(GP).

grupo_verbal_simple(gv(V, GAdv, GP)) -->
    verbo(V),
    grupo_adverbial(GAdv),
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
    grupo_nominal_base(GN).

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
   LEXICO DEL CORPUS
   ========================================================= */

det(el).
det(la).
det(las).
det(un).
det(una).
det(cada).
det(seis).

n(transformer).
n(modelo).
n(codificador).
n(codificacion).
n(decodificador).
n(conexion).
n(conexiones).
n(capa).
n(capas).
n(recurrencia).
n(representaciones).
n(posiciones).
n(secuencia).
n(matriz).
n(pesos).
n(codificaciones).
n(calidad).
n(traduccion).
n(paralelizacion).
n(atencion).
n(autoatencion).
n(funciones).
n(suma).
n(red).
n(softmax).
n(orden).
n(mecanismo).
n(mecanismos).
n(modulo).
n(embeddings).
n(salida).

v(usa).
v(usan).
v(elimina).
v(contiene).
v(produce).
v(producen).
v(relaciona).
v(comparte).
v(mejora).
v(permite).
v(calcula).
v(aplica).
v(genera).
v(representa).
v(representan).
v(generaliza).
v(es).
v(mantiene).

adj(residual).
adj(continuas).
adj(posicionales).
adj(posicional).
adj(ponderada).
adj(feed_forward).
adj(residuales).
adj(sinusoidales).

adv(bien).

conj(y).
conj(pero).

prep(de).

rel(que).

/* =========================================================
   SIMPLIFICACION
   ========================================================= */

simplificar_arbol(o(GN, GV), [o(GN, GV)]).

simplificar_arbol(
    oc(o(GN, GV1), _Conj, o(_GN, GV2)),
    [o(GN, GV1), o(GN, GV2)]
).

simplificar_arbol(
    or(o(GNSuj, gv(VMain, gn_rel(GNAnte, or_rel(_Rel, GVRel))))),
    [o(GNSuj, gv(VMain, GNAnte)), o(GNAnte, GVRel)]
).

simplificar_arbol(
    ocm(
        or(o(GNSuj, gv(VMain, gn_rel(GNAnte, or_rel(_Rel, GVRel))))),
        _Conj,
        o(_GNSuj2, GV2)
    ),
    [o(GNSuj, gv(VMain, GNAnte)), o(GNAnte, GVRel), o(GNSuj, GV2)]
).

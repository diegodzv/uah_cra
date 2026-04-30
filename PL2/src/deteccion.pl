:- encoding(utf8).

:- module(deteccion, [
    clasificar_oracion/4,
    ambiguedad_lexica/2,
    incoherencia_semantica/2,
    uso_no_literal/2
]).

:- use_module(semantico).

/* =========================================================
   2.3 DETECCION DE PROBLEMAS DE INTERPRETACION
   ========================================================= */

/*
    clasificar_oracion(Tokens, Arbol, Etiqueta, Advertencias)

    Etiquetas posibles:
    - correcta
    - ambigua
    - problematica
*/


/* =========================================================
   CLASIFICACION GENERAL
   ========================================================= */

clasificar_oracion(Tokens, Arbol, problematica, Advertencias) :-
    findall(I, incoherencia_semantica_arbol(Arbol, I), IncoherenciasArbol),
    findall(I2, incoherencia_semantica(Tokens, I2), IncoherenciasTokens),
    findall(M, uso_no_literal(Tokens, M), Metaforas),
    append(IncoherenciasArbol, IncoherenciasTokens, Aux1),
    append(Aux1, Metaforas, Todas),
    sort(Todas, Advertencias),
    Advertencias \= [],
    !.

clasificar_oracion(Tokens, _Arbol, ambigua, Advertencias) :-
    findall(A, ambiguedad_lexica(Tokens, A), Todas),
    sort(Todas, Advertencias),
    Advertencias \= [],
    !.

clasificar_oracion(_Tokens, _Arbol, correcta, []).


/* =========================================================
   2.3.1 AMBIGUEDAD LEXICA
   ========================================================= */

ambiguedad_lexica(Tokens, ambiguedad_lexica(Palabra, Sentidos)) :-
    member(Palabra, Tokens),
    semantico:palabra_ambigua(Palabra),
    findall(
        Sentido-Tipo,
        semantico:sentido(Palabra, Sentido, Tipo),
        Todos
    ),
    sort(Todos, Sentidos).


/* =========================================================
   2.3.2 INCOHERENCIA SEMANTICA USANDO TOKENS
   Sirve para ejemplos de prueba sin arbol sintactico.
   ========================================================= */

incoherencia_semantica(Tokens, incoherencia_sujeto(Sujeto, Verbo, TipoReal, TipoEsperado)) :-
    extraer_sujeto_verbo_objeto(Tokens, Sujeto, Verbo, _Objeto),
    semantico:espera_sujeto(Verbo, TipoEsperado),
    semantico:tipo(Sujeto, TipoReal),
    \+ semantico:categoria_valida(TipoReal, TipoEsperado).

incoherencia_semantica(Tokens, incoherencia_objeto(Verbo, Objeto, TipoReal, TipoEsperado)) :-
    extraer_sujeto_verbo_objeto(Tokens, _Sujeto, Verbo, Objeto),
    semantico:espera_objeto(Verbo, TipoEsperado),
    semantico:tipo(Objeto, TipoReal),
    \+ semantico:categoria_valida(TipoReal, TipoEsperado).


/* =========================================================
   INCOHERENCIA SEMANTICA USANDO EL ARBOL SINTACTICO
   Evita tomar adjetivos como si fueran objetos.
   ========================================================= */

incoherencia_semantica_arbol(sin_arbol, _) :-
    !,
    fail.

incoherencia_semantica_arbol(Arbol, incoherencia_sujeto(Sujeto, Verbo, TipoReal, TipoEsperado)) :-
    sub_term(o(GN, GV), Arbol),
    extraer_nombre_gn(GN, Sujeto),
    extraer_verbo_gv(GV, Verbo),
    semantico:espera_sujeto(Verbo, TipoEsperado),
    semantico:tipo(Sujeto, TipoReal),
    \+ semantico:categoria_valida(TipoReal, TipoEsperado).

incoherencia_semantica_arbol(Arbol, incoherencia_objeto(Verbo, Objeto, TipoReal, TipoEsperado)) :-
    sub_term(o(_GN, GV), Arbol),
    extraer_verbo_gv(GV, Verbo),
    extraer_objeto_gv(GV, Objeto),
    semantico:espera_objeto(Verbo, TipoEsperado),
    semantico:tipo(Objeto, TipoReal),
    \+ semantico:categoria_valida(TipoReal, TipoEsperado).


/* =========================================================
   2.3.3 USO NO LITERAL
   ========================================================= */

uso_no_literal(Tokens, uso_no_literal(Sujeto, Verbo, Explicacion)) :-
    extraer_sujeto_verbo_objeto(Tokens, Sujeto, Verbo, Objeto),
    metafora_simple(Sujeto, Verbo, Objeto, Explicacion).

metafora_simple(modelo, devora, datos,
    'El verbo devora se usa de forma no literal: un modelo no come datos fisicamente.').

metafora_simple(red, suena, representaciones,
    'El verbo suena se usa de forma no literal: una red neuronal no suena literalmente.').

metafora_simple(atencion, mira, secuencia,
    'El verbo mira se usa de forma no literal: la atencion no percibe visualmente.').

metafora_simple(modelo, mira, datos,
    'El verbo mira se usa de forma no literal: el modelo no ve datos como un ser vivo.').


/* =========================================================
   EXTRACCION DESDE TOKENS
   ========================================================= */

% Caso: [el, modelo, usa, mecanismos]
extraer_sujeto_verbo_objeto([_Det, Sujeto, Verbo, Objeto | _], Sujeto, Verbo, Objeto).

% Caso: [el, modelo, usa, la, matriz]
extraer_sujeto_verbo_objeto([_Det1, Sujeto, Verbo, _Det2, Objeto | _], Sujeto, Verbo, Objeto).

% Caso: [modelo, usa, mecanismos]
extraer_sujeto_verbo_objeto([Sujeto, Verbo, Objeto | _], Sujeto, Verbo, Objeto).


/* =========================================================
   EXTRACCION DESDE ARBOLES SINTACTICOS
   ========================================================= */

extraer_nombre_gn(gn(n(N)), N).
extraer_nombre_gn(gn(det(_), n(N)), N).
extraer_nombre_gn(gn(det(_), n(N), _), N).
extraer_nombre_gn(gn(n(N), _), N).
extraer_nombre_gn(gn(n(N), _, _), N).
extraer_nombre_gn(gn(det(_), n(N), _, _), N).

extraer_verbo_gv(gv(v(V)), V).
extraer_verbo_gv(gv(v(V), _), V).
extraer_verbo_gv(gv(v(V), _, _), V).

extraer_objeto_gv(gv(_, GN), Objeto) :-
    extraer_nombre_gn(GN, Objeto).

extraer_objeto_gv(gv(_, GN, _), Objeto) :-
    extraer_nombre_gn(GN, Objeto).

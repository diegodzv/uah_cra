:- module(conjunto_oraciones, [
    oracion_corpus/5,
    clasificacion_esperada/2
]).

/*
    oracion_corpus(Id, Dominio, Fuente, Tokens, TipoSintacticoEsperado).
*/

oracion_corpus(
    o1,
    economia,
    prensa,
    [el,mercado,compro,acciones],
    simple
).

oracion_corpus(
    o2,
    economia,
    prensa,
    [jose,estudia,derecho],
    simple
).

oracion_corpus(
    o3,
    economia,
    prensa,
    [jose,estudia,filosofia,pero,maria,estudia,derecho],
    coordinada
).

oracion_corpus(
    o4,
    economia,
    prensa,
    [la,inflacion,come,los,ahorros],
    simple
).

oracion_corpus(
    o5,
    economia,
    prensa,
    [el,banco,subio,los,tipos],
    simple
).

clasificacion_esperada(o1, correcta).
clasificacion_esperada(o2, correcta).
clasificacion_esperada(o3, correcta).
clasificacion_esperada(o4, problematica).
clasificacion_esperada(o5, ambigua).

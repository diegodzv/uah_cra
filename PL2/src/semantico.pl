:- module(semantico, [
    tipo/2,
    sentido/3,
    espera_sujeto/2,
    espera_objeto/2,
    uso_literal/3,
    palabra_ambigua/1
]).

/* =========================================================
   TIPOS SEMÁNTICOS BÁSICOS
   ========================================================= */

tipo(banco, institucion_financiera).
tipo(banco, objeto_fisico).
tipo(mercado, agente_economico).
tipo(inflacion, fenomeno_economico).
tipo(acciones, activo_financiero).
tipo(ahorros, activo_financiero).
tipo(jose, persona).
tipo(maria, persona).

tipo(comer, accion_fisica).
tipo(comprar, accion_economica).
tipo(estudiar, actividad_intelectual).
tipo(leer, actividad_intelectual).

/* =========================================================
   SENTIDOS POSIBLES
   ========================================================= */

sentido(banco, banco_financiero, institucion_financiera).
sentido(banco, banco_asiento, objeto_fisico).

/* =========================================================
   EXPECTATIVAS SEMÁNTICAS MUY SIMPLES
   ========================================================= */

espera_sujeto(come, ser_vivo).
espera_sujeto(compro, agente_economico).
espera_sujeto(estudia, persona).
espera_sujeto(lee, persona).

espera_objeto(come, alimento).
espera_objeto(compro, bien_o_activo).
espera_objeto(estudia, disciplina).
espera_objeto(lee, documento).

/* =========================================================
   USO LITERAL
   ========================================================= */

uso_literal(come, ser_vivo, alimento).
uso_literal(compro, agente_economico, bien_o_activo).
uso_literal(estudia, persona, disciplina).
uso_literal(lee, persona, documento).

/* =========================================================
   DERIVADOS
   ========================================================= */

palabra_ambigua(Palabra) :-
    sentido(Palabra, S1, _),
    sentido(Palabra, S2, _),
    S1 \= S2.

% =========================
% metricas.pl
% Contadores y reporte
% =========================

% metricas(Turnos, TiradasDados, Compras, Alquileres, Impuestos, Suertes, CasinosJugados, TrampasIntentadas, Bancarrotas, IterReglas)
metricas_inicial(metricas(0,0,0,0,0,0,0,0,0,0)).

inc_turnos(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T2,D,C,A,I,S,Ca,Tr,B,It)) :- T2 is T+1.
inc_dados(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D2,C,A,I,S,Ca,Tr,B,It)) :- D2 is D+1.
inc_compras(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D,C2,A,I,S,Ca,Tr,B,It)) :- C2 is C+1.
inc_alquileres(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D,C,A2,I,S,Ca,Tr,B,It)) :- A2 is A+1.
inc_impuestos(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D,C,A,I2,S,Ca,Tr,B,It)) :- I2 is I+1.
inc_suertes(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D,C,A,I,S2,Ca,Tr,B,It)) :- S2 is S+1.
inc_casinos(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D,C,A,I,S,Ca2,Tr,B,It)) :- Ca2 is Ca+1.
inc_trampas(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D,C,A,I,S,Ca,Tr2,B,It)) :- Tr2 is Tr+1.
inc_bancarrotas(metricas(T,D,C,A,I,S,Ca,Tr,B,It), metricas(T,D,C,A,I,S,Ca,Tr,B2,It)) :- B2 is B+1.
add_iter(metricas(T,D,C,A,I,S,Ca,Tr,B,It), K, metricas(T,D,C,A,I,S,Ca,Tr,B,It2)) :- It2 is It+K.

mostrar_metricas(metricas(T,D,C,A,I,S,Ca,Tr,B,It)) :-
    nl, write('--- METRICAS ---'), nl,
    write('Turnos jugados: '), write(T), nl,
    write('Eventos dados (tiradas): '), write(D), nl,
    write('Compras: '), write(C), nl,
    write('Alquileres: '), write(A), nl,
    write('Impuestos: '), write(I), nl,
    write('Suertes: '), write(S), nl,
    write('Casinos jugados: '), write(Ca), nl,
    write('Trampas intentadas: '), write(Tr), nl,
    write('Bancarrotas: '), write(B), nl,
    write('Iteraciones reglas (acum): '), write(It), nl.
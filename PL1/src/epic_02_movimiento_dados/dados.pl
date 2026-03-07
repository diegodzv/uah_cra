% =========================
% dados.pl
% Epica 2: pseudoaleatoriedad reproducible de dados
% =========================

:- module(dados, [
    secuencia_dados_base/1,
    crear_estado_dados/2,
    tirar_dos_dados/4,
    rotar_lista/3
]).

% Secuencia base larga para reducir repeticiones tempranas.
% Cada escenario arranca con una rotacion distinta segun la semilla.
secuencia_dados_base([
    1,1,5,4,3,5,6,6,2,2,4,4,3,1,3,4,4,3,2,3,4,2,3,3,1,6,2,5,1,1,
    1,4,1,1,5,4,6,2,1,6,5,2,1,6,4,5,3,1,2,3,4,1,4,5,6,4,2,3,6,2,
    4,6,1,5,1,1,1,4,5,2,5,3,5,2,6,2,2,5,6,3,4,6,1,2,3,6,2,2,5,3,
    5,4,1,2,5,1,5,4,6,3,1,3,5,1,4,3,2,2,4,3,3,5,6,2,4,6,2,2,1,6,
    6,5,4,1,1,4,6,6,3,3,6,5,6,4,4,1,6,6,2,3,6,3,1,6,6,6,2,4,3,3,
    3,5,4,1,4,3,3,3,3,6,5,6,3,4,2,5,3,6,1,1,4,3,4,2,6,5,1,2,2,6,
    6,2,6,3,2,1,3,1,5,5,5,2,2,5,4,5,6,4,2,1,4,4,3,1,1,5,4,2,5,4,
    4,1,5,4,6,6,2,3,1,3,3,1,6,5,4,5,1,5,1,6,5,1,3,3,3,2,3,1,2,5,
    5,4,3,5,2,6,1,2,1,5,1,5,4,4,2,1,6,2,1,6,2,4,1,2,4,3,6,4,4,4,
    4,6,3,1,2,5,6,5,4,4,1,2,5,1,1,2,5,1,6,3,5,5,3,4,3,5,2,6,4,6,
    6,5,5,1,2,2,4,3,6,4,2,3,6,3,5,1,1,3,5,3,5,3,2,6,2,3,2,2,5,2,
    1,6,4,3,4,1,5,3,3,3,2,5,4,5,2,4,4,3,6,6,3,5,6,5,1,2,3,1,6,6
]).

% ------------------------------------------------------------------
% Estado de dados:
% estado_dados(Semilla, SecuenciaBaseRotada, SecuenciaRestante)
% ------------------------------------------------------------------

crear_estado_dados(Semilla, estado_dados(Semilla, Rotada, Rotada)) :-
    secuencia_dados_base(Base),
    rotar_lista(Base, Semilla, Rotada).

tirar_dos_dados(Estado0, D1, D2, Estado2) :-
    extraer_siguiente(Estado0, D1, Estado1),
    extraer_siguiente(Estado1, D2, Estado2).

extraer_siguiente(
    estado_dados(Semilla, Base, []),
    Valor,
    EstadoSiguiente
) :-
    % Cuando se agota la secuencia restante, se recarga la base rotada.
    extraer_siguiente(
        estado_dados(Semilla, Base, Base),
        Valor,
        EstadoSiguiente
    ).

extraer_siguiente(
    estado_dados(Semilla, Base, [X|Resto]),
    X,
    estado_dados(Semilla, Base, Resto)
).

rotar_lista(Lista, Offset, Rotada) :-
    length(Lista, Len),
    Len > 0,
    OffsetNormalizado is Offset mod Len,
    dividir_lista(Lista, OffsetNormalizado, Prefijo, Sufijo),
    append(Sufijo, Prefijo, Rotada).

dividir_lista(Lista, 0, [], Lista) :- !.
dividir_lista([X|R], N, [X|Pref], Suf) :-
    N > 0,
    N2 is N - 1,
    dividir_lista(R, N2, Pref, Suf).

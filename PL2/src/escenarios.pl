:- module(escenarios, [
    ejecutar_escenarios/0
]).

:- use_module(main).
:- use_module(conjunto_oraciones).

ejecutar_escenarios :-
    forall(
        conjunto_oraciones:oracion_corpus(Id, _Dominio, _Fuente, Tokens, _Tipo),
        ejecutar_escenario(Id, Tokens)
    ).

ejecutar_escenario(Id, Tokens) :-
    write('--- Escenario: '), writeln(Id),
    write('Tokens: '), writeln(Tokens),
    (
        main:analizar_con_todo(Tokens, Arbol, Simples, Etiqueta, Advertencias) ->
        write('Arbol: '), writeln(Arbol),
        write('Simples: '), writeln(Simples),
        write('Etiqueta: '), writeln(Etiqueta),
        write('Advertencias: '), writeln(Advertencias)
    ;
        writeln('No analizable por la gramática actual')
    ),
    nl.

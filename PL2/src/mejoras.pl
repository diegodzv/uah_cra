:- encoding(utf8).

:- module(mejoras, [
    normalizar_tokens/2,
    tokenizar_basico/2,
    menu/0,
    simplificar_corpus/0
]).

/*
    Mejoras incluidas:
    1. Normalizacion basica.
    2. Tokenizacion simple.
    3. Menu interactivo visual.
    4. Simplificacion automatica del corpus.
    5. Visualizacion del enriquecimiento semantico.
    6. Deteccion visual de problemas de interpretacion.
*/

:- use_module(semantico).
:- use_module(deteccion).


/* =========================================================
   NORMALIZACION Y TOKENIZACION
   ========================================================= */

normalizar_tokens([], []).

normalizar_tokens([X | Resto], [Normalizado | Normalizados]) :-
    atom(X),
    downcase_atom(X, Normalizado),
    normalizar_tokens(Resto, Normalizados).

normalizar_tokens([X | Resto], [X | Normalizados]) :-
    \+ atom(X),
    normalizar_tokens(Resto, Normalizados).

tokenizar_basico(Texto, Tokens) :-
    atomic_list_concat(Partes, ' ', Texto),
    normalizar_tokens(Partes, Tokens).


/* =========================================================
   MENU
   ========================================================= */

menu :-
    nl,
    writeln('============================================================'),
    writeln('        PRACTICA 2 - ANALISIS SINTACTICO Y SEMANTICO        '),
    writeln('============================================================'),
    writeln('  1. Probar una frase del corpus'),
    writeln('  2. Probar todo el corpus'),
    writeln('  3. Simplificar una frase'),
    writeln('  4. Simplificar todo el corpus'),
    writeln('  5. Dibujar arbol de una frase'),
    writeln('  6. Tokenizar texto simple'),
    writeln('  7. Ver enriquecimiento semantico'),
    writeln('  8. Detectar problemas de interpretacion'),
    writeln('  0. Salir'),
    writeln('============================================================'),
    write('Elige una opcion: '),
    read(Opcion),
    ejecutar_opcion(Opcion).


/* =========================================================
   OPCIONES
   ========================================================= */

ejecutar_opcion(1) :-
    write('Introduce el ID de la frase: '),
    read(Id),
    user:probar_frase(Id),
    pausa,
    menu.

ejecutar_opcion(2) :-
    user:probar_corpus,
    pausa,
    menu.

ejecutar_opcion(3) :-
    write('Introduce el ID de la frase: '),
    read(Id),
    (
        user:simplificar_frase(Id, Simples)
    ->
        imprimir_titulo('SIMPLIFICACION DE ORACION'),
        write('Frase ID: '), writeln(Id),
        writeln('Oraciones simples obtenidas:'),
        mostrar_simples(Simples)
    ;
        writeln('ERROR: no se pudo simplificar esa frase')
    ),
    pausa,
    menu.

ejecutar_opcion(4) :-
    simplificar_corpus,
    pausa,
    menu.

ejecutar_opcion(5) :-
    write('Introduce el ID de la frase: '),
    read(Id),
    (
        user:dibujar_frase(Id)
    ->
        true
    ;
        writeln('ERROR: no se pudo dibujar esa frase')
    ),
    pausa,
    menu.

ejecutar_opcion(6) :-
    writeln('Introduce el texto entre comillas simples y termina con punto.'),
    writeln('Ejemplo: ''El modelo usa atencion''.'),
    read(Texto),
    tokenizar_basico(Texto, Tokens),
    imprimir_titulo('TOKENIZACION'),
    write('Texto original: '), writeln(Texto),
    write('Tokens: '), writeln(Tokens),
    pausa,
    menu.

ejecutar_opcion(7) :-
    mostrar_enriquecimiento_semantico,
    pausa,
    menu.

ejecutar_opcion(8) :-
    menu_deteccion,
    pausa,
    menu.

ejecutar_opcion(0) :-
    nl,
    writeln('Saliendo del programa...').

ejecutar_opcion(_) :-
    writeln('Opcion no valida.'),
    pausa,
    menu.


/* =========================================================
   SIMPLIFICACION COMPLETA DEL CORPUS
   ========================================================= */

simplificar_corpus :-
    imprimir_titulo('SIMPLIFICACION COMPLETA DEL CORPUS'),
    forall(
        user:frase(Id, Tipo, Texto, _Tokens),
        (
            writeln('------------------------------------------------------------'),
            write('Frase '), write(Id), write('  | Tipo sintactico: '), writeln(Tipo),
            write('Texto: '), writeln(Texto),
            (
                user:simplificar_frase(Id, Simples)
            ->
                writeln('Resultado:'),
                mostrar_simples(Simples)
            ;
                writeln('ERROR: no se pudo simplificar')
            ),
            nl
        )
    ).

mostrar_simples([]).

mostrar_simples([S | Resto]) :-
    write('   - '),
    writeln(S),
    mostrar_simples(Resto).


/* =========================================================
   OPCION 7: ENRIQUECIMIENTO SEMANTICO
   ========================================================= */

mostrar_enriquecimiento_semantico :-
    imprimir_titulo('2.2 ENRIQUECIMIENTO SEMANTICO'),
    writeln('Dominio: Tecnologia / Inteligencia Artificial'),
    writeln('Objetivo: asociar palabras del corpus a categorias semanticas.'),
    nl,

    imprimir_subtitulo('ENTIDADES PRINCIPALES'),
    mostrar_tipo(transformer),
    mostrar_tipo(modelo),
    mostrar_tipo(codificador),
    mostrar_tipo(decodificador),
    mostrar_tipo(red),
    mostrar_tipo(capa),
    mostrar_tipo(capas),
    nl,

    imprimir_subtitulo('MECANISMOS Y COMPONENTES'),
    mostrar_tipo(atencion),
    mostrar_tipo(autoatencion),
    mostrar_tipo(mecanismo),
    mostrar_tipo(mecanismos),
    mostrar_tipo(recurrencia),
    mostrar_tipo(conexion),
    mostrar_tipo(conexiones),
    nl,

    imprimir_subtitulo('DATOS Y REPRESENTACIONES'),
    mostrar_tipo(secuencia),
    mostrar_tipo(posiciones),
    mostrar_tipo(representaciones),
    mostrar_tipo(embeddings),
    mostrar_tipo(matriz),
    mostrar_tipo(pesos),
    mostrar_tipo(codificacion),
    mostrar_tipo(codificaciones),
    mostrar_tipo(salida),
    nl,

    imprimir_subtitulo('OPERACIONES Y PROPIEDADES'),
    mostrar_tipo(softmax),
    mostrar_tipo(suma),
    mostrar_tipo(funciones),
    mostrar_tipo(paralelizacion),
    mostrar_tipo(calidad),
    mostrar_tipo(traduccion),
    nl.

mostrar_tipo(Palabra) :-
    findall(Tipo, semantico:tipo(Palabra, Tipo), Tipos),
    write('   - '),
    write(Palabra),
    write(' -> '),
    writeln(Tipos).


/* =========================================================
   OPCION 8: DETECCION DE PROBLEMAS
   ========================================================= */

menu_deteccion :-
    imprimir_titulo('2.3 DETECCION DE PROBLEMAS DE INTERPRETACION'),
    writeln('1. Analizar una frase del corpus'),
    writeln('2. Analizar todo el corpus'),
    writeln('3. Ejecutar ejemplos de prueba'),
    write('Elige una opcion: '),
    read(Opcion),
    ejecutar_deteccion(Opcion).

ejecutar_deteccion(1) :-
    write('Introduce el ID de la frase: '),
    read(Id),
    (
        user:frase(Id, Tipo, Texto, Tokens),
        user:analizar_frase(Id, Arbol),
        deteccion:clasificar_oracion(Tokens, Arbol, Etiqueta, Advertencias)
    ->
        mostrar_resultado_deteccion(Id, Tipo, Texto, Tokens, Etiqueta, Advertencias)
    ;
        writeln('ERROR: no se pudo analizar esa frase')
    ).

ejecutar_deteccion(2) :-
    forall(
        user:frase(Id, Tipo, Texto, Tokens),
        (
            user:analizar_frase(Id, Arbol),
            deteccion:clasificar_oracion(Tokens, Arbol, Etiqueta, Advertencias),
            mostrar_resultado_deteccion(Id, Tipo, Texto, Tokens, Etiqueta, Advertencias)
        )
    ).

ejecutar_deteccion(3) :-
    imprimir_subtitulo('EJEMPLOS DE PRUEBA'),

    analizar_tokens_prueba(
        'Ambiguedad lexica',
        [el, modelo, usa, atencion]
    ),

    analizar_tokens_prueba(
        'Incoherencia semantica',
        [la, matriz, aprende, la, secuencia]
    ),

    analizar_tokens_prueba(
        'Uso no literal',
        [el, modelo, devora, datos]
    ),

    analizar_tokens_prueba(
        'Uso no literal',
        [la, atencion, mira, secuencia]
    ).

ejecutar_deteccion(_) :-
    writeln('Opcion de deteccion no valida.').

analizar_tokens_prueba(Nombre, Tokens) :-
    writeln('------------------------------------------------------------'),
    write('Caso: '), writeln(Nombre),
    write('Tokens: '), writeln(Tokens),
    deteccion:clasificar_oracion(Tokens, sin_arbol, Etiqueta, Advertencias),
    write('Clasificacion semantica: '), writeln(Etiqueta),
    writeln('Advertencias:'),
    mostrar_advertencias(Advertencias),
    nl.

mostrar_resultado_deteccion(Id, Tipo, Texto, Tokens, Etiqueta, Advertencias) :-
    writeln('------------------------------------------------------------'),
    write('Frase '), write(Id), write('  | Tipo sintactico: '), writeln(Tipo),
    write('Texto: '), writeln(Texto),
    write('Tokens: '), writeln(Tokens),
    write('Clasificacion semantica: '), writeln(Etiqueta),
    writeln('Advertencias:'),
    mostrar_advertencias(Advertencias),
    nl.

mostrar_advertencias([]) :-
    writeln('   - Ninguna').

mostrar_advertencias(Lista) :-
    Lista \= [],
    mostrar_advertencias_aux(Lista).

mostrar_advertencias_aux([]).

mostrar_advertencias_aux([A | Resto]) :-
    write('   - '),
    writeln(A),
    mostrar_advertencias_aux(Resto).


/* =========================================================
   UTILIDADES VISUALES
   ========================================================= */

imprimir_titulo(Titulo) :-
    nl,
    writeln('============================================================'),
    write('   '), writeln(Titulo),
    writeln('============================================================').

imprimir_subtitulo(Titulo) :-
    writeln('------------------------------------------------------------'),
    write('   '), writeln(Titulo),
    writeln('------------------------------------------------------------').

pausa :-
    nl,
    writeln('Pulsa cualquier termino seguido de punto para volver al menu.'),
    writeln('Ejemplo: ok.'),
    read(_).

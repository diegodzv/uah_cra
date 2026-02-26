% =========================
% reglas.pl
% Motor del Monopoly + reglas
% =========================

:- consult('metricas.pl').

% ---------- Config juego ----------
dinero_inicial(800).
cobro_salida(200).

alquiler_propiedad_divisor(4).      % alquiler = Precio // 4
incremento_alquiler_por_casa(25).
precio_casa(100).
max_casas(3).

pago_impuesto(150).
suerte_delta(75).

estacion_precio(200).
estacion_alquiler(50).

% ============================================================
% Entrada robusta (acepta con/sin punto final)
% ============================================================

read_line_trimmed(StringOut) :-
    read_line_to_string(user_input, S0),
    normalize_space(string(S1), S0),
    StringOut = S1.

strip_trailing_dot(S, Out) :-
    string_length(S, Len),
    ( Len > 0,
      LastIndex is Len - 1,
      sub_string(S, LastIndex, 1, 0, ".")
    -> sub_string(S, 0, LastIndex, 1, Out0),
       normalize_space(string(Out), Out0)
    ;  Out = S
    ).

sanitize_input(S0, S) :-
    normalize_space(string(S1), S0),
    strip_trailing_dot(S1, S2),
    normalize_space(string(S), S2).

read_atom_prompt(Prompt, Atom) :-
    repeat,
      nl, write(Prompt), nl,
      read_line_trimmed(S0),
      sanitize_input(S0, S1),
      ( S1 == "" ->
          write('Entrada vacia. Intenta de nuevo.'), nl, fail
      ; string_lower(S1, SLow),
        atom_string(Atom, SLow),
        !
      ).

read_int_min(Prompt, Min, Int) :-
    repeat,
      nl, write(Prompt), nl,
      read_line_trimmed(S0),
      sanitize_input(S0, S1),
      ( catch(number_string(N, S1), _, fail),
        integer(N),
        N >= Min
      -> Int = N, !
      ;  write('Valor invalido. Debe ser entero >= '), write(Min), nl,
         fail
      ).

read_yes_no(Prompt, Answer) :-
    repeat,
      nl, write(Prompt), nl,
      read_line_trimmed(S0),
      sanitize_input(S0, S1),
      string_lower(S1, L),
      ( (L = "si" ; L = "s") ->
          Answer = si, !
      ; (L = "no" ; L = "n") ->
          Answer = no, !
      ; write('Responde si/no.'), nl, fail
      ).

read_choice_int(Prompt, Allowed, Choice) :-
    repeat,
      nl, write(Prompt), nl,
      read_line_trimmed(S0),
      sanitize_input(S0, S1),
      ( catch(number_string(N, S1), _, fail),
        integer(N),
        member_int(N, Allowed)
      -> Choice = N, !
      ;  write('Opcion invalida. Opciones: '), write(Allowed), nl,
         fail
      ).

member_int(X, [X|_]) :- !.
member_int(X, [_|R]) :- member_int(X, R).

% ---------- Pseudo-azar cíclico ----------
dados_por_defecto([1,2,3,4,5,6,6,5,4,3,2,1,2,4,6,1,3,5,5,3,1,6,4,2]).
azar_por_defecto([5,91,12,77,33,64,18,49,81,2,56,27,73,40,99,7,61,14,88,21,45,67,30,10,95,52,38,79,25,60,1,86,44,71,16,58,90,34,63,9]).

next_from_cycle([], Default, V, Rest) :- Default = [V|Rest].
next_from_cycle([V|Rest], _Default, V, Rest).

% ---------- Tablero ----------
tablero([
  salida,                                      % 1
  propiedad(morado1,60,morado),                % 2
  suerte(suerte1),                              % 3
  propiedad(morado2,60,morado),                % 4
  impuesto(impuesto1),                          % 5
  estacion(estacion1),                          % 6
  propiedad(gris1,100,gris),                   % 7
  suerte(suerte2),                              % 8
  propiedad(gris2,100,gris),                   % 9
  propiedad(gris3,120,gris),                   % 10
  visita_carcel,                                % 11
  propiedad(rosa1,140,rosa),                   % 12
  impuesto(impuesto2),                          % 13
  propiedad(rosa2,140,rosa),                   % 14
  propiedad(rosa3,160,rosa),                   % 15
  estacion(estacion2),                          % 16
  propiedad(naranja1,180,naranja),             % 17
  suerte(suerte3),                              % 18
  propiedad(naranja2,180,naranja),             % 19
  propiedad(naranja3,200,naranja),             % 20
  parking,                                      % 21
  propiedad(rojo1,220,rojo),                   % 22
  suerte(suerte4),                              % 23
  propiedad(rojo2,220,rojo),                   % 24
  propiedad(rojo3,240,rojo),                   % 25
  estacion(estacion3),                          % 26
  propiedad(amarillo1,260,amarillo),           % 27
  propiedad(amarillo2,260,amarillo),           % 28
  impuesto(impuesto3),                          % 29
  propiedad(amarillo3,280,amarillo),           % 30
  carcel,                                       % 31
  propiedad(verde1,300,verde),                 % 32
  propiedad(verde2,300,verde),                 % 33
  casino,                                       % 34
  propiedad(verde3,320,verde),                 % 35
  estacion(estacion4),                          % 36
  suerte(suerte5),                              % 37
  propiedad(azul1,350,azul),                   % 38
  impuesto(impuesto4),                          % 39
  propiedad(azul2,400,azul)                    % 40
]).

% ---------- BancoProps inicial ----------
banco_props_inicial(BancoProps) :-
    tablero(T),
    banco_props_from_tablero(T, BancoProps).

banco_props_from_tablero([], []).
banco_props_from_tablero([Cas|R], Props) :-
    (   Cas = propiedad(N,P,C)
    ->  Props = [prop(N,P,C,0)|PropsR],
        banco_props_from_tablero(R, PropsR)
    ;   Cas = estacion(Nom)
    ->  estacion_precio(Pr),
        Props = [prop(Nom,Pr,estacion,0)|PropsR],
        banco_props_from_tablero(R, PropsR)
    ;   banco_props_from_tablero(R, Props)
    ).

% ---------- Crear partida ----------
crear_partida_interactiva(N, MaxT, Partida) :-
    banco_props_inicial(BancoProps),
    metricas_inicial(M0),
    dados_por_defecto(Dados0),
    azar_por_defecto(Azar0),
    crear_jugadores_interactivos(1, N, Jugadores),
    Partida = partida(BancoProps, 0, Jugadores, 0, 0, MaxT, Dados0, Azar0, M0).

crear_jugadores_interactivos(I, N, []) :- I > N, !.
crear_jugadores_interactivos(I, N, [J|R]) :-
    atom_concat('Nombre del jugador ', I, P1),
    atom_concat(P1, ' (puedes escribir "nombre" o "Nombre".): ', Prompt),
    read_atom_prompt(Prompt, Nombre),
    dinero_inicial(D0),
    J = jugador(Nombre, 1, D0, [], 0),
    I2 is I+1,
    crear_jugadores_interactivos(I2, N, R).

% ---------- Mostrar estado ----------
mostrar_estado(partida(_BancoProps, Caja, Jugadores, TurnoIdx, TurnoNum, MaxT, _Dados, _Azar, M)) :-
    nl, write('=== ESTADO PARTIDA ==='), nl,
    write('TurnoNum: '), write(TurnoNum), write(' / MaxTurnos: '), write(MaxT), nl,
    write('TurnoIdx actual (0-based): '), write(TurnoIdx), nl,
    write('Caja especial del banco: '), write(Caja), nl,
    nl, write('--- Jugadores ---'), nl,
    imprimir_jugadores(Jugadores),
    mostrar_metricas(M).

imprimir_jugadores([]).
imprimir_jugadores([jugador(N,Pos,D,Props,Carc)|R]) :-
    write('Jugador: '), write(N),
    write(' | Pos: '), write(Pos),
    write(' | Dinero: '), write(D),
    write(' | CarcelRestante: '), write(Carc), nl,
    write('  Propiedades:'), nl,
    imprimir_props(Props),
    nl,
    imprimir_jugadores(R).

imprimir_props([]) :-
    write('   (ninguna)'), nl.
imprimir_props([H|T]) :-
    imprimir_props_list([H|T]).
imprimir_props_list([]).
imprimir_props_list([prop(N,P,C,H)|R]) :-
    write('   - '), write(N),
    write(' (precio='), write(P),
    write(', color='), write(C),
    write(', casas='), write(H), write(')'), nl,
    imprimir_props_list(R).

% ---------- Fin de partida ----------
partida_terminada(partida(_,_,_Jugadores,_,TurnoNum,MaxT,_,_,_), motivo(max_turnos)) :-
    TurnoNum >= MaxT, !.
partida_terminada(partida(_,_,Jugadores,_,_,_,_,_,_), motivo(un_solo_jugador)) :-
    length_list(Jugadores, L), L =:= 1, !.

% ============================================================
% Turnos: FIX orden jugadores
% - En vez de poner el jugador actualizado al principio,
%   lo reinsertamos en la MISMA posicion Idx0.
% - Si el jugador es eliminado, NO avanzamos el indice:
%   el "siguiente" pasa a ocupar ese Idx0.
% ============================================================

turno_interactivo(Partida0, PartidaFinal) :-
    Partida0 = partida(BP0, Caja0, Jugadores0, Idx0, TurnoNum0, MaxT, Dados0, Azar0, M0),
    inc_turnos(M0, M1),
    TurnoNum1 is TurnoNum0 + 1,

    seleccionar_por_indice(Jugadores0, Idx0, Jug0, Resto0),
    Jug0 = jugador(Nombre,_,_,_,_),

    nl, write('============================='), nl,
    write('TURNO '), write(TurnoNum1), write(' -> Jugador: '), write(Nombre), nl,
    write('============================='), nl,

    read_yes_no('Quieres consultar la informacion completa de la partida? (si/no)', Ver),
    (Ver == si -> mostrar_estado(Partida0) ; true),

    ofrecer_compra_casas(Jug0, Jugadores0, JugA),

    aplicar_trampas_interactivo(JugA, Resto0, Azar0, Azar1, JugB0, Resto1, M1, M2),

    resolver_bancarrota_jugador_y_banco(JugB0, Resto1, BP0, BP_after_trampas, JugB, Resto2, M2, M3),

    ( JugB == eliminado ->
        % eliminado antes de mover: no avanzamos turno, el siguiente ocupa Idx0
        Jugadores1 = Resto2,
        Partida1 = partida(BP_after_trampas, Caja0, Jugadores1, Idx0, TurnoNum1, MaxT, Dados0, Azar1, M3),
        normalizar_sin_avanzar(Partida1, PartidaFinal)
    ;   gestionar_carcel(JugB, Dados0, Dados1, EstadoCarcel, M3, M4),
        ( EstadoCarcel = fin_turno_con(JugCarcActual) ->
            insertar_en_indice(Resto2, Idx0, JugCarcActual, Jugadores1),
            Partida1 = partida(BP_after_trampas, Caja0, Jugadores1, Idx0, TurnoNum1, MaxT, Dados1, Azar1, M4),
            avanzar_turno(Partida1, PartidaFinal)
        ;   mover_jugador(JugB, Dados1, Dados2, JugMov, Caja0, Caja1, M4, M5),
            JugMov = jugador(_, PosNueva, _, _, _),
            tablero(T),
            nth1_list(PosNueva, T, Casilla),
            nl, write('Has caido en: '), write(Casilla), nl,

            aplicar_reglas_casilla(Casilla, JugMov, Resto2, BP_after_trampas, BP1, Caja1, Caja2, Dados2, Dados3, JugFin, RestoFin, M5, M6, Iter),
            add_iter(M6, Iter, M7),

            ( JugFin == eliminado ->
                Jugadores1 = RestoFin,
                Partida1 = partida(BP1, Caja2, Jugadores1, Idx0, TurnoNum1, MaxT, Dados3, Azar1, M7),
                normalizar_sin_avanzar(Partida1, PartidaFinal)
            ;   insertar_en_indice(RestoFin, Idx0, JugFin, Jugadores1),
                Partida1 = partida(BP1, Caja2, Jugadores1, Idx0, TurnoNum1, MaxT, Dados3, Azar1, M7),
                avanzar_turno(Partida1, PartidaFinal)
            )
        )
    ).

normalizar_sin_avanzar(partida(BP,Caja,Jugadores,Idx,Tn,MaxT,D,A,M),
                       partida(BP,Caja,Jugadores,Idx2,Tn,MaxT,D,A,M)) :-
    length_list(Jugadores, L),
    ( L =:= 0 -> Idx2 = 0
    ; Idx2 is Idx mod L
    ).

avanzar_turno(partida(BP,Caja,Jugadores,Idx,Tn,MaxT,D,A,M),
              partida(BP,Caja,Jugadores,Idx2,Tn,MaxT,D,A,M)) :-
    length_list(Jugadores, L),
    (L =:= 0 -> Idx2 = 0
    ; Idx2 is (Idx + 1) mod L
    ).

% ---------- Dados ----------
tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M2) :-
    dados_por_defecto(Def),
    next_from_cycle(Dados0, Def, D1, Dados1),
    next_from_cycle(Dados1, Def, D2, Dados2),
    inc_dados(M0, M1),
    inc_dados(M1, M2).

tirar_un_dado(Dados0, Dados1, D, M0, M1) :-
    dados_por_defecto(Def),
    next_from_cycle(Dados0, Def, D, Dados1),
    inc_dados(M0, M1).

% ---------- Movimiento ----------
mover_jugador(jugador(N,Pos,Din,Props,Carc), Dados0, Dados2,
             jugador(N,PosNueva,DinNueva,Props,Carc),
             Caja0, Caja1, M0, M2) :-
    tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M1),
    Steps is D1 + D2,
    PosNueva is ((Pos - 1 + Steps) mod 40) + 1,
    (paso_por_salida(Pos, Steps) ->
        cobro_salida(C),
        DinNueva is Din + C,
        Caja1 = Caja0,
        nl, write('Pasas por SALIDA: +'), write(C), nl
    ;   DinNueva = Din,
        Caja1 = Caja0
    ),
    nl, write('Dados: '), write(D1), write(' y '), write(D2),
    write(' => avanzas '), write(Steps), nl,
    write('Nueva posicion: '), write(PosNueva), nl,
    M2 = M1.

paso_por_salida(Pos, Steps) :- S is Pos + Steps, S > 40.

% ---------- Carcel ----------
gestionar_carcel(jugador(N,Pos,Din,Props,Carc), Dados0, DadosFinal, EstadoOut, M0, MFinal) :-
    (Carc =:= 0 ->
        DadosFinal = Dados0,
        EstadoOut = continuar,
        MFinal = M0
    ;   nl, write('Estas en CARCEL. Intentos restantes: '), write(Carc), nl,
        read_choice_int('Opciones: pagar 200 (1) o tirar dados (2)', [1,2], Opc),
        (Opc =:= 1, Din >= 200 ->
            Din2 is Din - 200,
            nl, write('Pagas 200 y SALES. Tu turno termina.'), nl,
            EstadoOut = fin_turno_con(jugador(N,Pos,Din2,Props,0)),
            DadosFinal = Dados0,
            MFinal = M0
        ;   tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M1),
            nl, write('Dados en carcel: '), write(D1), write(' y '), write(D2), nl,
            (D1 =:= D2 ->
                nl, write('Dobles => SALES. Turno termina.'), nl,
                EstadoOut = fin_turno_con(jugador(N,Pos,Din,Props,0))
            ;   Carc2 is Carc - 1,
                (Carc2 =< 0 ->
                    nl, write('No dobles. Agotas intentos => proximo turno normal.'), nl,
                    EstadoOut = fin_turno_con(jugador(N,Pos,Din,Props,0))
                ;   nl, write('No dobles. Sigues en carcel. Restan: '), write(Carc2), nl,
                    EstadoOut = fin_turno_con(jugador(N,Pos,Din,Props,Carc2))
                )
            ),
            DadosFinal = Dados2,
            MFinal = M1
        )
    ).

% ---------- Trampas (AJUSTADO) ----------
aplicar_trampas_interactivo(Jug0, Resto0, Azar0, Azar1, JugFinal, RestoFinal, M0, M2) :-
    read_yes_no('Quieres intentar hacer trampas? (si/no)', R),
    (R == no ->
        JugFinal = Jug0, RestoFinal = Resto0, Azar1 = Azar0, M2 = M0
    ;   inc_trampas(M0, M1),
        tirar_azar(Azar0, Azar1, V),
        nl, write('TRAMPAS: azar='), write(V), nl,
        (V =< 30 ->
            sumar_dinero(Jug0, 200, JugTmp),
            nl, write('Te sale bien: +200.'), nl,
            JugFinal = JugTmp,
            RestoFinal = Resto0,
            M2 = M1
        ;   length_list(Resto0, Otros),
            % NUEVA REGLA:
            % - si hay 1 jugador mas => paga 200 a ese
            % - si hay 2 o mas => paga 100 a cada uno
            ( Otros =:= 1 -> PagoCadaUno = 200 ; PagoCadaUno = 100 ),
            Multa is PagoCadaUno * Otros,
            restar_dinero(Jug0, Multa, JugTmp),
            sumar_a_todos(Resto0, PagoCadaUno, RestoTmp),
            nl, write('Te pillan: pagas '), write(PagoCadaUno),
            write(' a cada jugador. Total -'), write(Multa), nl,
            JugFinal = JugTmp,
            RestoFinal = RestoTmp,
            M2 = M1
        )
    ).

tirar_azar(Azar0, Azar1, V) :-
    azar_por_defecto(Def),
    next_from_cycle(Azar0, Def, V, Azar1).

sumar_a_todos([], _X, []).
sumar_a_todos([jugador(N,Pos,Din,Props,Carc)|R], X, [jugador(N,Pos,Din2,Props,Carc)|R2]) :-
    Din2 is Din + X,
    sumar_a_todos(R, X, R2).

sumar_dinero(jugador(N,Pos,Din,Props,Carc), X, jugador(N,Pos,Din2,Props,Carc)) :- Din2 is Din + X.
restar_dinero(jugador(N,Pos,Din,Props,Carc), X, jugador(N,Pos,Din2,Props,Carc)) :- Din2 is Din - X.

% ---------- Casas/Monopolios ----------
ofrecer_compra_casas(Jug0, Jugadores, JugFinal) :-
    Jug0 = jugador(_,_,_,Props,_),
    (Props == [] ->
        JugFinal = Jug0
    ; monopolios_de_jugador(Jugadores, Jug0, ColoresMonopolio),
      (ColoresMonopolio == [] ->
          JugFinal = Jug0
      ; nl, write('Tienes monopolio en colores: '), write(ColoresMonopolio), nl,
        ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal)
      )
    ).

ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal) :-
    read_yes_no('Quieres comprar casas ahora? (si/no)', R),
    (R == no ->
        JugFinal = Jug0
    ; Jug0 = jugador(N,Pos,Din,Props,Carc),
      propiedades_elegibles_para_casas(Props, ColoresMonopolio, Elegibles),
      (Elegibles == [] ->
          write('No hay propiedades elegibles.'), nl,
          JugFinal = Jug0
      ; nl, write('Propiedades elegibles:'), nl,
        imprimir_props_con_indices(Elegibles, 1),
        read_int_min('Elige indice para comprar 1 casa (o 0 para terminar): ', 0, I),
        (I =:= 0 ->
            JugFinal = Jug0
        ; I0 is I - 1,
          seleccionar_por_indice(Elegibles, I0, PropSel, _),
          PropSel = prop(Nom,Precio,Color,Casas),
          max_casas(MaxH),
          (Casas >= MaxH ->
              write('Ya tiene el maximo de casas.'), nl,
              ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal)
          ; precio_casa(Costo),
            (Din < Costo ->
                write('No tienes dinero (100) para una casa.'), nl,
                ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal)
            ; Din2 is Din - Costo,
              Casas2 is Casas + 1,
              reemplazar_prop_en_lista(Props,
                  prop(Nom,Precio,Color,Casas),
                  prop(Nom,Precio,Color,Casas2),
                  Props2),
              nl, write('Compras 1 casa en '), write(Nom),
              write('. Casas ahora='), write(Casas2), nl,
              Jug1 = jugador(N,Pos,Din2,Props2,Carc),
              ciclo_comprar_casas(Jug1, ColoresMonopolio, JugFinal)
            )
          )
        )
      )
    ).

imprimir_props_con_indices([], _).
imprimir_props_con_indices([prop(N,P,C,H)|R], I) :-
    write(I), write(') '), write(N),
    write(' (color='), write(C),
    write(', precio='), write(P),
    write(', casas='), write(H), write(')'), nl,
    I2 is I+1,
    imprimir_props_con_indices(R, I2).

propiedades_elegibles_para_casas([], _, []).
propiedades_elegibles_para_casas([prop(N,P,C,H)|R], Colores, [prop(N,P,C,H)|R2]) :-
    C \== estacion,
    member_atom(C, Colores), !,
    propiedades_elegibles_para_casas(R, Colores, R2).
propiedades_elegibles_para_casas([_|R], Colores, R2) :-
    propiedades_elegibles_para_casas(R, Colores, R2).

colores_del_tablero([morado,gris,rosa,naranja,rojo,amarillo,verde,azul]).

monopolios_de_jugador(_Jugadores, jugador(_,_,_,Props,_), ColoresMonopolio) :-
    colores_del_tablero(Colores),
    monopolios_por_colores(Colores, Props, [], ColoresMonopolio).

monopolios_por_colores([], _Props, Acc, Acc).
monopolios_por_colores([C|R], Props, Acc, Out) :-
    nombres_propiedades_color(C, TodosNombres),
    (TodosNombres == [] ->
        monopolios_por_colores(R, Props, Acc, Out)
    ; jugador_posee_todos(Props, TodosNombres) ->
        monopolios_por_colores(R, Props, [C|Acc], Out)
    ; monopolios_por_colores(R, Props, Acc, Out)
    ).

nombres_propiedades_color(Color, Nombres) :-
    tablero(T),
    nombres_propiedades_color_tablero(T, Color, [], Rev),
    reverse_list(Rev, Nombres).

nombres_propiedades_color_tablero([], _, Acc, Acc).
nombres_propiedades_color_tablero([propiedad(N,_,C)|R], Color, Acc, Out) :-
    (C == Color -> nombres_propiedades_color_tablero(R, Color, [N|Acc], Out)
    ; nombres_propiedades_color_tablero(R, Color, Acc, Out)
    ).
nombres_propiedades_color_tablero([_|R], Color, Acc, Out) :-
    nombres_propiedades_color_tablero(R, Color, Acc, Out).

jugador_posee_todos(_Props, []).
jugador_posee_todos(Props, [N|R]) :-
    tiene_prop_nombre(Props, N),
    jugador_posee_todos(Props, R).

tiene_prop_nombre([prop(N,_,_,_)|_], N) :- !.
tiene_prop_nombre([_|R], N) :- tiene_prop_nombre(R, N).

% ---------- Reglas por casilla ----------
aplicar_reglas_casilla(Casilla, Jug0, Resto0, BP0, BPFinal, Caja0, CajaFinal, Dados0, DadosFinal, JugFinal, RestoFinal, M0, MFinal, Iter) :-
    aplicar_reglas_loop(Casilla, Jug0, Resto0, BP0, BPFinal, Caja0, CajaFinal, Dados0, DadosFinal, JugFinal, RestoFinal, M0, MFinal, 0, Iter).

aplicar_reglas_loop(Casilla, Jug0, Resto0, BP0, BP2, Caja0, Caja2, Dados0, Dados2, Jug2, Resto2, M0, M2, Acc, Iter) :-
    aplicar_una_vez(Casilla, Jug0, Resto0, BP0, BP1, Caja0, Caja1, Dados0, Dados1, Jug1, Resto1, M0, M1, Cambio),
    Acc1 is Acc + 1,
    (Cambio == si, Jug1 \== eliminado, Acc1 < 10 ->
        aplicar_reglas_loop(Casilla, Jug1, Resto1, BP1, BP2, Caja1, Caja2, Dados1, Dados2, Jug2, Resto2, M1, M2, Acc1, Iter)
    ; BP2=BP1, Caja2=Caja1, Dados2=Dados1, Jug2=Jug1, Resto2=Resto1, M2=M1, Iter=Acc1).

aplicar_una_vez(Casilla, Jug0, Resto0, BP0, BP1, Caja0, Caja1, Dados0, Dados1, JugOut, RestoOut, M0, MOut, Cambio) :-
    ( Casilla = salida ->
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no
    ; Casilla = visita_carcel ->
        nl, write('Visita carcel: no pasa nada.'), nl,
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no
    ; Casilla = carcel ->
        nl, write('CARCEL: vas a VISITA CARCEL y quedas encerrado (3 intentos).'), nl,
        set_pos_y_carcel(Jug0, 11, 3, JugTmp),
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Jug1=JugTmp, Resto1=Resto0, M1=M0, Cambio0=si
    ; Casilla = parking ->
        cobrar_parking(Jug0, Caja0, JugTmp, CajaTmp),
        BP1=BP0, Caja1=CajaTmp, Dados1=Dados0, Jug1=JugTmp, Resto1=Resto0, M1=M0, Cambio0=si
    ; Casilla = impuesto(_) ->
        pagar_impuesto(Jug0, Caja0, JugTmp, CajaTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=Dados0, Jug1=JugTmp, Resto1=Resto0, Cambio0=si
    ; Casilla = suerte(_) ->
        jugar_suerte(Jug0, Caja0, CajaTmp, Dados0, DadosTmp, JugTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=DadosTmp, Jug1=JugTmp, Resto1=Resto0, Cambio0=si
    ; Casilla = casino ->
        jugar_casino_interactivo(Jug0, Caja0, CajaTmp, Dados0, DadosTmp, JugTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=DadosTmp, Jug1=JugTmp, Resto1=Resto0, Cambio0=si
    ; Casilla = estacion(Nom) ->
        gestionar_estacion(Nom, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio0),
        Caja1=Caja0, Dados1=Dados0
    ; Casilla = propiedad(Nom,Precio,Color) ->
        gestionar_propiedad(Nom,Precio,Color, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio0),
        Caja1=Caja0, Dados1=Dados0
    ),
    resolver_bancarrota_jugador_y_banco(Jug1, Resto1, BP1, BPX, JugX, RestoX, M1, M2),
    JugOut=JugX, RestoOut=RestoX, BP1=BPX, MOut=M2,
    (Cambio0 == si ; JugX == eliminado -> Cambio = si ; Cambio = no).

% ---------- Impuesto / Suerte / Parking / Casino ----------
pagar_impuesto(jugador(N,Pos,Din,Props,Carc), Caja0, jugador(N,Pos,Din2,Props,Carc), Caja1, M0, M1) :-
    pago_impuesto(P),
    Din2 is Din - P,
    Caja1 is Caja0 + P,
    inc_impuestos(M0, M1),
    nl, write('Impuesto: -'), write(P), write(' (a caja especial).'), nl.

jugar_suerte(jugador(N,Pos,Din,Props,Carc), Caja0, Caja1, Dados0, Dados1, jugador(N,Pos,Din2,Props,Carc), M0, M2) :-
    tirar_un_dado(Dados0, Dados1, D, M0, M1),
    suerte_delta(SD),
    (0 is D mod 2 ->
        Din2 is Din + SD,
        Caja1 = Caja0,
        nl, write('SUERTE: dado='), write(D), write(' par => +'), write(SD), nl
    ;   Din2 is Din - SD,
        Caja1 is Caja0 + SD,
        nl, write('SUERTE: dado='), write(D), write(' impar => -'), write(SD),
        write(' (a caja especial)'), nl
    ),
    inc_suertes(M1, M2).

cobrar_parking(jugador(N,Pos,Din,Props,Carc), Caja0, jugador(N,Pos,Din2,Props,Carc), Caja1) :-
    Premio is Caja0 // 2,
    Din2 is Din + Premio,
    Caja1 is Caja0 - Premio,
    nl, write('PARKING: cobras 50% caja = '), write(Premio), nl.

jugar_casino_interactivo(Jug0, Caja0, Caja1, Dados0, Dados1, Jug1, M0, M2) :-
    nl, write('CASINO.'), nl,
    read_yes_no('Quieres jugar? (si/no)', R),
    (R == no ->
        Jug1 = Jug0, Caja1 = Caja0, Dados1 = Dados0, M2 = M0,
        write('No juegas.'), nl
    ; read_choice_int('Apuesta (100/200/500/1000): ', [100,200,500,1000], Apuesta),
      Jug0 = jugador(N,Pos,Din,Props,Carc),
      (Din < Apuesta ->
          write('No tienes dinero para esa apuesta. No juegas.'), nl,
          Jug1=Jug0, Caja1=Caja0, Dados1=Dados0, M2=M0
      ; tirar_un_dado(Dados0, Dados1, D, M0, M1),
        (D=:=1 ; D=:=6 ->
            Gan is Apuesta*3,
            Din2 is Din + Gan,
            Jug1 = jugador(N,Pos,Din2,Props,Carc),
            Caja1 = Caja0,
            nl, write('CASINO: dado='), write(D), write(' => ganas '), write(Gan), nl
        ;   Din2 is Din - Apuesta,
            Jug1 = jugador(N,Pos,Din2,Props,Carc),
            Caja1 is Caja0 + Apuesta,
            nl, write('CASINO: dado='), write(D), write(' => pierdes '), write(Apuesta),
            write(' (a caja especial)'), nl
        ),
        inc_casinos(M1, M2)
      )
    ).

% ---------- Propiedad / Estacion ----------
gestionar_propiedad(Nom,Precio,Color, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio) :-
    (banco_posee(Nom, BP0) ->
        nl, write('Propiedad del BANCO: '), write(Nom), write(' precio='), write(Precio), nl,
        Jug0 = jugador(_,_,Din,_,_),
        (Din >= Precio ->
            nl,
            write('Comprar? Dinero actual: '), write(Din), write(' (si/no)'),
            nl,
            read_yes_no('', R),
            (R==si ->
                comprar_propiedad(Nom,Precio,Color, Jug0, BP0, Jug1, BP1, M0, M1),
                Resto1 = Resto0, Cambio = si
            ; Jug1=Jug0, BP1=BP0, Resto1=Resto0, M1=M0, Cambio = no)
        ;   write('No tienes fondos.'), nl,
            Jug1=Jug0, BP1=BP0, Resto1=Resto0, M1=M0, Cambio=no)
    ;   encontrar_duenio(Nom, Resto0, Duenio, RestoSin, Idx),
        calcular_alquiler_prop(Precio, Duenio, Nom, Color, Alq),
        nl, write('Propiedad de otro jugador. Alquiler='), write(Alq), nl,
        pagar_a_otro(Jug0, Duenio, Alq, JugTmp, DuenioTmp),
        reinsertar_duenio(RestoSin, Idx, DuenioTmp, Resto1),
        Jug1 = JugTmp, BP1 = BP0, inc_alquileres(M0, M1), Cambio = si
    ).

gestionar_estacion(Nom, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio) :-
    estacion_precio(Precio),
    (banco_posee(Nom, BP0) ->
        nl, write('Estacion del BANCO: '), write(Nom), write(' precio='), write(Precio), nl,
        Jug0 = jugador(_,_,Din,_,_),
        (Din >= Precio ->
            nl,
            write('Comprar? Dinero actual: '), write(Din), write(' (si/no)'),
            nl,
            read_yes_no('', R),
            (R==si ->
                comprar_estacion(Nom,Precio, Jug0, BP0, Jug1, BP1, M0, M1),
                Resto1=Resto0, Cambio=si
            ; Jug1=Jug0, BP1=BP0, Resto1=Resto0, M1=M0, Cambio=no)
        ; write('No tienes fondos.'), nl,
          Jug1=Jug0, BP1=BP0, Resto1=Resto0, M1=M0, Cambio=no)
    ;   encontrar_duenio(Nom, Resto0, Duenio, RestoSin, Idx),
        estacion_alquiler(Alq),
        nl, write('Estacion de otro jugador. Alquiler='), write(Alq), nl,
        pagar_a_otro(Jug0, Duenio, Alq, JugTmp, DuenioTmp),
        reinsertar_duenio(RestoSin, Idx, DuenioTmp, Resto1),
        Jug1 = JugTmp, BP1 = BP0, inc_alquileres(M0, M1), Cambio=si
    ).

comprar_propiedad(Nom,Precio,Color, jugador(N,Pos,Din,Props,Carc), BP0,
                 jugador(N,Pos,Din2,[prop(Nom,Precio,Color,0)|Props],Carc), BP1, M0, M1) :-
    Din2 is Din - Precio,
    quitar_de_banco(Nom, BP0, BP1),
    inc_compras(M0, M1),
    nl, write('Compra: '), write(Nom), write(' (-'), write(Precio), write(').'), nl.

comprar_estacion(Nom,Precio, jugador(N,Pos,Din,Props,Carc), BP0,
                jugador(N,Pos,Din2,[prop(Nom,Precio,estacion,0)|Props],Carc), BP1, M0, M1) :-
    Din2 is Din - Precio,
    quitar_de_banco(Nom, BP0, BP1),
    inc_compras(M0, M1),
    nl, write('Compra: '), write(Nom), write(' (-'), write(Precio), write(').'), nl.

calcular_alquiler_prop(Precio, jugador(_,_,_,Props,_), Nom, Color, Alq) :-
    alquiler_propiedad_divisor(Div),
    Base is Precio // Div,
    casas_de(Props, Nom, Precio, Color, Casas),
    incremento_alquiler_por_casa(Inc),
    Alq is Base + Casas*Inc.

casas_de([prop(Nom,Precio,Color,C)|_], Nom, Precio, Color, C) :- !.
casas_de([_|R], Nom, Precio, Color, C) :- casas_de(R, Nom, Precio, Color, C).
casas_de([], _, _, _, 0).

pagar_a_otro(jugador(N,Pos,Din,Props,Carc),
            jugador(N2,Pos2,DinO,PropsO,CarcO),
            Monto,
            jugador(N,Pos,Din2,Props,Carc),
            jugador(N2,Pos2,DinO2,PropsO,CarcO)) :-
    Din2 is Din - Monto,
    DinO2 is DinO + Monto,
    nl, write('Pagas '), write(Monto), write(' a '), write(N2), nl.

% ---------- Bancarrota ----------
resolver_bancarrota_jugador_y_banco(Jug0, Resto0, BP0, BPFinal, JugFinal, RestoFinal, M0, MFinal) :-
    ( Jug0 = jugador(N,Pos,Din,Props,Carc),
      Din < 0 ->
        nl, write('*** BANCARROTA: '), write(N), write(' (dinero='), write(Din), write(') ***'), nl,
        inc_bancarrotas(M0, M1),
        valor_venta_20(Props, Venta),
        nl, write('El banco compra tus propiedades por '), write(Venta), nl,
        Din2 is Din + Venta,
        anexar_listas(BP0, Props, BP1),
        (Din2 >= 0 ->
            nl, write('Tras liquidacion sigues en juego con dinero='), write(Din2), nl,
            JugFinal = jugador(N,Pos,Din2,[],Carc),
            RestoFinal = Resto0,
            BPFinal = BP1,
            MFinal = M1
        ;   nl, write('Sigues en negativo => ELIMINADO.'), nl,
            JugFinal = eliminado,
            RestoFinal = Resto0,
            BPFinal = BP1,
            MFinal = M1
        )
    ; JugFinal = Jug0, RestoFinal = Resto0, BPFinal = BP0, MFinal = M0
    ).

valor_venta_20([], 0).
valor_venta_20([prop(_,P,_,_)|R], Total) :-
    valor_venta_20(R, T2),
    V is (P * 20) // 100,
    Total is V + T2.

% ---------- BancoProps ----------
banco_posee(Nom, [prop(Nom,_,_,_)|_]) :- !.
banco_posee(Nom, [_|R]) :- banco_posee(Nom, R).

quitar_de_banco(_, [], []).
quitar_de_banco(Nom, [prop(Nom,_,_,_)|R], R) :- !.
quitar_de_banco(Nom, [X|R], [X|R2]) :- quitar_de_banco(Nom, R, R2).

% ---------- Duenio ----------
encontrar_duenio(Nom, Resto, Duenio, RestoSinDuenio, Idx) :-
    encontrar_duenio_loop(Nom, Resto, 0, Duenio, RestoSinDuenio, Idx).

encontrar_duenio_loop(_, [], _, _, _, _) :- fail.
encontrar_duenio_loop(Nom, [J|R], I, J, R, I) :-
    J = jugador(_,_,_,Props,_),
    tiene_prop_nombre(Props, Nom), !.
encontrar_duenio_loop(Nom, [J|R], I, D, [J|R2], Idx) :-
    I2 is I+1,
    encontrar_duenio_loop(Nom, R, I2, D, R2, Idx).

reinsertar_duenio(RestoSin, Idx, Duenio, RestoOut) :-
    insertar_en_indice(RestoSin, Idx, Duenio, RestoOut).

% ---------- Utilidades listas ----------
length_list([], 0).
length_list([_|R], L) :- length_list(R, L1), L is L1+1.

nth1_list(1, [X|_], X) :- !.
nth1_list(N, [_|R], X) :- N>1, N2 is N-1, nth1_list(N2, R, X).

reverse_list(L, R) :- rev_acc(L, [], R).
rev_acc([], Acc, Acc).
rev_acc([X|R], Acc, Out) :- rev_acc(R, [X|Acc], Out).

anexar_listas([], L, L).
anexar_listas([X|R], L, [X|Out]) :- anexar_listas(R, L, Out).

member_atom(X, [X|_]) :- !.
member_atom(X, [_|R]) :- member_atom(X, R).

seleccionar_por_indice([X|R], 0, X, R) :- !.
seleccionar_por_indice([X|R], I, Elem, [X|R2]) :-
    I > 0, I2 is I-1, seleccionar_por_indice(R, I2, Elem, R2).

insertar_en_indice(L, 0, X, [X|L]) :- !.
insertar_en_indice([H|T], I, X, [H|R]) :-
    I > 0, I2 is I-1, insertar_en_indice(T, I2, X, R).

reemplazar_prop_en_lista([], _, _, []).
reemplazar_prop_en_lista([Old|R], Old, New, [New|R]) :- !.
reemplazar_prop_en_lista([X|R], Old, New, [X|R2]) :- reemplazar_prop_en_lista(R, Old, New, R2).

set_pos_y_carcel(jugador(N,_Pos,Din,Props,_), Pos2, Carc2, jugador(N,Pos2,Din,Props,Carc2)).

% ---------- Escenarios ----------
escenario(1, Partida) :-
    banco_props_inicial(BP),
    metricas_inicial(M),
    dados_por_defecto(D),
    azar_por_defecto(A),
    J1 = jugador(ana,1,300,[],0),
    J2 = jugador(bob,1,300,[],0),
    J3 = jugador(carla,1,300,[],0),
    Partida = partida(BP,0,[J1,J2,J3],0,0,50,D,A,M).

escenario(2, Partida) :-
    banco_props_inicial(BP0),
    quitar_de_banco(morado1, BP0, BP1),
    quitar_de_banco(morado2, BP1, BP2),
    metricas_inicial(M),
    dados_por_defecto(D),
    azar_por_defecto(A),
    J1 = jugador(ana,12,250,[prop(morado1,60,morado,1), prop(morado2,60,morado,0)],0),
    J2 = jugador(bob,10,300,[],0),
    J3 = jugador(carla,20,300,[],0),
    Partida = partida(BP2,0,[J1,J2,J3],0,0,50,D,A,M).

escenario(3, Partida) :-
    banco_props_inicial(BP0),
    quitar_de_banco(rojo1, BP0, BP1),
    metricas_inicial(M),
    dados_por_defecto(D),
    azar_por_defecto(A),
    J1 = jugador(ana,22,300,[],0),
    J2 = jugador(bob,23,10,[prop(rojo1,220,rojo,0)],0),
    J3 = jugador(carla,24,300,[],0),
    Partida = partida(BP1,200,[J1,J2,J3],1,0,50,D,A,M).

escenario(4, Partida) :-
    banco_props_inicial(BP0),
    quitar_de_banco(gris1, BP0, BP1),
    quitar_de_banco(gris2, BP1, BP2),
    quitar_de_banco(estacion1, BP2, BP3),
    metricas_inicial(M),
    dados_por_defecto(D),
    azar_por_defecto(A),
    J1 = jugador(ana,6,200,[prop(gris1,100,gris,0), prop(gris2,100,gris,2), prop(estacion1,200,estacion,0)],0),
    J2 = jugador(bob,5,300,[],0),
    J3 = jugador(carla,8,300,[],0),
    Partida = partida(BP3,150,[J1,J2,J3],1,0,50,D,A,M).

escenario(5, Partida) :-
    escenario(1, P0),
    P0 = partida(BP,Caja,Js,Idx,_,_,D,A,M),
    Partida = partida(BP,Caja,Js,Idx,0,10,D,A,M).

% ---------- Ranking ----------
ranking_jugadores(partida(_,_,Jugadores,_,_,_,_,_,_), Ranking) :-
    jugadores_a_items(Jugadores, Items),
    sort_items_desc(Items, Ranking).

jugadores_a_items([], []).
jugadores_a_items([jugador(N,_,Din,_,_)|R], [item(N,Din)|R2]) :- jugadores_a_items(R, R2).

sort_items_desc(L, Sorted) :- bubble_desc(L, Sorted).

bubble_desc(L, Sorted) :-
    bubble_pass(L, L2, Swapped),
    (Swapped == no -> Sorted = L2 ; bubble_desc(L2, Sorted)).

bubble_pass([X], [X], no).
bubble_pass([item(N1,D1), item(N2,D2)|R], [item(N1,D1)|R2], Swapped) :-
    D1 >= D2, !,
    bubble_pass([item(N2,D2)|R], R2, Sw2),
    Swapped = Sw2.
bubble_pass([item(N1,D1), item(N2,D2)|R], [item(N2,D2)|R2], si) :-
    D1 < D2,
    bubble_pass([item(N1,D1)|R], R2, _).
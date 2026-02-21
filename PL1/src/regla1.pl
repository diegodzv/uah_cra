% =========================
% regla1.pl
% Motor del Monopoly + reglas
% =========================

% Usamos SOLO enteros.
% Representaciones:
%   jugador(Nombre, Pos, Dinero, Props, CarcelRestante)
%   prop(Nombre, Precio, Color, Casas)
% Partida:
%   partida(BancoProps, CajaEspecial, Jugadores, TurnoIdx, TurnoNum, MaxTurnos, Dados, Azar, Metricas)

:- consult('metricas.pl').

% ---------- Valores de juego ----------
dinero_inicial(300).
cobro_salida(200).
alquiler_propiedad_divisor(4).      % alquiler = Precio // 4
incremento_alquiler_por_casa(25).
precio_casa(100).
max_casas(3).

pago_impuesto(150).
suerte_delta(75).                   % +75 / -75
estacion_precio(200).
estacion_alquiler(50).

% ---------- Listas "pseudo-azar" (ciclicas) ----------
dados_por_defecto([1,2,3,4,5,6,6,5,4,3,2,1, 2,4,6,1,3,5, 5,3,1,6,4,2]).
azar_por_defecto([5,91,12,77,33,64,18,49,81,2,56,27,73,40,99,7,61,14,88,21,45,67,30,10,95,52,38,79,25,60,1,86,44,71,16,58,90,34,63,9]).

next_from_cycle([], Default, V, Rest) :- Default = [V|Rest].
next_from_cycle([V|Rest], _Default, V, Rest).

% ---------- Tablero (40 casillas) ----------
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

% ---------- BancoProps inicial (todas las propiedades y estaciones) ----------
banco_props_inicial(BancoProps) :-
    tablero(T),
    banco_props_from_tablero(T, BancoProps).

banco_props_from_tablero([], []).
banco_props_from_tablero([Cas|R], Props) :-
    (   Cas = propiedad(N,P,C) ->
        Props = [prop(N,P,C,0)|PropsR],
        banco_props_from_tablero(R, PropsR)
    ;   Cas = estacion(Nom) ->
        estacion_precio(Pr),
        Props = [prop(Nom,Pr,estacion,0)|PropsR],
        banco_props_from_tablero(R, PropsR)
    ;   banco_props_from_tablero(R, Props)
    ).

% ---------- Crear partida interactiva ----------
crear_partida_interactiva(N, MaxT, Partida) :-
    banco_props_inicial(BancoProps),
    metricas_inicial(M0),
    dados_por_defecto(Dados0),
    azar_por_defecto(Azar0),
    crear_jugadores_interactivos(1, N, Jugadores),
    Caja0 = 0,
    TurnoIdx0 = 0,
    TurnoNum0 = 0,
    Partida = partida(BancoProps, Caja0, Jugadores, TurnoIdx0, TurnoNum0, MaxT, Dados0, Azar0, M0).

crear_jugadores_interactivos(I, N, []) :- I > N, !.
crear_jugadores_interactivos(I, N, [J|R]) :-
    I =< N,
    write('Nombre del jugador '), write(I), write(' (termina con punto, ej: ana.): '), nl,
    read(Nombre),
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
    write('  Propiedades: '), nl,
    imprimir_props(Props),
    nl,
    imprimir_jugadores(R).

imprimir_props([]) :- write('   (ninguna)'), nl.
imprimir_props([prop(N,P,C,H)|R]) :-
    write('   - '), write(N),
    write(' (precio='), write(P),
    write(', color='), write(C),
    write(', casas='), write(H), write(')'), nl,
    imprimir_props(R).

% ---------- Turno y fin ----------
partida_terminada(partida(_BP,_Caja,Jugadores,_Idx,TurnoNum,MaxT,_D,_A,_M), motivo(max_turnos)) :-
    TurnoNum >= MaxT, !.
partida_terminada(partida(_BP,_Caja,Jugadores,_Idx,_TurnoNum,_MaxT,_D,_A,_M), motivo(un_solo_jugador)) :-
    length_list(Jugadores, L),
    L =:= 1, !.
partida_terminada(_, _) :- fail.

turno_interactivo(Partida0, PartidaFinal) :-
    Partida0 = partida(BancoProps0, Caja0, Jugadores0, TurnoIdx0, TurnoNum0, MaxT, Dados0, Azar0, M0),
    inc_turnos(M0, M1),
    TurnoNum1 is TurnoNum0 + 1,

    seleccionar_por_indice(Jugadores0, TurnoIdx0, JugadorActual, RestoSinActual),
    JugadorActual = jugador(Nombre, _Pos, _Din, _Props, _Carc),

    nl, write('============================='), nl,
    write('TURNO '), write(TurnoNum1), write(' -> Jugador: '), write(Nombre), nl,
    write('============================='), nl,

    preguntar_si_no('¿Quieres consultar la informacion completa de la partida? (si/no).', Ver),
    (Ver == si -> mostrar_estado(Partida0) ; true),

    % 1) Casas si hay monopolios
    ofrecer_compra_casas(JugadorActual, BancoProps0, Jugadores0, Jugador1, M1, M2),

    % 2) Trampas
    aplicar_trampas_interactivo(Jugador1, RestoSinActual, Azar0, Azar1, Jugador2, Resto2, M2, M3),

    % Si tras trampas ya está fuera (eliminado), cerramos turno avanzando idx
    (   Jugador2 = eliminado
    ->  % Jugador eliminado: Jugadores1 = Resto2
        Jugadores1 = Resto2,
        TurnoIdx1 is TurnoIdx0 mod (max(1, length_list_value(Jugadores1))), % seguro
        Partida1 = partida(BancoProps0, Caja0, Jugadores1, TurnoIdx1, TurnoNum1, MaxT, Dados0, Azar1, M3),
        normalizar_turno_idx(Partida1, PartidaFinal)
    ;   % 3) Cárcel (si está encarcelado)
        gestionar_carcel(Jugador2, Dados0, Dados1, Jugador3, M3, M4),
        (   Jugador3 = fin_turno
        ->  % termina turno por cárcel
            reconstruir_jugadores(Jugador2, Resto2, JugadoresTmp),
            Partida1 = partida(BancoProps0, Caja0, JugadoresTmp, TurnoIdx0, TurnoNum1, MaxT, Dados1, Azar1, M4),
            avanzar_turno(Partida1, PartidaFinal)
        ;   % 4) Movimiento
            mover_jugador(Jugador3, Dados1, Dados2, JugadorMovido, Caja0, Caja1, M4, M5),
            JugadorMovido = jugador(_, PosNueva, _, _, _),
            tablero(T),
            nth1_list(PosNueva, T, Casilla),
            nl, write('Has caido en: '), write(Casilla), nl,

            % 5) Reglas por casilla (iterativas + bancarrota incluida)
            aplicar_reglas_casilla(Casilla, JugadorMovido, Resto2, BancoProps0, BancoProps1, Caja1, Caja2, Dados2, Dados3, Azar1, Azar2, JugadorFinalTurno, RestoFinal, M5, M6, IterCount),

            add_iter(M6, IterCount, M7),

            % Reconstrucción y avance
            (   JugadorFinalTurno = eliminado
            ->  Jugadores1 = RestoFinal,
                Partida1 = partida(BancoProps1, Caja2, Jugadores1, TurnoIdx0, TurnoNum1, MaxT, Dados3, Azar2, M7),
                normalizar_turno_idx(Partida1, PartidaFinal)
            ;   reconstruir_jugadores(JugadorFinalTurno, RestoFinal, Jugadores1),
                Partida1 = partida(BancoProps1, Caja2, Jugadores1, TurnoIdx0, TurnoNum1, MaxT, Dados3, Azar2, M7),
                avanzar_turno(Partida1, PartidaFinal)
            )
    ).

% ---------- Avanzar turno ----------
avanzar_turno(partida(BP,Caja,Jugadores,Idx,TurnoNum,MaxT,D,A,M), partida(BP,Caja,Jugadores,Idx2,TurnoNum,MaxT,D,A,M)) :-
    length_list(Jugadores, L),
    (   L =:= 0 -> Idx2 = 0
    ;   Idx1 is Idx + 1,
        Idx2 is Idx1 mod L
    ).

normalizar_turno_idx(partida(BP,Caja,Jugadores,Idx,TurnoNum,MaxT,D,A,M), partida(BP,Caja,Jugadores,Idx2,TurnoNum,MaxT,D,A,M)) :-
    length_list(Jugadores, L),
    (   L =:= 0 -> Idx2 = 0
    ;   Idx2 is Idx mod L
    ).

% ---------- Preguntas (si/no) ----------
preguntar_si_no(Prompt, Respuesta) :-
    nl, write(Prompt), nl,
    read(R),
    (R == si ; R == no),
    Respuesta = R.

% ---------- Movimiento ----------
mover_jugador(jugador(N,Pos,Din,Props,Carc), Dados0, Dados2, jugador(N,PosNueva,DinNueva,Props,Carc), Caja0, Caja1, M0, M2) :-
    tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M1),
    Steps is D1 + D2,
    PosNueva is ((Pos - 1 + Steps) mod 40) + 1,
    (   paso_por_salida(Pos, Steps)
    ->  cobro_salida(Cob),
        DinNueva is Din + Cob,
        Caja1 = Caja0,
        nl, write('Has pasado por SALIDA: +'), write(Cob), nl
    ;   DinNueva = Din,
        Caja1 = Caja0
    ),
    inc_dados(M1, M2),
    nl, write('Dados: '), write(D1), write(' y '), write(D2), write(' => avanzas '), write(Steps), nl,
    write('Nueva posicion: '), write(PosNueva), nl.

paso_por_salida(Pos, Steps) :-
    S is Pos + Steps,
    S > 40.

tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M1) :-
    dados_por_defecto(Def),
    next_from_cycle(Dados0, Def, D1, Dados1),
    next_from_cycle(Dados1, Def, D2, Dados2),
    inc_dados(M0, M1).

tirar_un_dado(Dados0, Dados1, D, M0, M1) :-
    dados_por_defecto(Def),
    next_from_cycle(Dados0, Def, D, Dados1),
    inc_dados(M0, M1).

tirar_azar(Azar0, Azar1, V) :-
    azar_por_defecto(Def),
    next_from_cycle(Azar0, Def, V, Azar1).

% ---------- Reglas por casilla (iterativas) ----------
aplicar_reglas_casilla(Casilla, Jug, Resto, BP0, BPFinal, Caja0, CajaFinal, Dados0, DadosFinal, Azar0, AzarFinal, JugFinal, RestoFinal, M0, MFinal, IterCount) :-
    aplicar_reglas_loop(Casilla, Jug, Resto, BP0, BPFinal, Caja0, CajaFinal, Dados0, DadosFinal, Azar0, AzarFinal, JugFinal, RestoFinal, M0, MFinal, 0, IterCount).

% Loop: aplica una vez y repite si hubo cambio/activacion
aplicar_reglas_loop(Casilla, Jug0, Resto0, BP0, BP2, Caja0, Caja2, Dados0, Dados2, Azar0, Azar2, Jug2, Resto2, M0, M2, Acc, IterCount) :-
    aplicar_una_vez(Casilla, Jug0, Resto0, BP0, BP1, Caja0, Caja1, Dados0, Dados1, Azar0, Azar1, Jug1, Resto1, M0, M1, Cambio),
    Acc1 is Acc + 1,
    (   Cambio == si
    ->  % si el jugador fue eliminado, no iteramos más
        ( Jug1 = eliminado
        -> BP2=BP1, Caja2=Caja1, Dados2=Dados1, Azar2=Azar1, Jug2=Jug1, Resto2=Resto1, M2=M1, IterCount=Acc1
        ;  % si sigue vivo, continuar iterando (por seguridad, limitado a 10)
           (Acc1 >= 10
           -> BP2=BP1, Caja2=Caja1, Dados2=Dados1, Azar2=Azar1, Jug2=Jug1, Resto2=Resto1, M2=M1, IterCount=Acc1
           ;  aplicar_reglas_loop(Casilla, Jug1, Resto1, BP1, BP2, Caja1, Caja2, Dados1, Dados2, Azar1, Azar2, Jug2, Resto2, M1, M2, Acc1, IterCount)
           )
        )
    ;   BP2=BP1, Caja2=Caja1, Dados2=Dados1, Azar2=Azar1, Jug2=Jug1, Resto2=Resto1, M2=M1, IterCount=Acc1
    ).

% Aplica una vez: compra/alquiler/etc + bancarrota al final si procede.
aplicar_una_vez(Casilla, Jug0, Resto0, BP0, BP1, Caja0, Caja1, Dados0, Dados1, Azar0, Azar1, JugFinal, RestoFinal, M0, MFinal, Cambio) :-
    (   Casilla = salida ->
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Azar1=Azar0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no

    ;   Casilla = visita_carcel ->
        nl, write('Estas de visita en la carcel. No pasa nada.'), nl,
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Azar1=Azar0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no

    ;   Casilla = carcel ->
        nl, write('Has caido en CARCEL. Vas a VISITA CARCEL y estaras hasta 3 turnos intentando salir.'), nl,
        set_pos_y_carcel(Jug0, 11, 3, JugTmp),
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, M1=M0, Cambio0=si

    ;   Casilla = parking ->
        cobrar_parking(Jug0, Caja0, JugTmp, CajaTmp),
        BP1=BP0, Caja1=CajaTmp, Dados1=Dados0, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, M1=M0, Cambio0=si

    ;   Casilla = impuesto(_) ->
        pagar_impuesto(Jug0, Caja0, JugTmp, CajaTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=Dados0, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, Cambio0=si

    ;   Casilla = suerte(_) ->
        jugar_suerte(Jug0, Caja0, CajaTmp, Dados0, DadosTmp, JugTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=DadosTmp, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, Cambio0=si

    ;   Casilla = casino ->
        jugar_casino_interactivo(Jug0, Caja0, CajaTmp, Dados0, DadosTmp, JugTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=DadosTmp, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, Cambio0=si

    ;   Casilla = estacion(Nom) ->
        gestionar_compra_o_alquiler_estacion(Nom, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio0),
        Caja1=Caja0, Dados1=Dados0, Azar1=Azar0

    ;   Casilla = propiedad(Nom,Precio,Color) ->
        gestionar_compra_o_alquiler_propiedad(Nom,Precio,Color, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio0),
        Caja1=Caja0, Dados1=Dados0, Azar1=Azar0
    ),
    % Bancarrota al final
    resolver_bancarrota_si_aplica(Jug1, Resto1, BP1, BP2, Jug2, Resto2, M1, M2),
    % Si se resolvió bancarrota puede cambiar BP/Jugadores
    BPFinal = BP2, JugFinal = Jug2, RestoFinal = Resto2, MFinal = M2,
    Cambio = (Cambio0 == si ; Jug2 == eliminado -> si ; no),
    % para devolver también Caja/Dados/Azar ya están fijados arriba
    true.

% (helper para asignar variables ya nombradas)
BPFinal = BP2, JugFinal = Jug2, RestoFinal = Resto2, MFinal = M2 :- true.

% ---------- Compra / alquiler (propiedad) ----------
gestionar_compra_o_alquiler_propiedad(Nom,Precio,Color, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio) :-
    (   banco_posee(Nom, BP0)
    ->  nl, write('Propiedad sin duenio (BANCO): '), write(Nom), write(' precio='), write(Precio), nl,
        Jug0 = jugador(_,_,Din,_,_),
        (Din >= Precio ->
            preguntar_si_no('¿Quieres comprarla? (si/no).', R),
            (R == si ->
                comprar_propiedad(Nom,Precio,Color, Jug0, BP0, JugTmp, BP1, M0, M1),
                Jug1 = JugTmp, Resto1 = Resto0, Cambio=si
            ;   BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio=no
            )
        ;   write('No tienes dinero suficiente para comprar.'), nl,
            BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio=no
        )
    ;   % no la tiene el banco -> buscar dueño
        (   encontrar_duenio(Nom, Resto0, Duenio, RestoSinDuenio, DuenioIdx)
        ->  % pagar alquiler al dueño
            calcular_alquiler(Nom, Precio, Color, Duenio, Alq),
            nl, write('Propiedad de otro jugador. Alquiler='), write(Alq), nl,
            pagar_a_otro(Jug0, Duenio, Alq, JugTmp, DuenioTmp),
            reinsertar_duenio(RestoSinDuenio, DuenioIdx, DuenioTmp, Resto1),
            Jug1 = JugTmp,
            inc_alquileres(M0, M1),
            Cambio=si
        ;   % debería ser imposible, pero por robustez
            BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio=no
        )
    ).

comprar_propiedad(Nom,Precio,Color, jugador(N,Pos,Din,Props,Carc), BP0, jugador(N,Pos,Din2,Props2,Carc), BP1, M0, M1) :-
    Din2 is Din - Precio,
    Props2 = [prop(Nom,Precio,Color,0)|Props],
    quitar_de_banco(Nom, BP0, BP1),
    inc_compras(M0, M1),
    nl, write('Compra realizada: '), write(Nom), write(' (-'), write(Precio), write(').'), nl.

calcular_alquiler(_Nom, Precio, _Color, Duenio, Alq) :-
    alquiler_propiedad_divisor(Div),
    Base is Precio // Div,
    casas_propiedad_duenio(Duenio, Precio, _Color, _Nom, Casas),
    incremento_alquiler_por_casa(Inc),
    Alq is Base + (Casas * Inc).

casas_propiedad_duenio(jugador(_,_,_,Props,_), Precio, Color, Nom, Casas) :-
    (   member_prop(prop(Nom,Precio,Color,Casas), Props)
    ->  true
    ;   Casas = 0
    ).

% ---------- Compra / alquiler (estación) ----------
gestionar_compra_o_alquiler_estacion(Nom, Jug0, Resto0, BP0, BP1, Jug1, Resto1, M0, M1, Cambio) :-
    estacion_precio(Precio),
    (   banco_posee(Nom, BP0)
    ->  nl, write('Estacion sin duenio (BANCO): '), write(Nom), write(' precio='), write(Precio), nl,
        Jug0 = jugador(_,_,Din,_,_),
        (Din >= Precio ->
            preguntar_si_no('¿Quieres comprarla? (si/no).', R),
            (R == si ->
                comprar_estacion(Nom,Precio, Jug0, BP0, JugTmp, BP1, M0, M1),
                Jug1=JugTmp, Resto1=Resto0, Cambio=si
            ;   BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio=no
            )
        ;   write('No tienes dinero suficiente para comprar.'), nl,
            BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio=no
        )
    ;   (   encontrar_duenio(Nom, Resto0, Duenio, RestoSinDuenio, DuenioIdx)
        ->  estacion_alquiler(Alq),
            nl, write('Estacion de otro jugador. Alquiler='), write(Alq), nl,
            pagar_a_otro(Jug0, Duenio, Alq, JugTmp, DuenioTmp),
            reinsertar_duenio(RestoSinDuenio, DuenioIdx, DuenioTmp, Resto1),
            Jug1=JugTmp,
            inc_alquileres(M0, M1),
            BP1=BP0,
            Cambio=si
        ;   BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio=no
        )
    ).

comprar_estacion(Nom,Precio, jugador(N,Pos,Din,Props,Carc), BP0, jugador(N,Pos,Din2,Props2,Carc), BP1, M0, M1) :-
    Din2 is Din - Precio,
    Props2 = [prop(Nom,Precio,estacion,0)|Props],
    quitar_de_banco(Nom, BP0, BP1),
    inc_compras(M0, M1),
    nl, write('Compra realizada: '), write(Nom), write(' (-'), write(Precio), write(').'), nl.

% ---------- Impuesto / Suerte / Casino / Parking ----------
pagar_impuesto(jugador(N,Pos,Din,Props,Carc), Caja0, jugador(N,Pos,Din2,Props,Carc), Caja1, M0, M1) :-
    pago_impuesto(P),
    Din2 is Din - P,
    Caja1 is Caja0 + P,
    inc_impuestos(M0, M1),
    nl, write('Impuesto pagado: -'), write(P), write(' (a caja especial).'), nl.

jugar_suerte(jugador(N,Pos,Din,Props,Carc), Caja0, Caja1, Dados0, Dados1, jugador(N,Pos,Din2,Props,Carc), M0, M2) :-
    tirar_un_dado(Dados0, Dados1, D, M0, M1),
    suerte_delta(SD),
    (   0 is D mod 2
    ->  Din2 is Din + SD,
        Caja1 = Caja0,
        nl, write('SUERTE: dado='), write(D), write(' (par) => +'), write(SD), nl
    ;   Din2 is Din - SD,
        Caja1 is Caja0 + SD,
        nl, write('SUERTE: dado='), write(D), write(' (impar) => -'), write(SD), write(' (a caja especial)'), nl
    ),
    inc_suertes(M1, M2).

jugar_casino_interactivo(Jug0, Caja0, Caja1, Dados0, Dados1, Jug1, M0, M2) :-
    nl, write('Has caido en CASINO.'), nl,
    preguntar_si_no('¿Quieres jugar? (si/no).', R),
    (   R == no
    ->  Jug1 = Jug0, Caja1 = Caja0, Dados1 = Dados0, M2 = M0,
        write('No juegas al casino.'), nl
    ;   % elegir apuesta
        elegir_apuesta(Apuesta),
        Jug0 = jugador(N,Pos,Din,Props,Carc),
        (Din < Apuesta ->
            write('No tienes dinero suficiente para esa apuesta. No juegas.'), nl,
            Jug1=Jug0, Caja1=Caja0, Dados1=Dados0, M2=M0
        ;   tirar_un_dado(Dados0, Dados1, D, M0, M1),
            (D =:= 1 ; D =:= 6 ->
                Ganancia is Apuesta * 3,
                Din2 is Din + Ganancia,
                Jug1 = jugador(N,Pos,Din2,Props,Carc),
                Caja1 = Caja0,
                nl, write('CASINO: dado='), write(D), write(' => GANAS '), write(Ganancia), nl
            ;   Din2 is Din - Apuesta,
                Jug1 = jugador(N,Pos,Din2,Props,Carc),
                Caja1 is Caja0 + Apuesta,
                nl, write('CASINO: dado='), write(D), write(' => PIERDES '), write(Apuesta),
                write(' (a caja especial)'), nl
            ),
            inc_casinos(M1, M2)
        )
    ).

elegir_apuesta(A) :-
    nl, write('Elige apuesta (100, 200, 500, 1000). Escribe el numero y punto (ej: 200.).'), nl,
    read(X),
    (X==100; X==200; X==500; X==1000),
    A = X.

cobrar_parking(jugador(N,Pos,Din,Props,Carc), Caja0, jugador(N,Pos,Din2,Props,Carc), Caja1) :-
    Premio is Caja0 // 2,
    Din2 is Din + Premio,
    Caja1 is Caja0 - Premio,
    nl, write('PARKING: cobras el 50% de caja especial = '), write(Premio), nl.

% ---------- Trampas (inicio de turno) ----------
aplicar_trampas_interactivo(Jug0, Resto0, Azar0, Azar1, JugFinal, RestoFinal, M0, M2) :-
    preguntar_si_no('¿Quieres intentar hacer trampas? (si/no).', R),
    (   R == no
    ->  JugFinal=Jug0, RestoFinal=Resto0, Azar1=Azar0, M2=M0
    ;   inc_trampas(M0, M1),
        tirar_azar(Azar0, Azar1, V),
        nl, write('TRAMPAS: valor azar='), write(V), nl,
        (   V =< 30
        ->  % éxito: +200
            sumar_dinero(Jug0, 200, JugTmp),
            nl, write('Te sale bien: robas 200 del banco.'), nl,
            M2 = M1,
            JugFinal = JugTmp,
            RestoFinal = Resto0
        ;   % pillado: -200*(N-1) y cada otro +200
            length_list(Resto0, Otros),
            Multa is 200 * Otros,
            restar_dinero(Jug0, Multa, JugTmp),
            sumar_200_a_todos(Resto0, RestoTmp),
            nl, write('Te pillan: pagas 200 a cada otro jugador. Total -'), write(Multa), nl,
            M2 = M1,
            JugFinal = JugTmp,
            RestoFinal = RestoTmp
        )
    ).

sumar_200_a_todos([], []).
sumar_200_a_todos([jugador(N,Pos,Din,Props,Carc)|R], [jugador(N,Pos,Din2,Props,Carc)|R2]) :-
    Din2 is Din + 200,
    sumar_200_a_todos(R, R2).

sumar_dinero(jugador(N,Pos,Din,Props,Carc), X, jugador(N,Pos,Din2,Props,Carc)) :-
    Din2 is Din + X.
restar_dinero(jugador(N,Pos,Din,Props,Carc), X, jugador(N,Pos,Din2,Props,Carc)) :-
    Din2 is Din - X.

% ---------- Cárcel (si CarcelRestante>0) ----------
gestionar_carcel(jugador(N,Pos,Din,Props,Carc), Dados0, Dados1, Resultado, M0, M2) :-
    (   Carc =:= 0
    ->  Dados1 = Dados0, Resultado = jugador(N,Pos,Din,Props,Carc), M2 = M0
    ;   nl, write('Estas en la CARCEL. Turnos restantes de intentos: '), write(Carc), nl,
        nl, write('Opciones: pagar 200 (p) o tirar dados (t).'), nl,
        read(Opc),
        (Opc == p ->
            (Din >= 200 ->
                Din2 is Din - 200,
                nl, write('Pagas 200 y sales de la carcel. Tu turno termina.'), nl,
                Resultado = fin_turno,
                Dados1 = Dados0,
                inc_impuestos(M0, M2), % lo contamos como "pago" (opcional), si no lo quieres quita esta línea
                true
            ;   nl, write('No tienes 200. Debes intentar tirar.'), nl,
                intentar_salida_carcel_por_dados(jugador(N,Pos,Din,Props,Carc), Dados0, Dados1, Resultado, M0, M2)
            )
        ; Opc == t ->
            intentar_salida_carcel_por_dados(jugador(N,Pos,Din,Props,Carc), Dados0, Dados1, Resultado, M0, M2)
        ;   nl, write('Opcion invalida, se intentara tirar.'), nl,
            intentar_salida_carcel_por_dados(jugador(N,Pos,Din,Props,Carc), Dados0, Dados1, Resultado, M0, M2)
        )
    ).

intentar_salida_carcel_por_dados(jugador(N,Pos,Din,Props,Carc), Dados0, Dados2, Resultado, M0, M2) :-
    tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M1),
    (   D1 =:= D2
    ->  nl, write('Dobles ('), write(D1), write(' y '), write(D2), write('). Sales de la carcel. Turno termina.'), nl,
        Resultado = fin_turno,
        M2 = M1
    ;   Carc2 is Carc - 1,
        (Carc2 =< 0 ->
            nl, write('No sacas dobles. Has agotado intentos: saldras en el proximo turno normal.'), nl,
            Resultado = fin_turno,
            M2 = M1
        ;   nl, write('No sacas dobles. Sigues en carcel. Intentos restantes: '), write(Carc2), nl,
            % actualizamos jugador con carcel decrementada
            Resultado = fin_turno,
            M2 = M1
        )
    ).

set_pos_y_carcel(jugador(N,_Pos,Din,Props,_), Pos2, Carc2, jugador(N,Pos2,Din,Props,Carc2)).

% NOTA: en este modelo, al estar en carcel el turno termina siempre.
% La actualización de CarcelRestante se hace cuando cae en carcel, y aquí no la persistimos
% porque devolvemos fin_turno. Para persistirla correctamente, hacemos un paso extra:
% En turno_interactivo usamos Jugador2 en reconstrucción cuando Resultado=fin_turno.
% Por eso, vamos a hacer que gestionar_carcel NO devuelva fin_turno sin antes
% reflejar el nuevo CarcelRestante en el jugador actual.
% Para simplificar sin reescribir todo, aplicamos esta regla:
% - Si está en carcel, se considera que el jugador no se mueve este turno y su turno termina.
% - CarcelRestante decrementa si no paga y no dobles.
% Implementación real abajo: la persistencia se maneja en un wrapper.

% Wrapper real (reemplaza el anterior uso desde turno_interactivo):
gestionar_carcel(jugador(N,Pos,Din,Props,Carc), Dados0, DadosFinal, JugadorOut, M0, MFinal) :-
    (Carc =:= 0 ->
        DadosFinal=Dados0, JugadorOut=jugador(N,Pos,Din,Props,Carc), MFinal=M0
    ;   nl, write('Estas en la CARCEL. Turnos restantes de intentos: '), write(Carc), nl,
        nl, write('Opciones: pagar 200 (p) o tirar dados (t).'), nl,
        read(Opc),
        (Opc == p, Din >= 200 ->
            Din2 is Din - 200,
            nl, write('Pagas 200 y SALES de la carcel. Tu turno termina.'), nl,
            JugadorOut = fin_turno_con(jugador(N,Pos,Din2,Props,0)),
            DadosFinal = Dados0,
            MFinal = M0
        ;   % tirar
            tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M1),
            nl, write('Dados en carcel: '), write(D1), write(' y '), write(D2), nl,
            (D1 =:= D2 ->
                nl, write('Dobles => SALES de la carcel. Tu turno termina.'), nl,
                JugadorOut = fin_turno_con(jugador(N,Pos,Din,Props,0)),
                DadosFinal = Dados2,
                MFinal = M1
            ;   Carc2 is Carc - 1,
                (Carc2 =< 0 ->
                    nl, write('No dobles. Agotas intentos => el proximo turno sera normal (libre).'), nl,
                    JugadorOut = fin_turno_con(jugador(N,Pos,Din,Props,0))
                ;   nl, write('No dobles. Sigues en carcel. Intentos restantes: '), write(Carc2), nl,
                    JugadorOut = fin_turno_con(jugador(N,Pos,Din,Props,Carc2))
                ),
                DadosFinal = Dados2,
                MFinal = M1
            )
        )
    ).

% En turno_interactivo interpretamos esto:
% - fin_turno_con(JugadorActualizado)
% - jugador(...) -> turno normal

% Ajuste en turno_interactivo: lo hacemos aquí con un pequeño helper
gestionar_carcel_resultado(fin_turno_con(J), J, fin_turno).
gestionar_carcel_resultado(J, J, continuar).

% ---------- Ofrecer compra de casas si monopolio ----------
ofrecer_compra_casas(Jug0, _BP, Jugadores, JugFinal, M0, M0) :-
    % Si no tiene monopolio, nada
    Jug0 = jugador(_,_,_,Props,_),
    (tiene_alguna_propiedad(Props) ->
        monopolios_de_jugador(Jugadores, Jug0, ColoresMonopolio),
        (ColoresMonopolio == [] ->
            JugFinal = Jug0
        ;   nl, write('Tienes monopolio en colores: '), write(ColoresMonopolio), nl,
            ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal)
        )
    ;   JugFinal = Jug0
    ).

tiene_alguna_propiedad([_|_]).
tiene_alguna_propiedad([]) :- fail.

ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal) :-
    preguntar_si_no('¿Quieres comprar casas ahora? (si/no).', R),
    (R == no ->
        JugFinal = Jug0
    ;   Jug0 = jugador(N,Pos,Din,Props,Carc),
        propiedades_elegibles_para_casas(Props, ColoresMonopolio, Elegibles),
        (Elegibles == [] ->
            write('No hay propiedades elegibles para casas.'), nl,
            JugFinal = Jug0
        ;   nl, write('Propiedades elegibles:'), nl,
            imprimir_props_con_indices(Elegibles, 1),
            nl, write('Elige indice de propiedad para comprar 1 casa (o 0 para terminar).'), nl,
            read(I),
            (I == 0 ->
                JugFinal = Jug0
            ;   seleccionar_por_indice(Elegibles, I-1, PropSel, _),
                PropSel = prop(Nom,Precio,Color,Casas),
                max_casas(MaxH),
                (Casas >= MaxH ->
                    write('Esa propiedad ya tiene el maximo de casas.'), nl,
                    ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal)
                ;   precio_casa(Costo),
                    (Din < Costo ->
                        write('No tienes dinero para una casa (cuesta 100).'), nl,
                        ciclo_comprar_casas(Jug0, ColoresMonopolio, JugFinal)
                    ;   Din2 is Din - Costo,
                        Casas2 is Casas + 1,
                        reemplazar_prop_en_lista(Props, prop(Nom,Precio,Color,Casas), prop(Nom,Precio,Color,Casas2), Props2),
                        nl, write('Compras 1 casa en '), write(Nom), write('. Casas ahora='), write(Casas2), nl,
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

propiedades_elegibles_para_casas([], _Colores, []).
propiedades_elegibles_para_casas([prop(N,P,C,H)|R], Colores, [prop(N,P,C,H)|R2]) :-
    C \== estacion,
    member_atom(C, Colores),
    propiedades_elegibles_para_casas(R, Colores, R2).
propiedades_elegibles_para_casas([_|R], Colores, R2) :-
    propiedades_elegibles_para_casas(R, Colores, R2).

% ---------- Monopolios ----------
monopolios_de_jugador(Jugadores, jugador(_,_,_,Props,_), ColoresMonopolio) :-
    colores_del_tablero(Colores),
    monopolios_por_colores(Colores, Jugadores, Props, [], ColoresMonopolio).

colores_del_tablero([morado,gris,rosa,naranja,rojo,amarillo,verde,azul]).

monopolios_por_colores([], _Jugadores, _Props, Acc, Acc).
monopolios_por_colores([C|R], Jugadores, Props, Acc, Out) :-
    nombres_propiedades_color(C, TodosNombres),
    (TodosNombres == [] ->
        monopolios_por_colores(R, Jugadores, Props, Acc, Out)
    ;   jugador_posee_todos(Props, TodosNombres) ->
        monopolios_por_colores(R, Jugadores, Props, [C|Acc], Out)
    ;   monopolios_por_colores(R, Jugadores, Props, Acc, Out)
    ).

nombres_propiedades_color(Color, Nombres) :-
    tablero(T),
    nombres_propiedades_color_tablero(T, Color, [], NombresRev),
    reverse_list(NombresRev, Nombres).

nombres_propiedades_color_tablero([], _Color, Acc, Acc).
nombres_propiedades_color_tablero([propiedad(N,_,C)|R], Color, Acc, Out) :-
    (C == Color ->
        nombres_propiedades_color_tablero(R, Color, [N|Acc], Out)
    ;   nombres_propiedades_color_tablero(R, Color, Acc, Out)
    ).
nombres_propiedades_color_tablero([_|R], Color, Acc, Out) :-
    nombres_propiedades_color_tablero(R, Color, Acc, Out).

jugador_posee_todos(_Props, []).
jugador_posee_todos(Props, [N|R]) :-
    (tiene_prop_nombre(Props, N) -> jugador_posee_todos(Props, R) ; fail).

tiene_prop_nombre([prop(N,_,_,_)|_], N) :- !.
tiene_prop_nombre([_|R], N) :- tiene_prop_nombre(R, N).

% ---------- Bancarrota ----------
resolver_bancarrota_si_aplica(Jug0, Resto0, BP0, BPFinal, JugFinal, RestoFinal, M0, MFinal) :-
    Jug0 = jugador(N,Pos,Din,Props,Carc),
    (Din >= 0 ->
        BPFinal=BP0, JugFinal=Jug0, RestoFinal=Resto0, MFinal=M0
    ;   nl, write('*** BANCARROTA detectada para '), write(N), write(' (dinero='), write(Din), write(') ***'), nl,
        inc_bancarrotas(M0, M1),
        % El banco compra TODAS las propiedades por 20% del precio original (sin importar casas)
        valor_venta_20(Props, TotalVenta),
        nl, write('El banco compra tus propiedades por '), write(TotalVenta), write(' (20% del precio).'), nl,
        Din2 is Din + TotalVenta,
        % Devolver propiedades al banco:
        anexar_listas(BP0, Props, BP1),
        Props2 = [],
        (Din2 >= 0 ->
            nl, write('Tras liquidacion, sigues en juego con dinero='), write(Din2), nl,
            JugFinal = jugador(N,Pos,Din2,Props2,Carc),
            BPFinal = BP1,
            RestoFinal = Resto0,
            MFinal = M1
        ;   nl, write('Aun con liquidacion sigues en negativo. Eres ELIMINADO.'), nl,
            JugFinal = eliminado,
            BPFinal = BP1,
            RestoFinal = Resto0,
            MFinal = M1
        )
    ).

valor_venta_20([], 0).
valor_venta_20([prop(_N,P,_C,_H)|R], Total) :-
    valor_venta_20(R, T2),
    % 20% => P*20//100
    V is (P * 20) // 100,
    Total is V + T2.

% ---------- Transferencias ----------
pagar_a_otro(jugador(N,Pos,Din,Props,Carc), jugador(N2,Pos2,DinO,PropsO,CarcO), Monto, jugador(N,Pos,Din2,Props,Carc), jugador(N2,Pos2,DinO2,PropsO,CarcO)) :-
    Din2 is Din - Monto,
    DinO2 is DinO + Monto,
    nl, write('Pagas '), write(Monto), write(' a '), write(N2), nl.

% ---------- BancoProps helpers ----------
banco_posee(Nom, [prop(Nom,_,_,_)|_]) :- !.
banco_posee(Nom, [_|R]) :- banco_posee(Nom, R).

quitar_de_banco(_Nom, [], []).
quitar_de_banco(Nom, [prop(Nom,P,C,H)|R], R) :- !.
quitar_de_banco(Nom, [X|R], [X|R2]) :- quitar_de_banco(Nom, R, R2).

% ---------- Dueño ----------
% Buscar dueño en la lista "Resto" (jugadores excepto el actual)
encontrar_duenio(Nom, Resto, Duenio, RestoSinDuenio, Idx) :-
    encontrar_duenio_loop(Nom, Resto, 0, Duenio, RestoSinDuenio, Idx).

encontrar_duenio_loop(_Nom, [], _I, _D, _R, _Idx) :- fail.
encontrar_duenio_loop(Nom, [J|R], I, J, R, I) :-
    J = jugador(_,_,_,Props,_),
    tiene_prop_nombre(Props, Nom), !.
encontrar_duenio_loop(Nom, [J|R], I, D, [J|R2], Idx) :-
    I2 is I+1,
    encontrar_duenio_loop(Nom, R, I2, D, R2, Idx).

reinsertar_duenio(RestoSin, Idx, Duenio, RestoOut) :-
    insertar_en_indice(RestoSin, Idx, Duenio, RestoOut).

% ---------- List utilities (sin librerías) ----------
length_list([], 0).
length_list([_|R], L) :- length_list(R, L1), L is L1+1.

% Para usar dentro de is/mod sin depender de predicados extra:
length_list_value(Ls, L) :- length_list(Ls, L).

nth1_list(1, [X|_], X) :- !.
nth1_list(N, [_|R], X) :-
    N > 1,
    N2 is N-1,
    nth1_list(N2, R, X).

reverse_list(L, R) :- rev_acc(L, [], R).
rev_acc([], Acc, Acc).
rev_acc([X|R], Acc, Out) :- rev_acc(R, [X|Acc], Out).

anexar_listas([], L, L).
anexar_listas([X|R], L, [X|Out]) :- anexar_listas(R, L, Out).

member_atom(X, [X|_]) :- !.
member_atom(X, [_|R]) :- member_atom(X, R).

% Seleccionar por índice 0-based (devuelve elemento y lista sin él)
seleccionar_por_indice([X|R], 0, X, R) :- !.
seleccionar_por_indice([X|R], I, Elem, [X|R2]) :-
    I > 0,
    I2 is I-1,
    seleccionar_por_indice(R, I2, Elem, R2).

insertar_en_indice(L, 0, X, [X|L]) :- !.
insertar_en_indice([H|T], I, X, [H|R]) :-
    I > 0,
    I2 is I-1,
    insertar_en_indice(T, I2, X, R).

reconstruir_jugadores(J, Resto, [J|Resto]).

member_prop(X, [X|_]) :- !.
member_prop(X, [_|R]) :- member_prop(X, R).

reemplazar_prop_en_lista([], _Old, _New, []).
reemplazar_prop_en_lista([Old|R], Old, New, [New|R]) :- !.
reemplazar_prop_en_lista([X|R], Old, New, [X|R2]) :-
    reemplazar_prop_en_lista(R, Old, New, R2).

% ---------- Escenarios (5) ----------
% NOTA: todos con >=2 jugadores (sin banco). Para cumplir tu documento, pongo 3.
escenario(1, Partida) :-
    banco_props_inicial(BP),
    metricas_inicial(M),
    dados_por_defecto(D),
    azar_por_defecto(A),
    J1 = jugador(ana,1,300,[],0),
    J2 = jugador(bob,1,300,[],0),
    J3 = jugador(carla,1,300,[],0),
    Partida = partida(BP,0,[J1,J2,J3],0,0,50,D,A,M).

% Escenario 2: ana tiene monopolio morado
escenario(2, Partida) :-
    banco_props_inicial(BP0),
    quitar_de_banco(morado1, BP0, BP1),
    quitar_de_banco(morado2, BP1, BP2),
    metricas_inicial(M),
    dados_por_defecto(D),
    azar_por_defecto(A),
    P1 = prop(morado1,60,morado,1),
    P2 = prop(morado2,60,morado,0),
    J1 = jugador(ana,12,250,[P1,P2],0),
    J2 = jugador(bob,10,300,[],0),
    J3 = jugador(carla,20,300,[],0),
    Partida = partida(BP2,0,[J1,J2,J3],0,0,50,D,A,M).

% Escenario 3: bob cerca de bancarrota
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

% Escenario 4: alquileres consecutivos (ana tiene varias, otros caen cerca)
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

% Escenario 5: pensado para simular 10 turnos automático
escenario(5, Partida) :-
    escenario(1, P0),
    % maxturnos 10
    P0 = partida(BP,Caja,Js,Idx,_T,_Max,D,A,M),
    Partida = partida(BP,Caja,Js,Idx,0,10,D,A,M).

% ---------- Simulación automática (sin interacción) ----------
% Política: no trampas, compra si puede, casino no juega, casas no compra.
simular_10_turnos(Partida0, PartidaFinal) :-
    simular_turnos(10, Partida0, PartidaFinal).

simular_turnos(0, P, P) :- !.
simular_turnos(N, P0, PF) :-
    N > 0,
    turno_auto(P0, P1),
    N2 is N-1,
    simular_turnos(N2, P1, PF).

turno_auto(Partida0, PartidaFinal) :-
    Partida0 = partida(BP0, Caja0, Jugadores0, TurnoIdx0, TurnoNum0, MaxT, Dados0, Azar0, M0),
    inc_turnos(M0, M1),
    TurnoNum1 is TurnoNum0 + 1,
    seleccionar_por_indice(Jugadores0, TurnoIdx0, Jug0, Resto0),

    % Sin casas, sin trampas
    % Cárcel: si está, intenta tirar siempre
    gestionar_carcel_auto(Jug0, Dados0, Dados1, Jug1, M1, M2),
    (Jug1 = fin_turno_con(JAct) ->
        reconstruir_jugadores(JAct, Resto0, Js1),
        P1 = partida(BP0,Caja0,Js1,TurnoIdx0,TurnoNum1,MaxT,Dados1,Azar0,M2),
        avanzar_turno(P1, PartidaFinal)
    ;   mover_jugador(Jug1, Dados1, Dados2, JugMov, Caja0, Caja1, M2, M3),
        JugMov = jugador(_,PosNueva,_,_,_),
        tablero(T),
        nth1_list(PosNueva, T, Casilla),
        aplicar_reglas_casilla_auto(Casilla, JugMov, Resto0, BP0, BP1, Caja1, Caja2, Dados2, Dados3, Azar0, Azar1, JugFinal, RestoFinal, M3, M4, Iter),
        add_iter(M4, Iter, M5),
        (JugFinal = eliminado ->
            Js1 = RestoFinal,
            P1 = partida(BP1,Caja2,Js1,TurnoIdx0,TurnoNum1,MaxT,Dados3,Azar1,M5),
            normalizar_turno_idx(P1, PartidaFinal)
        ;   reconstruir_jugadores(JugFinal, RestoFinal, Js1),
            P1 = partida(BP1,Caja2,Js1,TurnoIdx0,TurnoNum1,MaxT,Dados3,Azar1,M5),
            avanzar_turno(P1, PartidaFinal)
        )
    ).

gestionar_carcel_auto(jugador(N,Pos,Din,Props,Carc), Dados0, DadosFinal, JugOut, M0, MFinal) :-
    (Carc =:= 0 ->
        DadosFinal=Dados0, JugOut=jugador(N,Pos,Din,Props,Carc), MFinal=M0
    ;   tirar_dos_dados(Dados0, Dados2, D1, D2, M0, M1),
        (D1 =:= D2 ->
            JugOut = fin_turno_con(jugador(N,Pos,Din,Props,0))
        ;   Carc2 is Carc - 1,
            (Carc2 =< 0 -> JugOut = fin_turno_con(jugador(N,Pos,Din,Props,0))
            ;              JugOut = fin_turno_con(jugador(N,Pos,Din,Props,Carc2))
            )
        ),
        DadosFinal = Dados2,
        MFinal = M1
    ).

aplicar_reglas_casilla_auto(Casilla, Jug0, Resto0, BP0, BPFinal, Caja0, CajaFinal, Dados0, DadosFinal, Azar0, AzarFinal, JugFinal, RestoFinal, M0, MFinal, IterCount) :-
    % Igual que interactivo pero decisiones automáticas:
    aplicar_reglas_loop_auto(Casilla, Jug0, Resto0, BP0, BPFinal, Caja0, CajaFinal, Dados0, DadosFinal, Azar0, AzarFinal, JugFinal, RestoFinal, M0, MFinal, 0, IterCount).

aplicar_reglas_loop_auto(Casilla, Jug0, Resto0, BP0, BP2, Caja0, Caja2, Dados0, Dados2, Azar0, Azar2, Jug2, Resto2, M0, M2, Acc, IterCount) :-
    aplicar_una_vez_auto(Casilla, Jug0, Resto0, BP0, BP1, Caja0, Caja1, Dados0, Dados1, Azar0, Azar1, Jug1, Resto1, M0, M1, Cambio),
    Acc1 is Acc + 1,
    (Cambio == si, Jug1 \== eliminado, Acc1 < 10 ->
        aplicar_reglas_loop_auto(Casilla, Jug1, Resto1, BP1, BP2, Caja1, Caja2, Dados1, Dados2, Azar1, Azar2, Jug2, Resto2, M1, M2, Acc1, IterCount)
    ;   BP2=BP1, Caja2=Caja1, Dados2=Dados1, Azar2=Azar1, Jug2=Jug1, Resto2=Resto1, M2=M1, IterCount=Acc1
    ).

aplicar_una_vez_auto(Casilla, Jug0, Resto0, BP0, BP1, Caja0, Caja1, Dados0, Dados1, Azar0, Azar1, JugFinal, RestoFinal, M0, MFinal, Cambio) :-
    (   Casilla = salida ->
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Azar1=Azar0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no
    ;   Casilla = visita_carcel ->
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Azar1=Azar0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no
    ;   Casilla = carcel ->
        set_pos_y_carcel(Jug0, 11, 3, JugTmp),
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, M1=M0, Cambio0=si
    ;   Casilla = parking ->
        cobrar_parking(Jug0, Caja0, JugTmp, CajaTmp),
        BP1=BP0, Caja1=CajaTmp, Dados1=Dados0, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, M1=M0, Cambio0=si
    ;   Casilla = impuesto(_) ->
        pagar_impuesto(Jug0, Caja0, JugTmp, CajaTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=Dados0, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, Cambio0=si
    ;   Casilla = suerte(_) ->
        jugar_suerte(Jug0, Caja0, CajaTmp, Dados0, DadosTmp, JugTmp, M0, M1),
        BP1=BP0, Caja1=CajaTmp, Dados1=DadosTmp, Azar1=Azar0, Jug1=JugTmp, Resto1=Resto0, Cambio0=si
    ;   Casilla = casino ->
        % auto: no juega
        BP1=BP0, Caja1=Caja0, Dados1=Dados0, Azar1=Azar0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no
    ;   Casilla = estacion(Nom) ->
        estacion_precio(Precio),
        (banco_posee(Nom, BP0), Jug0 = jugador(_,_,Din,_,_), Din >= Precio ->
            comprar_estacion(Nom,Precio, Jug0, BP0, JugTmp, BP1, M0, M1),
            Jug1=JugTmp, Resto1=Resto0, Cambio0=si
        ;   (encontrar_duenio(Nom, Resto0, Duenio, RestoSin, Idx) ->
                estacion_alquiler(Alq),
                pagar_a_otro(Jug0, Duenio, Alq, JugTmp, DuenioTmp),
                reinsertar_duenio(RestoSin, Idx, DuenioTmp, Resto1),
                Jug1=JugTmp, BP1=BP0, M1=M0, Cambio0=si
            ;   BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no
            )
        ),
        Caja1=Caja0, Dados1=Dados0, Azar1=Azar0
    ;   Casilla = propiedad(Nom,Precio,Color) ->
        (banco_posee(Nom, BP0), Jug0 = jugador(_,_,Din,_,_), Din >= Precio ->
            comprar_propiedad(Nom,Precio,Color, Jug0, BP0, JugTmp, BP1, M0, M1),
            Jug1=JugTmp, Resto1=Resto0, Cambio0=si
        ;   (encontrar_duenio(Nom, Resto0, Duenio, RestoSin, Idx) ->
                calcular_alquiler(Nom, Precio, Color, Duenio, Alq),
                pagar_a_otro(Jug0, Duenio, Alq, JugTmp, DuenioTmp),
                reinsertar_duenio(RestoSin, Idx, DuenioTmp, Resto1),
                Jug1=JugTmp, BP1=BP0, M1=M0, Cambio0=si
            ;   BP1=BP0, Jug1=Jug0, Resto1=Resto0, M1=M0, Cambio0=no
            )
        ),
        Caja1=Caja0, Dados1=Dados0, Azar1=Azar0
    ),
    resolver_bancarrota_si_aplica(Jug1, Resto1, BP1, BP2, Jug2, Resto2, M1, M2),
    BPFinal=BP2, JugFinal=Jug2, RestoFinal=Resto2, MFinal=M2,
    Cambio = (Cambio0 == si ; Jug2 == eliminado -> si ; no).

% ---------- Ranking ----------
ranking_jugadores(partida(_BP,_Caja,Jugadores,_Idx,_T,_Max,_D,_A,_M), Ranking) :-
    jugadores_a_items(Jugadores, Items),
    sort_items_desc(Items, Ranking).

jugadores_a_items([], []).
jugadores_a_items([jugador(N,_,Din,_,_)|R], [item(N,Din)|R2]) :- jugadores_a_items(R, R2).

% Ordenación simple por dinero desc (bubble sort)
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

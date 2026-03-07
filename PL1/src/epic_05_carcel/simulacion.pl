% =========================
% simulacion.pl
% Epica 5: simulacion con compras, alquileres y carcel
% =========================

:- module(simulacion, [
    simular_partida/3
]).

:- use_module(tablero).
:- use_module(dados).
:- use_module(compras).
:- use_module(alquileres).
:- use_module(carcel).

simular_partida(PartidaInicial, PartidaFinal, Eventos) :-
    PartidaInicial = partida(_, _, _, _, MaxTurnos, _, _, _, _),
    simular_n_turnos(PartidaInicial, MaxTurnos, 1, PartidaFinal, [], EventosRev),
    reverse(EventosRev, Eventos).

simular_n_turnos(Partida, MaxTurnos, TurnoActual, Partida, EventosAcc, EventosAcc) :-
    TurnoActual > MaxTurnos, !.
simular_n_turnos(Partida0, MaxTurnos, TurnoActual, PartidaFinal, EventosAcc, EventosFinal) :-
    simular_turno(Partida0, Partida1, EventoTurno),
    TurnoSiguiente is TurnoActual + 1,
    simular_n_turnos(Partida1, MaxTurnos, TurnoSiguiente, PartidaFinal, [EventoTurno|EventosAcc], EventosFinal).

simular_turno(
    partida(Tablero, Banco0, Jugadores0, TurnoActual, MaxTurnos, EstadoDados0, PoliticaCompra, PoliticaCarcel, historial(Etiqueta, Historial0)),
    partida(Tablero, BancoFinal, JugadoresFinal, TurnoSiguiente, MaxTurnos, EstadoDadosFinal, PoliticaCompra, PoliticaCarcel, historial(Etiqueta, [Evento|Historial0])),
    Evento
) :-
    length(Jugadores0, NumJugadores),
    NumJugadores > 0,
    IndiceJugador is ((TurnoActual - 1) mod NumJugadores) + 1,
    nth1(IndiceJugador, Jugadores0, JugadorActual),

    JugadorActual = jugador(NombreJugador, PosAnterior, DineroInicialTurno, PropsAntesLista, EstadoCarcelAntes),
    length(PropsAntesLista, NumPropsAntes),

    carcel:resolver_turno_carcel(
        PoliticaCarcel,
        EstadoDados0,
        JugadorActual,
        JugadorTrasCarcel,
        EstadoDados1,
        DecisionCarcel,
        EventoCarcelInicio,
        PerdidoPorCarcel,
        DineroInicialTurno,
        DineroTrasCarcel
    ),

    (
        PerdidoPorCarcel = si ->
            reemplazar_jugador_en_indice(Jugadores0, IndiceJugador, JugadorTrasCarcel, JugadoresFinal),
            BancoFinal = Banco0,
            EstadoDadosFinal = EstadoDados1,
            tablero:casilla_en_posicion(PosAnterior, Tablero, CasillaActual),
            CasillaActual = casilla(_, TipoCasillaActual, NombreCasillaActual, PrecioCasillaActual, ColorCasillaActual),
            JugadorTrasCarcel = jugador(_, PosFinalPerdido, DineroFinalTurno, PropsDespuesLista, _),
            length(PropsDespuesLista, NumPropsDespues),
            Evento = evento_turno(
                TurnoActual,
                IndiceJugador,
                NombreJugador,
                EstadoCarcelAntes,
                DecisionCarcel,
                EventoCarcelInicio,
                no_aplica,
                0, 0, 0,
                PosAnterior,
                PosFinalPerdido,
                no,
                NombreCasillaActual,
                TipoCasillaActual,
                PrecioCasillaActual,
                ColorCasillaActual,
                no,
                sin_compra,
                no,
                sin_alquiler,
                0,
                0,
                DineroInicialTurno,
                DineroTrasCarcel,
                DineroFinalTurno,
                NumPropsAntes,
                NumPropsDespues,
                si
            )
    ;
        dados:tirar_dos_dados(EstadoDados1, D1, D2, EstadoDados2),
        Suma is D1 + D2,
        PosMovida is ((PosAnterior - 1 + Suma) mod 40) + 1,
        ( PosAnterior + Suma > 40 -> PasoSalida = si ; PasoSalida = no ),

        JugadorTrasCarcel = jugador(NombreJugador, _, _, _, EstadoTrasCarcel),
        JugadorMovido0 = jugador(NombreJugador, PosMovida, DineroTrasCarcel, PropsAntesLista, EstadoTrasCarcel),
        tablero:casilla_en_posicion(PosMovida, Tablero, CasillaDestino0),

        aplicar_efecto_carcel_si_caes(CasillaDestino0, JugadorMovido0, CasillaDestinoFinal, JugadorDespuesEspecial, EventoCarcelFin),

        (
            EventoCarcelFin \== no_aplica ->
                Banco1 = Banco0,
                JugadorDespuesCompra = JugadorDespuesEspecial,
                CompraRealizada = no,
                EventoCompra = sin_compra
        ;
            compras:aplicar_compra_si_procede(
                TurnoActual,
                PoliticaCompra,
                JugadorDespuesEspecial,
                CasillaDestinoFinal,
                Banco0,
                JugadorDespuesCompra,
                Banco1,
                CompraRealizada,
                EventoCompra,
                DineroTrasCarcel,
                _DineroDespuesCompra
            )
        ),

        reemplazar_jugador_en_indice(Jugadores0, IndiceJugador, JugadorDespuesCompra, JugadoresTmp),

        (
            EventoCarcelFin \== no_aplica ->
                JugadoresDespuesAlquiler = JugadoresTmp,
                AlquilerRealizado = no,
                EventoAlquiler = sin_alquiler,
                AlquilerTeorico = 0,
                PagoReal = 0
        ;
            alquileres:aplicar_alquiler_si_procede(
                TurnoActual,
                NombreJugador,
                CasillaDestinoFinal,
                JugadoresTmp,
                JugadoresDespuesAlquiler,
                AlquilerRealizado,
                EventoAlquiler,
                AlquilerTeorico,
                PagoReal
            )
        ),

        jugador_por_nombre(JugadoresDespuesAlquiler, NombreJugador, JugadorFinal),
        JugadorFinal = jugador(_, PosNueva, DineroFinalTurno, PropsDespuesLista, _),
        length(PropsDespuesLista, NumPropsDespues),

        CasillaDestinoFinal = casilla(_, TipoCasilla, NombreCasilla, PrecioCasilla, ColorCasilla),

        BancoFinal = Banco1,
        JugadoresFinal = JugadoresDespuesAlquiler,
        EstadoDadosFinal = EstadoDados2,

        Evento = evento_turno(
            TurnoActual,
            IndiceJugador,
            NombreJugador,
            EstadoCarcelAntes,
            DecisionCarcel,
            EventoCarcelInicio,
            EventoCarcelFin,
            D1, D2, Suma,
            PosAnterior,
            PosNueva,
            PasoSalida,
            NombreCasilla,
            TipoCasilla,
            PrecioCasilla,
            ColorCasilla,
            CompraRealizada,
            EventoCompra,
            AlquilerRealizado,
            EventoAlquiler,
            AlquilerTeorico,
            PagoReal,
            DineroInicialTurno,
            DineroTrasCarcel,
            DineroFinalTurno,
            NumPropsAntes,
            NumPropsDespues,
            no
        )
    ),

    TurnoSiguiente is TurnoActual + 1.

aplicar_efecto_carcel_si_caes(casilla(_, carcel, _, _, _), JugadorIn, CasillaFinal, JugadorOut, EventoCarcelFin) :-
    carcel:entrar_en_carcel(JugadorIn, JugadorOut, EventoCarcelFin),
    CasillaFinal = casilla(11, visita_carcel, visita_carcel, 0, ninguno), !.
aplicar_efecto_carcel_si_caes(Casilla, Jugador, Casilla, Jugador, no_aplica).

reemplazar_jugador_en_indice([_|R], 1, JugadorNuevo, [JugadorNuevo|R]) :- !.
reemplazar_jugador_en_indice([X|R], I, JugadorNuevo, [X|R2]) :-
    I > 1,
    I2 is I - 1,
    reemplazar_jugador_en_indice(R, I2, JugadorNuevo, R2).

jugador_por_nombre([jugador(Nombre, Pos, Din, Props, Estado)|_], Nombre, jugador(Nombre, Pos, Din, Props, Estado)) :- !.
jugador_por_nombre([_|R], Nombre, Jugador) :-
    jugador_por_nombre(R, Nombre, Jugador).

% =========================
% simulacion.pl
% Epica 8: simulacion con monopoly, parking, compras, alquileres, impuestos, carcel y bancarrota
% =========================

:- module(simulacion, [
    simular_partida/3
]).

:- use_module(tablero).
:- use_module(dados).
:- use_module(compras).
:- use_module(alquileres).
:- use_module(impuestos).
:- use_module(carcel).
:- use_module(bancarrota).
:- use_module(parking).
:- use_module(monopoly).

simular_partida(PartidaInicial, PartidaFinal, Eventos) :-
    PartidaInicial = partida(_, _, Jugadores0, _, MaxTurnos, _, _, _, _),
    length(Jugadores0, NumJugadores),
    NumJugadores > 0,
    simular_n_turnos(PartidaInicial, MaxTurnos, 1, PartidaFinal, [], EventosRev),
    reverse(EventosRev, Eventos).

simular_n_turnos(Partida, MaxTurnos, TurnoActual, Partida, EventosAcc, EventosAcc) :-
    TurnoActual > MaxTurnos, !.
simular_n_turnos(
    partida(Tablero, Banco, [], TurnoActual, MaxTurnos, EstadoDados, PoliticaCompra, PoliticaCarcel, Historial),
    _MaxTurnos,
    TurnoActual,
    partida(Tablero, Banco, [], TurnoActual, MaxTurnos, EstadoDados, PoliticaCompra, PoliticaCarcel, Historial),
    EventosAcc,
    EventosAcc
) :- !.
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

    monopoly:aplicar_compra_casas_si_procede(
        TurnoActual,
        JugadorActual,
        JugadorTrasMonopoly,
        MonopolyRealizado,
        EventoMonopoly,
        CasasCompradas,
        CosteCasas
    ),

    JugadorTrasMonopoly = jugador(_, _, DineroTrasMonopoly, _, _),

    carcel:resolver_turno_carcel(
        PoliticaCarcel,
        EstadoDados0,
        JugadorTrasMonopoly,
        JugadorTrasCarcel,
        EstadoDados1,
        DecisionCarcel,
        EventoCarcelInicio,
        PerdidoPorCarcel,
        DineroTrasMonopoly,
        DineroTrasCarcel
    ),

    (
        PerdidoPorCarcel == si ->
            reemplazar_jugador_en_indice(Jugadores0, IndiceJugador, JugadorTrasCarcel, JugadoresFinal),
            BancoFinal = Banco0,
            EstadoDadosFinal = EstadoDados1,
            PosNueva = PosAnterior,
            tablero:casilla_en_posicion(PosNueva, Tablero, CasillaFinal),
            EventoCarcelFin = no_aplica,
            CompraRealizada = no,
            EventoCompra = sin_compra,
            AlquilerRealizado = no,
            EventoAlquiler = sin_alquiler,
            ImpuestoRealizado = no,
            EventoImpuesto = sin_impuesto,
            ParkingRealizado = no,
            EventoParking = sin_parking,
            BancarrotaRealizada = no,
            EventoBancarrota = sin_bancarrota,
            JugadorEliminado = no,
            AlquilerTeorico = 0,
            PagoReal = 0,
            D1Out = 0,
            D2Out = 0,
            SumaOut = 0,
            PasoSalidaFinal = no
    ;
        dados:tirar_dos_dados(EstadoDados1, D1, D2, EstadoDados2),
        Suma is D1 + D2,
        PosMovida is ((PosAnterior - 1 + Suma) mod 40) + 1,
        (PosAnterior + Suma > 40 -> PasoSalida = si ; PasoSalida = no),

        JugadorTrasCarcel = jugador(NombreJugador, _, _, PropsTrasCarcel, EstadoTrasCarcel),
        JugadorMovido0 = jugador(NombreJugador, PosMovida, DineroTrasCarcel, PropsTrasCarcel, EstadoTrasCarcel),
        tablero:casilla_en_posicion(PosMovida, Tablero, CasillaDestino0),

        aplicar_efecto_carcel_si_caes(CasillaDestino0, JugadorMovido0, CasillaDestino1, JugadorTrasEspecial, EventoCarcelFin),

        compras:aplicar_compra_si_procede(
            TurnoActual,
            PoliticaCompra,
            JugadorTrasEspecial,
            CasillaDestino1,
            Banco0,
            JugadorTrasCompra,
            Banco1,
            CompraRealizada,
            EventoCompra,
            DineroTrasCarcel,
            _DineroDespuesCompra
        ),

        reemplazar_jugador_en_indice(Jugadores0, IndiceJugador, JugadorTrasCompra, JugadoresTmp1),

        alquileres:aplicar_alquiler_si_procede(
            TurnoActual,
            NombreJugador,
            CasillaDestino1,
            JugadoresTmp1,
            JugadoresTmp2,
            AlquilerRealizado,
            EventoAlquiler,
            AlquilerTeorico,
            PagoReal
        ),

        jugador_por_nombre(JugadoresTmp2, NombreJugador, JugadorTrasAlquiler),

        impuestos:aplicar_impuesto_si_procede(
            TurnoActual,
            Banco1,
            JugadorTrasAlquiler,
            CasillaDestino1,
            Banco2,
            JugadorTrasImpuesto,
            ImpuestoRealizado,
            EventoImpuesto
        ),

        reemplazar_jugador_por_nombre(JugadoresTmp2, NombreJugador, JugadorTrasImpuesto, JugadoresTmp3),

        parking:aplicar_parking_si_procede(
            TurnoActual,
            Banco2,
            JugadorTrasImpuesto,
            CasillaDestino1,
            Banco3,
            JugadorTrasParking,
            ParkingRealizado,
            EventoParking
        ),

        reemplazar_jugador_por_nombre(JugadoresTmp3, NombreJugador, JugadorTrasParking, JugadoresTmp4),

        causa_bancarrota(AlquilerRealizado, ImpuestoRealizado, CausaBancarrota),
        bancarrota:resolver_bancarrota_si_procede(
            TurnoActual,
            CausaBancarrota,
            NombreJugador,
            JugadoresTmp4,
            Banco3,
            JugadoresFinal,
            BancoFinal,
            BancarrotaRealizada,
            EventoBancarrota,
            JugadorEliminado
        ),

        EstadoDadosFinal = EstadoDados2,
        PosNueva = PosMovida,
        CasillaFinal = CasillaDestino1,
        D1Out = D1,
        D2Out = D2,
        SumaOut = Suma,
        PasoSalidaFinal = PasoSalida
    ),

    jugador_final_o_placeholder(JugadoresFinal, NombreJugador, PosNueva, DineroInicialTurno, EstadoCarcelAntes, JugadorEliminado, JugadorFinalTermino),
    JugadorFinalTermino = jugador(_, PosFinalOut, DineroFinalTurno, PropsDespuesLista, _),
    length(PropsDespuesLista, NumPropsDespues),

    CasillaFinal = casilla(_, TipoCasilla, NombreCasilla, PrecioCasilla, ColorCasilla),

    Evento = evento_turno(
        TurnoActual,
        IndiceJugador,
        NombreJugador,
        EstadoCarcelAntes,
        MonopolyRealizado,
        EventoMonopoly,
        CasasCompradas,
        CosteCasas,
        DecisionCarcel,
        EventoCarcelInicio,
        EventoCarcelFin,
        D1Out,
        D2Out,
        SumaOut,
        PosAnterior,
        PosFinalOut,
        PasoSalidaFinal,
        NombreCasilla,
        TipoCasilla,
        PrecioCasilla,
        ColorCasilla,
        CompraRealizada,
        EventoCompra,
        AlquilerRealizado,
        EventoAlquiler,
        ImpuestoRealizado,
        EventoImpuesto,
        ParkingRealizado,
        EventoParking,
        BancarrotaRealizada,
        EventoBancarrota,
        DineroInicialTurno,
        DineroTrasMonopoly,
        DineroTrasCarcel,
        DineroFinalTurno,
        NumPropsAntes,
        NumPropsDespues,
        PerdidoPorCarcel,
        JugadorEliminado,
        AlquilerTeorico,
        PagoReal
    ),

    TurnoSiguiente is TurnoActual + 1.

causa_bancarrota(si, _, alquiler) :- !.
causa_bancarrota(_, si, impuesto) :- !.
causa_bancarrota(_, _, otra).

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

reemplazar_jugador_por_nombre([], _, _, []).
reemplazar_jugador_por_nombre([jugador(Nombre, _, _, _, _)|R], Nombre, JugadorNuevo, [JugadorNuevo|R]) :- !.
reemplazar_jugador_por_nombre([X|R], Nombre, JugadorNuevo, [X|R2]) :-
    reemplazar_jugador_por_nombre(R, Nombre, JugadorNuevo, R2).

jugador_final_o_placeholder(Jugadores, NombreJugador, _PosFallback, _DinFallback, _EstadoFallback, no, Jugador) :-
    jugador_por_nombre(Jugadores, NombreJugador, Jugador), !.
jugador_final_o_placeholder(_Jugadores, _NombreJugador, PosFallback, DinFallback, EstadoFallback, si, jugador(eliminado, PosFallback, DinFallback, [], EstadoFallback)).

% =========================
% simulacion.pl
% Epica 4: simulacion con movimiento, compra y alquiler
% =========================

:- module(simulacion, [
    simular_partida/3
]).

:- use_module(tablero).
:- use_module(dados).
:- use_module(compras).
:- use_module(alquileres).

simular_partida(PartidaInicial, PartidaFinal, Eventos) :-
    PartidaInicial = partida(_, _, _, _, MaxTurnos, _, _, _),
    simular_n_turnos(PartidaInicial, MaxTurnos, 1, PartidaFinal, [], EventosRev),
    reverse(EventosRev, Eventos).

simular_n_turnos(Partida, MaxTurnos, TurnoActual, Partida, EventosAcc, EventosAcc) :-
    TurnoActual > MaxTurnos, !.
simular_n_turnos(Partida0, MaxTurnos, TurnoActual, PartidaFinal, EventosAcc, EventosFinal) :-
    simular_turno(Partida0, Partida1, EventoTurno),
    TurnoSiguiente is TurnoActual + 1,
    simular_n_turnos(Partida1, MaxTurnos, TurnoSiguiente, PartidaFinal, [EventoTurno|EventosAcc], EventosFinal).

simular_turno(
    partida(Tablero, Banco0, Jugadores0, TurnoActual, MaxTurnos, EstadoDados0, PoliticaCompra, historial(Etiqueta, Historial0)),
    partida(Tablero, Banco1, Jugadores1, TurnoSiguiente, MaxTurnos, EstadoDados1, PoliticaCompra, historial(Etiqueta, [Evento|Historial0])),
    Evento
) :-
    length(Jugadores0, NumJugadores),
    NumJugadores > 0,
    IndiceJugador is ((TurnoActual - 1) mod NumJugadores) + 1,
    nth1(IndiceJugador, Jugadores0, JugadorActual, OtrosJugadores0),

    JugadorActual = jugador(NombreJugador, PosAnterior, DineroInicialTurno, PropsAntes, EnCarcel),

    dados:tirar_dos_dados(EstadoDados0, D1, D2, EstadoDados1),
    Suma is D1 + D2,

    PosNueva is ((PosAnterior - 1 + Suma) mod 40) + 1,
    (PosAnterior + Suma > 40 -> PasoSalida = si ; PasoSalida = no),

    tablero:casilla_en_posicion(PosNueva, Tablero, CasillaDestino),
    CasillaDestino = casilla(_, TipoCasilla, NombreCasilla, PrecioCasilla, ColorCasilla),

    JugadorMovido = jugador(NombreJugador, PosNueva, DineroInicialTurno, PropsAntes, EnCarcel),

    compras:aplicar_compra_si_procede(
        TurnoActual,
        PoliticaCompra,
        JugadorMovido,
        CasillaDestino,
        Banco0,
        JugadorTrasCompra,
        Banco1,
        CompraRealizada,
        EventoCompra,
        _DineroAntesCompra,
        _DineroDespuesCompra
    ),

    alquileres:resolver_alquiler_si_procede(
        TurnoActual,
        CompraRealizada,
        CasillaDestino,
        JugadorTrasCompra,
        OtrosJugadores0,
        JugadorFinal,
        OtrosJugadores1,
        AlquilerRealizado,
        EventoAlquiler,
        AlquilerTeorico,
        PagoReal,
        DineroFinalTurno
    ),

    nth1(IndiceJugador, Jugadores1, JugadorFinal, OtrosJugadores1),

    length(PropsAntes, NumPropsAntes),
    JugadorFinal = jugador(_, _, _, PropsDespues, _),
    length(PropsDespues, NumPropsDespues),

    Evento = evento_turno(
        TurnoActual,
        IndiceJugador,
        NombreJugador,
        D1,
        D2,
        Suma,
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
        DineroFinalTurno,
        NumPropsAntes,
        NumPropsDespues
    ),

    TurnoSiguiente is TurnoActual + 1.

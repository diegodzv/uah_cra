:- encoding(utf8).

:- module(semantico, [
    tipo/2,
    sentido/3,
    espera_sujeto/2,
    espera_objeto/2,
    uso_literal/3,
    palabra_ambigua/1,
    categoria_valida/2
]).

/* =========================================================
   2.2 ENRIQUECIMIENTO SEMANTICO
   Dominio: tecnologia / inteligencia artificial
   Corpus: frases adaptadas de "Attention Is All You Need"
   ========================================================= */


/* =========================================================
   TIPOS SEMANTICOS BASICOS DEL CORPUS
   ========================================================= */

% Entidades principales del dominio
tipo(transformer, arquitectura_neuronal).
tipo(modelo, sistema_computacional).
tipo(codificador, modulo_neuronal).
tipo(decodificador, modulo_neuronal).
tipo(modulo, modulo_neuronal).

tipo(capa, componente_modelo).
tipo(capas, componente_modelo).

tipo(red, sistema_computacional).

% Mecanismos y operaciones de arquitectura
tipo(atencion, mecanismo).
tipo(autoatencion, mecanismo).
tipo(mecanismo, mecanismo).
tipo(mecanismos, mecanismo).
tipo(recurrencia, mecanismo).

% En el dominio Transformer, una conexion residual se modela mejor
% como componente arquitectonico que como "mecanismo" generico.
tipo(conexion, componente_modelo).
tipo(conexiones, componente_modelo).

% Datos, representaciones y elementos matematicos
tipo(secuencia, estructura_datos).
tipo(posiciones, elemento_secuencia).
tipo(representaciones, representacion_vectorial).
tipo(embeddings, representacion_vectorial).

tipo(matriz, estructura_matematica).
tipo(pesos, parametro_modelo).

tipo(codificacion, representacion_vectorial).
tipo(codificaciones, representacion_vectorial).

tipo(orden, propiedad_secuencia).
tipo(salida, estructura_datos).

% Propiedades, funciones y tareas
tipo(paralelizacion, propiedad_computacional).
tipo(calidad, propiedad_resultado).
tipo(traduccion, tarea_linguistica).

tipo(softmax, funcion_matematica).
tipo(suma, operacion_matematica).
tipo(funciones, funcion_matematica).

% Adjetivos relevantes del corpus
tipo(residual, propiedad_arquitectonica).
tipo(residuales, propiedad_arquitectonica).
tipo(continuas, propiedad_representacion).
tipo(posicional, propiedad_representacion).
tipo(posicionales, propiedad_representacion).
tipo(sinusoidales, propiedad_matematica).
tipo(ponderada, propiedad_matematica).
tipo(feed_forward, tipo_red).


/* =========================================================
   LEXICO AUXILIAR PARA EJEMPLOS DE DETECCION
   Estas palabras no pertenecen necesariamente al corpus principal.
   Se usan para probar incoherencia y uso no literal.
   ========================================================= */

tipo(datos, estructura_datos).
tipo(texto, estructura_datos).
tipo(oracion, estructura_datos).
tipo(entrada, estructura_datos).
tipo(parametros, parametro_modelo).

tipo(aprende, proceso_aprendizaje).
tipo(entrena, proceso_aprendizaje).

tipo(devora, accion_fisica).
tipo(mira, accion_perceptiva).
tipo(suena, proceso_cognitivo).


/* =========================================================
   SENTIDOS POSIBLES PARA AMBIGUEDAD LEXICA
   ========================================================= */

sentido(modelo, modelo_ia, sistema_computacional).
sentido(modelo, modelo_teorico, abstraccion).

sentido(red, red_neuronal, sistema_computacional).
sentido(red, red_comunicacion, infraestructura).

sentido(capa, capa_neuronal, componente_modelo).
sentido(capa, capa_fisica, objeto_fisico).

sentido(capas, capas_neuronales, componente_modelo).
sentido(capas, capas_fisicas, objeto_fisico).

sentido(atencion, atencion_neuronal, mecanismo).
sentido(atencion, atencion_humana, proceso_cognitivo).

sentido(mecanismo, mecanismo_algoritmico, mecanismo).
sentido(mecanismo, mecanismo_fisico, objeto_fisico).

sentido(mecanismos, mecanismos_algoritmicos, mecanismo).
sentido(mecanismos, mecanismos_fisicos, objeto_fisico).


/* =========================================================
   EXPECTATIVAS SEMANTICAS DE SUJETO
   espera_sujeto(Verbo, TipoEsperado)

   Nota de diseño:
   Algunos verbos como usa/usan se dejan con sujeto "entidad"
   porque en el corpus aparecen con sujetos variados:
   - modelo
   - codificador
   - decodificador
   - capas
   - codificaciones
   ========================================================= */

espera_sujeto(usa, entidad).
espera_sujeto(usan, entidad).

espera_sujeto(elimina, sistema_computacional).
espera_sujeto(contiene, sistema_computacional).

espera_sujeto(produce, sistema_computacional).
espera_sujeto(producen, componente_modelo).

espera_sujeto(relaciona, mecanismo).
espera_sujeto(comparte, sistema_computacional).
espera_sujeto(mejora, sistema_computacional).
espera_sujeto(permite, sistema_computacional).

espera_sujeto(calcula, mecanismo).
espera_sujeto(aplica, sistema_computacional).
espera_sujeto(genera, sistema_computacional).

espera_sujeto(representa, representacion_vectorial).
espera_sujeto(representan, representacion_vectorial).

espera_sujeto(generaliza, sistema_computacional).
espera_sujeto(es, entidad).
espera_sujeto(mantiene, sistema_computacional).

% Verbos auxiliares para ejemplos problematicos
espera_sujeto(aprende, sistema_computacional).
espera_sujeto(entrena, sistema_computacional).

espera_sujeto(devora, ser_vivo).
espera_sujeto(mira, ser_vivo).
espera_sujeto(suena, ser_vivo).


/* =========================================================
   EXPECTATIVAS SEMANTICAS DE OBJETO
   espera_objeto(Verbo, TipoEsperado)

   Nota de diseño:
   Se relajan algunos objetos a "entidad" para evitar falsos positivos
   en frases correctas del corpus.
   ========================================================= */

espera_objeto(usa, entidad).
espera_objeto(usan, entidad).

espera_objeto(elimina, mecanismo).
espera_objeto(contiene, componente_modelo).

espera_objeto(produce, representacion_vectorial).
espera_objeto(producen, representacion_vectorial).

espera_objeto(relaciona, elemento_secuencia).
espera_objeto(comparte, estructura_matematica).
espera_objeto(mejora, propiedad_resultado).
espera_objeto(permite, propiedad_computacional).

espera_objeto(calcula, operacion_matematica).
espera_objeto(aplica, entidad).
espera_objeto(genera, estructura_datos).

espera_objeto(representa, propiedad_secuencia).
espera_objeto(representan, propiedad_secuencia).

espera_objeto(mantiene, entidad).

% Verbos auxiliares para ejemplos problematicos
espera_objeto(aprende, estructura_datos).
espera_objeto(entrena, estructura_datos).

espera_objeto(devora, alimento).
espera_objeto(mira, entidad).
espera_objeto(suena, entidad).


/* =========================================================
   USO LITERAL ESPERADO
   uso_literal(Verbo, TipoSujeto, TipoObjeto)
   ========================================================= */

uso_literal(usa, entidad, entidad).
uso_literal(usan, entidad, entidad).

uso_literal(elimina, sistema_computacional, mecanismo).
uso_literal(contiene, sistema_computacional, componente_modelo).

uso_literal(produce, sistema_computacional, representacion_vectorial).
uso_literal(producen, componente_modelo, representacion_vectorial).

uso_literal(relaciona, mecanismo, elemento_secuencia).
uso_literal(comparte, sistema_computacional, estructura_matematica).
uso_literal(mejora, sistema_computacional, propiedad_resultado).
uso_literal(permite, sistema_computacional, propiedad_computacional).

uso_literal(calcula, mecanismo, operacion_matematica).
uso_literal(aplica, sistema_computacional, entidad).
uso_literal(genera, sistema_computacional, estructura_datos).

uso_literal(representa, representacion_vectorial, propiedad_secuencia).
uso_literal(representan, representacion_vectorial, propiedad_secuencia).

uso_literal(mantiene, sistema_computacional, entidad).

% Usos literales auxiliares para pruebas
uso_literal(aprende, sistema_computacional, estructura_datos).
uso_literal(entrena, sistema_computacional, estructura_datos).

uso_literal(devora, ser_vivo, alimento).
uso_literal(mira, ser_vivo, entidad).
uso_literal(suena, ser_vivo, entidad).


/* =========================================================
   CATEGORIAS COMPATIBLES
   categoria_valida(TipoReal, TipoEsperado)
   ========================================================= */

% Una categoria siempre es compatible consigo misma.
categoria_valida(Tipo, Tipo).

% Jerarquia de entidades computacionales
categoria_valida(arquitectura_neuronal, sistema_computacional).
categoria_valida(modulo_neuronal, sistema_computacional).

% En el corpus, las capas pueden actuar como sujetos de verbos
% como producen/usan.
categoria_valida(componente_modelo, sistema_computacional).

% Categoria general entidad
categoria_valida(sistema_computacional, entidad).
categoria_valida(arquitectura_neuronal, entidad).
categoria_valida(modulo_neuronal, entidad).
categoria_valida(componente_modelo, entidad).

categoria_valida(mecanismo, entidad).
categoria_valida(representacion_vectorial, entidad).
categoria_valida(estructura_datos, entidad).
categoria_valida(elemento_secuencia, entidad).
categoria_valida(estructura_matematica, entidad).
categoria_valida(parametro_modelo, entidad).
categoria_valida(funcion_matematica, entidad).
categoria_valida(operacion_matematica, entidad).

categoria_valida(propiedad_resultado, entidad).
categoria_valida(propiedad_computacional, entidad).
categoria_valida(propiedad_secuencia, entidad).
categoria_valida(propiedad_representacion, entidad).
categoria_valida(propiedad_arquitectonica, entidad).
categoria_valida(propiedad_matematica, entidad).

categoria_valida(resultado_modelo, entidad).
categoria_valida(tarea_linguistica, entidad).
categoria_valida(tipo_red, entidad).

% Compatibilidades utiles del dominio
categoria_valida(funcion_matematica, mecanismo).
categoria_valida(operacion_matematica, funcion_matematica).

% Representaciones y datos
categoria_valida(representacion_vectorial, estructura_datos).
categoria_valida(parametro_modelo, estructura_datos).


/* =========================================================
   DERIVADOS
   ========================================================= */

palabra_ambigua(Palabra) :-
    sentido(Palabra, S1, _),
    sentido(Palabra, S2, _),
    S1 @< S2.

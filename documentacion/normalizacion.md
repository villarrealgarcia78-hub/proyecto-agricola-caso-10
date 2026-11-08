# Normalización

Organizo los datos para evitar repeticiones innecesarias y mantener clara la relación entre las tablas. En este documento explico cómo aplico la primera, segunda y tercera forma normal (1FN, 2FN y 3FN).

## Primera forma normal (1FN)

En las diez tablas del modelo, cada campo guarda un solo valor. No guardo listas de insumos ni creo grupos de columnas repetidas para ellos.

Para los insumos utilizados en una labor, uso `ConsumoInsumo`. Cada fila corresponde a una pareja formada por `id_labor`, que identifica la labor, e `id_insumo`, que identifica el insumo.

## Segunda forma normal (2FN)

Para aplicar la segunda forma normal, mantengo las condiciones de 1FN y reviso que los campos que no forman parte de una clave dependan de la clave completa, no solo de una parte.

En `ConsumoInsumo`, uso una clave compuesta, es decir, formada por dos campos: `id_labor` e `id_insumo`. La `cantidad` total y el `costo_unitario_aplicado` corresponden a esa pareja: necesito saber qué insumo se utiliza y en qué labor. El costo por unidad aplicado pertenece a ese consumo y se conserva aunque cambie el costo actual del insumo.

Dejo la fecha de la labor en `Labor`. El nombre, la unidad y el costo actual del insumo permanecen en `Insumo`, porque describen al insumo y no a cada consumo.

En `Lote` tengo dos claves candidatas, es decir, dos formas de identificar cada fila sin confundirla con otra: `id_lote` y la pareja formada por `id_predio` y `codigo_lote`. Elijo `id_lote` como clave primaria, es decir, como identificador principal.

El nombre y el área corresponden al lote identificado por la pareja completa. El predio por sí solo puede tener varios lotes, y el código del lote puede repetirse en otros predios. Por eso, reviso ambas claves candidatas al comprobar la segunda forma normal.

## Tercera forma normal (3FN)

Mantengo las condiciones de 2FN y reviso los datos que puedo obtener mediante las relaciones entre las tablas.

En `Labor` conservo `id_trabajador` e `id_ciclo`. Obtengo el nombre del trabajador desde `Trabajador`. Copiar ese nombre en `Labor` crea una dependencia indirecta: la labor identifica al trabajador y el trabajador determina su nombre. Esa dependencia se llama dependencia transitiva.

También obtengo el lote desde `CicloCultivo`, sin repetir `id_lote` en `Labor`.

En `CicloCultivo` no repito los nombres del lote, cultivo o temporada. Incluyo las fechas propias del ciclo, pero no copio las fechas de la temporada.

En `Cosecha` conservo `id_ciclo`, que identifica el ciclo. A través de él obtengo el lote, el cultivo y la temporada.

Calculo el costo total de los consumos, la producción y el rendimiento a partir de los datos registrados, sin añadir columnas para guardar esos resultados.

## Resultado

Mi modelo tiene diez tablas y 53 campos. Cumple la tercera forma normal (3FN), según las claves y las dependencias entre los datos que explico en este documento.

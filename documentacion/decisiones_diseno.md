# Caso 10: decisiones de diseño

**Parte I — Diseño de la base de datos y diccionario:** 11 de noviembre de 2026.  
**Parte II — Implementación:** 18 de noviembre de 2026.

En este documento explico las decisiones de mi diseño y los cálculos que planteo para las consultas. La implementación y las pruebas están pendientes para la Parte II.

Tomo como guía **Proyecto integrador.pdf**: las reglas generales de las páginas 1–5 y el caso 10 de las páginas 24–26. Mi [esquema propuesto](../modelo/esquema.json) contiene diez tablas, 53 campos y nueve relaciones mediante claves foráneas, que conectan los registros de las tablas.

En [reglas del negocio](reglas_negocio.md) presento las condiciones del enunciado, las comprobaciones previstas y las cantidades de datos requeridas. Aquí explico las decisiones que tomo sobre los detalles que el enunciado no especifica.

## 1. Decisiones de mi diseño

### D01. Separar tipo de cultivo y siembra concreta

En mi diseño, `Cultivo` representa el tipo de cultivo, por ejemplo, maíz. Uso `CicloCultivo` para representar una siembra de ese cultivo en un lote y una temporada. Así, un mismo cultivo puede aparecer en varios ciclos sin repetir sus datos de identificación.

### D02. Toda labor pertenece a un ciclo

En mi diseño, relaciono cada labor con un solo ciclo de cultivo. A través de ese ciclo identifico el lote donde se realiza la labor. Así represento la relación «lote/ciclo» del enunciado.

En la tabla `Labor` incluyo `id_ciclo`, que identifica el ciclo de la labor. No repito `id_lote`, el identificador del lote, porque ese dato ya está en el ciclo. Así evito que una labor indique un lote diferente al de su ciclo. Con esta decisión, solo puedo registrar labores en lotes que tienen un ciclo asociado.

Para cada labor, incluyo un trabajador responsable. Un trabajador puede estar registrado sin tener labores asignadas o ser responsable de una o varias labores.

### D03. Cada ciclo utiliza el lote completo

En mi diseño, cada ciclo utiliza toda el área de su lote. Esa área está en el campo `area_ha` de la tabla `Lote`, expresada en hectáreas. Por eso, en `CicloCultivo` no incluyo un campo para indicar que la siembra ocupa solo una parte del lote.

Para calcular el rendimiento, es decir, los kilogramos cosechados por hectárea, uso el área registrada del lote. La cuento una sola vez por cada ciclo con cosecha, aunque ese ciclo tenga varias cosechas.

En mi diseño no incluyo comprobaciones automáticas para impedir que un lote tenga ciclos al mismo tiempo ni para comparar la suma de las áreas de los lotes con el área del predio. Tampoco incluyo un historial de cambios del área.

### D04. Unidades explícitas

En mi diseño, uso las siguientes unidades:

- **Áreas:** hectáreas, identificadas como `ha`.
- **Duración de las labores:** horas.
- **Costos:** pesos colombianos, identificados como `COP`.
- **Cantidad sembrada:** `semillas`, `plantas` o kilogramos (`kg`). Para semillas y plantas uso cantidades enteras, es decir, sin decimales.
- **Insumos:** kilogramos (`kg`), litros (`L`) o `unidad`. La cantidad disponible y la cantidad consumida usan la misma unidad del insumo. Cuando uso `unidad`, ambas cantidades deben ser enteras.
- **Cosechas:** kilogramos (`kg`) o toneladas (`t`). Antes de sumar la producción, convierto las toneladas a kilogramos: **1 t = 1.000 kg**.

Solo sumo cantidades expresadas en la misma unidad.

En mi diseño, mantengo la unidad de un insumo cuando ya tiene consumos registrados, para conservar el significado de las cantidades anteriores. Si necesito usar otra unidad, debo convertir la cantidad a la unidad del insumo o usar un registro diferente para ese insumo.

El código y las pruebas de estas reglas están pendientes para la Parte II.

### D05. Una fila de consumo por pareja labor e insumo

En mi diseño, cada fila de `ConsumoInsumo` representa el consumo total de un insumo en una labor. Uso una **clave primaria compuesta**, formada por `id_labor`, que identifica la labor, e `id_insumo`, que identifica el insumo. Cada identificador puede repetirse por separado, pero la pareja no.

En esa fila incluyo la cantidad total utilizada y el costo por unidad aplicado en la labor. No uso esta fila para registrar cada retiro individual del almacén.

Calculo el importe del consumo, es decir, su costo total, multiplicando la cantidad utilizada por el costo de cada unidad:

`importe_consumo = cantidad × costo_unitario_aplicado`

Calculo este resultado cuando lo necesito; no incluyo una columna para guardarlo.

Conservo el costo por unidad aplicado en `ConsumoInsumo`, aunque después cambie el costo actual del insumo en `Insumo`. Así, el cambio de precio no altera el costo de una labor anterior.

### D06. Disponibilidad positiva y alcance del inventario

En mi diseño, defino que el campo `cantidad_disponible` de la tabla `Insumo` sea **mayor que cero**. La condición `> 0` significa que no admito cero ni valores negativos. Por eso, mi modelo no representa un insumo agotado con cantidad disponible igual a cero.

El punto 6 del enunciado pide registrar la cantidad disponible, pero no indica cómo tratar los insumos agotados. Tomo la condición de cantidades positivas del punto 9 y la aplico también a la disponibilidad. Esta es una decisión de mi diseño.

Incluyo la cantidad disponible de cada insumo y los consumos asociados a las labores. No incluyo un sistema completo para registrar las entradas, las salidas y las correcciones de las cantidades del inventario.

Mantengo la cantidad disponible separada del historial de consumos. En mi diseño, registrar un consumo no descuenta automáticamente esa cantidad de la disponibilidad.

### D07. Fechas y estado del ciclo

En mi diseño, la fecha de inicio de una temporada o un ciclo no puede ser posterior a su fecha final. Lo expreso como `fecha_inicio <= fecha_fin`: el símbolo `<=` significa **menor o igual**. Por eso, ambas fechas pueden coincidir.

Defino que cada ciclo esté dentro de las fechas de su temporada. Las fechas de las labores y las cosechas también deben estar dentro de las fechas de su ciclo. Estas son decisiones de mi diseño para mantener relacionadas las fechas.

Para el ciclo, uso los estados `Activo`, `Finalizado` y `Cancelado`. Elijo `Activo` como valor predeterminado: se asigna cuando no indico un estado al crear el registro.

Mientras el ciclo está activo, `fecha_fin` representa la fecha prevista de finalización. Al cerrar el ciclo, debo confirmar o corregir esa fecha sin que las labores o cosechas queden fuera del ciclo ni el ciclo fuera de su temporada.

Para comparar fechas de una misma fila, incluyo `CHECK`, que comprueba una condición sobre sus datos. Comparar registros de distintas tablas necesita otro mecanismo. Su elección, el código y las pruebas están pendientes para la Parte II.

Incluyo estas comprobaciones al agregar registros o cambiar sus fechas o referencias, como el ciclo al que pertenece una labor. También las considero si cambian las fechas de una temporada o un ciclo, aunque una operación afecte varias filas.

### D08. Campos obligatorios e identificadores

Todos los campos son obligatorios. Uso `NOT NULL` para impedir `NULL`, que significa ausencia de un valor. Un predio puede existir sin lotes y un lote sin ciclos. Si registro un lote, debo indicar un predio existente; si registro un ciclo, debo indicar su lote.

En nueve tablas defino identificadores de tipo `INT`, que guarda números enteros, y uso `IDENTITY(1,1)` para generarlos automáticamente. El primer `1` indica que la numeración empieza en uno; el segundo `1`, que aumenta de uno en uno. Los números guardados pueden tener saltos, así que no uso el último identificador para contar las filas.

`IDENTITY` genera el número. La **clave primaria** identifica la fila e impide que su identificador se repita. En `ConsumoInsumo` uso como clave primaria la pareja `id_labor` e `id_insumo`, sin añadir otro identificador.

Mantengo únicos los códigos de predio, cultivo, temporada e insumo y el documento del trabajador en sus respectivas tablas. El código del lote es único dentro de su predio.

También impido el texto vacío en los campos donde lo indica el diccionario. Esta comprobación es adicional: `NOT NULL` no impide por sí solo un texto vacío.

No incluyo **borrado en cascada**, que borra automáticamente los registros relacionados al eliminar el registro del que dependen. Impido borrar un registro mientras otros lo usan como referencia.

### D09. Estados y clasificaciones sencillas como campos

Represento los estados, el tipo de labor, las unidades y la calidad mediante campos de las tablas. No creo tablas adicionales para estas clasificaciones, porque el ejercicio no necesita manejarlas por separado.

Para los campos con una lista de valores permitidos, incluyo comprobaciones que impidan usar otros valores. Por ejemplo, el estado del ciclo admite `Activo`, `Finalizado` y `Cancelado`. El código y las pruebas de estas comprobaciones están pendientes para la Parte II.

Para el tipo de labor, tengo previsto usar nombres claros y escribir de la misma forma cada actividad, sin limitar el campo a una lista fija de opciones.

Mantengo `Cultivo` y `Temporada` como tablas independientes porque tienen sus propios datos y relaciones. Para ambas conservo el mínimo de 1.000 registros exigido por tabla. Sigue pendiente aclarar cómo cumplir esa cantidad con datos razonables para el caso.

## 2. Definiciones para las consultas de producción y costo

Defino los criterios que uso para calcular y comparar los resultados. El enunciado pide estas consultas, pero no establece sus fórmulas ni todos los criterios de comparación. Su implementación y sus pruebas están pendientes para la Parte II.

### Producción y rendimiento

Primero expreso cada cosecha en kilogramos. Después sumo las cosechas de cada ciclo y reúno sus resultados por lote y temporada.

Para calcular el rendimiento de un lote en una temporada, uso esta fórmula:

`rendimiento_kg_ha = producción total en kg / suma de las áreas de los ciclos con cosecha`

El signo `/` indica división. Expreso el resultado en `kg/ha`, es decir, kilogramos por hectárea.

Cuento el área del lote **una sola vez por cada ciclo con cosecha**, aunque ese ciclo tenga varias cosechas. No sumo las áreas de los ciclos sin cosecha. Si no hay ciclos con cosecha, dejo el rendimiento sin resultado calculable.

En un ejemplo ficticio, un lote de 2 ha tiene un ciclo con cosechas de 6.000 kg y 4.000 kg. El rendimiento es `(6.000 + 4.000) / 2 = 5.000 kg/ha`. Si ese lote tiene dos ciclos con cosecha en la temporada, cuento 2 ha por ciclo: 4 ha en total para el cálculo.

Para comparar cultivos, calculo el rendimiento de cada cultivo por temporada: sumo su producción y la divido entre la suma de las áreas de sus ciclos con cosecha. Obtengo el promedio sumando los rendimientos de los cultivos con cosecha y dividiendo entre el número de esos cultivos, todos de la misma temporada. Uso `>`, que significa «mayor que», para seleccionar los rendimientos superiores al promedio. Los iguales al promedio no cumplen esa condición. Este cálculo mide producción por área, no ganancias económicas.

Para comparar predios, sumo su producción en kilogramos por temporada. Identifico la mayor producción y conservo todos los predios que tengan ese resultado, incluidos los empates. Uso la temporada asignada al ciclo.

### Costos de insumos

Calculo el costo de cada consumo multiplicando la cantidad utilizada por el costo por unidad aplicado en la labor. Para obtener el costo de insumos de un ciclo, sumo los costos de todos los consumos de sus labores. Expreso el resultado en pesos colombianos.

Uso el costo aplicado que conserva `ConsumoInsumo`, aunque después cambie el precio actual del insumo. Si un ciclo no tiene consumos, su costo de insumos es cero para este cálculo.

Para comparar los ciclos de una misma temporada, sumo sus costos y divido entre la cantidad de ciclos. Incluyo también los ciclos sin consumos, con costo cero. Selecciono los ciclos con costos mayores que ese promedio. La comparación `>` significa **mayor que**; los costos iguales al promedio no cumplen «superior».

Cuando necesito combinar producción y costos, primero sumo las cosechas por ciclo y, por separado, los costos de sus consumos. Después relaciono esos resultados por ciclo. Así evito repetir cosechas o consumos y aumentar incorrectamente los totales.

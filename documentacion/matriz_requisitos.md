# Caso 10: matriz de requisitos

**Parte I — Diseño y diccionario:** 11 de noviembre de 2026.  
**Parte II:** 18 de noviembre de 2026.

En esta matriz relaciono los requisitos del caso con las tablas del modelo, las reglas que deben cumplir los datos y las consultas previstas.

El diseño corresponde a la Parte I. La implementación y las pruebas de SQL Server y MongoDB están pendientes para la Parte II.

Fuentes: enunciado del profesor (`Proyecto integrador.pdf`), páginas 1 a 5, 24 a 26, 28 y 29; [esquema del modelo](../modelo/esquema.json), [reglas de negocio](reglas_negocio.md) y [decisiones de diseño](decisiones_diseno.md).

## 1. Las diez reglas específicas

En esta tabla relaciono las diez reglas del caso con los datos y los controles que incluyo en mi diseño. Uso los códigos R01 a R10 para identificar las reglas. Las pruebas están pendientes para la Parte II.

| Regla y fuente | Requisito | Cómo lo represento | Qué tengo pendiente probar |
|---|---|---|---|
| R01, p. 24 | Código único de predio, código de lote único dentro de su predio y áreas mayores que cero. | Uso `UNIQUE`, que impide repeticiones, para `Predio.codigo_predio` y la pareja `id_predio` y `codigo_lote` de `Lote`. Uso `CHECK`, que comprueba condiciones sobre los datos de una fila, para las áreas `area_ha`. Cada lote hace referencia a un predio existente. | Rechazar códigos de predio repetidos, lotes repetidos dentro del mismo predio, referencias inexistentes y áreas iguales o menores que cero. Admitir el mismo código de lote en predios distintos y áreas mayores que cero. |
| R02, p. 24 | Tipos de cultivo y temporadas con códigos únicos y fechas coherentes. | En `Cultivo.codigo_cultivo` y `Temporada.codigo_temporada` uso `UNIQUE`. En `Temporada`, uso `CHECK` para que `fecha_inicio` sea anterior o igual a `fecha_fin`. Las fechas de siembra están en `CicloCultivo`. | Rechazar códigos repetidos y fechas invertidas. Admitir fechas de inicio y final iguales o en el orden correcto. |
| R03, p. 24 | Ciclos con lote, cultivo, temporada, fechas y cantidad sembrada. | En `CicloCultivo`, incluyo `id_lote`, `id_cultivo` e `id_temporada`. Uso `FOREIGN KEY`, o clave foránea, para comprobar que esas referencias existan, y `NOT NULL` para exigir datos. Incluyo fechas, `cantidad_sembrada` y `unidad_siembra`. Uso `CHECK` para las condiciones de la misma fila y otra comprobación para que el ciclo quede dentro de su temporada. | Rechazar referencias inexistentes, datos ausentes, cantidades iguales o menores que cero, unidades no permitidas y fechas invertidas o fuera de temporada. Comprobar que semillas y plantas tengan cantidades enteras, sin decimales. |
| R04, p. 24 | Trabajadores con documento único, función y estado. | En `Trabajador`, conservo `documento` como texto único, junto con `funcion` y `estado`. Uso `UNIQUE`, `NOT NULL` y comprobaciones de texto no vacío y estados permitidos. `NOT NULL` impide la ausencia de un dato, pero no impide por sí solo un texto vacío. | Rechazar documentos repetidos, datos ausentes, textos vacíos y estados distintos de `Activo` e `Inactivo`. |
| R05, p. 25 | Labores con tipo, fecha, lote/ciclo, responsable y duración mayor que cero. | En `Labor`, incluyo `tipo`, `fecha`, `id_ciclo`, `id_trabajador` y `duracion_horas`. Las claves foráneas comprueban el ciclo y el trabajador; `CHECK` comprueba la duración. Relaciono cada labor con un ciclo y obtengo el lote desde ese ciclo, según mi decisión D02. La fecha debe quedar dentro del ciclo. | Rechazar referencias inexistentes, datos ausentes, duración igual o menor que cero y fechas fuera del ciclo. |
| R06, p. 25 | Insumos con código único, unidad, costo por unidad mayor o igual que cero y cantidad disponible. | En `Insumo`, incluyo `codigo_insumo`, `unidad`, `costo_unitario` y `cantidad_disponible`. Uso `UNIQUE` y `CHECK` para el código y las condiciones de esos datos. Defino la disponibilidad como mayor que cero, según mi decisión D06, basada en R09. No descuento automáticamente la disponibilidad al registrar consumos. | Rechazar códigos repetidos, costos negativos, disponibilidad igual o menor que cero y unidades no permitidas. Admitir costo cero y exigir disponibilidad entera cuando el insumo se mide en `unidad`. |
| R07, p. 25 | Varios insumos por labor y varias labores por insumo, con cantidad y costo aplicado. | En `ConsumoInsumo`, uso `PRIMARY KEY`, o clave primaria, para identificar cada fila con la pareja `id_labor` e `id_insumo`. Las claves foráneas comprueban ambas referencias. `cantidad` guarda el total consumido y `costo_unitario_aplicado` conserva el costo por unidad de esa labor. Uso `CHECK` para cantidad mayor que cero y costo mayor o igual que cero. | Rechazar parejas repetidas, referencias inexistentes y cantidades o costos inválidos. Consultar la unidad del insumo para exigir consumos enteros cuando se mide en `unidad`. Comprobar que cambiar el costo actual del insumo no cambie el costo aplicado de los consumos anteriores. |
| R08, p. 25 | Cosechas por ciclo, con fecha, cantidad obtenida, unidad y calidad. | En `Cosecha`, incluyo `id_ciclo`, `fecha`, `cantidad`, `unidad` y `calidad`. Una clave foránea comprueba el ciclo y `CHECK` comprueba cantidad y valores permitidos. La fecha debe quedar dentro del ciclo. Un ciclo puede tener varias cosechas. | Rechazar ciclos inexistentes, fechas fuera del ciclo, cantidades iguales o menores que cero, unidades distintas de `kg` y `t`, y calidades distintas de `Primera`, `Segunda` e `Industrial`. |
| R09, p. 25 | Fechas coherentes, cantidades, áreas y duraciones mayores que cero, y estado inicial del ciclo. | Uso `CHECK` para condiciones de una misma fila y comprobaciones entre tablas para las fechas relacionadas. En `CicloCultivo.estado`, uso `DEFAULT`, que asigna `Activo` cuando no indico un estado al crear el registro. Los costos sí admiten cero. | Probar fechas válidas e inválidas y valores iguales o menores que cero donde exijo valores positivos. Comprobar el estado inicial al omitirlo y rechazar estados distintos de `Activo`, `Finalizado` y `Cancelado`. |
| R10, p. 25 | Permitir lotes sin siembras activas e insumos no utilizados durante una temporada. | Permito lotes sin ciclos e insumos sin consumos. Para revisar una temporada, relaciono `Lote` con `CicloCultivo`, e `Insumo` con `ConsumoInsumo`, `Labor` y `CicloCultivo`. Un lote o insumo puede tener historial y no tener actividad en la temporada consultada. | Preparar lotes sin ciclos, lotes sin ciclos activos e insumos sin consumos. También probar lotes e insumos con registros de otras temporadas para comprobar el filtro de la temporada consultada. |

Todos los campos son obligatorios en mi diseño. Tengo pendiente probar los datos válidos e inválidos y comprobar que no se guarden registros que incumplen estas reglas.

Para las fechas relacionadas y los consumos en unidades enteras, necesito consultar otras tablas. Tengo pendiente elegir el mecanismo para estas comprobaciones. Incluyo las operaciones de agregar o modificar registros, los cambios en los datos relacionados y las operaciones que afectan varias filas. Mantengo la unidad del insumo cuando ya tiene consumos, como explico en D04.

En [reglas del negocio](reglas_negocio.md) y [decisiones de diseño](decisiones_diseno.md) explico estos controles y las decisiones D02, D04 y D06.

## 2. Preguntas de negocio para resolver con SQL

Las diez preguntas corresponden a la página 25 del enunciado. En esta tabla explico qué datos necesito y cómo planteo cada consulta. Su implementación y sus pruebas están pendientes para la Parte II.

| Código | Pregunta del profesor | Tablas que relaciono | Cómo planteo la consulta |
|---|---|---|---|
| Q01 | Listar lotes por predio y área. | `Predio` y `Lote`. | Uso `SELECT` para elegir los datos que muestro y `JOIN` para relacionar las tablas. Incluyo la identificación, el nombre y el área del lote, y ordeno los resultados por predio y área. |
| Q02 | Consultar labores por rango de fechas. | `Labor`. Puedo añadir `CicloCultivo` y `Trabajador` para mostrar esos datos. | Uso `WHERE` para filtrar `Labor.fecha`. Incluyo tanto el día inicial como el final del rango y ordeno las labores por fecha. |
| Q03 | Contar labores por cultivo y temporada. | `Cultivo`, `CicloCultivo`, `Temporada` y `Labor`. | Uso `COUNT` para contar las labores y `GROUP BY` para agruparlas por cultivo y temporada. Cuento cada labor una sola vez. No añado los consumos a este conteo, porque una labor con varios insumos aparecería repetida. |
| Q04 | Calcular producción total y rendimiento por lote. | `Lote`, `CicloCultivo`, `Cosecha` y `Temporada`. | Convierto las cosechas a kilogramos. Uso `SUM` para sumarlas primero por ciclo y después por lote y temporada. Para el rendimiento, divido la producción total en kilogramos entre la suma de las áreas de los ciclos con cosecha. Cuento el área completa del lote una sola vez por cada ciclo con cosecha. |
| Q05 | Mostrar labores con lote, cultivo, trabajador e insumos. | `Labor`, `CicloCultivo`, `Lote`, `Cultivo`, `Trabajador`, `ConsumoInsumo` e `Insumo`. | Uso `JOIN` para las relaciones obligatorias y `LEFT JOIN` para añadir consumos e insumos. `LEFT JOIN` conserva también las labores que no tienen consumos. Si una labor utiliza varios insumos, aparece en varias filas, una por insumo. |
| Q06 | Listar insumos nunca utilizados. | `Insumo` y `ConsumoInsumo`. | Uso una subconsulta, es decir, una consulta dentro de otra. Con `NOT EXISTS` selecciono los insumos para los que esa subconsulta no encuentra consumos. Reviso todo el historial, sin limitarlo a una temporada. |
| Q07 | Encontrar lotes sin ciclos de cultivo. | `Lote` y `CicloCultivo`. | Uso `NOT EXISTS` para seleccionar los lotes que no tienen ningún ciclo registrado. Un lote con ciclos finalizados o cancelados tiene historial y no cumple esta condición. |
| Q08 | Identificar cultivos con rendimiento superior al promedio. | `Cultivo`, `CicloCultivo`, `Temporada`, `Lote` y `Cosecha`. | Calculo el rendimiento de cada cultivo por temporada: divido su producción total en kilogramos entre la suma de las áreas de sus ciclos con cosecha, contando cada área una vez por ciclo. Uso `AVG`, que calcula el promedio, sobre los rendimientos de los cultivos con cosecha de esa temporada. Cada cultivo cuenta una vez en ese promedio. Mediante una subconsulta selecciono solo los rendimientos mayores que el promedio, sin incluir los iguales. |
| Q09 | Consultar ciclos con costo de insumos superior al promedio. | `CicloCultivo`, `Labor`, `ConsumoInsumo` y `Temporada`. | Multiplico la cantidad de cada consumo por su `costo_unitario_aplicado` y sumo los costos por ciclo. Uso el costo aplicado de los consumos anteriores, aunque cambie el costo actual del insumo. Los ciclos sin consumos tienen costo cero y también cuentan en el promedio de todos los ciclos de la misma temporada. Mediante una subconsulta selecciono solo los costos mayores que ese promedio, sin incluir los iguales. |
| Q10 | Mostrar predios con mayor producción por temporada. | `Predio`, `Lote`, `CicloCultivo`, `Cosecha` y `Temporada`. | Sumo la producción en kilogramos por predio y temporada. Uso `MAX` para obtener la mayor producción de cada temporada y conservo todos los predios que tienen ese resultado, incluidos los empates. Uso la temporada asignada al ciclo. No añado los consumos a esta suma, para no repetir las cosechas. |

Antes de sumar la producción, convierto las toneladas a kilogramos: una tonelada equivale a 1.000 kilogramos. Expreso el rendimiento en `kg/ha`, es decir, kilogramos por hectárea, y los costos en pesos colombianos.

Si no hay ciclos con cosecha en el grupo que consulto, dejo el rendimiento sin resultado calculable. No lo trato como rendimiento cero. Este cálculo mide producción por área, no ganancias económicas.

En [decisiones de diseño](decisiones_diseno.md) explico las fórmulas y los criterios que uso para comparar lotes, cultivos, ciclos y predios por temporada.

## 3. Entidades y relaciones

Una entidad es un elemento del caso del que necesito guardar datos, como un predio o un trabajador. Represento esas entidades mediante diez tablas. En la columna de referencias, R identifica una regla y Q una pregunta de los apartados anteriores. Por ejemplo, R01 es la primera regla y Q10 es la décima pregunta.

| Tabla | Qué representa | Reglas y preguntas relacionadas | Cómo se relaciona |
|---|---|---|---|
| `Predio` | Una propiedad agrícola. | Regla R01 y pregunta Q10. | Un predio puede tener cero, uno o varios lotes. Cada lote pertenece a un solo predio. |
| `Lote` | Una parte de un predio, identificada con su propio código. | Reglas R01, R03 y R10; preguntas Q01, Q04 y Q07. | Un lote puede tener cero, uno o varios ciclos. Cada ciclo utiliza un solo lote. |
| `Cultivo` | Un tipo de cultivo, como maíz. | Reglas R02 y R03; preguntas Q03 y Q08. | Un cultivo puede aparecer en cero, uno o varios ciclos. Cada ciclo corresponde a un solo cultivo. |
| `Temporada` | Un periodo con fecha de inicio y fecha final que sirve de referencia para los ciclos. | Reglas R02, R03 y R09; comparaciones por temporada. | Una temporada puede tener cero, uno o varios ciclos. Cada ciclo pertenece a una sola temporada. |
| `CicloCultivo` | Una siembra de un cultivo en un lote y una temporada. | Regla R03. | Cada ciclo tiene un lote, un cultivo y una temporada. Puede tener cero, una o varias labores y cero, una o varias cosechas. |
| `Trabajador` | Una persona que puede estar a cargo de las labores agrícolas. | Reglas R04 y R05. | Un trabajador puede tener cero, una o varias labores asignadas. Cada labor tiene un solo trabajador responsable. |
| `Labor` | Una actividad agrícola realizada durante un ciclo de cultivo. | Reglas R05 y R07. | Cada labor pertenece a un ciclo y tiene un trabajador responsable. Puede tener cero, uno o varios registros de consumo de insumos. |
| `Insumo` | Un recurso que puede utilizarse en las labores, con unidad, costo actual por unidad y cantidad disponible. | Reglas R06 y R10. | Un insumo puede aparecer en cero, uno o varios registros de consumo. |
| `ConsumoInsumo` | El uso de un insumo en una labor, con la cantidad total y el costo por unidad aplicado. | Regla R07. | Cada fila corresponde a una labor y un insumo. Conservo el costo aplicado aunque cambie el costo actual del insumo. |
| `Cosecha` | La producción obtenida de un ciclo en una fecha. | Regla R08. | Cada cosecha corresponde a un solo ciclo. Un ciclo puede tener cero, una o varias cosechas. |

Con `ConsumoInsumo` represento que una labor puede usar varios insumos y que un insumo puede utilizarse en varias labores.

Las nueve relaciones del modelo usan claves foráneas, que indican con qué registro de otra tabla se relaciona cada fila. En mi diseño, esas referencias son obligatorias y deben señalar registros existentes.

Defino diez claves primarias, una por tabla, para identificar sus filas. Nueve usan un solo campo. En `ConsumoInsumo`, la clave es compuesta: reúne `id_labor` e `id_insumo`. Cada identificador puede repetirse por separado, pero la pareja no.

Todos los campos son obligatorios. Esto no obliga a que cada predio tenga lotes ni a que cada lote tenga ciclos. Si registro un lote, debo indicar un predio existente; si registro un ciclo, debo indicar su lote, cultivo y temporada.

La creación de las tablas y las pruebas están pendientes para la Parte II.

## 4. Requisitos generales y estado de la entrega

En esta tabla separo lo que pide la guía, cómo lo incluyo en mi proyecto y su estado actual. Uso los códigos G01 a G11 para identificar los requisitos generales; por ejemplo, G01 es el primero.

| Código | Qué pide la guía | Cómo lo incluyo en mi proyecto | Estado actual |
|---|---|---|---|
| G01 | Modelo entidad-relación (E-R), modelo relacional y normalización hasta la tercera forma normal (3FN), cuando corresponde. Los modelos incluyen campos, identificadores, relaciones, cardinalidad y participación. | Presento ambos modelos y explico la normalización. La cardinalidad indica cuántos registros pueden relacionarse; la participación indica si esa relación es obligatoria u opcional. | Parte I: modelos y normalización preparados. |
| G02 | Un diccionario que explique el significado, el tipo de dato, si el campo es obligatorio, las claves y las reglas. | El diccionario describe los 53 campos del modelo. Su contenido tiene una comprobación documental contra el esquema y el modelo relacional. | Parte I: diccionario completo y comprobado documentalmente. |
| G03 | SQL Server como componente principal, con archivos separados que permitan crear y reconstruir la base de datos. | Tengo previstos archivos con instrucciones, llamados scripts, para crear la estructura, aplicar las reglas, cargar los datos y realizar las consultas. | Parte II: creación y ejecución de los scripts pendientes. |
| G04 | Al menos 1.000 registros ficticios, variados y coherentes por cada tabla de SQL Server. | Incluyo las diez tablas, también `Cultivo`, `Temporada` y `ConsumoInsumo`. Los datos deben corresponder al caso y relacionarse correctamente. | Parte II: carga pendiente. Mantengo el mínimo de 1.000 filas mientras aclaro cómo reunir datos razonables para `Cultivo` y `Temporada`. |
| G05 | Consultas con filtros, orden, cálculos, agrupaciones, uniones y subconsultas, junto con la explicación de sus resultados. | Planteo las diez preguntas de negocio y las técnicas que explico debajo de esta tabla. Debo comprobar que las consultas incluyan todas las técnicas exigidas, también `MIN` y `HAVING`. | Parte II: consultas, pruebas y explicación de resultados pendientes. |
| G06 | Probar operaciones válidas e inválidas y comparar el resultado esperado con el obtenido. | El plan de pruebas incluye datos correctos y datos que incumplen las reglas. En cada prueba registraré la regla revisada, los pasos, el resultado esperado y el resultado obtenido. También comprobaré las cantidades de registros y la creación completa desde cero. | Parte II: pruebas y registro de resultados pendientes. |
| G07 | Un script separado de limpieza o reinicio, con advertencia de borrado, e instrucciones para reconstruir la base desde cero. | Prepararé el script con la advertencia correspondiente. El README indicará el entorno, las versiones, el orden de ejecución y las comprobaciones. | Parte II: script e instrucciones definitivas pendientes de crear y probar. |
| G08 | Un repositorio Git con commits descriptivos y una bitácora individual. | La bitácora contiene los avances documentales. Usaré commits, que guardan versiones de los archivos con un mensaje que describe el cambio. Registraré mis actividades reales en la bitácora. | Bitácora preparada. Repositorio Git, commits y registro individual de actividades pendientes. |
| G09 | MongoDB como complemento obligatorio, con al menos tres documentos ficticios y coherentes. Agregar, consultar, modificar y eliminar documentos, comprobando los resultados, y realizar una consulta que aproveche su estructura. | Tengo definido el alcance de la colección `observaciones_labor`. Cada documento es un registro con referencia a una labor o un ciclo, fecha y hora, tipo de observación, valores y unidades, y ubicación cuando corresponde. | Parte II: colección, carga de documentos, consultas y pruebas pendientes. |
| G10 | Explicar cómo se comprueba que las referencias de MongoDB correspondan a registros de SQL Server. | Comprobaré que cada identificador de labor o ciclo exista en SQL Server y guardaré el resultado de esa revisión. Guardar el identificador en MongoDB no crea una clave foránea automática entre los dos sistemas. | Parte II: mecanismo de comprobación y evidencia pendientes. |
| G11 | Sustentación individual y declaración del apoyo de inteligencia artificial cuando corresponda. | Explicaré el modelo, las decisiones, el código, las consultas y el complemento de MongoDB. Conservo la declaración breve de apoyo incluida en el README. | Declaración incluida. Sustentación individual pendiente. |

Para las consultas de G05, tengo previstas estas instrucciones y funciones:

| Instrucción o función | Para qué la uso |
|---|---|
| `SELECT` | Elegir los datos que muestro. |
| `WHERE` | Filtrar las filas que cumplen una condición. |
| `ORDER BY` | Ordenar los resultados. |
| `COUNT` | Contar registros. |
| `SUM` | Sumar valores. |
| `AVG` | Calcular un promedio. |
| `MIN` | Obtener el valor menor. |
| `MAX` | Obtener el valor mayor. |
| `GROUP BY` | Agrupar registros, por ejemplo, por cultivo y temporada. |
| `HAVING` | Filtrar grupos después de agrupar los registros. |
| `JOIN` | Relacionar datos de distintas tablas. |
| Subconsulta | Usar una consulta dentro de otra. |

Una vista es una consulta guardada que puedo consultar como una tabla. Incluiré vistas si aportan algo útil al caso. Tengo pendiente comprobar el uso de todas las técnicas y explicar qué significan los resultados obtenidos.

En MongoDB, las operaciones de agregar, consultar, modificar y eliminar se conocen como CRUD. Tengo previstas una consulta con filtro y otra que use un dato agrupado dentro de una observación. Para probar la eliminación, usaré un documento adicional de prueba y comprobaré que se elimine, conservando los tres documentos requeridos.

## 5. Comprobación documental del diseño

El esquema contiene diez tablas, 53 campos y nueve relaciones. La comprobación documental muestra cómo estos elementos representan los datos necesarios para las diez reglas y las diez preguntas del caso, según las decisiones explicadas en esta matriz.

Esta comprobación corresponde al diseño. En la Parte II tengo pendiente crear y probar las restricciones, comprobar los resultados de las consultas y verificar que la base de datos se pueda reconstruir desde cero.

Mantengo el requisito de al menos 1.000 filas por cada una de las diez tablas, incluidas `Cultivo` y `Temporada`. Tengo pendiente aclarar cómo reunir esa cantidad con datos razonables para el caso. Los datos deben ser variados y coherentes, sin repetir filas solo para completar el mínimo.

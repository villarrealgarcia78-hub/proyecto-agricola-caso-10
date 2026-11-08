# Caso 10: reglas del negocio

**Parte I — Diseño y diccionario:** 11 de noviembre de 2026.  
**Parte II — Implementación:** 18 de noviembre de 2026.

En este documento presento las reglas que debe cumplir mi base de datos y explico cómo las represento en mi diseño. La creación de las tablas, la carga de datos y las pruebas en SQL Server están pendientes para la Parte II.

Tomo como guía **Proyecto integrador.pdf**: las reglas generales de las páginas 1–5 y el caso 10 de las páginas 24–26. Mi [esquema propuesto](../modelo/esquema.json) contiene diez tablas, 53 campos y nueve relaciones mediante claves foráneas, que conectan los registros de las tablas.

En [decisiones de diseño](decisiones_diseno.md) explico los detalles que defino cuando el caso no los especifica. Allí también presento las fórmulas de producción, rendimiento y costo.

## 1. Requisitos y decisiones de diseño

Distingo dos tipos de indicaciones:

- **Requisitos del enunciado:** son las condiciones que debo cumplir en el proyecto.
- **Decisiones de diseño:** son las opciones que defino cuando el enunciado no da un detalle exacto.

Por ejemplo, el enunciado establece un estado inicial predeterminado para cada ciclo. En mi diseño elijo `Activo` y lo defino con `DEFAULT`, que asigna ese valor cuando no indico un estado al crear el registro.

Las **restricciones** son condiciones que SQL Server comprueba al guardar o modificar los datos. En esta parte del proyecto defino esas condiciones y la forma prevista de aplicarlas.

## 2. Reglas expresas del caso y su representación

En esta tabla presento las diez reglas del enunciado y explico cómo las represento en mi diseño. Uso los códigos R01 a R10 para identificar cada regla.

| Regla | Requisito del enunciado | Cómo lo represento en mi diseño |
|---|---|---|
| R01 | Predios con código único y área mayor que cero. Lotes con identificador único dentro de su predio y área mayor que cero. | En `Predio`, defino un código que no se repite. En `Lote`, el código no se repite dentro del mismo predio, pero puede usarse en otro predio. Defino las áreas de predios y lotes como mayores que cero. |
| R02 | Tipos de cultivo y temporadas con códigos únicos y fechas coherentes. | Defino códigos únicos en `Cultivo` y `Temporada`. En una temporada, la fecha de inicio es anterior o igual a la fecha final. Las fechas corresponden a las temporadas y los ciclos; en `Cultivo` incluyo su identificación y nombre. |
| R03 | Ciclos que relacionan lote, cultivo y temporada, con fechas y cantidad sembrada. | En `CicloCultivo`, incluyo las referencias al lote, al cultivo y a la temporada, las fechas y la cantidad sembrada. Añado la unidad de siembra para indicar cómo se mide esa cantidad. |
| R04 | Trabajadores con documento único, función y estado. | En `Trabajador`, incluyo el documento, la función y el estado. El documento es un dato de texto y no se repite. Los ejemplos y los datos previstos para las pruebas son ficticios. |
| R05 | Labores con tipo, fecha, lote/ciclo, responsable y duración mayor que cero. | En `Labor`, incluyo el tipo, la fecha, el ciclo, el trabajador responsable y la duración en horas, mayor que cero. Relaciono cada labor con un ciclo y, a través de ese ciclo, identifico su lote. |
| R06 | Insumos con código único, unidad, costo por unidad mayor o igual que cero y cantidad disponible. | En `Insumo`, incluyo esos datos y defino un código que no se repite. El costo actual por unidad puede ser cero. La cantidad disponible se expresa en la misma unidad del insumo. |
| R07 | Una labor puede consumir varios insumos y un insumo puede usarse en varias labores. Se registra la cantidad y el costo aplicado. | En `ConsumoInsumo`, relaciono una labor y un insumo. Uso como clave primaria la pareja `id_labor`, que identifica la labor, e `id_insumo`, que identifica el insumo. La pareja no se repite. Cada fila reúne la cantidad total y el costo por unidad aplicado en esa labor. Conservo ese costo aunque después cambie el costo actual del insumo. |
| R08 | Cosechas por ciclo, con fecha, cantidad obtenida, unidad y calidad. | En `Cosecha`, incluyo el ciclo, la fecha, la cantidad obtenida, la unidad y la calidad. Cada fila representa una cosecha y un mismo ciclo puede tener varias cosechas. |
| R09 | Fechas de temporada coherentes; cantidades, áreas y duraciones mayores que cero; estado inicial del ciclo con `DEFAULT`. | Defino condiciones para comprobar las fechas y los valores mayores que cero. En mi diseño, aplico esta condición también a la cantidad disponible de los insumos. Los costos admiten cero, según R06. Elijo `Activo` como estado inicial y uso `DEFAULT` para asignarlo cuando no indico otro estado al crear el ciclo. |
| R10 | Permitir lotes sin siembras activas e insumos no utilizados durante una temporada. | Mi diseño permite lotes sin ciclos e insumos sin consumos. También permite identificar lotes sin siembras activas e insumos que no se usan en una temporada, aunque tengan registros de otras temporadas. |

Las reglas R01 a R04 corresponden a la página 24 de **Proyecto integrador.pdf**, y las reglas R05 a R10, a la página 25. En [decisiones de diseño](decisiones_diseno.md) explico por qué relaciono cada labor con un ciclo y los demás detalles que elijo para mi modelo.

## 3. Mecanismos previstos para la Parte II

En la Parte II tengo pendiente crear estas reglas en SQL Server y probarlas. Para ello, incluyo en mi diseño los siguientes mecanismos:

| Qué necesito definir o comprobar | Mecanismo previsto y para qué sirve |
|---|---|
| Identificar cada fila y cada pareja de labor e insumo. | `PRIMARY KEY`, o clave primaria, identifica cada registro con un valor o una combinación de valores que no se repite y no admite `NULL`, es decir, ausencia de un dato. |
| Relacionar un registro con otro que existe. | `FOREIGN KEY`, o clave foránea, comprueba que la referencia corresponda a un registro existente en la tabla relacionada. |
| Exigir datos obligatorios. | `NOT NULL` impide que un campo tenga `NULL`. Así defino los campos que deben tener un dato. |
| Evitar códigos y documentos repetidos. | `UNIQUE` impide repetir un valor o una combinación de valores. En `Lote`, la combinación del predio (`id_predio`) y el código del lote (`codigo_lote`) es la que no se repite. |
| Comprobar cantidades, áreas y duraciones mayores que cero, costos mayores o iguales a cero, listas de valores permitidos y fechas de una misma fila. | `CHECK` comprueba condiciones, como que un área sea mayor que cero, que un costo sea mayor o igual que cero, que un estado esté entre los valores permitidos o que la fecha de inicio no sea posterior a la fecha final. |
| Asignar el estado inicial de un ciclo. | `DEFAULT` define un valor que se asigna cuando no indico uno al crear el registro. En mi diseño, el estado inicial es `Activo`. |

También tengo previstas dos comprobaciones que necesitan consultar otras tablas:

1. **Fechas relacionadas.** Cada ciclo debe quedar dentro de las fechas de su temporada, y cada labor y cosecha, dentro de las fechas de su ciclo. Incluyo la revisión al agregar registros y al cambiar sus fechas o referencias. También considero los cambios en la temporada o el ciclo al que pertenecen.

2. **Consumos en unidades enteras.** Cuando un insumo se mide en `unidad`, la cantidad consumida debe ser un número entero, sin decimales. Para comprobarlo, necesito consultar la unidad del insumo relacionado. También incluyo la revisión de sus consumos existentes si se intenta cambiar esa unidad.

Un `CHECK` simple sobre una fila no basta para estas dos comprobaciones, porque necesito consultar registros de otras tablas. Las comprobaciones deben considerar las operaciones que afectan varias filas a la vez e impedir que se guarden cambios que incumplen las reglas.

Tengo pendiente elegir cómo realizar estas comprobaciones. El código y las pruebas corresponden a la Parte II.

## 4. Cantidades de datos y complemento documental

En mi diseño mantengo el requisito de **al menos 1.000 registros (filas) de datos ficticios por cada tabla de SQL Server**, incluidas `Cultivo`, `Temporada` y `ConsumoInsumo`. Los datos deben ser variados y coherentes entre sí, sin repetir filas solo para completar la cantidad. Este requisito aparece en las páginas 2, 25 y 29 de **Proyecto integrador.pdf**.

Tengo pendiente aclarar cómo cumplir esta cantidad en `Cultivo` y `Temporada` con datos razonables para el caso. Mientras esa aclaración está pendiente, mantengo el mínimo de 1.000 filas en ambas tablas.

Para MongoDB, incluyo en mi diseño la colección `observaciones_labor`, que agrupa los registros de las observaciones de campo. En MongoDB, estos registros se llaman **documentos**. El mínimo es de **tres documentos de prueba**, con datos ficticios y coherentes.

En cada documento, mi diseño incluye la referencia a una labor o a un ciclo de SQL Server, la fecha y la hora, el tipo de observación, los valores con sus unidades y la ubicación dentro del lote cuando corresponde.

Los registros oficiales de labores, ciclos, inventarios y cosechas corresponden a SQL Server. También incluyo la comprobación de que cada referencia de MongoDB corresponda a una labor o a un ciclo existente. MongoDB no verifica por sí mismo esa relación con SQL Server.

La carga de datos, la creación de la colección y las pruebas están pendientes para la Parte II. Las pruebas de MongoDB incluyen agregar, consultar y modificar documentos, y eliminar un documento adicional de prueba.

En el [plan de pruebas](pruebas.md) presento las comprobaciones previstas. En el [documento de MongoDB](mongodb.md) explico la información y las operaciones previstas para las observaciones de campo.

# Diccionario de datos

Caso 10. Gestión agrícola y producción de cultivos. Parte I: diseño de la base de datos y diccionario. Fecha de entrega: 6 de noviembre de 2026.

Este diccionario define las 53 columnas de las diez tablas del modelo y sus nueve relaciones mediante claves foráneas. Para cada campo se especifican el tipo de dato, la obligatoriedad, las claves, el significado, las reglas y un ejemplo. Su estructura corresponde a [esquema.json](esquema.json).

## Convenciones del diccionario

Una tabla reúne registros de una misma clase. Cada columna guarda un dato con significado y reglas definidos. La columna «Nulo» indica si se permite dejar el dato sin valor. En esta propuesta todos los campos son obligatorios: **Nulo = No**.

Los ejemplos son ficticios y muestran el formato de los valores de cada campo. Los identificadores internos son numéricos, como id_ciclo = 1, id_labor = 1 e id_trabajador = 1.

| Término | Explicación y uso en este diseño |
|---|---|
| INT | Número entero, sin decimales. Se utiliza para los identificadores internos y las referencias a ellos. |
| IDENTITY(1,1) | Generación automática de un valor numérico al insertar una fila, comenzando en 1 y con incremento configurado de 1. Puede haber saltos; no garantiza una secuencia sin huecos. La PK es la que exige la unicidad del identificador. |
| DATE | Fecha sin hora. Los ejemplos se escriben como año-mes-día: 2026-02-20. |
| VARCHAR(n) | Texto de longitud variable; n fija el máximo en bytes. Se propone para códigos, documentos y vocabularios breves con caracteres simples, donde el tamaño previsto coincide con el número de esos caracteres. No se utiliza como número para hacer cuentas. |
| NVARCHAR(n) | Texto Unicode de longitud variable, apropiado para nombres y descripciones con tildes y ñ. n indica unidades de almacenamiento de dos bytes; los caracteres habituales de los ejemplos ocupan una unidad cada uno. |
| DECIMAL(p,s) | Número decimal exacto: p es el máximo total de dígitos y s es el número de dígitos después del separador decimal. DECIMAL(12,2) permite hasta 10 dígitos enteros y 2 decimales. Es apropiado para costos y medidas con precisión definida. |
| NOT NULL | Exige que exista un valor. No impide por sí solo un texto vacío; por eso los campos de texto relevantes incluyen también esa regla. |
| PK, PRIMARY KEY | Clave primaria: columna o conjunto de columnas que identifica cada fila, sin repetirse y sin valores nulos. |
| FK, FOREIGN KEY | Clave foránea: exige que el identificador usado como referencia exista en la tabla indicada. |
| UQ, UNIQUE | Regla de unicidad para otra identificación del negocio. En una UQ compuesta se protege la combinación completa, no cada columna por separado. |
| CHECK | Condición que deben cumplir los valores de una fila, como área mayor que cero. No se usará un CHECK simple para afirmar que se validan fechas o cantidades de otras filas. |
| DEFAULT | Valor que se asigna cuando una inserción omite la columna correspondiente. En CicloCultivo se propone Activo como estado inicial. Un DEFAULT no corrige cualquier valor inválido ni reemplaza las demás restricciones. |

## Unidades y convenciones comunes

- Las áreas se expresan en hectáreas (ha) y la duración de una labor en horas.
- Los costos se expresan en pesos colombianos (COP). Un costo unitario es el costo de una unidad del insumo.
- La cantidad sembrada incluye su unidad: semillas, plantas o kg. Las cantidades de semillas o plantas son enteras aunque el tipo numérico admita decimales.
- Cada insumo define su unidad: kg, L o unidad. La disponibilidad y el consumo de ese insumo se interpretan con esa misma unidad. Cuando se cuentan unidades, la cantidad debe ser entera.
- Las cosechas admiten kg o t. Para sumar y comparar producción se utiliza kg; 1 t equivale a 1.000 kg. No se almacena un factor de conversión repetido en cada cosecha.
- En los ejemplos de valores DECIMAL se utiliza punto decimal, como 1500.00. En las explicaciones en español, 1.500 pesos representa mil quinientos pesos.
- Las referencias se conservan: el diseño no propone eliminar automáticamente registros relacionados mediante borrado en cascada.

## Tablas y columnas

### 1. Predio

Propiedad agrícola que contiene lotes.

**Clave primaria:** id_predio.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_predio | INT | No | PK | Identificador interno del predio. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| codigo_predio | VARCHAR(20) | No | UQ | Código con el que se identifica el predio. | Único y sin texto vacío. | P01 |
| nombre | NVARCHAR(100) | No | Sin clave | Nombre del predio. | Sin texto vacío. | El Arrayán |
| area_ha | DECIMAL(12,2) | No | Sin clave | Área total del predio en hectáreas. | Mayor que cero. | 12.00 |

### 2. Lote

Porción identificada de un predio.

**Clave primaria:** id_lote.

**Identificación alternativa:** UNIQUE (id_predio, codigo_lote). El código puede repetirse en predios distintos; no dentro del mismo predio.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_lote | INT | No | PK | Identificador interno del lote, único en la tabla. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| id_predio | INT | No | FK; parte de UQ compuesta; Predio.id_predio | Predio al que pertenece el lote. | Debe existir en la tabla referenciada. | 1 |
| codigo_lote | VARCHAR(20) | No | UQ compuesta | Código del lote dentro de su predio. | Sin texto vacío; el par (id_predio, codigo_lote) es único. | L01 |
| nombre | NVARCHAR(100) | No | Sin clave | Nombre que distingue al lote para las personas. | Sin texto vacío. | La Loma |
| area_ha | DECIMAL(12,2) | No | Sin clave | Área del lote en hectáreas. | Mayor que cero. | 2.00 |

### 3. Cultivo

Tipo de cultivo; no representa una siembra concreta.

**Clave primaria:** id_cultivo.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_cultivo | INT | No | PK | Identificador interno del tipo de cultivo. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| codigo_cultivo | VARCHAR(20) | No | UQ | Código del tipo de cultivo. | Único y sin texto vacío. | C01 |
| nombre | NVARCHAR(100) | No | Sin clave | Nombre del tipo de cultivo. | Sin texto vacío. | Maíz |

### 4. Temporada

Periodo de referencia de la actividad agrícola.

**Clave primaria:** id_temporada.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_temporada | INT | No | PK | Identificador interno de la temporada. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| codigo_temporada | VARCHAR(20) | No | UQ | Código de la temporada. | Único y sin texto vacío. | T2026A |
| nombre | NVARCHAR(100) | No | Sin clave | Nombre del periodo. | Sin texto vacío. | Primer semestre 2026 |
| fecha_inicio | DATE | No | Sin clave | Primer día de la temporada. | Menor o igual que fecha_fin. | 2026-01-01 |
| fecha_fin | DATE | No | Sin clave | Último día de la temporada. | Mayor o igual que fecha_inicio. | 2026-06-30 |

### 5. CicloCultivo

Siembra concreta de un cultivo en un lote y una temporada.

**Clave primaria:** id_ciclo.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_ciclo | INT | No | PK | Identificador interno de la siembra concreta. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| id_lote | INT | No | FK; Lote.id_lote | Lote donde se desarrolla el ciclo. | Debe existir en la tabla referenciada. | 1 |
| id_cultivo | INT | No | FK; Cultivo.id_cultivo | Tipo de cultivo de la siembra. | Debe existir en la tabla referenciada. | 1 |
| id_temporada | INT | No | FK; Temporada.id_temporada | Temporada a la que se asigna el ciclo. | Debe existir en la tabla referenciada. | 1 |
| fecha_inicio | DATE | No | Sin clave | Inicio del intervalo definido para el ciclo. | Menor o igual que fecha_fin; dentro de la temporada. | 2026-02-01 |
| fecha_fin | DATE | No | Sin clave | Fin del intervalo definido para el ciclo. | Mayor o igual que fecha_inicio; dentro de la temporada. Para ciclos activos es la fecha prevista; al cerrar se confirma. | 2026-05-31 |
| cantidad_sembrada | DECIMAL(14,3) | No | Sin clave | Cantidad de material de siembra, en unidad_siembra. | Mayor que cero; entera si la unidad es semillas o plantas. | 40000.000 |
| unidad_siembra | VARCHAR(10) | No | Sin clave | Unidad de la cantidad sembrada. | Valores propuestos: semillas, plantas, kg. | semillas |
| estado | VARCHAR(12) | No | Sin clave | Situación del ciclo. | Activo, Finalizado o Cancelado. DEFAULT propuesto: Activo. | Finalizado |

### 6. Trabajador

Persona responsable de labores agrícolas.

**Clave primaria:** id_trabajador.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_trabajador | INT | No | PK | Identificador interno del trabajador. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| documento | VARCHAR(25) | No | UQ | Documento ficticio que identifica al trabajador. | Único y sin texto vacío. Texto para conservar ceros iniciales. | FICT-001 |
| nombre | NVARCHAR(100) | No | Sin clave | Nombre del trabajador ficticio. | Sin texto vacío. | Persona de ejemplo 01 |
| funcion | NVARCHAR(60) | No | Sin clave | Función que desempeña. | Sin texto vacío. | Operario agrícola |
| estado | VARCHAR(8) | No | Sin clave | Estado del trabajador. | Valores propuestos: Activo, Inactivo. | Activo |

### 7. Labor

Actividad de un ciclo con un responsable.

**Clave primaria:** id_labor.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_labor | INT | No | PK | Identificador interno de la labor. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| id_ciclo | INT | No | FK; CicloCultivo.id_ciclo | Ciclo al que corresponde la labor; permite conocer su lote. | Debe existir en la tabla referenciada. | 1 |
| id_trabajador | INT | No | FK; Trabajador.id_trabajador | Responsable de la labor. | Debe existir en la tabla referenciada. | 1 |
| tipo | NVARCHAR(40) | No | Sin clave | Clase de actividad realizada. | Sin texto vacío; se documenta un vocabulario coherente para la carga. | Fertilización |
| fecha | DATE | No | Sin clave | Día en que se realiza la labor. | Dentro del intervalo del ciclo, según decisión de diseño. | 2026-02-20 |
| duracion_horas | DECIMAL(8,2) | No | Sin clave | Duración de la labor en horas. | Mayor que cero. | 2.00 |

### 8. Insumo

Recurso utilizable en labores, con costo actual y existencia registrada.

**Clave primaria:** id_insumo.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_insumo | INT | No | PK | Identificador interno del insumo. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| codigo_insumo | VARCHAR(20) | No | UQ | Código del insumo. | Único y sin texto vacío. | I01 |
| nombre | NVARCHAR(100) | No | Sin clave | Nombre del insumo. | Sin texto vacío. | Insumo A |
| unidad | VARCHAR(6) | No | Sin clave | Unidad para disponibilidad y consumo del insumo. | Valores propuestos: kg, L, unidad. | kg |
| costo_unitario | DECIMAL(12,2) | No | Sin clave | Costo actual por unidad del insumo, en pesos colombianos. | Mayor o igual que cero. | 1500.00 |
| cantidad_disponible | DECIMAL(14,3) | No | Sin clave | Existencia actual registrada, en la unidad del insumo. | Mayor que cero según lectura literal del punto 9; entera si unidad=unidad. | 200.000 |

### 9. ConsumoInsumo

Uso de un insumo en una labor; resuelve la relación de muchos a muchos.

**Clave primaria:** id_labor, id_insumo.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_labor | INT | No | PK, FK; Labor.id_labor | Labor que utiliza el insumo. | Debe existir en Labor; forma la PK junto con id_insumo. | 1 |
| id_insumo | INT | No | PK, FK; Insumo.id_insumo | Insumo utilizado en la labor. | Debe existir en Insumo; forma la PK junto con id_labor. | 1 |
| cantidad | DECIMAL(14,3) | No | Sin clave | Cantidad total utilizada del insumo en esa labor, en la unidad del insumo. | Mayor que cero; entera si la unidad del insumo es unidad. | 10.000 |
| costo_unitario_aplicado | DECIMAL(12,2) | No | Sin clave | Costo por unidad aplicado al consumo, en pesos colombianos. | Mayor o igual que cero. Es histórico; no cambia al actualizar el costo actual del insumo. | 1500.00 |

La PK compuesta identifica un solo consumo agregado por pareja labor-insumo. Cada una de sus dos columnas también es una FK. El costo_unitario_aplicado es un valor histórico de ese uso: no se sustituye por el costo actual de Insumo al consultar el pasado.

### 10. Cosecha

Registro de producción obtenida de un ciclo en una fecha.

**Clave primaria:** id_cosecha.

| Campo | Tipo SQL | Nulo | Clave y referencia | Significado | Regla o unidad | Ejemplo |
|---|---|---|---|---|---|---|
| id_cosecha | INT | No | PK | Identificador interno del registro de cosecha. | Generado automáticamente mediante IDENTITY(1,1); puede haber saltos. La PK exige que no se repita. | 1 |
| id_ciclo | INT | No | FK; CicloCultivo.id_ciclo | Ciclo que produjo la cosecha. | Debe existir en la tabla referenciada. | 1 |
| fecha | DATE | No | Sin clave | Día del registro de cosecha. | Dentro del intervalo del ciclo, según decisión de diseño. | 2026-05-15 |
| cantidad | DECIMAL(14,3) | No | Sin clave | Producción obtenida en este registro de cosecha. | Mayor que cero, expresada en unidad. | 6000.000 |
| unidad | VARCHAR(2) | No | Sin clave | Unidad de la cantidad cosechada. | Valores propuestos: kg o t. Para consultas se convierte t a kg (1 t = 1.000 kg). | kg |
| calidad | NVARCHAR(30) | No | Sin clave | Clasificación de calidad de la cosecha. | Valores propuestos: Primera, Segunda, Industrial. | Primera |

## Reglas que relacionan tablas

Las nueve FK propuestas protegen la existencia de referencias: por ejemplo, que el id_ciclo de una Labor exista en CicloCultivo. Una FK no comprueba por sí sola que la fecha de la labor esté dentro de las fechas del ciclo.

Los ciclos deben estar dentro de su temporada, y las labores y cosechas dentro de su ciclo. Cuando la unidad de un insumo sea unidad, su consumo debe ser entero. Estas reglas necesitan consultar información de otras tablas, por lo que su implementación requiere validaciones transaccionales o triggers que contemplen los registros relacionados.

Todas las FK del diseño son obligatorias en la fila hija. Esto no obliga a que cada fila padre tenga hijos: un lote puede existir sin ciclos y un insumo puede existir sin consumos. Así se mantienen los escenarios sin actividad solicitados en el caso.

## Datos calculados que no se guardan como columnas

El importe de un consumo se obtiene multiplicando cantidad por costo_unitario_aplicado. La producción total se obtiene de las cosechas, normalizando sus unidades. El rendimiento se calcula según el ámbito y la fórmula definidos en las decisiones del proyecto. No se agregan columnas para repetir esos resultados y mantenerlos manualmente sincronizados.

Las reglas adoptadas y la correspondencia con el enunciado se desarrollan en [reglas de negocio](../documentacion/reglas_negocio.md) y [decisiones de diseño](../documentacion/decisiones_diseno.md); la justificación de la organización de tablas aparece en [normalización](../documentacion/normalizacion.md).

## Fuentes técnicas de consulta

- Microsoft Learn: [DECIMAL y NUMERIC en SQL Server](https://learn.microsoft.com/en-us/sql/t-sql/data-types/decimal-and-numeric-transact-sql?view=sql-server-ver17), para precisión y escala.
- Microsoft Learn: [NCHAR y NVARCHAR en SQL Server](https://learn.microsoft.com/en-us/sql/t-sql/data-types/nchar-and-nvarchar-transact-sql?view=sql-server-ver17), para el almacenamiento de texto Unicode.
- Microsoft Learn: [Propiedad IDENTITY](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql-identity-property?view=sql-server-ver17), para generación de identificadores y posibles saltos.

# Paso 2. Las reglas de las tablas en SQL Server

Con [el script de restricciones](../scripts/sqlserver/02_restricciones_y_reglas.sql) agrego las relaciones entre tablas, las reglas para evitar repeticiones, las condiciones de los datos y el estado inicial de un ciclo. Con [la consulta de verificación](../scripts/sqlserver/02_verificar_restricciones.sql) puedo ver cuáles quedaron guardadas en `DNV_Caso10`.

## Qué significan las restricciones

| Tipo | Para qué sirve | Ejemplo del caso |
|---|---|---|
| **FK**, clave foránea | Comprueba que el registro al que hago referencia exista. | Para registrar un lote, el predio que indico debe existir. |
| **UQ**, restricción `UNIQUE` | Impide que se repita un valor o una combinación de valores. | Dos lotes de un mismo predio no pueden tener el mismo código. En predios distintos sí puedo usar el mismo código de lote. |
| **CK**, comprobación `CHECK` | Comprueba una condición antes de guardar o cambiar una fila. | Un área igual a cero queda por fuera de la condición `area_ha > 0`. |
| **DF**, valor `DEFAULT` | Asigna un valor cuando agrego una fila y omito ese campo. | Si agrego un ciclo sin indicar el estado, SQL Server asigna `Activo`. |

En una clave foránea, **TablaOrigen** y **ColumnaOrigen** indican dónde guardo la referencia. **TablaReferenciada** y **ColumnaReferenciada** indican dónde debe existir ese valor. En una comprobación, **Condicion** muestra lo que SQL Server evalúa. **Activa: Sí** significa que SQL Server aplica la regla. **Validada: Sí** indica que SQL Server verificó los datos existentes al habilitarla con validación. Para comprobar qué acepta o rechaza, registro por separado los resultados de los intentos con datos de prueba.

## Las nueve claves foráneas

| Nombre en SQL Server | Campo que guarda la referencia | Campo que debe existir | Relación en el proyecto |
|---|---|---|---|
| `FK_Lote_Predio` | `Lote.id_predio` | `Predio.id_predio` | Cada lote pertenece a un predio existente. |
| `FK_CicloCultivo_Lote` | `CicloCultivo.id_lote` | `Lote.id_lote` | Cada ciclo se realiza en un lote existente. |
| `FK_CicloCultivo_Cultivo` | `CicloCultivo.id_cultivo` | `Cultivo.id_cultivo` | Cada ciclo indica qué cultivo se sembró. |
| `FK_CicloCultivo_Temporada` | `CicloCultivo.id_temporada` | `Temporada.id_temporada` | Cada ciclo pertenece a una temporada registrada. |
| `FK_Labor_CicloCultivo` | `Labor.id_ciclo` | `CicloCultivo.id_ciclo` | Cada labor corresponde a un ciclo. |
| `FK_Labor_Trabajador` | `Labor.id_trabajador` | `Trabajador.id_trabajador` | Cada labor queda asociada a un trabajador. |
| `FK_ConsumoInsumo_Labor` | `ConsumoInsumo.id_labor` | `Labor.id_labor` | Cada consumo indica en qué labor se usó el insumo. |
| `FK_ConsumoInsumo_Insumo` | `ConsumoInsumo.id_insumo` | `Insumo.id_insumo` | Cada consumo indica cuál insumo se utilizó. |
| `FK_Cosecha_CicloCultivo` | `Cosecha.id_ciclo` | `CicloCultivo.id_ciclo` | Cada cosecha indica de cuál ciclo salió. |

Guardo `id_cultivo` en cada ciclo para relacionarlo con la tabla `Cultivo`. Con esa relación puedo consultar el nombre del cultivo sin repetirlo en cada ciclo.

## Las seis restricciones de unicidad

| Nombre en SQL Server | Tabla y campos | Qué dato impide repetir |
|---|---|---|
| `UQ_Predio_codigo` | `Predio.codigo_predio` | El código de un predio. |
| `UQ_Lote_predio_codigo` | `Lote.id_predio`, `Lote.codigo_lote` | La pareja de predio y código de lote. |
| `UQ_Cultivo_codigo` | `Cultivo.codigo_cultivo` | El código de un cultivo. |
| `UQ_Temporada_codigo` | `Temporada.codigo_temporada` | El código de una temporada. |
| `UQ_Trabajador_documento` | `Trabajador.documento` | El documento de un trabajador. |
| `UQ_Insumo_codigo` | `Insumo.codigo_insumo` | El código de un insumo. |

## Las 26 comprobaciones

| Tabla | Nombre en SQL Server | Qué compruebo |
|---|---|---|
| `Predio` | `CK_Predio_textos` | El código y el nombre tienen texto después de quitar los espacios de los extremos. |
| `Predio` | `CK_Predio_area` | El área es mayor que cero. |
| `Lote` | `CK_Lote_textos` | El código y el nombre tienen texto. |
| `Lote` | `CK_Lote_area` | El área es mayor que cero. |
| `Cultivo` | `CK_Cultivo_textos` | El código y el nombre tienen texto. |
| `Temporada` | `CK_Temporada_textos` | El código y el nombre tienen texto. |
| `Temporada` | `CK_Temporada_fechas` | La fecha final es igual o posterior a la inicial. |
| `CicloCultivo` | `CK_CicloCultivo_fechas` | La fecha final es igual o posterior a la inicial. |
| `CicloCultivo` | `CK_CicloCultivo_cantidad` | La cantidad sembrada es mayor que cero. |
| `CicloCultivo` | `CK_CicloCultivo_unidad` | La unidad de siembra es `semillas`, `plantas` o `kg`. |
| `CicloCultivo` | `CK_CicloCultivo_cantidad_entera` | Las semillas y plantas se cuentan en cantidades enteras. Los kilogramos admiten decimales. |
| `CicloCultivo` | `CK_CicloCultivo_estado` | El estado es `Activo`, `Finalizado` o `Cancelado`. |
| `Trabajador` | `CK_Trabajador_textos` | El documento, el nombre y la función tienen texto. |
| `Trabajador` | `CK_Trabajador_estado` | El estado es `Activo` o `Inactivo`. |
| `Labor` | `CK_Labor_tipo` | El tipo de labor tiene texto. |
| `Labor` | `CK_Labor_duracion` | La duración es mayor que cero. |
| `Insumo` | `CK_Insumo_textos` | El código y el nombre tienen texto. |
| `Insumo` | `CK_Insumo_unidad` | La unidad es `kg`, `L` o `unidad`. |
| `Insumo` | `CK_Insumo_costo` | El costo por unidad es igual o superior a cero. |
| `Insumo` | `CK_Insumo_disponibilidad` | La cantidad disponible es mayor que cero. |
| `Insumo` | `CK_Insumo_disponibilidad_entera` | Cuando la medida es `unidad`, la disponibilidad se cuenta en enteros. |
| `ConsumoInsumo` | `CK_ConsumoInsumo_cantidad` | La cantidad consumida es mayor que cero. |
| `ConsumoInsumo` | `CK_ConsumoInsumo_costo` | El costo por unidad aplicado es igual o superior a cero. |
| `Cosecha` | `CK_Cosecha_cantidad` | La cantidad cosechada es mayor que cero. |
| `Cosecha` | `CK_Cosecha_unidad` | La unidad es `kg` o `t`. |
| `Cosecha` | `CK_Cosecha_calidad` | La calidad es `Primera`, `Segunda` o `Industrial`. |

En las condiciones, `>` significa «mayor que» y `>=` significa «mayor o igual que». Por ejemplo, una cantidad de cosecha de `0` no cumple `cantidad > 0`. Un costo de `0` sí cumple `costo_unitario >= 0`.

## El valor predeterminado del ciclo

`DF_CicloCultivo_estado` completa el campo `estado` con `Activo` si lo omito al registrar un ciclo. Si indico otro estado, SQL Server revisa el valor con `CK_CicloCultivo_estado`.

## Evidencia del paso 2

La consulta de conteo devolvió 9 claves foráneas, 6 restricciones únicas, 26 comprobaciones y 1 valor predeterminado. Las capturas muestran el [conteo](../evidencias/capturas_o_resultados/P02_01_Conteo_restricciones.png) y un [extracto del detalle](../evidencias/capturas_o_resultados/P02_02_Detalle_visible.png). El listado de esta guía corresponde a las reglas definidas en el script. El extracto de SSMS muestra las primeras filas de la consulta. Las pruebas con datos válidos e inválidos y las reglas que comparan registros de tablas distintas se registran aparte.

## Reglas que consultan otra tabla

Una clave foránea comprueba que el registro relacionado exista. Cuando también necesito revisar un dato de ese registro, uso un **trigger**. Es un bloque que SQL Server ejecuta automáticamente al agregar o cambiar datos. Si encuentra una fila que incumple la regla, SQL Server rechaza la operación y muestra el motivo. El [script de reglas entre tablas](../scripts/sqlserver/02_reglas_entre_tablas.sql) instala los seis bloques.

| Regla de SQL Server | Qué compruebo | Ejemplo del caso |
|---|---|---|
| `TR_Temporada_intervalo` | Si cambio las fechas de una temporada, sus ciclos deben seguir dentro del periodo. | Si un ciclo termina en mayo, no puedo acortar su temporada hasta abril. |
| `TR_CicloCultivo_intervalos` | El ciclo debe quedar dentro de su temporada. Si cambio el ciclo, sus labores y cosechas deben seguir dentro de sus fechas. | Si una labor se hizo el 10 de abril, no puedo cerrar el ciclo el 5 de abril. |
| `TR_Labor_fecha` | La fecha de la labor debe estar dentro del ciclo al que pertenece. | Si el ciclo inicia el 1 de marzo, una labor del 28 de febrero queda por fuera. |
| `TR_Cosecha_fecha` | La fecha de la cosecha debe estar dentro del ciclo al que pertenece. | Si el ciclo termina el 31 de mayo, no puedo registrar una cosecha del 1 de junio para ese ciclo. |
| `TR_ConsumoInsumo_cantidad_entera` | Si un insumo se mide en unidades, la cantidad usada debe ser entera. | Puedo registrar 2 unidades. Para ese mismo insumo, 2,5 unidades no cumplen la regla. |
| `TR_Insumo_conservar_unidad` | Si el insumo ya tiene consumos, conservo la unidad para que las cantidades anteriores sigan teniendo el mismo significado. | Si se registró un consumo de 3 kg, no puedo cambiar la unidad del insumo a litros. |

Las fechas del primer y del último día sí cuentan como parte del periodo. El bloque revisa todas las filas de una misma operación. En el código, `inserted` contiene los datos nuevos y `deleted` permite leer el valor que tenía un registro antes del cambio. Así puedo comparar, por ejemplo, la unidad anterior de un insumo con la unidad nueva.

El 14 de noviembre de 2026, la consulta de SSMS mostró **seis reglas activas**. En la prueba P03 comprobaré qué ocurre al guardar fechas y unidades válidas e inválidas. [Captura de las seis reglas activas](../evidencias/capturas_o_resultados/P03_01_Reglas_activas.png)

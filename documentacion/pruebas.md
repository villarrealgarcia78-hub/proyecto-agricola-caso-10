# Caso 10: plan de pruebas

En este documento presento las pruebas previstas para SQL Server y MongoDB. Indico qué necesito comprobar y qué resultado espero.

La implementación y la ejecución de las pruebas están pendientes para la Parte II.

| Sistema | Pruebas ejecutadas |
|---|---:|
| SQL Server | 0 |
| MongoDB | 0 |

La revisión de la Parte I corresponde a los documentos del diseño.

Las reglas y los resultados esperados se basan en [reglas del negocio](reglas_negocio.md), [decisiones de diseño](decisiones_diseno.md) y la [matriz de requisitos](matriz_requisitos.md).
## Comprobaciones previstas

Uso los códigos P01 a P09 para identificar cada prueba. En la tabla explico qué comprobaré, qué resultado espero y si la prueba ya se ejecutó.

| Prueba | Qué comprobaré | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| P01 | Crearé la base de datos y sus tablas desde cero en el entorno del proyecto. Compararé su estructura con el modelo y el diccionario. | Diez tablas, 53 campos y nueve relaciones. Los tipos de datos, las claves que identifican y relacionan los registros y los campos obligatorios coinciden con el diccionario. | No ejecutado. |
| P02 | Probaré datos correctos y datos que incumplen las reglas, como campos sin datos, valores repetidos o referencias a registros que no existen. También crearé un ciclo sin indicar su estado. | Se aceptan los datos válidos y se rechazan los inválidos. El código de un lote no se repite dentro de su predio, aunque puede usarse en otro. La pareja de labor e insumo no se repite. Las cantidades, áreas y duraciones son mayores que cero; los costos admiten cero. El estado inicial del ciclo es `Activo`. | No ejecutado. |
| P03 | Probaré las fechas, las unidades y las cantidades al agregar o modificar registros. Incluiré cambios en los registros relacionados y operaciones que afectan varias filas a la vez. | Cada ciclo queda dentro de las fechas de su temporada, y cada labor y cosecha, dentro de su ciclo. Las semillas, las plantas y los insumos medidos en `unidad` usan cantidades sin decimales. La cantidad disponible y la consumida usan la unidad del insumo. Esa unidad se conserva si el insumo ya tiene consumos. Se rechazan los cambios que incumplen estas condiciones. | No ejecutado. |
| P04 | Cargaré datos ficticios y revisaré la cantidad de filas, su variedad y sus relaciones en cada tabla. | Al menos 1.000 filas en cada una de las diez tablas, incluidas `Cultivo`, `Temporada` y `ConsumoInsumo`. Los datos corresponden al caso, se relacionan con registros existentes y no se repiten solo para completar la cantidad. Mantengo pendiente aclarar cómo reunir datos razonables para `Cultivo` y `Temporada`, sin reducir ese mínimo. | No ejecutado. |
| P05 | Ejecutaré las diez consultas y compararé sus respuestas con cálculos hechos por separado. Explicaré qué significa cada resultado. | Las respuestas coinciden con esos cálculos. La producción se expresa en kilogramos y el área se cuenta una vez por ciclo con cosecha. Los costos conservan el precio aplicado en cada consumo. Los promedios siguen los criterios descritos debajo de la tabla. Las consultas conservan los empates de mayor producción y no repiten cantidades al relacionar los datos. | No ejecutado. |
| P06 | Revisaré las instrucciones usadas en las consultas y probaré casos sin actividad. | Las consultas incluyen filtros, orden, conteos, sumas, promedios, mínimos y máximos, agrupaciones, filtros de grupos, uniones de tablas y consultas dentro de otras. Distingo los lotes sin ciclos y los insumos nunca utilizados de los que no tienen actividad en una temporada. También compruebo los lotes sin siembras activas. | No ejecutado. |
| P07 | En MongoDB, agregaré, consultaré y modificaré observaciones de campo en la colección `observaciones_labor`, que reúne esos registros. Haré una consulta con filtro y otra que use un dato agrupado dentro de una observación. También eliminaré un documento adicional de prueba. | Cada operación produce el resultado esperado. Se elimina únicamente el documento adicional identificado y se conservan al menos tres documentos ficticios y coherentes. | No ejecutado. |
| P08 | Compararé los identificadores de labor o ciclo guardados en MongoDB con los registros de SQL Server. | Cada referencia corresponde a una labor o un ciclo existente. La comprobación queda registrada; guardar el identificador en MongoDB no comprueba por sí solo su existencia en SQL Server. | No ejecutado. |
| P09 | Ejecutaré la creación completa de la base desde cero y el archivo separado de reinicio en el entorno del proyecto. Seguiré el orden indicado en el README y comprobaré los resultados. | La base se puede reconstruir con los archivos y las instrucciones del proyecto. El archivo de reinicio muestra una advertencia de borrado antes de eliminar los datos. | No ejecutado. |

En P05, compararé los rendimientos de los cultivos con cosecha de una misma temporada. Para el promedio de costos, incluiré todos los ciclos de esa temporada, también los que no tienen consumos, con costo cero. En ambos casos, seleccionaré los resultados mayores que el promedio; los iguales no cumplen esa condición.

Para P06, revisaré las instrucciones `SELECT`, `WHERE`, `ORDER BY`, `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`, `JOIN` y las subconsultas. Su significado está explicado en el apartado «Requisitos generales y estado de la entrega» de la [matriz de requisitos](matriz_requisitos.md).

## Registro de resultados

Cuando ejecute cada prueba, registraré:

- La fecha de la prueba.
- La regla o consulta que compruebo.
- El sistema operativo, los programas utilizados y sus versiones.
- El archivo utilizado y los pasos que seguí.
- Los datos que utilicé en la prueba.
- El resultado que esperaba y el que obtuve.
- La evidencia, como una captura o un archivo con los resultados.

Guardaré los errores y las correcciones con sus fechas reales.

Después de ejecutar las pruebas, guardaré las evidencias en la carpeta `evidencias/capturas_o_resultados/`. Actualmente no hay resultados de pruebas de SQL Server o MongoDB.

Fuente: Proyecto integrador.pdf, páginas 3–4, 25–26 y 28–29.

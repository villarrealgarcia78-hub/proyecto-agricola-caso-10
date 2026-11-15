# Caso 10: plan de pruebas

En este documento presento las pruebas de la Parte II. Indico qué compruebo y registro los resultados obtenidos.

La comprobación inicial de la estructura y los ocho casos con datos ficticios de las restricciones ya tienen resultados.

| Sistema | Pruebas ejecutadas |
|---|---:|
| SQL Server | P01 parcial. Ocho casos de P02 ejecutados. |
| MongoDB | Fuera del alcance de esta entrega, según la indicación del profesor en clase |

La revisión de la Parte I corresponde a los documentos del diseño.

Las reglas y los resultados esperados se basan en [reglas del negocio](reglas_negocio.md), [decisiones de diseño](decisiones_diseno.md) y la [matriz de requisitos](matriz_requisitos.md).
## Comprobaciones previstas

Uso los códigos P01 a P09 para identificar cada prueba. En la tabla explico qué comprobaré, qué resultado espero y si la prueba ya se ejecutó.

| Prueba | Qué comprobaré | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| P01 | Crearé la base de datos y sus tablas desde cero en el entorno del proyecto. Compararé su estructura con el modelo y el diccionario. | Diez tablas, 53 campos y nueve relaciones. Los tipos de datos, las claves que identifican y relacionan los registros y los campos obligatorios coinciden con el diccionario. | El 14 de noviembre de 2026, los recuentos mostraron 10 tablas, 53 campos y 9 claves foráneas. Falta cotejar todos los detalles con el diccionario. |
| P02 | Probaré datos correctos y datos que incumplen las reglas, como campos sin datos, valores repetidos o referencias a registros que no existen. También crearé un ciclo sin indicar su estado. | Se aceptan los datos válidos y se rechazan los inválidos. El código de un lote no se repite dentro de su predio, aunque puede usarse en otro. La pareja de labor e insumo no se repite. Las cantidades, áreas y duraciones son mayores que cero; los costos admiten cero. El estado inicial del ciclo es `Activo`. | Ocho casos comprobados el 14 de noviembre de 2026. Los ocho cumplieron. |
| P03 | Probaré las fechas, las unidades y las cantidades al agregar o modificar registros. Incluiré cambios en los registros relacionados y operaciones que afectan varias filas a la vez. | Cada ciclo queda dentro de las fechas de su temporada, y cada labor y cosecha, dentro de su ciclo. Las semillas, las plantas y los insumos medidos en `unidad` usan cantidades sin decimales. La cantidad disponible y la consumida usan la unidad del insumo. Esa unidad se conserva si el insumo ya tiene consumos. Se rechazan los cambios que incumplen estas condiciones. | No ejecutado. |
| P04 | Cargaré datos ficticios y revisaré la cantidad de filas, su variedad y sus relaciones en cada tabla. | Al menos 1.000 filas en cada una de las diez tablas, incluidas `Cultivo`, `Temporada` y `ConsumoInsumo`. Los datos corresponden al caso, se relacionan con registros existentes y no se repiten solo para completar la cantidad. Mantengo pendiente aclarar cómo reunir datos razonables para `Cultivo` y `Temporada`, sin reducir ese mínimo. | No ejecutado. |
| P05 | Ejecutaré las diez consultas y compararé sus respuestas con cálculos hechos por separado. Explicaré qué significa cada resultado. | Las respuestas coinciden con esos cálculos. La producción se expresa en kilogramos y el área se cuenta una vez por ciclo con cosecha. Los costos conservan el precio aplicado en cada consumo. Los promedios siguen los criterios descritos debajo de la tabla. Las consultas conservan los empates de mayor producción y no repiten cantidades al relacionar los datos. | No ejecutado. |
| P06 | Revisaré las instrucciones usadas en las consultas y probaré casos sin actividad. | Las consultas incluyen filtros, orden, conteos, sumas, promedios, mínimos y máximos, agrupaciones, filtros de grupos, uniones de tablas y consultas dentro de otras. Distingo los lotes sin ciclos y los insumos nunca utilizados de los que no tienen actividad en una temporada. También compruebo los lotes sin siembras activas. | No ejecutado. |
| P07 | Pruebas de operaciones y consultas de MongoDB previstas en el enunciado inicial. | No aplica. | Fuera del alcance de esta entrega por indicación del profesor. |
| P08 | Comprobación de referencias entre MongoDB y SQL Server prevista en el enunciado inicial. | No aplica. | Fuera del alcance de esta entrega por indicación del profesor. |
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

Después de ejecutar las pruebas, guardaré las evidencias en la carpeta `evidencias/capturas_o_resultados/`. La comprobación inicial está en [la captura de SSMS](../evidencias/capturas_o_resultados/P01_01_Tablas_y_campos.png).

Fuente: Proyecto integrador.pdf, páginas 3–4, 25–26 y 28–29.

## Comprobación de restricciones con datos ficticios

Cada caso del [script de prueba](../scripts/sqlserver/02_probar_restricciones.sql) indica el resultado esperado. El 14 de noviembre de 2026, SSMS mostró 8 casos probados, 8 que cumplen, 0 que no cumplen y 0 predios de prueba restantes. [Captura de SSMS](../evidencias/capturas_o_resultados/P02_03_Pruebas_restricciones.png)

| Caso | Resultado obtenido |
|---|---|
| Lote con un predio existente | SQL Server lo aceptó. |
| Mismo código de lote en otro predio | SQL Server lo aceptó. |
| Insumo con costo cero | SQL Server lo aceptó. |
| Ciclo sin indicar estado | SQL Server le asignó `Activo`. |
| Lote repetido en el mismo predio | `UQ_Lote_predio_codigo` impidió el duplicado. |
| Lote con predio inexistente | `FK_Lote_Predio` impidió la referencia. |
| Predio con área cero | `CK_Predio_area` rechazó el área. |
| Cosecha con cantidad cero | `CK_Cosecha_cantidad` rechazó la cantidad. |

Las pruebas que comparan fechas y unidades entre tablas se registran en P03.

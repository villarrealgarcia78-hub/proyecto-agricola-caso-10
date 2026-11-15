# Caso 10: plan de pruebas

En este documento presento las pruebas de la Parte II. Indico qué compruebo y registro los resultados obtenidos.

Ya están registrados los resultados de la comprobación inicial de la estructura, las pruebas de las reglas, la carga de datos ficticios, las diez consultas y la prueba de reconstrucción y reinicio.

| Sistema | Pruebas ejecutadas |
|---|---:|
| SQL Server | P01 parcial. Resultados registrados de P02, P03, P04, P05 y P09. |
| MongoDB | Fuera del alcance de esta entrega, según la indicación del profesor en clase |

La revisión de la Parte I corresponde a los documentos del diseño.

Las reglas y los resultados esperados se basan en [reglas del negocio](reglas_negocio.md), [decisiones de diseño](decisiones_diseno.md) y la [matriz de requisitos](matriz_requisitos.md).
## Comprobaciones previstas

Uso los códigos P01 a P09 para identificar cada prueba. En la tabla explico qué comprobaré, qué resultado espero y si la prueba ya se ejecutó.

| Prueba | Qué comprobaré | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| P01 | Crearé la base de datos y sus tablas desde cero en el entorno del proyecto. Compararé su estructura con el modelo y el diccionario. | Diez tablas, 53 campos y nueve relaciones. Los tipos de datos, las claves que identifican y relacionan los registros y los campos obligatorios coinciden con el diccionario. | El 14 de noviembre de 2026, los recuentos mostraron 10 tablas, 53 campos y 9 claves foráneas. Falta cotejar todos los detalles con el diccionario. |
| P02 | Probaré datos correctos y datos que incumplen las reglas, como campos sin datos, valores repetidos o referencias a registros que no existen. También crearé un ciclo sin indicar su estado. | Se aceptan los datos válidos y se rechazan los inválidos. El código de un lote no se repite dentro de su predio, aunque puede usarse en otro. La pareja de labor e insumo no se repite. Las cantidades, áreas y duraciones son mayores que cero; los costos admiten cero. El estado inicial del ciclo es `Activo`. | Ocho casos comprobados el 14 de noviembre de 2026. Los ocho cumplieron. |
| P03 | Compruebo las fechas, las unidades y las cantidades al agregar o modificar registros. Incluyo cambios en los registros relacionados y operaciones que afectan varias filas a la vez. | Cada ciclo queda dentro de las fechas de su temporada, y cada labor y cosecha, dentro de su ciclo. Las semillas, las plantas y los insumos medidos en `unidad` usan cantidades sin decimales. La cantidad disponible y la consumida usan la unidad del insumo. Esa unidad se conserva si el insumo ya tiene consumos. Se rechazan los cambios que incumplen estas condiciones. | El 14 de noviembre de 2026, [los nueve casos probados cumplieron](#p03-reglas-entre-tablas). |
| P04 | Compruebo cuántas filas hay por tabla y reviso las fechas, las cantidades y las relaciones de los datos ficticios. | Al menos 1.000 filas en cada una de las diez tablas, con datos variados y relacionados. | El 14 de noviembre de 2026, las diez tablas alcanzaron el mínimo y [los diez controles coincidieron](#p04-carga-de-datos-ficticios). |
| P05 | Comparo las respuestas de las diez consultas con los resultados esperados. | Las respuestas coinciden con esos cálculos. La producción se expresa en kilogramos y el área se cuenta una vez por ciclo con cosecha. Los costos conservan el precio aplicado en cada consumo. Los promedios siguen los criterios descritos debajo de la tabla. Las consultas conservan los empates de mayor producción y no repiten cantidades al relacionar los datos. | Las diez salidas del 14 de noviembre de 2026 coinciden con lo esperado. [Resultados de P05](#p05-diez-consultas-del-caso). |
| P06 | Revisaré las instrucciones usadas en las consultas y probaré casos sin actividad. | Las consultas incluyen filtros, orden, conteos, sumas, promedios, mínimos y máximos, agrupaciones, filtros de grupos, uniones de tablas y consultas dentro de otras. Distingo los lotes sin ciclos y los insumos nunca utilizados de los que no tienen actividad en una temporada. También compruebo los lotes sin siembras activas. | No ejecutado. |
| P07 | Pruebas de operaciones y consultas de MongoDB previstas en el enunciado inicial. | No aplica. | Fuera del alcance de esta entrega por indicación del profesor. |
| P08 | Comprobación de referencias entre MongoDB y SQL Server prevista en el enunciado inicial. | No aplica. | Fuera del alcance de esta entrega por indicación del profesor. |
| P09 | Compruebo que los scripts crean una base de prueba desde cero, cargan los datos y devuelven los conteos de las diez consultas. Uso un archivo aparte para probar el reinicio. | La reconstrucción termina con los resultados esperados y el reinicio elimina solo la base de prueba. | El 14 de noviembre de 2026, [la reconstrucción y el reinicio cumplieron lo esperado](#p09-reconstrucción-y-reinicio). |

En P05 comparo los rendimientos de los cultivos con cosecha de una misma temporada. Para el promedio de costos, incluyo todos los ciclos de esa temporada. Los ciclos sin consumos tienen costo cero. En los dos casos selecciono valores mayores que el promedio.

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

## P03. Reglas entre tablas

En P03 compruebo cómo responde SQL Server cuando un cambio en una tabla afecta los datos de otra. El [script de prueba](../scripts/sqlserver/02_probar_reglas_entre_tablas.sql) usa datos ficticios y al final de cada caso deshace los cambios. El código 0 indica que SQL Server aceptó la operación. Los códigos del 50131 al 50138 identifican el motivo de cada rechazo.

El 14 de noviembre de 2026, SSMS mostró **9 casos probados, 9 que cumplen, 0 que no cumplen y 0 predios de prueba restantes**. Los nueve códigos obtenidos coinciden con los esperados. [Captura de SSMS](../evidencias/capturas_o_resultados/P03_02_Pruebas_reglas_entre_tablas.png)

| Caso | Resultado obtenido | Código obtenido |
|---|---|---:|
| Fechas dentro del período y consumo de 2 unidades | SQL Server aceptó los datos. | 0 |
| Acortar una temporada y dejar un ciclo por fuera | SQL Server rechazó el cambio de la temporada. | 50131 |
| Mover el inicio de un ciclo fuera de su temporada | SQL Server rechazó la nueva fecha del ciclo. | 50132 |
| Mover el inicio del ciclo y dejar una labor por fuera | SQL Server rechazó el cambio del ciclo. | 50133 |
| Acortar el ciclo y dejar una cosecha por fuera | SQL Server rechazó el cambio del ciclo. | 50134 |
| Mover una labor a una fecha fuera de su ciclo | SQL Server rechazó la nueva fecha de la labor. | 50135 |
| Agregar dos cosechas juntas cuando una queda fuera del ciclo | SQL Server rechazó la operación. | 50136 |
| Cambiar un consumo de 2 unidades a 2,5 unidades | SQL Server rechazó la cantidad con decimales. | 50137 |
| Cambiar la unidad de un insumo que ya tiene un consumo | SQL Server rechazó el cambio de unidad. | 50138 |

## P04. Carga de datos ficticios

En el [script de carga](../scripts/sqlserver/03_datos_semilla.sql) combino 40 tipos de cultivo con cinco duraciones y cinco características, como el tamaño o el rendimiento. Así se forman 1.000 variedades ficticias. Para las temporadas uso dos semestres por año, de 2002 a 2026, en 20 zonas ficticias. Cada temporada tiene ciclos en dos predios de su zona.

Los conteos de SSMS del 14 de noviembre de 2026 suman **19.034 filas**. Las diez tablas alcanzaron el mínimo de 1.000 filas. [Captura de SSMS](../evidencias/capturas_o_resultados/P04_01_Carga_y_controles.png)

| Tabla | Filas obtenidas |
|---|---:|
| Predio | 1.000 |
| Lote | 2.000 |
| Cultivo | 1.000 |
| Temporada | 1.000 |
| CicloCultivo | 2.000 |
| Trabajador | 1.000 |
| Labor | 5.000 |
| Insumo | 1.000 |
| ConsumoInsumo | 1.250 |
| Cosecha | 3.784 |

Los diez controles dieron el resultado esperado. Por ejemplo, las labores y las cosechas quedaron dentro de sus ciclos. Los lotes sin ciclos y los insumos nunca usados sirven para probar las consultas que buscan registros sin actividad.

| Control | Esperado | Obtenido |
|---|---:|---:|
| Tablas con menos de 1.000 filas | 0 | 0 |
| Ciclos por fuera de su temporada | 0 | 0 |
| Labores fuera de su ciclo o posteriores a la fecha de referencia | 0 | 0 |
| Cosechas fuera de su ciclo o de ciclos sin finalizar | 0 | 0 |
| Consumos en unidades con cantidad decimal | 0 | 0 |
| Temporadas sin dos predios con ciclos | 0 | 0 |
| Lotes sin ciclos | 750 | 750 |
| Insumos nunca usados | 100 | 100 |
| Labores sin consumo registrado | 4.000 | 4.000 |
| Predios con lotes que suman más que el área del predio | 0 | 0 |

## P05. Diez consultas del caso

En [04_consultas_negocio.sql](../scripts/sqlserver/04_consultas_negocio.sql) identifico cada pregunta con un código, de Q01 a Q10. El 14 de noviembre de 2026, las diez salidas de SSMS coincidieron con lo esperado. Los conteos de las cuadrículas suman 15.780 filas. [Ejemplos de los resultados de SSMS](../evidencias/capturas_o_resultados/P05_01_Resultados_SSMS.md)

| Consulta | Qué muestra | Filas esperadas | Filas obtenidas |
|---|---|---:|---:|
| Q01 | Lotes ordenados por predio y área. | 2.000 | 2.000 |
| Q02 | Labores del 12 al 22 de enero de 2026, incluidos ambos días. | 90 | 90 |
| Q03 | Conteo de labores por cultivo y temporada. | 1.950 | 1.950 |
| Q04 | Producción y rendimiento por lote y temporada. | 2.750 | 2.750 |
| Q05 | Detalle de labores, con una fila por insumo cuando hay varios. | 5.250 | 5.250 |
| Q06 | Insumos que nunca se utilizaron. | 100 | 100 |
| Q07 | Lotes que nunca tuvieron un ciclo. | 750 | 750 |
| Q08 | Cultivos con rendimiento superior al promedio de su temporada. | 845 | 845 |
| Q09 | Ciclos con costo de insumos superior al promedio de su temporada. | 1.000 | 1.000 |
| Q10 | Predios con mayor producción de su temporada. | 1.045 | 1.045 |

En Q05 aparecen las 5.000 labores. Hay 4.000 sin insumos y 250 con dos insumos. Esas 250 explican por qué la consulta devuelve 5.250 filas. En Q10 aparecen 992 temporadas con cosecha. En 53 de esas temporadas hay dos predios empatados en el primer lugar.

## P09. Reconstrucción y reinicio

Uso una base aparte, `DNV_Caso10_Reconstruccion`, para comprobar si los archivos permiten empezar desde cero. El orden de ejecución está en la [guía de reconstrucción](../scripts/sqlserver/p09_reconstruccion/README.md).

| Qué compruebo | Qué mostró SSMS el 14 de noviembre de 2026 |
|---|---|
| Tablas y campos | 10 tablas y 53 campos. |
| Reglas de los datos | 9 claves foráneas, 6 reglas de unicidad, 26 comprobaciones, 1 valor predeterminado y 6 reglas activas entre tablas. |
| Carga de datos ficticios | 19.034 filas en total, al menos 1.000 por tabla y los diez controles con el resultado esperado. |
| Consultas del caso | Los conteos de Q01 a Q10 coinciden con los registrados en P05 y suman 15.780 filas. |
| Reinicio | La vista previa confirmó la marca de la base de prueba. El borrado eliminó `DNV_Caso10_Reconstruccion` y `DNV_Caso10` quedó en estado `ONLINE`. |

La marca permite comprobar que el reinicio apunta a la base creada para la prueba. `ONLINE` es el estado que SQL Server mostró para la base del video. [Vista previa del reinicio](../evidencias/capturas_o_resultados/P09_06_Reinicio_vista_previa.png) · [Resultado del borrado](../evidencias/capturas_o_resultados/P09_07_Reinicio_confirmado.png)

# Evidencias de ejecución

En esta carpeta guardo capturas y resultados de las pruebas de SQL Server.

Para cada resultado, registro estos datos.

- La fecha de la prueba.
- El archivo utilizado o la operación que realicé.
- La regla o consulta que comprobé.
- El resultado que esperaba y el que obtuve.

Las pruebas usan datos ficticios.

El [registro de pruebas](../../documentacion/pruebas.md) explica qué se comprobó y qué mostró SSMS.

Los modelos y el diccionario disponibles pertenecen a la Parte I y se encuentran en la carpeta [modelo](../../modelo/).

## Resultados guardados

| Fecha | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|
| 14 de noviembre de 2026 | P01, recuento inicial después de ejecutar el [script de creación](../../scripts/sqlserver/01_crear_base_y_tablas.sql) | 10 tablas y 53 campos | 10 tablas y 53 campos | [Captura de SSMS](P01_01_Tablas_y_campos.png) |
| 14 de noviembre de 2026 | P02, restricciones de las tablas | Los ocho casos cumplen el resultado esperado. | 8 de 8 casos conformes. | [Conteo de restricciones](P02_01_Conteo_restricciones.png) y [casos de prueba](P02_03_Pruebas_restricciones.png) |
| 14 de noviembre de 2026 | P03, reglas entre tablas | Seis reglas activas y nueve casos conformes. | Seis reglas activas y 9 de 9 casos conformes. | [Reglas activas](P03_01_Reglas_activas.png) y [casos de prueba](P03_02_Pruebas_reglas_entre_tablas.png) |
| 14 de noviembre de 2026 | P04, carga de datos ficticios | Al menos 1.000 filas por tabla y diez controles conformes. | 19.034 filas y diez controles conformes. | [Carga y controles](P04_01_Carga_y_controles.png) |
| 14 de noviembre de 2026 | P05, consultas del caso | Las diez salidas coinciden con los resultados esperados. | Diez consultas comprobadas, 15.780 filas en total. | [Ejemplos de las salidas](P05_01_Resultados_SSMS.md) |
| 14 de noviembre de 2026 | P09, reconstrucción y reinicio | La base de prueba se reconstruye y el reinicio elimina esa base. | Carga y consultas comprobadas. La base de prueba se eliminó y la base del video quedó `ONLINE`. | [Vista previa](P09_06_Reinicio_vista_previa.png) y [resultado del reinicio](P09_07_Reinicio_confirmado.png) |

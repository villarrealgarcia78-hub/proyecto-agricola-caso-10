# Evidencias de ejecución

En esta carpeta guardo capturas y resultados de las pruebas de SQL Server.

Para cada resultado, indicaré:

- La fecha de la prueba.
- El archivo utilizado o la operación que realicé.
- La regla o consulta que comprobé.
- El resultado que esperaba y el que obtuve.

Usaré datos ficticios para las pruebas.

Relacionaré las evidencias con el [plan de pruebas](../../documentacion/pruebas.md) y el [documento de MongoDB](../../documentacion/mongodb.md).

Los modelos y el diccionario disponibles pertenecen a la Parte I y se encuentran en la carpeta [modelo](../../modelo/).

## Resultados guardados

| Fecha | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|
| 14 de noviembre de 2026 | P01, recuento inicial después de ejecutar el [script de creación](../../scripts/sqlserver/01_crear_base_y_tablas.sql) | 10 tablas y 53 campos | 10 tablas y 53 campos | [Captura de SSMS](P01_01_Tablas_y_campos.png) |

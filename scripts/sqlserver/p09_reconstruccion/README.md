# Reinicio y reconstrucción en una base de prueba

Uso `DNV_Caso10_Reconstruccion` para comprobar que puedo crear el caso desde cero. En esta carpeta están las copias de los archivos que ejecutan la prueba. La base `DNV_Caso10` se usa para el video.

## Reconstruir en SSMS

Me conecto a mi instancia de SQL Server en SSMS. Abro cada archivo **de esta carpeta** en una pestaña nueva, pulso **Ctrl+D** para mostrar cuadrículas y ejecuto el archivo completo con **F5**. Sigo con el próximo archivo cuando el anterior termina sin errores.

| Orden | Archivo | Qué espero ver |
|---|---|---|
| 1 | [01_crear_base_y_tablas.sql](01_crear_base_y_tablas.sql) | `DNV_Caso10_Reconstruccion`, 10 tablas y 53 campos. |
| 2 | [02_restricciones_y_reglas.sql](02_restricciones_y_reglas.sql) | 9 claves foráneas, 6 reglas de unicidad, 26 comprobaciones y 1 valor predeterminado. |
| 3 | [02_reglas_entre_tablas.sql](02_reglas_entre_tablas.sql) | 6 reglas entre tablas activas. |
| 4 | [03_datos_semilla.sql](03_datos_semilla.sql) | 19.034 filas en total, al menos 1.000 por tabla y los 10 controles iguales a lo esperado. |
| 5 | [04_consultas_negocio.sql](04_consultas_negocio.sql) | 10 cuadrículas, identificadas como Q01 a Q10. En Mensajes, los conteos esperados en ese orden son 2.000, 90, 1.950, 2.750, 5.250, 100, 750, 845, 1.000 y 1.045. |

La columna `BaseDePrueba` en el paso 1 identifica dónde se crearon las tablas. Los identificadores de labor y ciclo se generan al cargar una base vacía y pueden empezar en números distintos de los del video. Comparo las cantidades, fechas y resultados del caso.

## Probar el reinicio

**ADVERTENCIA DE BORRADO.** Al confirmar el reinicio se elimina `DNV_Caso10_Reconstruccion` completa, con sus tablas y datos.

1. Ejecuto [00_reiniciar_base_prueba.sql](00_reiniciar_base_prueba.sql) con `@confirmarBorrado = 0`. El resultado indica que la base tiene la marca de prueba y que no se borró nada.
2. Para probar el borrado, cierro las demás pestañas conectadas a `DNV_Caso10_Reconstruccion`. En la pestaña del archivo de reinicio cambio `@confirmarBorrado` de `0` a `1` y ejecuto el archivo completo. Espero el mensaje «La base de prueba se eliminó». Conservo el archivo guardado con `0`.
3. Si quiero volver a dejar disponible la base de prueba, ejecuto otra vez los cinco archivos en el orden de la tabla.

Si un archivo se detiene, reviso el primer error que aparece en **Mensajes** antes de continuar.

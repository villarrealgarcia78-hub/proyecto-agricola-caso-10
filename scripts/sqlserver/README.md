# SQL Server: implementación pendiente

En esta carpeta reuniré los archivos con instrucciones para SQL Server, llamados scripts. Corresponden a la Parte II.

La entrega actual contiene el diseño y el diccionario. Los scripts todavía no están creados ni se han ejecutado.

Tengo previstos estos archivos:

| Orden previsto | Archivo | Para qué sirve |
|---|---|---|
| 1 | `01_crear_base_y_tablas.sql` | Crear la base de datos del ejercicio y las tablas del modelo. |
| 2 | `02_restricciones_y_reglas.sql` | Definir las reglas que deben cumplir los datos, como identificadores únicos, referencias entre tablas y valores permitidos. |
| 3 | `03_datos_semilla.sql` | Cargar datos ficticios, variados y relacionados, con al menos 1.000 filas por cada tabla. |
| 4 | `04_consultas_negocio.sql` | Resolver las diez preguntas de negocio y explicar los resultados. |
| 5, si aplica | `05_vistas.sql` | Crear vistas, que son consultas guardadas, si resultan útiles para el caso. |

Si una consulta utiliza una vista, crearé primero esa vista.

También prepararé un archivo separado de reinicio o limpieza. Explicaré qué elimina e incluiré una advertencia de borrado.

Añadiré los comandos de instalación, ejecución y reconstrucción después de probarlos en mi equipo. También indicaré las versiones utilizadas y el orden para crear la base desde cero.

Usaré como referencia el [diccionario de datos](../../modelo/diccionario_datos.md), las [reglas de negocio](../../documentacion/reglas_negocio.md) y el [plan de pruebas](../../documentacion/pruebas.md).


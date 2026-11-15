# SQL Server: implementación de la Parte II

En esta carpeta reuniré los archivos con instrucciones para SQL Server, llamados scripts. Corresponden a la Parte II.

Los scripts de creación y restricciones están disponibles. La base `DNV_Caso10` y sus tablas se crearon en SQL Server desde SSMS el 14 de noviembre de 2026. Germán ejecutó el script y la comprobación dio **10 tablas y 53 campos**.

Tengo previstos estos archivos:

| Orden previsto | Archivo | Para qué sirve |
|---|---|---|
| 1 | [01_crear_base_y_tablas.sql](01_crear_base_y_tablas.sql) | Crear la base de datos del ejercicio y las tablas del modelo. |
| 2 | [02_restricciones_y_reglas.sql](02_restricciones_y_reglas.sql) | Definir las reglas que deben cumplir los datos, como identificadores únicos, referencias entre tablas y valores permitidos. |
| 3 | `03_datos_semilla.sql` | Cargar datos ficticios, variados y relacionados, con al menos 1.000 filas por cada tabla. |
| 4 | `04_consultas_negocio.sql` | Resolver las diez preguntas de negocio y explicar los resultados. |
| 5, si aplica | `05_vistas.sql` | Crear vistas, que son consultas guardadas, si resultan útiles para el caso. |

Si una consulta utiliza una vista, crearé primero esa vista.

También prepararé un archivo separado de reinicio o limpieza. Explicaré qué elimina e incluiré una advertencia de borrado.

Añadiré los comandos de instalación, ejecución y reconstrucción después de probarlos en mi equipo. También indicaré las versiones utilizadas y el orden para crear la base desde cero.

Usaré como referencia el [diccionario de datos](../../modelo/diccionario_datos.md), las [reglas de negocio](../../documentacion/reglas_negocio.md) y el [plan de pruebas](../../documentacion/pruebas.md).

## Paso 1. Crear la base y comprobar las tablas

1. Abrir `01_crear_base_y_tablas.sql` en SSMS y ejecutar el archivo completo.
2. Abrir una consulta nueva y ejecutar la siguiente comprobación. `sys.tables` permite consultar las tablas y `sys.columns`, sus campos. `DISTINCT` evita contar varias veces la misma tabla.

```sql
SELECT COUNT(DISTINCT tablas.object_id) AS Tablas,
       COUNT(*) AS Campos
FROM DNV_Caso10.sys.tables AS tablas
JOIN DNV_Caso10.sys.columns AS campos
    ON campos.object_id = tablas.object_id
WHERE tablas.is_ms_shipped = 0;
```

| Fecha | Comprobación | Esperado | Obtenido |
|---|---|---|---|
| 14 de noviembre de 2026 | Recuento inicial de la estructura (P01) | 10 tablas y 53 campos | 10 tablas y 53 campos |

## Paso 2. Agregar y revisar las restricciones

El script crea las nueve claves foráneas y las reglas de cada tabla. Para ver el detalle, ejecuto [02_verificar_restricciones.sql](02_verificar_restricciones.sql) en SSMS. La [guía de restricciones](../../documentacion/restricciones_sqlserver.md) explica cómo leer cada resultado.

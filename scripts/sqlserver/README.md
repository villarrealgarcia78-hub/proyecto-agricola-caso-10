# SQL Server: implementación de la Parte II

En esta carpeta guardo los scripts que uso para crear y comprobar la base de datos de la Parte II.

Los scripts de creación y restricciones están disponibles. El 14 de noviembre de 2026, la comprobación en SSMS mostró **10 tablas y 53 campos** en la base `DNV_Caso10`.

Este es el orden de los scripts de la Parte II.

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

1. Uso `01_crear_base_y_tablas.sql` en SSMS para crear la base y sus tablas.
2. Compruebo cuántas tablas y campos tiene la base. `sys.tables` muestra las tablas y `sys.columns` muestra sus campos. `DISTINCT` cuenta cada tabla una sola vez.

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

### Prueba con datos ficticios

Con [02_probar_restricciones.sql](02_probar_restricciones.sql) puedo repetir ocho ejemplos del paso 2. El archivo retira los registros de prueba antes de mostrar qué esperaba y qué ocurrió. El resultado de SSMS está en el [registro de pruebas](../../documentacion/pruebas.md#comprobación-de-restricciones-con-datos-ficticios).

### Reglas entre tablas

Con [02_reglas_entre_tablas.sql](02_reglas_entre_tablas.sql) compruebo fechas de registros relacionados y la unidad de los insumos. Aplico estas reglas después de las claves y restricciones de cada tabla, antes de cargar los datos. SSMS mostró seis reglas activas. Describo cada una en la [guía de restricciones](../../documentacion/restricciones_sqlserver.md#reglas-que-consultan-otra-tabla).

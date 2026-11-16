# SQL Server: implementación de la Parte II

En esta carpeta guardo los scripts que uso para crear y comprobar la base de datos de la Parte II.

Las pruebas en SSMS se hicieron con SQL Server 2022, versión `16.0.4315.2`. La comprobación del 14 de noviembre de 2026 mostró **10 tablas y 53 campos** en `DNV_Caso10`, la base del video.

Este es el orden de los scripts de la Parte II.

| Orden de ejecución | Archivo | Para qué sirve |
|---|---|---|
| 1 | [01_crear_base_y_tablas.sql](01_crear_base_y_tablas.sql) | Crear la base de datos del ejercicio y las tablas del modelo. |
| 2 | [02_restricciones_y_reglas.sql](02_restricciones_y_reglas.sql) | Definir las reglas que deben cumplir los datos, como identificadores únicos, referencias entre tablas y valores permitidos. |
| 3 | [02_reglas_entre_tablas.sql](02_reglas_entre_tablas.sql) | Aplicar las reglas que comparan fechas o unidades de datos relacionados. |
| 4 | [03_datos_semilla.sql](03_datos_semilla.sql) | Cargar datos ficticios, variados y relacionados, con al menos 1.000 filas por cada tabla. |
| 5 | [04_consultas_negocio.sql](04_consultas_negocio.sql) | Resolver las diez preguntas de negocio y mostrar los resultados. |

En SSMS abro cada archivo y ejecuto el contenido completo con **F5**. Reviso el resultado antes de seguir con el próximo.

Para empezar desde cero, uso la [guía de reconstrucción](p09_reconstruccion/README.md). Incluye las copias para la base de prueba y el archivo de reinicio con la advertencia de borrado. [Resultado de P09](../../documentacion/pruebas.md#p09-reconstrucción-y-reinicio)

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

Con [02_probar_reglas_entre_tablas.sql](02_probar_reglas_entre_tablas.sql) puedo repetir los nueve casos de P03. El archivo muestra qué casos acepta o rechaza SQL Server y cuántos cumplen lo esperado. Los resultados se encuentran en el [registro de pruebas](../../documentacion/pruebas.md#p03-reglas-entre-tablas).

## Paso 3. Cargar datos ficticios

Uso [03_datos_semilla.sql](03_datos_semilla.sql) después de crear las tablas y activar las reglas. El archivo comprueba que estén vacías, carga los datos y muestra dos cuadrículas. En la primera reviso cuántas filas quedaron por tabla. En la segunda comparo los controles con lo que esperaba. Los conteos suman 19.034 filas y los diez controles coinciden con lo esperado. [Resultados de P04](../../documentacion/pruebas.md#p04-carga-de-datos-ficticios)

## Paso 4. Consultar los datos del caso

Uso [04_consultas_negocio.sql](04_consultas_negocio.sql) después de cargar los datos. Cada cuadrícula muestra el código de la pregunta en la primera columna. En Q02 puedo cambiar las dos fechas para consultar otro intervalo. Los conteos y ejemplos de las diez salidas de SSMS están en el [registro de P05](../../documentacion/pruebas.md#p05-diez-consultas-del-caso).

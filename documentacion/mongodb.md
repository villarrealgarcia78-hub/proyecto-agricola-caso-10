# Caso 10: componente MongoDB

En este documento presento el uso previsto de MongoDB para guardar observaciones de campo.

La creación de la colección y la ejecución de las operaciones están pendientes para la Parte II.

## Propósito y colección

Propongo guardar observaciones sobre el suelo, el clima, la humedad, las plagas u otros datos de campo. La información puede variar según el tipo de observación.

En MongoDB, un **documento** es un registro de datos. En este proyecto, cada documento reúne la información de una observación. Una **colección** agrupa esos documentos.

La colección prevista es `observaciones_labor`. En mi diseño, cada observación se relaciona con una labor o un ciclo de cultivo registrado en SQL Server.

Los registros oficiales de labores, ciclos, inventarios y cosechas corresponden a SQL Server. MongoDB los complementa con las observaciones de campo.

## Contenido lógico previsto

En esta tabla presento la información que tendrá cada observación. En la Parte II definiré los nombres finales de los campos, sus tipos de datos y las comprobaciones para aceptar o rechazar sus valores.

| Dato | Qué representa |
|---|---|
| Identificador de la observación | Valor único que permite distinguir una observación de las demás en MongoDB. |
| Referencia a SQL Server | Indica si la observación corresponde a una labor o a un ciclo y cuál es su identificador. |
| Fecha y hora | Momento en que se realiza la observación. Lo guardaré como un dato de fecha y hora. |
| Tipo de observación | Texto que indica qué se observa, como humedad, clima o plagas. |
| Valores y unidades | Mediciones o detalles de la observación, con sus unidades cuando corresponda. Puedo agrupar datos relacionados dentro del documento, como el valor de una medición y su unidad. |
| Ubicación dentro del lote | Sector o lugar del lote, cuando sea necesario indicarlo. |
| Referencias a fotografías | Información para localizar una fotografía relacionada con la observación, si se utiliza. El caso no exige guardar la imagen dentro del documento. |

Para la referencia a SQL Server, usaré uno de estos datos:

- En la tabla `Labor`, el campo `id_labor` identifica la labor.
- En la tabla `CicloCultivo`, el campo `id_ciclo` identifica el ciclo.

Esta organización permite guardar distintos detalles según el tipo de observación. Mantengo en SQL Server las relaciones entre tablas, las reglas de sus datos y las consultas de la base principal.

## Referencias y consistencia

En cada observación, indicaré si la referencia corresponde a una labor o a un ciclo y guardaré el identificador de ese registro.

En la Parte II definiré cómo comprobar que el registro exista en SQL Server. Explicaré los pasos y guardaré el resultado de cada comprobación.

Guardar el identificador en MongoDB no crea una **clave foránea automática** entre los dos sistemas. Esto significa que MongoDB no comprueba por sí solo si la labor o el ciclo existe en SQL Server.

## Implementación y verificación previstas

En la Parte II realizaré estas actividades:

1. Crearé la colección `observaciones_labor` y explicaré los campos, sus tipos de datos y los identificadores que utilice.
2. Agregaré al menos tres documentos con datos ficticios y coherentes con el caso.
3. Haré una consulta con filtro, que seleccione las observaciones que cumplan una condición. También haré otra consulta que use un dato agrupado dentro de una observación, por ejemplo, el valor de una medición.
4. Modificaré un documento de prueba y comprobaré el cambio.
5. Agregaré un documento adicional para probar la eliminación. Eliminaré solo ese documento, comprobaré que ya no exista y conservaré al menos tres documentos al terminar.
6. Comprobaré que las referencias a labores o ciclos correspondan a registros existentes en SQL Server. Guardaré las evidencias según el [plan de pruebas](pruebas.md).

Tengo previsto reunir estas instrucciones en el archivo `scripts/mongodb/caso_10_funcionalidad.js`. Este archivo todavía no está creado.

Cuando realice la implementación, añadiré a este documento las versiones de los programas utilizados, los comandos para ejecutar el archivo y los resultados que obtenga.

El mínimo para MongoDB es de tres documentos. El requisito de 1.000 filas por tabla corresponde a SQL Server.

Fuentes: Proyecto integrador.pdf, páginas 2–3 y 26; [reglas del negocio](reglas_negocio.md) y [decisiones de diseño](decisiones_diseno.md).


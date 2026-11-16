# Caso 10: componente MongoDB

En este documento presento el uso previsto de MongoDB para guardar observaciones de campo.

El enunciado inicial incluía este componente. La implementación y las pruebas de MongoDB quedaron fuera de la Parte II por indicación del profesor en clase. Conservo aquí el diseño de las observaciones de campo.

## Propósito y colección

Propongo guardar observaciones sobre el suelo, el clima, la humedad, las plagas u otros datos de campo. La información puede variar según el tipo de observación.

En MongoDB, un **documento** es un registro de datos. En este proyecto, cada documento reúne la información de una observación. Una **colección** agrupa esos documentos.

La colección prevista es `observaciones_labor`. En mi diseño, cada observación se relaciona con una labor o un ciclo de cultivo registrado en SQL Server.

Los registros oficiales de labores, ciclos, inventarios y cosechas corresponden a SQL Server. MongoDB los complementa con las observaciones de campo.

## Contenido lógico previsto

En esta tabla presento los datos previstos para cada observación.

| Dato | Qué representa |
|---|---|
| Identificador de la observación | Valor único que permite distinguir una observación de las demás en MongoDB. |
| Referencia a SQL Server | Indica si la observación corresponde a una labor o a un ciclo y cuál es su identificador. |
| Fecha y hora | Momento en que se realiza la observación. Se representa como un dato de fecha y hora. |
| Tipo de observación | Texto que indica qué se observa, como humedad, clima o plagas. |
| Valores y unidades | Mediciones o detalles de la observación, con sus unidades cuando corresponda. Puedo agrupar datos relacionados dentro del documento, como el valor de una medición y su unidad. |
| Ubicación dentro del lote | Sector o lugar del lote, cuando sea necesario indicarlo. |
| Referencias a fotografías | Información para localizar una fotografía relacionada con la observación, si se utiliza. El caso no exige guardar la imagen dentro del documento. |

La referencia a SQL Server puede usar uno de estos datos.

- En la tabla `Labor`, el campo `id_labor` identifica la labor.
- En la tabla `CicloCultivo`, el campo `id_ciclo` identifica el ciclo.

Esta organización permite guardar distintos detalles según el tipo de observación. Mantengo en SQL Server las relaciones entre tablas, las reglas de sus datos y las consultas de la base principal.

## Referencias y consistencia

En el diseño, cada observación indica si la referencia corresponde a una labor o a un ciclo y guarda el identificador de ese registro.

La revisión prevista consiste en buscar ese identificador en la tabla correspondiente de SQL Server.

Guardar el identificador en MongoDB no crea una **clave foránea automática** entre los dos sistemas. Esto significa que MongoDB no comprueba por sí solo si la labor o el ciclo existe en SQL Server.

## Operaciones previstas en el enunciado inicial

El alcance inicial incluía estas actividades.

1. Crear la colección `observaciones_labor` y explicar sus campos y tipos de datos.
2. Agregar al menos tres documentos con datos ficticios y coherentes con el caso.
3. Hacer una consulta con filtro y otra que use un dato agrupado dentro de una observación, como el valor de una medición.
4. Modificar un documento de prueba y comprobar el cambio.
5. Agregar un documento adicional para probar el borrado y conservar al menos tres documentos al terminar.
6. Comprobar que las referencias correspondan a labores o ciclos registrados en SQL Server.

El estado de estas comprobaciones figura en las pruebas P07 y P08. [Plan de pruebas](pruebas.md#comprobaciones-previstas)

Fuentes: Proyecto integrador.pdf, páginas 2–3 y 26; [reglas del negocio](reglas_negocio.md) y [decisiones de diseño](decisiones_diseno.md).


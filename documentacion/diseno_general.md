# Parte I. Diseño de la base de datos y diccionario

**Caso:** 10, Gestión agrícola y producción de cultivos.  
**Estudiante:** Donovan Esteban García Villarreal.  
**Parte I — Diseño y diccionario:** 11 de noviembre de 2026.  
**Parte II — Implementación:** 18 de noviembre de 2026.

## 1. Problema y propósito

En este proyecto presento un diseño para organizar la información de los predios, lotes, cultivos, temporadas, trabajadores, labores, insumos y cosechas de una organización agrícola.

Mi diseño relaciona cada actividad con su ciclo de cultivo, que corresponde a la siembra de un cultivo en un lote y una temporada. Esto permite definir cómo consultar el costo de los insumos, la producción y el rendimiento, es decir, cuánto se produce por hectárea.

Mi modelo tiene diez tablas y 53 campos. Cada tabla reúne un tipo de información y cada campo representa un dato; por ejemplo, el nombre o el área de un lote.

En los diagramas muestro los elementos del caso, sus datos y las relaciones entre ellos. En el diccionario explico qué significa cada campo, qué tipo de dato admite y qué reglas debe cumplir en SQL Server.

## 2. Alcance de las entregas

En la Parte I, con entrega el 11 de noviembre de 2026, presento el modelo entidad-relación, el modelo relacional, la normalización, el diccionario de datos y las reglas de diseño. Con estos documentos explico cómo organizo la información de la base de datos.

En la Parte II, con entrega el 18 de noviembre de 2026, tengo pendiente crear la base de datos y sus tablas en SQL Server, cargar los datos de prueba, preparar las diez consultas y comprobar las reglas de la base de datos y los resultados.

También tengo pendiente preparar en MongoDB el registro de observaciones de campo sobre las labores agrícolas.

## 3. Entidades propuestas

En mi diseño uso diez entidades. Una **entidad** representa algo de lo que necesito guardar información, como un predio o un trabajador. Organizo cada entidad en una tabla y llamo **registro** a cada fila. En los ejemplos, **ha** significa hectáreas y **kg** significa kilogramos.

| Entidad | Qué representa | Ejemplo |
|---|---|---|
| Predio | Una propiedad agrícola. | El Arrayán. |
| Lote | Una parte de un predio. | La Loma, de 2 ha. |
| Cultivo | Un tipo de cultivo. | Maíz. |
| Temporada | Un periodo para organizar los ciclos de cultivo. | Enero a junio de 2026. |
| CicloCultivo | Una siembra de un cultivo en un lote y una temporada. | Maíz en La Loma, febrero a mayo. |
| Trabajador | Una persona responsable de labores. | Un trabajador ficticio. |
| Labor | Una actividad agrícola de un ciclo de cultivo. | Fertilización del 20 de febrero. |
| Insumo | Un recurso para realizar las labores agrícolas. | Un fertilizante medido en kg. |
| ConsumoInsumo | El uso de un insumo en una labor, con cantidad y costo aplicado. | 10 kg a 1.500 pesos por kg. |
| Cosecha | La producción de un ciclo en una fecha. | 6.000 kg del ciclo de maíz. |

Para identificar cada registro, defino una **clave primaria**: un campo o conjunto de campos cuyo valor no se repite dentro de la tabla. En nueve tablas uso un solo campo de tipo `INT`, que guarda números enteros, sin decimales.

En `ConsumoInsumo` uso una **clave primaria compuesta**: la pareja `id_labor` (identificador de la labor) e `id_insumo` (identificador del insumo). Cada identificador puede repetirse por separado, pero la pareja no. Así reúno en una sola fila la cantidad total de un insumo usada en una labor y su costo por unidad aplicado en esa labor.

También defino reglas de **unicidad**, que impiden repetir ciertos datos: los códigos de predio, cultivo, temporada e insumo y el documento del trabajador son únicos en sus respectivas tablas. El código de un lote es único dentro de su predio.

## 4. Relaciones y cardinalidad

En mi diseño, la **cardinalidad** indica cuántos registros pueden relacionarse. La **participación** indica si la relación es obligatoria u opcional. Por ejemplo, cada lote debe pertenecer a un predio, pero puedo registrar un predio aunque todavía no tenga lotes.

En los diagramas, **1** significa exactamente uno y **0..N** significa cero, uno o varios. La **N** indica que puede haber varios registros. La tabla siguiente explica cómo leo cada relación.

Para relacionar las tablas uso **claves foráneas**, identificadas con la abreviatura **FK**. Son campos que señalan un registro de otra tabla. Por ejemplo, `id_predio` en `Lote` indica a qué predio pertenece el lote y debe corresponder a un predio existente. En mi diseño, estas referencias son obligatorias.

| Relación | Cómo la interpreto |
|---|---|
| Predio - Lote | Un predio puede tener cero, uno o varios lotes; cada lote pertenece a un solo predio. |
| Lote - CicloCultivo | Un lote puede tener cero, uno o varios ciclos; cada ciclo corresponde a un solo lote. |
| Cultivo - CicloCultivo | Un tipo de cultivo puede aparecer en cero, uno o varios ciclos; cada ciclo tiene un solo tipo de cultivo. |
| Temporada - CicloCultivo | Una temporada puede agrupar cero, uno o varios ciclos; cada ciclo pertenece a una sola temporada. |
| CicloCultivo - Labor | Un ciclo puede tener cero, una o varias labores; cada labor corresponde a un solo ciclo. |
| Trabajador - Labor | Un trabajador puede ser responsable de cero, una o varias labores; cada labor tiene un solo trabajador responsable. |
| Labor - ConsumoInsumo | Una labor puede tener cero, uno o varios consumos; cada consumo corresponde a una sola labor. |
| Insumo - ConsumoInsumo | Un insumo puede aparecer en cero, uno o varios consumos; cada consumo corresponde a un solo insumo. |
| CicloCultivo - Cosecha | Un ciclo puede tener cero, una o varias cosechas; cada cosecha corresponde a un solo ciclo. |

Una labor puede utilizar varios insumos y un insumo puede utilizarse en varias labores. Esta relación se llama **muchos a muchos** y la represento mediante `ConsumoInsumo`. En cada fila represento la cantidad total de un insumo usada en una labor y su costo por unidad aplicado en esa labor.

Mi diseño permite registrar lotes sin ciclos e insumos sin consumos. También permite registrar un ciclo sin cosechas, por ejemplo, mientras el cultivo está en desarrollo.

## 5. Recorrido de un ejemplo

Uso este ejemplo ficticio para explicar cómo relaciono la información en mi diseño:

1. El predio **El Arrayán** tiene el lote **La Loma**, de **2 hectáreas**. En `CicloCultivo` relaciono ese lote con una siembra de maíz y con la temporada de enero a junio de 2026.

2. En `Labor` relaciono una fertilización con ese ciclo y con su trabajador responsable. Represento sus dos consumos en dos filas de `ConsumoInsumo`: **10 kg** de un insumo a **1.500 pesos por kilogramo** y **2 L**, es decir, dos litros, de otro insumo a **4.000 pesos por litro**. Uso el costo por unidad aplicado en esa labor.

3. Calculo el costo de cada consumo multiplicando la cantidad por su costo por unidad: **10 × 1.500 = 15.000 pesos** para el primero y **2 × 4.000 = 8.000 pesos** para el segundo. Al sumarlos, obtengo el costo total de insumos de la labor: **15.000 + 8.000 = 23.000 pesos**.

4. En `Cosecha` represento dos cosechas del mismo ciclo en fechas diferentes: **6.000 kg** y **4.000 kg**. Las sumo y obtengo una producción de **10.000 kg**. Como el ciclo ocupa las **2 hectáreas completas** del lote, calculo el rendimiento así: **10.000 ÷ 2 = 5.000 kg por hectárea**. Cuento el área una sola vez porque las dos cosechas pertenecen al mismo ciclo.

## 6. Relación con MongoDB

En mi diseño, propongo MongoDB para guardar observaciones de campo, como mediciones de suelo, clima, humedad o plagas. Los datos pueden variar según el tipo de observación. Las agrupo en la colección `observaciones_labor`. Una **colección** es un conjunto de documentos, y cada **documento** reúne los datos de una observación.

Para cada observación, incluyo en el diseño:

- La referencia a una labor o a un ciclo de SQL Server. Indico a cuál de los dos corresponde y su número identificador, que permite encontrar el registro.
- La fecha y la hora de la observación.
- El tipo de observación, como humedad o plagas.
- Los valores con sus unidades de medida.
- La ubicación dentro del lote, cuando hace falta indicarla.
- Referencias a fotografías, si se utilizan.

Reservo SQL Server para los registros oficiales de ciclos, labores, inventarios y cosechas. MongoDB complementa esa información con las observaciones de campo.

Guardar el identificador en MongoDB no crea una **clave foránea automática** entre las dos bases de datos. MongoDB no comprueba por sí solo que esa labor o ese ciclo exista en SQL Server. Por eso, dejo prevista la comprobación de cada referencia y la explicación de cómo se realiza. La creación de la colección y sus pruebas están pendientes.

## 7. Fuentes

Para mi diseño, tomo como guía el documento **Proyecto integrador.pdf**:

- **Páginas 1–5:** reglas generales del proyecto.
- **Páginas 24–26:** requisitos del caso 10, sobre gestión agrícola y producción de cultivos.
- **Páginas 28–29:** lista de comprobación para revisar los requisitos de la entrega.

Las fechas de entrega de mi proyecto figuran al inicio del [README](../README.md).

## 8. Uso de herramientas de apoyo

Utilicé inteligencia artificial como apoyo para elaborar los diagramas del modelo entidad-relación y del modelo relacional, y para revisar la documentación del proyecto.

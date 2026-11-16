# Caso 10: Gestión agrícola y producción de cultivos

**Estudiante:** Donovan Esteban García Villarreal.  
**Parte I — Diseño y diccionario:** 11 de noviembre de 2026.  
**Parte II — Implementación:** 18 de noviembre de 2026.  
**Repositorio:** `proyecto-agricola-caso-10`.

## Propósito

El proyecto relaciona los predios, los lotes y las actividades de cada ciclo de cultivo. Uso SQL Server para consultar las labores, los costos de los insumos, la producción y el rendimiento.

## Estado de la entrega

| Componente | Estado |
|---|---|
| Parte I | El Word reúne los modelos, el diccionario, la normalización y las reglas del caso. |
| SQL Server | La base tiene 10 tablas, 53 campos y 9 relaciones. La carga contiene 19.034 filas ficticias y cada tabla tiene al menos 1.000. |
| Consultas y pruebas | Están comprobadas las diez consultas, las pruebas de restricciones y la reconstrucción y el reinicio en una base de prueba. |
| Video | Pendiente de grabar. Debe durar máximo 10 minutos. |
| MongoDB | Fuera del alcance de la Parte II por indicación del profesor en clase. El diseño inicial se conserva como referencia. |

## Archivos de esta entrega

| Archivo | Contenido |
|---|---|
| [Parte_I_Diseno_y_Diccionario.docx](documentacion/Parte_I_Diseno_y_Diccionario.docx) | Documento principal en Word con los modelos, el diccionario y la normalización. |
| [Modelo entidad-relación](modelo/modelo_er.png) y [modelo relacional](modelo/modelo_relacional.png) | Entidades, tablas y relaciones del caso. |
| [Diccionario de datos](modelo/diccionario_datos.md) | Significado, tipo, obligatoriedad, claves y reglas de los 53 campos. |
| [Diseño general](documentacion/diseno_general.md), [reglas](documentacion/reglas_negocio.md) y [decisiones](documentacion/decisiones_diseno.md) | Explicación del caso, las condiciones de los datos y los criterios de cálculo. |
| [Matriz de requisitos](documentacion/matriz_requisitos.md) | Relación entre cada requisito, su aplicación y el estado de las comprobaciones. |
| [Scripts de SQL Server](scripts/sqlserver/README.md) | Orden para crear la base, aplicar las reglas, cargar los datos y ejecutar las consultas. |
| [Guía de reconstrucción](scripts/sqlserver/p09_reconstruccion/README.md) | Pasos para repetir la reconstrucción y el reinicio en una base de prueba. |
| [Pruebas](documentacion/pruebas.md) y [evidencias](evidencias/capturas_o_resultados/README.md) | Resultados comprobados en SSMS. |
| [Bitácora](BITACORA.md) | Avances documentados con sus fechas y referencias. |

## Modelo propuesto

Las diez tablas son `Predio`, `Lote`, `Cultivo`, `Temporada`, `CicloCultivo`, `Trabajador`, `Labor`, `Insumo`, `ConsumoInsumo` y `Cosecha`.

Un predio puede contener varios lotes. Cada ciclo representa una siembra de un cultivo en un lote y una temporada. Las labores se vinculan con el ciclo y con su trabajador responsable. `ConsumoInsumo` relaciona las labores con los insumos y conserva cantidad y costo unitario aplicado. Cada cosecha pertenece a un ciclo.

La clave primaria de `ConsumoInsumo` es la pareja `(id_labor, id_insumo)`. Las otras nueve tablas utilizan claves primarias simples. El código del lote es único dentro de su predio mediante `UNIQUE (id_predio, codigo_lote)`.

Cada ciclo utiliza el área completa del lote y cada labor pertenece a un ciclo. El costo aplicado a un consumo se conserva aunque después cambie el precio del insumo. Convierto las toneladas a kilogramos antes de sumar la producción. Uso `CHECK` para comprobar condiciones de una misma fila, como un área mayor que cero. Para comparar fechas o unidades de registros relacionados, uso reglas que SQL Server ejecuta al cambiar esos datos. [Restricciones y reglas entre tablas](documentacion/restricciones_sqlserver.md)

## Requisitos de lectura e instalación

La Parte I se puede consultar con un lector de Word, un visor de imágenes y GitHub. Para ejecutar los archivos de la Parte II uso SQL Server y SQL Server Management Studio (SSMS). Las pruebas se hicieron con SQL Server 2022, versión `16.0.4315.2`.

## Consulta y comprobación de la Parte I

1. Abrir el documento principal y revisar el problema y las entidades.
2. Comparar los modelos E-R y relacional con el diccionario.
3. Revisar las diez tablas y las nueve relaciones. Comprobar la clave compuesta de `ConsumoInsumo` y que el código de cada lote sea único dentro de su predio.
4. Consultar la normalización, las reglas adoptadas y la matriz de requisitos.

La comprobación documental contrastó las 53 columnas del esquema con el diccionario y el modelo relacional, las referencias de las nueve relaciones y la presentación del documento.

## Ejecución y reconstrucción de la Parte II

Sigo el orden de la [guía de SQL Server](scripts/sqlserver/README.md). Primero creo las tablas y aplico las restricciones y las reglas entre tablas. Luego cargo los datos ficticios y ejecuto las consultas. Uso `DNV_Caso10` para el video y `DNV_Caso10_Reconstruccion` para reproducir la [prueba de reconstrucción y reinicio](documentacion/pruebas.md#p09-reconstrucción-y-reinicio).

## Datos, consultas y pruebas

La carga cumple el mínimo de 1.000 filas por tabla, incluidas `Cultivo`, `Temporada` y `ConsumoInsumo`. El registro de pruebas explica cómo se formaron las variedades y temporadas ficticias y muestra los diez controles de la carga. [Resultados de la carga de datos](documentacion/pruebas.md#p04-carga-de-datos-ficticios)

Q01 a Q10 identifican las diez preguntas. Cada resultado muestra el código de la consulta. En el video explicaré cómo funciona cada consulta, mostraré su ejecución en SSMS y leeré un resultado que responda a la pregunta. [Conteos y ejemplos para las diez preguntas](documentacion/pruebas.md#p05-diez-consultas-del-caso)

Queda pendiente la revisión interna P06. Allí reviso las instrucciones SQL y los casos sin actividad, como los lotes sin ciclos, los lotes sin siembras activas y los insumos sin consumo durante una temporada. [Plan de pruebas](documentacion/pruebas.md#comprobaciones-previstas)

## Historial y bitácora

Los commits guardan versiones del proyecto y su mensaje indica qué cambió. En la bitácora reúno los avances con su fecha, sus resultados y los códigos de las versiones relacionadas. [Bitácora](BITACORA.md)

## Fuentes y apoyo utilizado

La fuente académica de mi proyecto es **Proyecto integrador.pdf**. Las reglas generales están en las páginas 1–5, el caso 10 en las páginas 24–26 y la lista de comprobación en las páginas 28–29.

Utilicé inteligencia artificial como apoyo para elaborar los diagramas del modelo entidad-relación y del modelo relacional, y para revisar la documentación del proyecto.

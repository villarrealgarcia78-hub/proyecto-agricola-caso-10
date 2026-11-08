# Caso 10: Gestión agrícola y producción de cultivos

**Estudiante:** Donovan Esteban García Villarreal.  
**Parte I — Diseño y diccionario:** 11 de noviembre de 2026.  
**Parte II — Implementación:** 18 de noviembre de 2026.  
**Cuenta GitHub:** `villarrealgarcia78-hub`.  
**Nombre propuesto del repositorio:** `proyecto-agricola-caso-10`.

## Propósito

El proyecto organiza la información de predios, lotes, cultivos, temporadas, trabajadores, labores, insumos y cosechas de una organización agrícola. Su finalidad es relacionar las actividades con cada ciclo de cultivo y consultar los costos de insumos, la producción y el rendimiento.

SQL Server almacenará los datos estructurados del proyecto. MongoDB guardará información adicional sobre las labores agrícolas, como datos del clima, la humedad o las plagas. Esta información se agrupará en una colección llamada `observaciones_labor`.

## Estado de la entrega

| Componente | Estado |
|---|---|
| Modelo entidad-relación y modelo relacional | Preparados en imágenes e incluidos en el documento Word de Parte I. |
| Diccionario y normalización | Completos: diez tablas, 53 campos, nueve relaciones y normalización hasta tercera forma normal. |
| Reglas y decisiones de diseño | Documentadas en el Word completo de 21 páginas. |
| SQL Server | Pendientes la creación de la base, los scripts, la carga de datos y las pruebas. |
| MongoDB | Definido el uso de la colección `observaciones_labor`; implementación y pruebas pendientes. |
| README y bitácora | README y bitácora disponibles con el estado actual del proyecto. |
| Organización del repositorio | Preparados 19 archivos en la raíz y las carpetas de modelo, scripts, documentación y evidencias. |
| Git y publicación en GitHub | Pendientes la creación del repositorio y la publicación. |

## Archivos de esta entrega

| Archivo | Contenido |
|---|---|
| [README.md](README.md) | Presentación del proyecto, archivos de la entrega y pasos de implementación previstos. |
| [.gitignore](.gitignore) | Indica qué archivos locales debe excluir Git, como configuraciones privadas y respaldos de bases de datos. |
| [.gitattributes](.gitattributes) | Define el tratamiento de archivos de texto y de archivos binarios, como Word e imágenes. |
| [Parte_I_Diseno_y_Diccionario.docx](documentacion/Parte_I_Diseno_y_Diccionario.docx) | Documento principal en Word de 21 páginas: diseño, diagramas, normalización, diccionario y reglas. |
| [diseno_general.md](documentacion/diseno_general.md) | Problema, entidades, relaciones, ejemplo agrícola y alcance de MongoDB. |
| [modelo_er.png](modelo/modelo_er.png) | Modelo entidad-relación. |
| [modelo_relacional.png](modelo/modelo_relacional.png) | Modelo de tablas, columnas y claves. |
| [diccionario_datos.md](modelo/diccionario_datos.md) | Significado, tipo, obligatoriedad, claves y reglas de los 53 campos. |
| [esquema.json](modelo/esquema.json) | Representación estructurada del diseño; no es un script de creación de base de datos. |
| [normalizacion.md](documentacion/normalizacion.md) | Justificación de primera, segunda y tercera forma normal. |
| [decisiones_diseno.md](documentacion/decisiones_diseno.md) | Decisiones adoptadas para concretar el modelo y los cálculos. |
| [reglas_negocio.md](documentacion/reglas_negocio.md) | Requisitos del caso y mecanismos de validación previstos. |
| [matriz_requisitos.md](documentacion/matriz_requisitos.md) | Correspondencia entre reglas, preguntas, diseño y verificaciones previstas. |
| [pruebas.md](documentacion/pruebas.md) | Plan de pruebas de implementación; sin resultados ejecutados. |
| [mongodb.md](documentacion/mongodb.md) | Alcance del componente documental; implementación pendiente. |
| [scripts/sqlserver/README.md](scripts/sqlserver/README.md) | Estado pendiente y archivos T-SQL previstos. |
| [scripts/mongodb/README.md](scripts/mongodb/README.md) | Estado pendiente del script de observaciones de campo. |
| [evidencias/capturas_o_resultados/README.md](evidencias/capturas_o_resultados/README.md) | Criterios para incorporar resultados reales cuando se ejecuten las pruebas. |
| [BITACORA.md](BITACORA.md) | Avances documentales reales y registro individual pendiente de completar con actividades realizadas. |

## Organización según el enunciado

Los archivos se organizan en carpetas de modelo, documentación, scripts y evidencias. El diseño de la Parte I está completo. Las carpetas de scripts y evidencias contienen por ahora archivos README que describen el trabajo pendiente de la Parte II.

```text
proyecto-agricola-caso-10/
├── README.md
├── BITACORA.md
├── .gitignore
├── .gitattributes
├── modelo/
│   ├── modelo_er.png
│   ├── modelo_relacional.png
│   ├── diccionario_datos.md
│   └── esquema.json
├── scripts/
│   ├── sqlserver/
│   │   └── README.md                 (implementación pendiente)
│   └── mongodb/
│       └── README.md                 (implementación pendiente)
├── documentacion/
│   ├── Parte_I_Diseno_y_Diccionario.docx
│   ├── diseno_general.md
│   ├── normalizacion.md
│   ├── decisiones_diseno.md
│   ├── reglas_negocio.md
│   ├── matriz_requisitos.md
│   ├── pruebas.md                    (plan, sin ejecución)
│   └── mongodb.md                    (alcance, sin implementación)
└── evidencias/
    └── capturas_o_resultados/
        └── README.md                 (resultados pendientes)
```

## Modelo propuesto

Las diez tablas son `Predio`, `Lote`, `Cultivo`, `Temporada`, `CicloCultivo`, `Trabajador`, `Labor`, `Insumo`, `ConsumoInsumo` y `Cosecha`.

Un predio puede contener varios lotes. Cada ciclo representa una siembra de un cultivo en un lote y una temporada. Las labores se vinculan con el ciclo y con su trabajador responsable. `ConsumoInsumo` relaciona las labores con los insumos y conserva cantidad y costo unitario aplicado. Cada cosecha pertenece a un ciclo.

La clave primaria de `ConsumoInsumo` es la pareja `(id_labor, id_insumo)`. Las otras nueve tablas utilizan claves primarias simples. El código del lote es único dentro de su predio mediante `UNIQUE (id_predio, codigo_lote)`.

Cada ciclo utiliza el área completa del lote y cada labor pertenece a un ciclo. El costo aplicado a un consumo se conserva aunque después cambie el precio del insumo. Las toneladas se convierten a kilogramos antes de sumar la producción. Para validar condiciones de un mismo registro se utilizará `CHECK`, por ejemplo, exigir un área mayor que cero. Las reglas que comparan datos de tablas distintas necesitarán validaciones adicionales.

## Requisitos de lectura e instalación

La documentación de la Parte I puede consultarse con Microsoft Word u otro lector compatible con DOCX, un visor de imágenes y un lector de Markdown. Para revisar estos documentos no es necesario instalar SQL Server ni MongoDB.

Para implementar la Parte II utilizaré SQL Server y MongoDB, junto con herramientas para ejecutar sus instrucciones. Utilizaré Git para conservar el historial de cambios del proyecto.

Antes de definir la instalación, comprobaré el sistema operativo, las versiones y los programas disponibles en mi equipo.

## Consulta y comprobación de la Parte I

1. Abrir el documento principal y revisar el problema y las entidades.
2. Comparar los modelos E-R y relacional con el diccionario.
3. Revisar las diez tablas y las nueve relaciones; comprobar la clave compuesta de `ConsumoInsumo` y que el código de cada lote sea único dentro de su predio.
4. Consultar la normalización, las reglas adoptadas y la matriz de requisitos.

La comprobación documental registrada contrastó las 53 columnas del esquema con el diccionario y el modelo relacional, las referencias de las nueve relaciones y la presentación del documento. Esta comprobación corresponde al diseño. No representa pruebas ejecutadas en SQL Server o MongoDB.

## Ejecución y reconstrucción de la Parte II

En la Parte II desarrollaré y probaré los siguientes archivos con instrucciones, llamados scripts. Los organizaré para crear la base de datos, aplicar las reglas del modelo, cargar datos de prueba y resolver las consultas del caso. Cuando los haya probado, añadiré los comandos, las versiones utilizadas y el orden definitivo para ejecutarlos.

| Orden previsto | Archivo por desarrollar | Función |
|---|---|---|
| 1 | `scripts/sqlserver/01_crear_base_y_tablas.sql` | Crear la base de datos del ejercicio y las tablas del modelo. |
| 2 | `scripts/sqlserver/02_restricciones_y_reglas.sql` | Agregar las reglas que controlan qué datos pueden guardarse, como claves, relaciones y valores permitidos. |
| 3 | `scripts/sqlserver/03_datos_semilla.sql` | Cargar los datos iniciales de prueba (datos semilla sintéticos): información ficticia, variada y relacionada, con al menos 1.000 registros por tabla. |
| 4 | `scripts/sqlserver/04_consultas_negocio.sql` | Resolver las diez preguntas del caso mediante consultas y explicar sus resultados. |
| 5, si aplica | `scripts/sqlserver/05_vistas.sql` | Crear consultas guardadas, llamadas vistas, si resultan útiles. Si una consulta utiliza una vista, crearé primero esa vista. |
| 6 | `scripts/mongodb/caso_10_funcionalidad.js` | Registrar y consultar observaciones de campo, probar la actualización y eliminación de un documento de prueba y comprobar que sus referencias correspondan a registros de SQL Server. |

También prepararé un archivo separado de reinicio o limpieza para dejar el entorno del proyecto listo para empezar de nuevo. Indicaré exactamente qué elimina e incluiré la advertencia de borrado solicitada en el enunciado.

Comprobaré que sea posible crear nuevamente la base de datos, sus tablas y los datos de prueba siguiendo los archivos en orden. También comprobaré las reglas, las consultas y el funcionamiento de MongoDB. Actualizaré este README con las instrucciones de ejecución y reinicio que haya probado.

## Datos, consultas y pruebas por implementar

Cargaré al menos 1.000 registros (filas) de datos ficticios por cada tabla de SQL Server, incluida `ConsumoInsumo`, que relaciona las labores con los insumos. Mantendré este mínimo también para `Cultivo` y `Temporada` mientras no se aclare una excepción para estas tablas. Los datos serán variados y coherentes entre sí; no repetiré filas solo para completar la cantidad.

Resolveré las diez preguntas del caso: lotes por predio y área; labores por rango de fechas; cantidad de labores por cultivo y temporada; producción y rendimiento por lote; detalle de labores con lote, cultivo, trabajador e insumos; insumos nunca utilizados; lotes sin ciclos; cultivos con rendimiento superior al promedio; ciclos con costo de insumos superior al promedio; y predios con mayor producción por temporada. La [matriz de requisitos](documentacion/matriz_requisitos.md) detalla los datos y criterios de cálculo.

En las consultas utilizaré filtros para seleccionar registros y ordenamiento para presentar los resultados. Comprobaré el uso de `COUNT` para contar, `SUM` para sumar, `AVG` para calcular promedios y `MIN`/`MAX` para obtener los valores menor y mayor. Usaré `GROUP BY` para agrupar resultados, por ejemplo por cultivo, y `HAVING` para filtrar esos grupos. `JOIN` permitirá combinar datos de varias tablas; las subconsultas permitirán usar el resultado de una consulta dentro de otra.

Probaré operaciones correctas y otras que deban rechazarse: claves repetidas, referencias a registros inexistentes, valores fuera de lo permitido y fechas incoherentes. Por ejemplo, comprobaré que una labor no pueda asociarse con un ciclo inexistente. Para cada prueba registraré qué regla revisé, cómo lo hice, qué esperaba y qué obtuve. También verificaré la cantidad de registros de cada tabla y repetiré la creación del proyecto desde cero.

En MongoDB crearé al menos tres registros de prueba, llamados documentos, agrupados en la colección `observaciones_labor`. Incluirán la referencia a una labor o ciclo, fecha y hora, tipo de observación, valores con sus unidades y ubicación cuando corresponda. Probaré cómo agregar, buscar con un filtro y modificar documentos; para la eliminación utilizaré un documento adicional de prueba. También consultaré un dato agrupado dentro de una observación, como el valor de humedad de una medición. Comprobaré que los identificadores de labor o ciclo existan en SQL Server, porque MongoDB no verifica por sí mismo esa relación. Añadiré los comandos y resultados a la [documentación de MongoDB](documentacion/mongodb.md) después de probarlos.

## Historial y bitácora

La [bitácora](BITACORA.md) reúne los avances documentales del proyecto. Registraré las actividades que realice, sus resultados y lo que aprenda o corrija, siempre con su fecha real.

Cuando cree el repositorio, guardaré los cambios mediante **commits**, que son versiones registradas del proyecto. Cada commit tendrá un mensaje que explique qué cambió. Añadiré a la bitácora su **identificador**, un código que permite localizar esa versión en el historial.

## Fuentes y apoyo utilizado

La fuente académica de mi proyecto es **Proyecto integrador.pdf**: reglas generales en las páginas 1–5, caso 10 en las páginas 24–26 y lista de comprobación en las páginas 28–29. Las fechas previstas de entrega figuran al inicio de este README.

Utilicé inteligencia artificial como apoyo para elaborar los diagramas del modelo entidad-relación y del modelo relacional, y para revisar la documentación del proyecto.

Registraré las ejecuciones y pruebas que realice y explicaré el código y sus resultados en la sustentación.

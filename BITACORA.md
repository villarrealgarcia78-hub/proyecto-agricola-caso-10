# Bitácora del proyecto agrícola

**Estudiante:** Donovan Esteban García Villarreal.  
**Caso:** 10, Gestión agrícola y producción de cultivos.

En esta bitácora reúno los avances y documentos de mi proyecto. La versión actual de la Parte I es el [documento en Word](documentacion/Parte_I_Diseno_y_Diccionario.docx) de 21 páginas.

Registraré las actividades de instalación, programación, pruebas y sustentación cuando las realice, con su fecha, resultado y una explicación breve de lo aprendido o corregido.

## Avances documentales registrados

Reúno aquí los avances documentales que constan en los archivos del proyecto. El apoyo utilizado para los diagramas y la revisión de la documentación está declarado en el [README](README.md#fuentes-y-apoyo-utilizado).

| Fecha de la actividad | Avance documental | Resultado actual |
|---|---|---|
| 5 de noviembre de 2026 | Análisis de las reglas generales, el caso agrícola y los entregables. | Reglas y preguntas del caso relacionadas con el diseño en la [matriz de requisitos](documentacion/matriz_requisitos.md). |
| 5 de noviembre de 2026 | Preparación del modelo entidad-relación, modelo relacional, diccionario y normalización. | Diez tablas, 53 columnas y nueve relaciones; [modelos y diccionario](README.md#archivos-de-esta-entrega) disponibles. |
| 5 de noviembre de 2026 | Revisión del contenido y la presentación del documento de la Parte I. | Documento de la Parte I en Word de 21 páginas, con los modelos, el diccionario de datos, la normalización y las reglas del proyecto. |
| 6 de noviembre de 2026 | Preparación del README y de esta bitácora para un repositorio independiente. | El [README](README.md) presenta la organización y el estado de la entrega. El historial está disponible en GitHub. |
| 6 de noviembre de 2026 | Organización de las carpetas del proyecto y separación de las reglas y decisiones. | El repositorio reúne los modelos, los scripts, la documentación y las evidencias. |

## Avances comprobados de la Parte II

En esta tabla reúno los resultados que muestran las pruebas del proyecto.

| Fecha | Avance | Resultado actual | Referencia |
|---|---|---|---|
| 14 de noviembre de 2026 | Creación de la estructura y prueba de las reglas. | 10 tablas, 53 campos y 9 claves foráneas. Los 8 casos de restricciones y los 9 casos de reglas entre tablas cumplieron lo esperado. | [Registro y capturas de las pruebas](documentacion/pruebas.md) |
| 14 de noviembre de 2026 | Carga de datos ficticios. | 19.034 filas, al menos 1.000 por tabla y 10 controles conformes. | [P04](documentacion/pruebas.md#p04-carga-de-datos-ficticios), commit `86b8939`. |
| 14 de noviembre de 2026 | Comprobación de las diez consultas. | Los resultados coinciden con los esperados y suman 15.780 filas. | [P05](documentacion/pruebas.md#p05-diez-consultas-del-caso), commit `bf5e210`. |
| 14 de noviembre de 2026 | Reconstrucción y reinicio en una base de prueba. | La base de prueba se creó, se cargó y se eliminó. La base del video quedó disponible. | [P09](documentacion/pruebas.md#p09-reconstrucción-y-reinicio), commit `9ad21a9`. |

Mis diagramas muestran las entidades, las claves primarias y sus relaciones. El modelo tiene diez entidades, 53 campos y nueve relaciones.

Mi diccionario de datos presenta los 53 campos en fichas visuales. Incluye claves, ejemplos y gráficos que muestran las relaciones entre las tablas.

## Registro de mis actividades

Registraré cada actividad que realice con su fecha, el archivo o resultado y una explicación breve de lo aprendido o corregido. Cuando guarde una versión del proyecto en Git, llamada **commit**, añadiré el código que la identifica.

| Fecha | Actividad realizada | Archivo o resultado | Qué aprendí o corregí | Código del commit, si existe |
|---|---|---|---|---|
| Pendiente de registro | — | — | — | — |

## Próximas actividades previstas

1. Revisaré el modelo y el diccionario para explicar las tablas, sus relaciones y sus campos en la sustentación.
2. Revisaré las técnicas SQL y los ejemplos de lotes e insumos sin actividad, que corresponden a P06.
3. Prepararé y ensayaré el video de máximo 10 minutos. Mostraré la ejecución y un resultado de cada consulta y explicaré cómo responde a su pregunta.

## Declaración de apoyo

Utilicé inteligencia artificial como apoyo para elaborar los diagramas del modelo entidad-relación y del modelo relacional, y para revisar la documentación del proyecto.

## Normalización del documento

En mi documento, la normalización del caso 10 ocupa una página e incluye la primera, segunda y tercera forma normal (1FN, 2FN y 3FN). El documento completo tiene 21 páginas y el diccionario contiene 53 campos.

## Documento de entrega en Word

Mi [documento de la Parte I](documentacion/Parte_I_Diseno_y_Diccionario.docx) está en Word y tiene 21 páginas. Incluye los modelos, la normalización, el diccionario de datos y las reglas del proyecto.

En el [README](README.md) explico cómo consultar el documento y dónde están los archivos y resultados de la Parte II.

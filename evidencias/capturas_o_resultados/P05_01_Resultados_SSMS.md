# Ejemplos de las diez consultas en SSMS

En esta tabla muestro ejemplos de las salidas del 14 de noviembre de 2026. Los códigos Q01 a Q10 identifican las preguntas del caso. Los códigos que empiezan por `P04` identifican los datos ficticios de la carga.

| Consulta | Ejemplo del resultado |
|---|---|
| Q01 | El lote B del predio `P04-P0001` tiene 1,25 ha. |
| Q02 | La primera labor del intervalo es una siembra del 12 de enero de 2026 en `P04-P0099`, lote A. La última es una instalación de trampas del 22 de enero en `P04-P0999`, lote A. |
| Q03 | El cultivo `P04-C0001` tiene 5 labores en la temporada `P04-T0001`. |
| Q04 | En `P04-T0001`, el lote A del predio `P04-P0001` produjo 10.265 kg sobre 1,50 ha. Su rendimiento fue 6.843,33 kg/ha. El lote B del mismo predio aparece sin rendimiento calculado porque no tiene área con cosecha. |
| Q05 | La labor 10 aparece sin insumos. La labor 27 aparece en dos filas porque usó `P04-I0004` y `P04-I0014`. |
| Q06 | El abono `P04-I0901` tiene 150 kg disponibles y no tiene registros de consumo. |
| Q07 | El lote B del predio `P04-P0001` aparece porque no tiene ciclos registrados. |
| Q08 | En `P04-T0002`, el cultivo `P04-C0002` rindió 7.212,67 kg/ha. El promedio de la temporada fue 4.237,33 kg/ha. |
| Q09 | El ciclo 11 de `P04-T0001` tuvo un costo de insumos de 6.763,50 pesos. El promedio de los ciclos de esa temporada fue 3.381,75 pesos. |
| Q10 | En `P04-T0001`, los predios `P04-P0001` y `P04-P0002` empataron con 10.265 kg cada uno. |

[Conteos por consulta](../../documentacion/pruebas.md#p05-diez-consultas-del-caso) · [Archivo de consultas](../../scripts/sqlserver/04_consultas_negocio.sql)

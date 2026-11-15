-- Parte II. Respondo las diez preguntas del caso agrícola.
-- Q01 a Q10 identifican las preguntas. Cada consulta muestra su código en la primera columna.
USE DNV_Caso10;
GO

-- GO separa la elección de la base del bloque con las consultas. DB_NAME() devuelve la base actual.
IF DB_NAME() <> N'DNV_Caso10'
    THROW 50160, N'Selecciona la base académica DNV_Caso10 para ejecutar las consultas.', 1;

SET NOCOUNT OFF;  -- La pestaña Mensajes indica cuántas filas devuelve cada consulta.

-- Q01. ¿Qué lotes tiene cada predio y cuál es el área de cada lote?
-- SELECT elige las columnas. JOIN une cada lote con su predio usando id_predio.
-- ORDER BY ordena por predio y luego de menor a mayor área. El código del lote ordena los empates.
SELECT 'Q01' AS Consulta,
       predio.codigo_predio AS CodigoPredio, predio.nombre AS Predio,
       lote.codigo_lote AS CodigoLote, lote.nombre AS Lote, lote.area_ha AS AreaLoteHa
FROM dbo.Predio AS predio
JOIN dbo.Lote AS lote ON lote.id_predio = predio.id_predio
ORDER BY predio.codigo_predio, lote.area_ha, lote.codigo_lote;

-- Q02. ¿Qué labores se hicieron entre dos fechas?
-- DECLARE guarda los dos límites de ejemplo. Escribo las fechas en formato AAAAMMDD.
-- WHERE conserva las labores del intervalo. >= y <= incluyen el primer y el último día.
DECLARE @fechaDesde DATE = '20260112';
DECLARE @fechaHasta DATE = '20260122';

SELECT 'Q02' AS Consulta,
       labor.fecha AS Fecha, labor.tipo AS Labor, labor.duracion_horas AS DuracionHoras,
       predio.codigo_predio AS CodigoPredio, lote.codigo_lote AS CodigoLote,
       trabajador.nombre AS Trabajador
FROM dbo.Labor AS labor
JOIN dbo.CicloCultivo AS ciclo ON ciclo.id_ciclo = labor.id_ciclo
JOIN dbo.Lote AS lote ON lote.id_lote = ciclo.id_lote
JOIN dbo.Predio AS predio ON predio.id_predio = lote.id_predio
JOIN dbo.Trabajador AS trabajador ON trabajador.id_trabajador = labor.id_trabajador
WHERE labor.fecha >= @fechaDesde AND labor.fecha <= @fechaHasta
ORDER BY labor.fecha, labor.id_labor;

-- Q03. ¿Cuántas labores hay por cultivo y temporada?
-- GROUP BY reúne las labores del mismo cultivo y temporada. COUNT cuenta las filas de ese grupo.
-- MIN y MAX indican la primera y la última fecha de labor. Cuento desde Labor para contar cada labor una vez.
SELECT 'Q03' AS Consulta,
       temporada.codigo_temporada AS CodigoTemporada, temporada.nombre AS Temporada,
       cultivo.codigo_cultivo AS CodigoCultivo, cultivo.nombre AS Cultivo,
       COUNT(labor.id_labor) AS CantidadLabores, MIN(labor.fecha) AS PrimeraLabor,
       MAX(labor.fecha) AS UltimaLabor
FROM dbo.Labor AS labor
JOIN dbo.CicloCultivo AS ciclo ON ciclo.id_ciclo = labor.id_ciclo
JOIN dbo.Temporada AS temporada ON temporada.id_temporada = ciclo.id_temporada
JOIN dbo.Cultivo AS cultivo ON cultivo.id_cultivo = ciclo.id_cultivo
GROUP BY temporada.codigo_temporada, temporada.nombre, cultivo.codigo_cultivo, cultivo.nombre
ORDER BY temporada.codigo_temporada, cultivo.codigo_cultivo;

-- Q04. ¿Cuánto produce cada lote y cuánto rinde por hectárea?
-- WITH da nombre a un resultado intermedio. Primero saco una fila por ciclo con cosecha.
-- CASE convierte de toneladas a kilos cuando la unidad es 't'. SUM reúne las cosechas del ciclo.
;WITH ProduccionPorCiclo AS (
    SELECT cosecha.id_ciclo,
           SUM(CASE WHEN cosecha.unidad = 't' THEN cosecha.cantidad * 1000
                    ELSE cosecha.cantidad END) AS produccion_kg
    FROM dbo.Cosecha AS cosecha
    GROUP BY cosecha.id_ciclo
), ProduccionPorLoteTemporada AS (
    -- LEFT JOIN conserva los lotes sin ciclos y los ciclos sin cosecha.
    -- COALESCE usa 0 si no hay producción. Sumo el área una vez por cada ciclo con cosecha.
    SELECT lote.id_lote, ciclo.id_temporada,
           SUM(COALESCE(produccion.produccion_kg, 0)) AS produccion_kg,
           SUM(CASE WHEN produccion.id_ciclo IS NOT NULL THEN lote.area_ha ELSE 0 END) AS area_con_cosecha_ha
    FROM dbo.Lote AS lote
    LEFT JOIN dbo.CicloCultivo AS ciclo ON ciclo.id_lote = lote.id_lote
    LEFT JOIN ProduccionPorCiclo AS produccion ON produccion.id_ciclo = ciclo.id_ciclo
    GROUP BY lote.id_lote, ciclo.id_temporada
)
-- NULLIF devuelve NULL si el área sumada es cero. En ese caso el rendimiento queda sin valor.
-- CAST con DECIMAL(20,2) presenta el cociente con hasta 20 cifras, dos de ellas decimales.
SELECT 'Q04' AS Consulta,
       predio.codigo_predio AS CodigoPredio, lote.codigo_lote AS CodigoLote,
       temporada.codigo_temporada AS CodigoTemporada,
       total.produccion_kg AS ProduccionKg, total.area_con_cosecha_ha AS AreaConCosechaHa,
       CAST(total.produccion_kg / NULLIF(total.area_con_cosecha_ha, 0) AS DECIMAL(20,2)) AS RendimientoKgHa
FROM ProduccionPorLoteTemporada AS total
JOIN dbo.Lote AS lote ON lote.id_lote = total.id_lote
JOIN dbo.Predio AS predio ON predio.id_predio = lote.id_predio
LEFT JOIN dbo.Temporada AS temporada ON temporada.id_temporada = total.id_temporada
ORDER BY predio.codigo_predio, lote.codigo_lote, temporada.codigo_temporada;

-- Q05. ¿Qué lote, cultivo, trabajador e insumos corresponden a cada labor?
-- JOIN trae los datos obligatorios. LEFT JOIN deja la labor en el resultado aunque no tenga insumos.
-- Si una labor usa dos insumos, muestro dos filas con el mismo IdLabor, una por insumo.
SELECT 'Q05' AS Consulta,
       labor.id_labor AS IdLabor, labor.fecha AS Fecha, labor.tipo AS Labor,
       predio.codigo_predio AS CodigoPredio, lote.codigo_lote AS CodigoLote,
       cultivo.nombre AS Cultivo, trabajador.nombre AS Trabajador,
       insumo.codigo_insumo AS CodigoInsumo, insumo.nombre AS Insumo,
       consumo.cantidad AS CantidadUsada, insumo.unidad AS Unidad,
       consumo.costo_unitario_aplicado AS CostoUnitarioAplicado
FROM dbo.Labor AS labor
JOIN dbo.CicloCultivo AS ciclo ON ciclo.id_ciclo = labor.id_ciclo
JOIN dbo.Lote AS lote ON lote.id_lote = ciclo.id_lote
JOIN dbo.Predio AS predio ON predio.id_predio = lote.id_predio
JOIN dbo.Cultivo AS cultivo ON cultivo.id_cultivo = ciclo.id_cultivo
JOIN dbo.Trabajador AS trabajador ON trabajador.id_trabajador = labor.id_trabajador
LEFT JOIN dbo.ConsumoInsumo AS consumo ON consumo.id_labor = labor.id_labor
LEFT JOIN dbo.Insumo AS insumo ON insumo.id_insumo = consumo.id_insumo
ORDER BY labor.id_labor, insumo.codigo_insumo;

-- Q06. ¿Qué insumos nunca se han utilizado?
-- NOT EXISTS conserva el insumo si la consulta interna no encuentra su identificador en los consumos.
-- SELECT 1 solo sirve para comprobar si hay alguna fila en todo el historial de consumos.
SELECT 'Q06' AS Consulta,
       insumo.codigo_insumo AS CodigoInsumo, insumo.nombre AS Insumo,
       insumo.unidad AS Unidad, insumo.cantidad_disponible AS CantidadDisponible
FROM dbo.Insumo AS insumo
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.ConsumoInsumo AS consumo WHERE consumo.id_insumo = insumo.id_insumo
)
ORDER BY insumo.codigo_insumo;

-- Q07. ¿Qué lotes no tienen ciclos de cultivo?
-- Busco si hay algún ciclo asociado al lote. Cualquier ciclo cuenta como historial,
-- incluso cuando está finalizado o cancelado.
SELECT 'Q07' AS Consulta,
       predio.codigo_predio AS CodigoPredio, predio.nombre AS Predio,
       lote.codigo_lote AS CodigoLote, lote.nombre AS Lote, lote.area_ha AS AreaLoteHa
FROM dbo.Lote AS lote
JOIN dbo.Predio AS predio ON predio.id_predio = lote.id_predio
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.CicloCultivo AS ciclo WHERE ciclo.id_lote = lote.id_lote
)
ORDER BY predio.codigo_predio, lote.codigo_lote;

-- Q08. ¿Qué cultivos rinden más que el promedio de su temporada?
-- Primero sumo los kilos por ciclo. Así, al unir el resultado con el lote, su área se cuenta una vez.
;WITH ProduccionPorCiclo AS (
    SELECT cosecha.id_ciclo,
           SUM(CASE WHEN cosecha.unidad = 't' THEN cosecha.cantidad * 1000
                    ELSE cosecha.cantidad END) AS produccion_kg
    FROM dbo.Cosecha AS cosecha
    GROUP BY cosecha.id_ciclo
), RendimientoPorCultivo AS (
    -- Solo entran ciclos con cosecha. Divido los kilos totales entre el área de esos ciclos.
    SELECT ciclo.id_temporada, ciclo.id_cultivo,
           SUM(produccion.produccion_kg) AS produccion_kg, SUM(lote.area_ha) AS area_con_cosecha_ha,
           SUM(produccion.produccion_kg) / NULLIF(SUM(lote.area_ha), 0) AS rendimiento_kg_ha
    FROM ProduccionPorCiclo AS produccion
    JOIN dbo.CicloCultivo AS ciclo ON ciclo.id_ciclo = produccion.id_ciclo
    JOIN dbo.Lote AS lote ON lote.id_lote = ciclo.id_lote
    GROUP BY ciclo.id_temporada, ciclo.id_cultivo
), PromedioPorTemporada AS (
    -- AVG calcula un promedio por temporada. Cada cultivo con cosecha aporta un rendimiento.
    SELECT id_temporada, AVG(rendimiento_kg_ha) AS promedio_kg_ha
    FROM RendimientoPorCultivo
    GROUP BY id_temporada
)
-- El signo > exige que el rendimiento sea mayor. Muestro dos decimales después de comparar.
SELECT 'Q08' AS Consulta,
       temporada.codigo_temporada AS CodigoTemporada, cultivo.codigo_cultivo AS CodigoCultivo,
       cultivo.nombre AS Cultivo, rendimiento.produccion_kg AS ProduccionKg,
       rendimiento.area_con_cosecha_ha AS AreaConCosechaHa,
       CAST(rendimiento.rendimiento_kg_ha AS DECIMAL(20,2)) AS RendimientoKgHa,
       CAST(promedio.promedio_kg_ha AS DECIMAL(20,2)) AS PromedioTemporadaKgHa
FROM RendimientoPorCultivo AS rendimiento
JOIN PromedioPorTemporada AS promedio ON promedio.id_temporada = rendimiento.id_temporada
JOIN dbo.Temporada AS temporada ON temporada.id_temporada = rendimiento.id_temporada
JOIN dbo.Cultivo AS cultivo ON cultivo.id_cultivo = rendimiento.id_cultivo
WHERE rendimiento.rendimiento_kg_ha > promedio.promedio_kg_ha
ORDER BY temporada.codigo_temporada, rendimiento.rendimiento_kg_ha DESC, cultivo.codigo_cultivo;

-- Q09. ¿Qué ciclos tienen un costo de insumos superior al promedio de su temporada?
-- Multiplico la cantidad de cada consumo por el costo unitario guardado en ese consumo.
-- LEFT JOIN y COALESCE conservan los ciclos sin consumos y les asignan costo 0 para el promedio.
;WITH CostoPorCiclo AS (
    SELECT ciclo.id_ciclo, ciclo.id_temporada,
           COALESCE(SUM(consumo.cantidad * consumo.costo_unitario_aplicado), 0) AS costo_insumos
    FROM dbo.CicloCultivo AS ciclo
    LEFT JOIN dbo.Labor AS labor ON labor.id_ciclo = ciclo.id_ciclo
    LEFT JOIN dbo.ConsumoInsumo AS consumo ON consumo.id_labor = labor.id_labor
    GROUP BY ciclo.id_ciclo, ciclo.id_temporada
), PromedioPorTemporada AS (
    SELECT id_temporada, AVG(costo_insumos) AS costo_promedio
    FROM CostoPorCiclo
    GROUP BY id_temporada
)
-- Comparo el costo del ciclo con el promedio de la misma temporada antes de mostrar dos decimales.
SELECT 'Q09' AS Consulta,
       temporada.codigo_temporada AS CodigoTemporada, ciclo.id_ciclo AS IdCiclo,
       predio.codigo_predio AS CodigoPredio, lote.codigo_lote AS CodigoLote,
       cultivo.codigo_cultivo AS CodigoCultivo,
       CAST(costo.costo_insumos AS DECIMAL(20,2)) AS CostoInsumosCOP,
       CAST(promedio.costo_promedio AS DECIMAL(20,2)) AS PromedioTemporadaCOP
FROM CostoPorCiclo AS costo
JOIN PromedioPorTemporada AS promedio ON promedio.id_temporada = costo.id_temporada
JOIN dbo.CicloCultivo AS ciclo ON ciclo.id_ciclo = costo.id_ciclo
JOIN dbo.Temporada AS temporada ON temporada.id_temporada = costo.id_temporada
JOIN dbo.Lote AS lote ON lote.id_lote = ciclo.id_lote
JOIN dbo.Predio AS predio ON predio.id_predio = lote.id_predio
JOIN dbo.Cultivo AS cultivo ON cultivo.id_cultivo = ciclo.id_cultivo
WHERE costo.costo_insumos > promedio.costo_promedio
ORDER BY temporada.codigo_temporada, costo.costo_insumos DESC, ciclo.id_ciclo;

-- Q10. ¿Qué predios tienen la mayor producción en cada temporada?
-- Convierto las cosechas a kilos y las sumo por predio y temporada del ciclo.
-- HAVING filtra el grupo ya sumado. Solo comparo predios que registraron cosecha en esa temporada.
;WITH ProduccionPorPredio AS (
    SELECT lote.id_predio, ciclo.id_temporada,
           SUM(CASE WHEN cosecha.unidad = 't' THEN cosecha.cantidad * 1000
                    ELSE cosecha.cantidad END) AS produccion_kg
    FROM dbo.CicloCultivo AS ciclo
    JOIN dbo.Lote AS lote ON lote.id_lote = ciclo.id_lote
    LEFT JOIN dbo.Cosecha AS cosecha ON cosecha.id_ciclo = ciclo.id_ciclo
    GROUP BY lote.id_predio, ciclo.id_temporada
    HAVING COUNT(cosecha.id_cosecha) > 0
), MaximoPorTemporada AS (
    -- MAX encuentra el mayor total de producción de cada temporada.
    SELECT id_temporada, MAX(produccion_kg) AS maximo_kg
    FROM ProduccionPorPredio
    GROUP BY id_temporada
)
-- La condición = conserva a todos los predios cuya producción sea igual al máximo.
SELECT 'Q10' AS Consulta,
       temporada.codigo_temporada AS CodigoTemporada, temporada.nombre AS Temporada,
       predio.codigo_predio AS CodigoPredio, predio.nombre AS Predio,
       produccion.produccion_kg AS ProduccionKg
FROM ProduccionPorPredio AS produccion
JOIN MaximoPorTemporada AS maximo ON maximo.id_temporada = produccion.id_temporada
JOIN dbo.Predio AS predio ON predio.id_predio = produccion.id_predio
JOIN dbo.Temporada AS temporada ON temporada.id_temporada = produccion.id_temporada
WHERE produccion.produccion_kg = maximo.maximo_kg
ORDER BY temporada.codigo_temporada, predio.codigo_predio;

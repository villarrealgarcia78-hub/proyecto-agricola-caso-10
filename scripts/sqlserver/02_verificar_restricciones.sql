-- Paso 2. Consulto las restricciones guardadas en la base del proyecto.
-- USE selecciona la base. GO separa el bloque inicial en SSMS.
USE DNV_Caso10;
GO

-- DB_NAME devuelve el nombre de la base actual. Si es otra, detengo la consulta.
IF DB_NAME() <> N'DNV_Caso10'
    THROW 50003, N'Abre DNV_Caso10 antes de revisar las restricciones.', 1;

-- 1. Claves foráneas. OBJECT_NAME y COL_NAME muestran los nombres a partir de sus identificadores.
-- JOIN relaciona cada clave con las columnas de origen y destino.
SELECT OBJECT_NAME(clave.parent_object_id) AS TablaOrigen,
       clave.name AS ClaveForanea,
       COL_NAME(columnas.parent_object_id, columnas.parent_column_id) AS ColumnaOrigen,
       OBJECT_NAME(clave.referenced_object_id) AS TablaReferenciada,
       COL_NAME(columnas.referenced_object_id, columnas.referenced_column_id) AS ColumnaReferenciada,
       CASE WHEN clave.is_disabled = 0 THEN N'Sí' ELSE N'No' END AS Activa,
       CASE WHEN clave.is_not_trusted = 0 THEN N'Sí' ELSE N'No' END AS Validada
FROM sys.foreign_keys AS clave
JOIN sys.foreign_key_columns AS columnas ON columnas.constraint_object_id = clave.object_id
WHERE OBJECT_SCHEMA_NAME(clave.parent_object_id) = N'dbo' AND clave.is_ms_shipped = 0
ORDER BY TablaOrigen, ClaveForanea, columnas.constraint_column_id;

-- 2. Claves únicas. UQ identifica las restricciones UNIQUE. key_ordinal indica el orden de los campos.
-- STRING_AGG junta los campos en una fila por restricción, incluso cuando la clave usa dos campos.
SELECT OBJECT_NAME(clave.parent_object_id) AS Tabla,
       clave.name AS RestriccionUnica,
       STRING_AGG(COL_NAME(columnas.object_id, columnas.column_id), N', ')
           WITHIN GROUP (ORDER BY columnas.key_ordinal) AS Columnas
FROM sys.key_constraints AS clave
JOIN sys.index_columns AS columnas
    ON columnas.object_id = clave.parent_object_id AND columnas.index_id = clave.unique_index_id
WHERE clave.type = 'UQ' AND columnas.key_ordinal > 0
  AND OBJECT_SCHEMA_NAME(clave.parent_object_id) = N'dbo' AND clave.is_ms_shipped = 0
GROUP BY clave.parent_object_id, clave.name
ORDER BY Tabla, RestriccionUnica;

-- 3. Comprobaciones. definition muestra la condición. Activa y Validada describen su estado en SQL Server.
SELECT OBJECT_NAME(regla.parent_object_id) AS Tabla,
       regla.name AS Comprobacion,
       regla.definition AS Condicion,
       CASE WHEN regla.is_disabled = 0 THEN N'Sí' ELSE N'No' END AS Activa,
       CASE WHEN regla.is_not_trusted = 0 THEN N'Sí' ELSE N'No' END AS Validada
FROM sys.check_constraints AS regla
WHERE OBJECT_SCHEMA_NAME(regla.parent_object_id) = N'dbo' AND regla.is_ms_shipped = 0
ORDER BY Tabla, Comprobacion;

-- 4. Valores predeterminados. definition muestra el valor que se usa al omitir la columna.
SELECT OBJECT_NAME(valor.parent_object_id) AS Tabla,
       valor.name AS Restriccion,
       COL_NAME(valor.parent_object_id, valor.parent_column_id) AS Columna,
       valor.definition AS ValorPredeterminado
FROM sys.default_constraints AS valor
WHERE OBJECT_SCHEMA_NAME(valor.parent_object_id) = N'dbo' AND valor.is_ms_shipped = 0
ORDER BY Tabla, Columna;

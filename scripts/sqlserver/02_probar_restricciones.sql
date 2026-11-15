-- Paso 2. Pruebo las restricciones de la base con registros ficticios.
-- Uso ROLLBACK al terminar para retirar las filas de prueba.
USE DNV_Caso10;
GO

-- DB_NAME confirma la base. @@TRANCOUNT indica si ya hay una transacción abierta.
IF DB_NAME() <> N'DNV_Caso10' OR @@TRANCOUNT <> 0
BEGIN
    THROW 50004, N'Abre una consulta nueva en DNV_Caso10 antes de ejecutar la prueba.', 1;
END;

-- XACT_ABORT OFF permite continuar después de los rechazos que quiero comprobar.
SET XACT_ABORT OFF;
SET NOCOUNT ON;

-- @resultados es una variable con filas y columnas que dura mientras ejecuto este archivo.
-- ROLLBACK retira los datos de prueba de la base y me permite conservar este registro hasta el final.
DECLARE @resultados TABLE (
    numero INT,
    caso NVARCHAR(100),
    resultado_esperado NVARCHAR(100),
    resultado_obtenido NVARCHAR(4000),
    estado NVARCHAR(12)
);
DECLARE @predioUno INT, @predioDos INT, @loteUno INT;
DECLARE @cultivo INT, @temporada INT, @ciclo INT;
DECLARE @estadoInicial VARCHAR(12), @predioInexistente INT = -1;

-- Uso estos códigos solo para esta prueba. Si ya están ocupados, me detengo.
IF EXISTS (SELECT 1 FROM dbo.Predio WHERE codigo_predio IN ('DNV_P02_A', 'DNV_P02_B', 'DNV_P02_C'))
   OR EXISTS (SELECT 1 FROM dbo.Predio WHERE id_predio = @predioInexistente)
   OR EXISTS (SELECT 1 FROM dbo.Cultivo WHERE codigo_cultivo = 'DNV_P02_CULTIVO')
   OR EXISTS (SELECT 1 FROM dbo.Temporada WHERE codigo_temporada = 'DNV_P02_TEMP')
   OR EXISTS (SELECT 1 FROM dbo.Insumo WHERE codigo_insumo = 'DNV_P02_INSUMO')
BEGIN
    THROW 50005, N'Los identificadores de esta prueba ya están en uso. Revisa la base antes de continuar.', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    -- SCOPE_IDENTITY devuelve el último identificador generado por mi INSERT.
    -- Lo guardo para asociar los lotes a los predios ficticios que acabo de crear.
    INSERT INTO dbo.Predio (codigo_predio, nombre, area_ha)
    VALUES ('DNV_P02_A', N'Predio de prueba A', 12.00);
    SET @predioUno = SCOPE_IDENTITY();

    INSERT INTO dbo.Predio (codigo_predio, nombre, area_ha)
    VALUES ('DNV_P02_B', N'Predio de prueba B', 9.00);
    SET @predioDos = SCOPE_IDENTITY();

    -- 1. La clave foránea acepta un lote cuando su predio existe.
    INSERT INTO dbo.Lote (id_predio, codigo_lote, nombre, area_ha)
    VALUES (@predioUno, 'L01', N'Lote de prueba A', 2.00);
    SET @loteUno = SCOPE_IDENTITY();
    INSERT INTO @resultados VALUES (1, N'Lote con predio existente', N'Insertado', N'Insertado', N'Cumple');

    -- 2. UNIQUE permite repetir L01 cuando cambia el predio.
    INSERT INTO dbo.Lote (id_predio, codigo_lote, nombre, area_ha)
    VALUES (@predioDos, 'L01', N'Lote de prueba B', 3.00);
    INSERT INTO @resultados VALUES (2, N'Mismo código de lote en otro predio', N'Insertado', N'Insertado', N'Cumple');

    -- 3. El costo de un insumo puede ser cero. Su cantidad sigue siendo positiva.
    INSERT INTO dbo.Insumo (codigo_insumo, nombre, unidad, costo_unitario, cantidad_disponible)
    VALUES ('DNV_P02_INSUMO', N'Insumo de prueba', 'kg', 0.00, 3.000);
    INSERT INTO @resultados VALUES (3, N'Insumo con costo cero', N'Insertado', N'Insertado', N'Cumple');

    -- 4. Creo las referencias del ciclo y omito estado para comprobar DEFAULT.
    -- Uso AAAAMMDD para que SQL Server lea las fechas sin depender del idioma de SSMS.
    INSERT INTO dbo.Cultivo (codigo_cultivo, nombre)
    VALUES ('DNV_P02_CULTIVO', N'Maíz de prueba');
    SET @cultivo = SCOPE_IDENTITY();

    INSERT INTO dbo.Temporada (codigo_temporada, nombre, fecha_inicio, fecha_fin)
    VALUES ('DNV_P02_TEMP', N'Temporada de prueba', '20260101', '20260630');
    SET @temporada = SCOPE_IDENTITY();

    INSERT INTO dbo.CicloCultivo (id_lote, id_cultivo, id_temporada, fecha_inicio, fecha_fin, cantidad_sembrada, unidad_siembra)
    VALUES (@loteUno, @cultivo, @temporada, '20260201', '20260531', 100.000, 'semillas');
    SET @ciclo = SCOPE_IDENTITY();

    SELECT @estadoInicial = estado FROM dbo.CicloCultivo WHERE id_ciclo = @ciclo;
    INSERT INTO @resultados
    VALUES (4, N'Ciclo sin indicar estado', N'Activo', COALESCE(@estadoInicial, N'Sin resultado'),
            CASE WHEN @estadoInicial = 'Activo' THEN N'Cumple' ELSE N'No cumple' END);

    -- En los siguientes casos el INSERT debe fallar. CATCH recibe el error y leemos qué regla lo produjo.
    -- CHARINDEX devuelve una posición mayor que cero si encuentra el nombre esperado en el mensaje.

    -- 5. La pareja de predio y código de lote debe ser única.
    BEGIN TRY
        INSERT INTO dbo.Lote (id_predio, codigo_lote, nombre, area_ha)
        VALUES (@predioUno, 'L01', N'Lote duplicado de prueba', 2.00);
        INSERT INTO @resultados VALUES (5, N'Lote repetido en el mismo predio', N'Rechazado', N'Insertado', N'No cumple');
    END TRY
    BEGIN CATCH
        INSERT INTO @resultados
        VALUES (5, N'Lote repetido en el mismo predio', N'Rechazado por UQ_Lote_predio_codigo', ERROR_MESSAGE(),
                CASE WHEN ERROR_NUMBER() = 2627 AND CHARINDEX(N'UQ_Lote_predio_codigo', ERROR_MESSAGE()) > 0
                     THEN N'Cumple' ELSE N'No cumple' END);
    END CATCH;

    -- 6. Un lote requiere un predio existente.
    BEGIN TRY
        INSERT INTO dbo.Lote (id_predio, codigo_lote, nombre, area_ha)
        VALUES (@predioInexistente, 'L02', N'Lote sin predio de prueba', 2.00);
        INSERT INTO @resultados VALUES (6, N'Lote con predio inexistente', N'Rechazado', N'Insertado', N'No cumple');
    END TRY
    BEGIN CATCH
        INSERT INTO @resultados
        VALUES (6, N'Lote con predio inexistente', N'Rechazado por FK_Lote_Predio', ERROR_MESSAGE(),
                CASE WHEN ERROR_NUMBER() = 547 AND CHARINDEX(N'FK_Lote_Predio', ERROR_MESSAGE()) > 0
                     THEN N'Cumple' ELSE N'No cumple' END);
    END CATCH;

    -- 7. El área del predio debe ser mayor que cero.
    BEGIN TRY
        INSERT INTO dbo.Predio (codigo_predio, nombre, area_ha)
        VALUES ('DNV_P02_C', N'Predio de prueba con área cero', 0.00);
        INSERT INTO @resultados VALUES (7, N'Predio con área cero', N'Rechazado', N'Insertado', N'No cumple');
    END TRY
    BEGIN CATCH
        INSERT INTO @resultados
        VALUES (7, N'Predio con área cero', N'Rechazado por CK_Predio_area', ERROR_MESSAGE(),
                CASE WHEN ERROR_NUMBER() = 547 AND CHARINDEX(N'CK_Predio_area', ERROR_MESSAGE()) > 0
                     THEN N'Cumple' ELSE N'No cumple' END);
    END CATCH;

    -- 8. La cantidad cosechada debe ser mayor que cero.
    BEGIN TRY
        INSERT INTO dbo.Cosecha (id_ciclo, fecha, cantidad, unidad, calidad)
        VALUES (@ciclo, '20260501', 0.000, 'kg', N'Primera');
        INSERT INTO @resultados VALUES (8, N'Cosecha con cantidad cero', N'Rechazado', N'Insertado', N'No cumple');
    END TRY
    BEGIN CATCH
        INSERT INTO @resultados
        VALUES (8, N'Cosecha con cantidad cero', N'Rechazado por CK_Cosecha_cantidad', ERROR_MESSAGE(),
                CASE WHEN ERROR_NUMBER() = 547 AND CHARINDEX(N'CK_Cosecha_cantidad', ERROR_MESSAGE()) > 0
                     THEN N'Cumple' ELSE N'No cumple' END);
    END CATCH;

    -- Retiro los datos ficticios antes de mostrar la evidencia. Los números automáticos pueden quedar con saltos.
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    -- Si falla la preparación de los datos, deshago la transacción y muestro el error.
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- ORDER BY muestra los resultados en el mismo orden en que hice las pruebas.
SELECT numero AS Prueba, caso AS Caso, resultado_esperado AS Esperado,
       resultado_obtenido AS Obtenido, estado AS Estado
FROM @resultados
ORDER BY numero;

SELECT COUNT(*) AS CasosProbados,
       SUM(CASE WHEN estado = N'Cumple' THEN 1 ELSE 0 END) AS Cumplen,
       SUM(CASE WHEN estado = N'No cumple' THEN 1 ELSE 0 END) AS NoCumplen,
       (SELECT COUNT(*) FROM dbo.Predio WHERE codigo_predio IN ('DNV_P02_A', 'DNV_P02_B', 'DNV_P02_C')) AS PrediosDePruebaRestantes
FROM @resultados;

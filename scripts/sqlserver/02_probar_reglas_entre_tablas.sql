-- P03. Pruebo cómo se comportan las reglas de fechas y unidades entre tablas.
-- Cada caso usa datos ficticios propios y los retiro con ROLLBACK al terminar.
USE DNV_Caso10;
GO

-- Compruebo la base y uso una consulta sin transacciones previas.
IF DB_NAME() <> N'DNV_Caso10' OR @@TRANCOUNT <> 0
BEGIN
    THROW 50140, N'Abre una consulta nueva en DNV_Caso10 para ejecutar este archivo.', 1;
END;

SET XACT_ABORT ON;
SET NOCOUNT ON;

-- Guardo los casos junto con el número de error que espero. El cero indica que el caso debe aceptarse.
-- Una variable de tabla conserva el resumen aunque deshaga los datos ficticios con ROLLBACK.
DECLARE @pruebas TABLE (
    numero INT PRIMARY KEY,
    caso NVARCHAR(120),
    error_esperado INT,
    error_obtenido INT,
    resultado_obtenido NVARCHAR(4000),
    estado NVARCHAR(12)
);

INSERT INTO @pruebas (numero, caso, error_esperado)
VALUES (1, N'Fechas en el periodo y consumo de 2 unidades', 0),
       (2, N'Acortar temporada y dejar el ciclo fuera', 50131),
       (3, N'Mover el inicio del ciclo fuera de la temporada', 50132),
       (4, N'Mover el inicio del ciclo y dejar su labor fuera', 50133),
       (5, N'Acortar un ciclo y dejar su cosecha fuera', 50134),
       (6, N'Mover una labor a una fecha fuera de su ciclo', 50135),
       (7, N'Agregar dos cosechas juntas y que una quede fuera del ciclo', 50136),
       (8, N'Cambiar un consumo de 2 unidades a 2,5 unidades', 50137),
       (9, N'Cambiar la unidad de un insumo con consumo registrado', 50138);

DECLARE @numero INT = 1;
DECLARE @esperado INT, @obtenido INT, @mensaje NVARCHAR(4000), @datosPreparados BIT;
DECLARE @predio INT, @lote INT, @cultivo INT, @temporada INT, @ciclo INT;
DECLARE @trabajador INT, @labor INT, @insumo INT;

-- WHILE repite la preparación para cada caso. Hago una transacción nueva en cada vuelta,
-- porque el rechazo de una regla puede obligarme a deshacer la transacción completa.
WHILE @numero <= 9
BEGIN
    SELECT @esperado = error_esperado FROM @pruebas WHERE numero = @numero;
    SET @datosPreparados = 0;
    SET @obtenido = 0;
    SET @mensaje = N'SQL Server aceptó la operación.';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- SCOPE_IDENTITY devuelve el identificador que se acaba de generar.
        -- Lo guardo para enlazar los registros de este caso sin adivinar sus identificadores.
        INSERT INTO dbo.Predio (codigo_predio, nombre, area_ha) VALUES ('DNV_P03_P', N'Predio ficticio', 20);
        SET @predio = SCOPE_IDENTITY();

        INSERT INTO dbo.Lote (id_predio, codigo_lote, nombre, area_ha) VALUES (@predio, 'L01', N'Lote ficticio', 5);
        SET @lote = SCOPE_IDENTITY();

        INSERT INTO dbo.Cultivo (codigo_cultivo, nombre) VALUES ('DNV_P03_C', N'Maíz de prueba');
        SET @cultivo = SCOPE_IDENTITY();

        -- Escribo las fechas en formato AAAAMMDD para que SQL Server las lea igual en distintos idiomas.
        INSERT INTO dbo.Temporada (codigo_temporada, nombre, fecha_inicio, fecha_fin)
        VALUES ('DNV_P03_T', N'Temporada ficticia', '20260101', '20260630');
        SET @temporada = SCOPE_IDENTITY();

        INSERT INTO dbo.CicloCultivo (id_lote, id_cultivo, id_temporada, fecha_inicio, fecha_fin, cantidad_sembrada, unidad_siembra)
        VALUES (@lote, @cultivo, @temporada, '20260201', '20260531', 100, 'semillas');
        SET @ciclo = SCOPE_IDENTITY();

        INSERT INTO dbo.Trabajador (documento, nombre, funcion, estado)
        VALUES ('DNV_P03_TR', N'Trabajador de prueba', N'Siembra', 'Activo');
        SET @trabajador = SCOPE_IDENTITY();

        INSERT INTO dbo.Labor (id_ciclo, id_trabajador, tipo, fecha, duracion_horas)
        VALUES (@ciclo, @trabajador, N'Riego', '20260410', 1.50);
        SET @labor = SCOPE_IDENTITY();

        -- Uso el último día del ciclo para comprobar que una fecha en el límite sí es válida.
        INSERT INTO dbo.Cosecha (id_ciclo, fecha, cantidad, unidad, calidad)
        VALUES (@ciclo, '20260531', 400.000, 'kg', N'Primera');

        INSERT INTO dbo.Insumo (codigo_insumo, nombre, unidad, costo_unitario, cantidad_disponible)
        VALUES ('DNV_P03_I', N'Insumo de prueba', 'unidad', 2500, 10);
        SET @insumo = SCOPE_IDENTITY();

        INSERT INTO dbo.ConsumoInsumo (id_labor, id_insumo, cantidad, costo_unitario_aplicado)
        VALUES (@labor, @insumo, 2, 2500);
        SET @datosPreparados = 1;

        -- Caso 1: los datos anteriores son válidos. En los demás casos intento incumplir una regla.
        -- UPDATE cambia solo el campo que quiero comprobar. WHERE selecciona la fila de este caso.
        IF @numero = 2
            UPDATE dbo.Temporada SET fecha_fin = '20260430' WHERE id_temporada = @temporada;
        ELSE IF @numero = 3
            UPDATE dbo.CicloCultivo SET fecha_inicio = '20251231' WHERE id_ciclo = @ciclo;
        ELSE IF @numero = 4
            UPDATE dbo.CicloCultivo SET fecha_inicio = '20260411' WHERE id_ciclo = @ciclo;
        ELSE IF @numero = 5
            UPDATE dbo.CicloCultivo SET fecha_fin = '20260530' WHERE id_ciclo = @ciclo;
        ELSE IF @numero = 6
            UPDATE dbo.Labor SET fecha = '20260131' WHERE id_labor = @labor;
        ELSE IF @numero = 7
            -- En una sola operación incluyo una cosecha válida y otra que queda fuera del ciclo.
            INSERT INTO dbo.Cosecha (id_ciclo, fecha, cantidad, unidad, calidad)
            VALUES (@ciclo, '20260525', 10, 'kg', N'Primera'),
                   (@ciclo, '20260601', 10, 'kg', N'Primera');
        ELSE IF @numero = 8
            UPDATE dbo.ConsumoInsumo SET cantidad = 2.500 WHERE id_labor = @labor AND id_insumo = @insumo;
        ELSE IF @numero = 9
            UPDATE dbo.Insumo SET unidad = 'kg' WHERE id_insumo = @insumo;

        ROLLBACK TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Guardo el motivo del rechazo y cierro esta transacción antes de pasar al caso siguiente.
        SET @obtenido = ERROR_NUMBER();
        SET @mensaje = ERROR_MESSAGE();
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
    END CATCH;

    -- El caso cumple si los datos iniciales eran válidos y se obtuvo el error previsto o la aceptación.
    UPDATE @pruebas
    SET error_obtenido = @obtenido,
        resultado_obtenido = @mensaje,
        estado = CASE WHEN @datosPreparados = 1 AND @obtenido = @esperado THEN N'Cumple' ELSE N'No cumple' END
    WHERE numero = @numero;

    SET @numero = @numero + 1;
END;

-- Muestro el detalle y el resumen. Cero errores indican que SQL Server aceptó el caso.
SELECT numero AS Prueba, caso AS Caso, error_esperado AS CodigoEsperado,
       error_obtenido AS CodigoObtenido, resultado_obtenido AS Obtenido, estado AS Estado
FROM @pruebas
ORDER BY numero;

SELECT COUNT(*) AS CasosProbados,
       SUM(CASE WHEN estado = N'Cumple' THEN 1 ELSE 0 END) AS Cumplen,
       SUM(CASE WHEN estado = N'No cumple' THEN 1 ELSE 0 END) AS NoCumplen,
       (SELECT COUNT(*) FROM dbo.Predio WHERE codigo_predio = 'DNV_P03_P') AS PrediosDePruebaRestantes
FROM @pruebas;

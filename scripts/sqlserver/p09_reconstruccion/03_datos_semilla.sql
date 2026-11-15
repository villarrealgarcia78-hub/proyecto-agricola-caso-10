-- P09. Copia de 03_datos_semilla.sql para DNV_Caso10_Reconstruccion.
-- Parte II. Cargo datos ficticios para probar las consultas del caso agrícola.
-- Los códigos P04 identifican ejemplos. Todos los documentos de trabajadores son inventados.
USE DNV_Caso10_Reconstruccion;
GO

-- Reviso el nombre y la marca de la base de prueba antes de ejecutar este bloque.
IF DB_NAME() <> N'DNV_Caso10_Reconstruccion' OR NOT EXISTS (
    SELECT 1 FROM sys.extended_properties
    WHERE class = 0 AND name = N'DNV_AmbitoDePrueba'
      AND CONVERT(NVARCHAR(128), value) = N'Caso10_Reconstruccion_P09'
)
    THROW 50173, N'Este archivo requiere la base de prueba marcada por el paso 01.', 1;


-- DB_NAME() identifica la base actual y @@TRANCOUNT cuenta las transacciones abiertas.
IF DB_NAME() <> N'DNV_Caso10_Reconstruccion' OR @@TRANCOUNT <> 0
    THROW 50150, N'La carga requiere una consulta nueva en DNV_Caso10_Reconstruccion.', 1;

SET NOCOUNT ON;                -- Muestro solo las cuadrículas, sin un mensaje por cada fila.
SET IMPLICIT_TRANSACTIONS OFF;  -- Abro y cierro una sola transacción de forma explícita.
SET XACT_ABORT ON;              -- Un error durante la carga impide guardar solo una parte.

-- Cada fila de esta lista tiene una referencia de días, unidad de siembra, cantidad por hectárea
-- y kilos de cosecha por hectárea. Uso valores ilustrativos para los datos de prueba.
DECLARE @tiposCultivo TABLE (
    numero INT PRIMARY KEY, nombre NVARCHAR(40), dias INT,
    unidad VARCHAR(10), siembra_por_ha INT, cosecha_kg_por_ha INT
);

INSERT INTO @tiposCultivo VALUES
    ( 1, N'Maíz dulce',        85, 'semillas',  55000,  8000),
    ( 2, N'Maíz para grano',  120, 'semillas',  60000,  5500),
    ( 3, N'Fríjol cargamanto',110, 'kg',          55,  1800),
    ( 4, N'Fríjol negro',      95, 'kg',          65,  1600),
    ( 5, N'Fríjol rojo',      100, 'kg',          60,  1700),
    ( 6, N'Fríjol mungo',      80, 'kg',          25,  1400),
    ( 7, N'Arveja verde',      95, 'kg',          85,  4500),
    ( 8, N'Haba',             115, 'kg',         120,  4500),
    ( 9, N'Lenteja',           95, 'kg',          60,  1400),
    (10, N'Garbanzo',         115, 'kg',          90,  1500),
    (11, N'Soya',             115, 'kg',          60,  2700),
    (12, N'Sorgo',            110, 'kg',          18,  3700),
    (13, N'Arroz de secano',  120, 'kg',          85,  3500),
    (14, N'Arroz de riego',   120, 'kg',         110,  5400),
    (15, N'Cebada',           110, 'kg',         100,  3000),
    (16, N'Avena',            105, 'kg',          90,  2700),
    (17, N'Trigo',            120, 'kg',         125,  3200),
    (18, N'Quinua',           125, 'kg',          10,  2000),
    (19, N'Amaranto',         110, 'kg',           7,  1700),
    (20, N'Ajonjolí',          95, 'kg',           5,  1100),
    (21, N'Maní',             120, 'kg',          85,  2700),
    (22, N'Girasol',          110, 'semillas',  48000,  2100),
    (23, N'Papa criolla',     115, 'kg',        1800, 14000),
    (24, N'Papa pastusa',     135, 'kg',        2200, 24000),
    (25, N'Camote',           125, 'plantas',  33000, 16000),
    (26, N'Cebolla de bulbo', 125, 'plantas', 210000, 24000),
    (27, N'Cebolla larga',    105, 'plantas', 110000, 18000),
    (28, N'Zanahoria',        105, 'semillas',700000, 26000),
    (29, N'Remolacha',         90, 'semillas',270000, 22000),
    (30, N'Rábano',            45, 'semillas',700000,  9500),
    (31, N'Lechuga crespa',    65, 'plantas',  80000, 16000),
    (32, N'Lechuga romana',    75, 'plantas',  70000, 19000),
    (33, N'Acelga',            65, 'plantas',  55000, 14000),
    (34, N'Espinaca',          50, 'semillas',600000, 10000),
    (35, N'Brócoli',           90, 'plantas',  36000, 11000),
    (36, N'Coliflor',         100, 'plantas',  31000, 12000),
    (37, N'Repollo',          105, 'plantas',  35000, 20000),
    (38, N'Tomate chonto',    125, 'plantas',  22000, 34000),
    (39, N'Pepino',            75, 'semillas', 21000, 21000),
    (40, N'Calabacín',         65, 'semillas', 13000, 18000);

DECLARE @duraciones TABLE (numero INT PRIMARY KEY, nombre NVARCHAR(20), diferencia_dias INT);
INSERT INTO @duraciones VALUES
    (1, N'Muy temprano', -10), (2, N'Temprano', -5), (3, N'Intermedio', 0),
    (4, N'Tardío', 5), (5, N'Muy tardío', 10);

DECLARE @selecciones TABLE (numero INT PRIMARY KEY, nombre NVARCHAR(20), rendimiento_pct INT);
INSERT INTO @selecciones VALUES
    (1, N'Uniformidad', 94), (2, N'Tamaño', 98), (3, N'Conservación', 90),
    (4, N'Rendimiento', 110), (5, N'Calidad', 96);

-- Distingo la unidad usada para el consumo del tamaño de la presentación que ofrece el proveedor.
DECLARE @familiasInsumo TABLE (
    numero INT PRIMARY KEY, nombre NVARCHAR(35), unidad VARCHAR(6),
    labor NVARCHAR(40), costo_base INT
);
INSERT INTO @familiasInsumo VALUES
    ( 1, N'Abono orgánico',        'kg',    N'Preparación del suelo',     800),
    ( 2, N'Fertilizante granulado','kg',    N'Preparación del suelo',    4600),
    ( 3, N'Cal agrícola',          'kg',    N'Preparación del suelo',     700),
    ( 4, N'Enmienda mineral',      'kg',    N'Preparación del suelo',    1500),
    ( 5, N'Biofertilizante',       'L',     N'Aplicación de insumos',   15000),
    ( 6, N'Corrector foliar',      'L',     N'Aplicación de insumos',   19000),
    ( 7, N'Fertilizante líquido',  'L',     N'Aplicación de insumos',   13000),
    ( 8, N'Jabón agrícola',        'L',     N'Aplicación de insumos',   12000),
    ( 9, N'Trampa adhesiva',       'unidad', N'Instalación de trampas',   2200),
    (10, N'Etiqueta de parcela',   'unidad', N'Marcación de parcela',     300);

-- Uso esta lista durante la carga para relacionar cada fila con el identificador real que recibió.
DECLARE @referencias TABLE (
    numero INT PRIMARY KEY, id_lote_a INT, id_lote_b INT, id_cultivo INT,
    id_temporada INT, id_trabajador INT, id_insumo INT,
    dias INT, unidad_siembra VARCHAR(10), siembra_por_ha INT, cosecha_kg_por_ha INT
);
DECLARE @totales TABLE (orden INT, tabla NVARCHAR(25), filas INT);
DECLARE @controles TABLE (orden INT, control NVARCHAR(85), esperado INT, obtenido INT);

DECLARE @numero INT = 1, @zona INT, @periodo INT, @anio INT, @semestre INT;
DECLARE @tipo INT, @duracion INT, @seleccion INT, @dias INT;
DECLARE @codigo VARCHAR(4), @inicioTemporada DATE, @finTemporada DATE;
DECLARE @idPredio INT, @idLoteA INT, @idLoteB INT, @idCultivo INT;
DECLARE @idTemporada INT, @idTrabajador INT, @idInsumo INT;
DECLARE @areaLoteA DECIMAL(12,2), @areaLoteB DECIMAL(12,2), @areaLote DECIMAL(12,2);
DECLARE @nombreCultivo NVARCHAR(100), @unidadSiembra VARCHAR(10);
DECLARE @siembraPorHa INT, @cosechaKgPorHa INT, @cantidadSembrada DECIMAL(14,3);
DECLARE @familia INT, @proveedor INT, @presentacion INT, @nombreInsumo NVARCHAR(100);
DECLARE @unidadInsumo VARCHAR(6), @tipoLabor NVARCHAR(40), @costo DECIMAL(12,2);
DECLARE @cantidadConsumo DECIMAL(14,3), @cantidadDisponible DECIMAL(14,3);
DECLARE @posicion INT, @numeroPredio INT, @numeroCultivo INT, @numeroInsumo INT;
DECLARE @idLote INT, @idCiclo INT, @idLabor INT, @idTrabajadorAlterno INT;
DECLARE @inicioCiclo DATE, @finCiclo DATE, @fechaLabor DATE, @estado VARCHAR(12);
DECLARE @fechaReferencia DATE = '20261114';
DECLARE @cosechaTotalKg INT, @primeraCosechaKg INT, @segundaCosechaT DECIMAL(14,3);

BEGIN TRY
    BEGIN TRANSACTION;

    -- Las reglas de P03 deben estar activas antes de agregar datos.
    IF (SELECT COUNT(*) FROM sys.triggers
        WHERE is_disabled = 0 AND is_ms_shipped = 0 AND name IN (
            N'TR_Temporada_intervalo', N'TR_CicloCultivo_intervalos', N'TR_Labor_fecha',
            N'TR_Cosecha_fecha', N'TR_ConsumoInsumo_cantidad_entera', N'TR_Insumo_conservar_unidad'
        )) <> 6
        THROW 50151, N'Faltan reglas activas del paso 2. La carga se detuvo.', 1;

    -- EXISTS comprueba si hay filas. TABLOCKX y HOLDLOCK reservan cada tabla hasta terminar,
    -- para que la comprobación de que está vacía y la carga formen un solo paso.
    IF EXISTS (SELECT 1 FROM dbo.Predio WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Lote WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Cultivo WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Temporada WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Trabajador WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Insumo WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.CicloCultivo WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Labor WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Cosecha WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.ConsumoInsumo WITH (TABLOCKX, HOLDLOCK))
        THROW 50152, N'Hay tablas con datos. La carga solo se aplica a las tablas vacías del ejercicio.', 1;

    -- WHILE repite el bloque para los números 1 a 1.000. % devuelve el residuo de una división.
    -- Aquí separo 20 zonas de 50 períodos, dos semestres por año, de 2002 a 2026.
    WHILE @numero <= 1000
    BEGIN
        SET @codigo = RIGHT(CONCAT('0000', @numero), 4);
        SET @zona = (@numero - 1) / 50 + 1;
        SET @periodo = (@numero - 1) % 50;
        SET @anio = 2002 + @periodo / 2;
        SET @semestre = @periodo % 2 + 1;

        -- DATEFROMPARTS une año, mes y día. DATEADD suma o resta el intervalo indicado.
        SET @inicioTemporada = DATEFROMPARTS(@anio, 1 + (@semestre - 1) * 6, 1);
        SET @finTemporada = DATEADD(DAY, -1, DATEADD(MONTH, 6, @inicioTemporada));
        INSERT INTO dbo.Temporada (codigo_temporada, nombre, fecha_inicio, fecha_fin)
        VALUES (CONCAT('P04-T', @codigo), CONCAT(N'Zona ', @zona, N' / ', @anio, N'-S', @semestre),
                @inicioTemporada, @finTemporada);
        SET @idTemporada = SCOPE_IDENTITY();

        -- SCOPE_IDENTITY() devuelve el identificador de la fila que acabo de insertar en este bloque.
        -- El área total del predio deja espacio libre después de descontar sus dos lotes.
        SET @areaLoteA = 1.25 + (@numero % 37) * 0.25;
        SET @areaLoteB = 1.00 + (@numero % 23) * 0.25;
        -- Algunos predios vecinos usan lotes del mismo tamaño para comparar cosechas empatadas.
        IF @numero % 20 = 2
            SET @areaLoteA = 1.25 + ((@numero - 1) % 37) * 0.25;
        INSERT INTO dbo.Predio (codigo_predio, nombre, area_ha)
        VALUES (CONCAT('P04-P', @codigo), CONCAT(N'Predio ', @codigo, N' de la zona ', @zona),
                @areaLoteA + @areaLoteB + 0.50 + (@numero % 6) * 0.25);
        SET @idPredio = SCOPE_IDENTITY();

        INSERT INTO dbo.Lote (id_predio, codigo_lote, nombre, area_ha)
        VALUES (@idPredio, 'A', N'Llano', @areaLoteA);
        SET @idLoteA = SCOPE_IDENTITY();
        INSERT INTO dbo.Lote (id_predio, codigo_lote, nombre, area_ha)
        VALUES (@idPredio, 'B', N'Ladera', @areaLoteB);
        SET @idLoteB = SCOPE_IDENTITY();

        -- Combino 40 tipos agrícolas con cinco duraciones y cinco características de selección.
        -- Cada nombre describe una variedad ficticia. CROSS JOIN combina las tres listas y WHERE
        -- selecciona la combinación de este número. Cada combinación cambia la duración o el rendimiento.
        SET @tipo = (@numero - 1) / 25 + 1;
        SET @duracion = ((@numero - 1) % 25) / 5 + 1;
        SET @seleccion = (@numero - 1) % 5 + 1;

        SELECT @nombreCultivo = CONCAT(cultivo.nombre, N' / ', duracion.nombre, N' / ', seleccion.nombre),
               @dias = cultivo.dias + duracion.diferencia_dias,
               @unidadSiembra = cultivo.unidad,
               @siembraPorHa = cultivo.siembra_por_ha,
               @cosechaKgPorHa = cultivo.cosecha_kg_por_ha * seleccion.rendimiento_pct / 100
        FROM @tiposCultivo AS cultivo
        CROSS JOIN @duraciones AS duracion
        CROSS JOIN @selecciones AS seleccion
        WHERE cultivo.numero = @tipo AND duracion.numero = @duracion AND seleccion.numero = @seleccion;

        INSERT INTO dbo.Cultivo (codigo_cultivo, nombre)
        VALUES (CONCAT('P04-C', @codigo), @nombreCultivo);
        SET @idCultivo = SCOPE_IDENTITY();

        -- CASE elige una función o un estado según el número del trabajador ficticio.
        INSERT INTO dbo.Trabajador (documento, nombre, funcion, estado)
        VALUES (CONCAT('P04-DOC-', @codigo), CONCAT(N'Trabajador de campo ', @codigo),
                CASE @numero % 3 WHEN 0 THEN N'Operación de campo'
                                 WHEN 1 THEN N'Apoyo de campo' ELSE N'Supervisión de campo' END,
                CASE WHEN @numero % 50 >= 1 AND @numero % 50 <= 4
                     THEN 'Inactivo' ELSE 'Activo' END);
        SET @idTrabajador = SCOPE_IDENTITY();

        -- Diez familias, diez proveedores ficticios y diez presentaciones por proveedor.
        SET @familia = (@numero - 1) % 10 + 1;
        SET @proveedor = (@numero - 1) / 100 + 1;
        SELECT @unidadInsumo = unidad, @nombreInsumo = nombre, @costo = costo_base
        FROM @familiasInsumo WHERE numero = @familia;
        SET @presentacion = ((@numero - 1) % 100) / 10 + 1;
        SET @presentacion = CASE WHEN @unidadInsumo = 'L' THEN @presentacion
                                 WHEN @unidadInsumo = 'kg' THEN @presentacion * 5
                                 ELSE @presentacion * 10 END;
        SET @cantidadDisponible = @presentacion * (20 + @proveedor);

        INSERT INTO dbo.Insumo (codigo_insumo, nombre, unidad, costo_unitario, cantidad_disponible)
        VALUES (CONCAT('P04-I', @codigo),
                CONCAT(@nombreInsumo, N' / proveedor ', @proveedor, N' / paquete ', @presentacion, N' ', @unidadInsumo),
                @unidadInsumo, @costo + @proveedor * 30 + @presentacion, @cantidadDisponible);
        SET @idInsumo = SCOPE_IDENTITY();

        INSERT INTO @referencias VALUES
            (@numero, @idLoteA, @idLoteB, @idCultivo, @idTemporada, @idTrabajador,
             @idInsumo, @dias, @unidadSiembra, @siembraPorHa, @cosechaKgPorHa);

        SET @numero = @numero + 1;
    END;

    -- Cargo dos ciclos por temporada, en dos predios de la misma zona.
    -- El segundo predio es el siguiente de la zona. Al llegar al último, vuelvo al primero.
    SET @numero = 1;
    WHILE @numero <= 1000
    BEGIN
        SET @periodo = (@numero - 1) % 50;
        SET @posicion = 1;
        SELECT @idTemporada = id_temporada FROM @referencias WHERE numero = @numero;
        SELECT @inicioTemporada = fecha_inicio FROM dbo.Temporada WHERE id_temporada = @idTemporada;

        WHILE @posicion <= 2
        BEGIN
            SET @numeroPredio = @numero;
            IF @posicion = 2
                SET @numeroPredio = CASE WHEN @periodo = 49 THEN @numero - 49 ELSE @numero + 1 END;

            -- Uso el lote de ladera en algunos predios y dejo otros lotes sin ciclos para las consultas.
            SELECT @idLote = CASE WHEN @posicion = 2 AND @numero % 4 = 0 THEN id_lote_b ELSE id_lote_a END,
                   @idTrabajador = id_trabajador
            FROM @referencias WHERE numero = @numeroPredio;
            SELECT @areaLote = area_ha FROM dbo.Lote WHERE id_lote = @idLote;

            -- En parte de las temporadas los dos predios siembran la misma variedad.
            -- En las demás uso una variedad de otro tipo para comparar producciones y rendimientos.
            SET @numeroCultivo = @numero;
            IF @posicion = 2 AND @numero % 20 <> 1
                SET @numeroCultivo = (@numero + 124) % 1000 + 1;

            SELECT @idCultivo = id_cultivo, @dias = dias, @unidadSiembra = unidad_siembra,
                   @siembraPorHa = siembra_por_ha, @cosechaKgPorHa = cosecha_kg_por_ha
            FROM @referencias WHERE numero = @numeroCultivo;

            SET @inicioCiclo = DATEADD(DAY, 5 + @posicion * 3 + @numero % 7, @inicioTemporada);
            SET @finCiclo = DATEADD(DAY, @dias, @inicioCiclo);

            -- En el último semestre dejo un ciclo en curso por zona. La fecha de referencia
            -- del conjunto es fija para poder repetir los resultados del ejercicio.
            IF @periodo = 49 AND @posicion = 2
            BEGIN
                SET @finCiclo = '20261208';
                SET @inicioCiclo = DATEADD(DAY, -@dias, @finCiclo);
                SELECT @idTrabajador = id_trabajador FROM @referencias WHERE numero = @numero;
            END;

            SET @estado = CASE WHEN @finCiclo > @fechaReferencia THEN 'Activo'
                               WHEN @posicion = 2 AND @numero % 10 = 0 THEN 'Cancelado'
                               ELSE 'Finalizado' END;
            IF @estado = 'Cancelado'
                SET @finCiclo = DATEADD(DAY, 15, @inicioCiclo);

            -- ROUND con cero decimales deja enteras las cantidades medidas en semillas o plantas.
            SET @cantidadSembrada = @areaLote * @siembraPorHa;
            IF @unidadSiembra <> 'kg'
                SET @cantidadSembrada = ROUND(@cantidadSembrada, 0);

            INSERT INTO dbo.CicloCultivo (id_lote, id_cultivo, id_temporada, fecha_inicio, fecha_fin,
                                         cantidad_sembrada, unidad_siembra, estado)
            VALUES (@idLote, @idCultivo, @idTemporada, @inicioCiclo, @finCiclo,
                    @cantidadSembrada, @unidadSiembra, @estado);
            SET @idCiclo = SCOPE_IDENTITY();

            -- Siembro al comienzo y registro un riego unos días después. Estas dos labores
            -- quedan sin insumos registrados y sirven para probar que sigan apareciendo al consultar.
            SET @idTrabajadorAlterno = @idTrabajador;
            IF @estado <> 'Activo'
                SELECT @idTrabajadorAlterno = id_trabajador FROM @referencias WHERE numero = @numero;

            INSERT INTO dbo.Labor (id_ciclo, id_trabajador, tipo, fecha, duracion_horas)
            VALUES (@idCiclo, @idTrabajador, N'Siembra', DATEADD(DAY, 2, @inicioCiclo), 2 + @areaLote / 2),
                   (@idCiclo, @idTrabajadorAlterno, N'Riego', DATEADD(DAY, 6, @inicioCiclo), 1 + @areaLote / 4);

            -- Alterno kilos, litros y unidades en las labores con consumo. Uso los primeros
            -- 900 insumos y dejo los otros 100 disponibles para probar la consulta de insumos sin uso.
            IF @posicion = 1
            BEGIN
                SET @numeroInsumo = (@numero - 1) % 900 + 1;
                SET @familia = (@numeroInsumo - 1) % 10 + 1;
                SELECT @tipoLabor = labor FROM @familiasInsumo WHERE numero = @familia;
                SELECT @idInsumo = id_insumo FROM @referencias WHERE numero = @numeroInsumo;
                SELECT @unidadInsumo = unidad, @costo = costo_unitario FROM dbo.Insumo WHERE id_insumo = @idInsumo;
                SET @fechaLabor = CASE WHEN @familia <= 4 THEN @inicioCiclo ELSE DATEADD(DAY, 8, @inicioCiclo) END;

                INSERT INTO dbo.Labor (id_ciclo, id_trabajador, tipo, fecha, duracion_horas)
                VALUES (@idCiclo, @idTrabajador, @tipoLabor, @fechaLabor, 1.50 + @areaLote / 3);
                SET @idLabor = SCOPE_IDENTITY();

                SET @cantidadConsumo = CASE @unidadInsumo WHEN 'kg' THEN 6 + @areaLote * 2
                                                         WHEN 'L' THEN 1 + @areaLote / 2
                                                         ELSE 4 + @numero % 12 END;
                -- El precio que guardo en el consumo corresponde a la labor de ese momento.
                IF YEAR(@fechaLabor) < 2025
                    SET @costo = @costo * 0.90;

                INSERT INTO dbo.ConsumoInsumo (id_labor, id_insumo, cantidad, costo_unitario_aplicado)
                VALUES (@idLabor, @idInsumo, @cantidadConsumo, @costo);

                -- En algunas labores registro otra presentación de la misma familia.
                -- El salto de 10 mantiene la familia y cambia el código del insumo.
                IF @numero % 4 = 0
                BEGIN
                    SET @numeroInsumo = (@numeroInsumo + 9) % 900 + 1;
                    SELECT @idInsumo = id_insumo FROM @referencias WHERE numero = @numeroInsumo;
                    SELECT @costo = costo_unitario FROM dbo.Insumo WHERE id_insumo = @idInsumo;
                    IF YEAR(@fechaLabor) < 2025
                        SET @costo = @costo * 0.90;

                    INSERT INTO dbo.ConsumoInsumo (id_labor, id_insumo, cantidad, costo_unitario_aplicado)
                    VALUES (@idLabor, @idInsumo, @cantidadConsumo, @costo);
                END;
            END;

            -- Un ciclo finalizado registra dos recolecciones en fechas distintas. Divido los kilos
            -- de la segunda entre 1.000, con decimal, para guardar esa parte en toneladas.
            IF @estado = 'Finalizado'
            BEGIN
                SET @cosechaTotalKg = ROUND(@cosechaKgPorHa * @areaLote * (90 + @numero % 19) / 100, 0);
                -- Cuando los lotes tienen la misma área y variedad, el cálculo deja empatados los predios.
                SET @primeraCosechaKg = @cosechaTotalKg * 65 / 100;
                SET @segundaCosechaT = (@cosechaTotalKg - @primeraCosechaKg) / 1000.0;
                INSERT INTO dbo.Cosecha (id_ciclo, fecha, cantidad, unidad, calidad)
                VALUES (@idCiclo, DATEADD(DAY, -7, @finCiclo), @primeraCosechaKg, 'kg', N'Primera'),
                       (@idCiclo, @finCiclo, @segundaCosechaT, 't',
                        CASE WHEN @numero % 9 = 0 THEN N'Industrial' ELSE N'Segunda' END);
            END;

            SET @posicion = @posicion + 1;
        END;
        SET @numero = @numero + 1;
    END;

    -- COUNT(*) cuenta las filas de cada tabla y UNION ALL reúne los diez conteos.
    INSERT INTO @totales
    SELECT 1, N'Predio', COUNT(*) FROM dbo.Predio
    UNION ALL SELECT 2, N'Lote', COUNT(*) FROM dbo.Lote
    UNION ALL SELECT 3, N'Cultivo', COUNT(*) FROM dbo.Cultivo
    UNION ALL SELECT 4, N'Temporada', COUNT(*) FROM dbo.Temporada
    UNION ALL SELECT 5, N'CicloCultivo', COUNT(*) FROM dbo.CicloCultivo
    UNION ALL SELECT 6, N'Trabajador', COUNT(*) FROM dbo.Trabajador
    UNION ALL SELECT 7, N'Labor', COUNT(*) FROM dbo.Labor
    UNION ALL SELECT 8, N'Insumo', COUNT(*) FROM dbo.Insumo
    UNION ALL SELECT 9, N'ConsumoInsumo', COUNT(*) FROM dbo.ConsumoInsumo
    UNION ALL SELECT 10, N'Cosecha', COUNT(*) FROM dbo.Cosecha;

    -- Reviso relaciones y fechas con JOIN. NOT EXISTS comprueba que no haya un registro asociado.
    -- En estas filas el número esperado puede ser cero o una cantidad que preparé para las consultas.
    INSERT INTO @controles
    SELECT 1, N'Tablas con menos de 1000 filas', 0, COUNT(*) FROM @totales WHERE filas < 1000
    UNION ALL
    SELECT 2, N'Ciclos por fuera de su temporada', 0, COUNT(*)
    FROM dbo.CicloCultivo AS ciclo JOIN dbo.Temporada AS temporada ON ciclo.id_temporada = temporada.id_temporada
    WHERE ciclo.fecha_inicio < temporada.fecha_inicio OR ciclo.fecha_fin > temporada.fecha_fin
    UNION ALL
    SELECT 3, N'Labores fuera de su ciclo o posteriores a la fecha de referencia', 0, COUNT(*)
    FROM dbo.Labor AS labor JOIN dbo.CicloCultivo AS ciclo ON labor.id_ciclo = ciclo.id_ciclo
    WHERE labor.fecha < ciclo.fecha_inicio OR labor.fecha > ciclo.fecha_fin OR labor.fecha > @fechaReferencia
    UNION ALL
    SELECT 4, N'Cosechas fuera de su ciclo o de ciclos sin finalizar', 0, COUNT(*)
    FROM dbo.Cosecha AS cosecha JOIN dbo.CicloCultivo AS ciclo ON cosecha.id_ciclo = ciclo.id_ciclo
    WHERE cosecha.fecha < ciclo.fecha_inicio OR cosecha.fecha > ciclo.fecha_fin
       OR cosecha.fecha > @fechaReferencia OR ciclo.estado <> 'Finalizado'
    UNION ALL
    SELECT 5, N'Consumos en unidades con cantidad decimal', 0, COUNT(*)
    FROM dbo.ConsumoInsumo AS consumo JOIN dbo.Insumo AS insumo ON consumo.id_insumo = insumo.id_insumo
    WHERE insumo.unidad = 'unidad' AND consumo.cantidad <> FLOOR(consumo.cantidad)
    UNION ALL
    SELECT 6, N'Temporadas sin dos predios con ciclos', 0, COUNT(*)
    FROM dbo.Temporada AS temporada
    WHERE (SELECT COUNT(DISTINCT lote.id_predio)
           FROM dbo.CicloCultivo AS ciclo JOIN dbo.Lote AS lote ON ciclo.id_lote = lote.id_lote
           WHERE ciclo.id_temporada = temporada.id_temporada) <> 2
    UNION ALL
    SELECT 7, N'Lotes sin ciclos', 750, COUNT(*) FROM dbo.Lote AS lote
    WHERE NOT EXISTS (SELECT 1 FROM dbo.CicloCultivo AS ciclo WHERE ciclo.id_lote = lote.id_lote)
    UNION ALL
    SELECT 8, N'Insumos nunca usados', 100, COUNT(*) FROM dbo.Insumo AS insumo
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ConsumoInsumo AS consumo WHERE consumo.id_insumo = insumo.id_insumo)
    UNION ALL
    SELECT 9, N'Labores sin consumo registrado', 4000, COUNT(*) FROM dbo.Labor AS labor
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ConsumoInsumo AS consumo WHERE consumo.id_labor = labor.id_labor)
    UNION ALL
    SELECT 10, N'Predios con lotes que suman más que el área del predio', 0, COUNT(*)
    FROM dbo.Predio AS predio
    WHERE predio.area_ha < (SELECT SUM(lote.area_ha) FROM dbo.Lote AS lote WHERE lote.id_predio = predio.id_predio);

    -- COMMIT guarda todo solo cuando las comprobaciones coinciden con lo esperado.
    IF EXISTS (SELECT 1 FROM @controles WHERE esperado <> obtenido)
    BEGIN
        SELECT control AS Control, esperado AS Esperado, obtenido AS Obtenido
        FROM @controles WHERE esperado <> obtenido ORDER BY orden;
        THROW 50153, N'Una comprobación de P04 no coincidió. No se guardó la carga.', 1;
    END;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Si hay una transacción abierta, ROLLBACK deshace la carga. THROW devuelve el error original.
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Cuando la carga se guarda, estas dos cuadrículas muestran los conteos y los controles de P04.
SELECT tabla AS Tabla, filas AS Filas, 1000 AS Minimo FROM @totales ORDER BY orden;
SELECT control AS Control, esperado AS Esperado, obtenido AS Obtenido FROM @controles ORDER BY orden;

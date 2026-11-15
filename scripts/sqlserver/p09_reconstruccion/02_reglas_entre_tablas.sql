-- P09. Copia de 02_reglas_entre_tablas.sql para DNV_Caso10_Reconstruccion.
-- Paso 2. Valido las reglas que necesitan consultar datos de otra tabla.
-- R03, R05, R07 y R08 se refieren a reglas del caso. D04 y D07 son decisiones del diseño.
USE DNV_Caso10_Reconstruccion;
GO

-- Reviso el nombre y la marca de la base de prueba antes de ejecutar este bloque.
IF DB_NAME() <> N'DNV_Caso10_Reconstruccion' OR NOT EXISTS (
    SELECT 1 FROM sys.extended_properties
    WHERE class = 0 AND name = N'DNV_AmbitoDePrueba'
      AND CONVERT(NVARCHAR(128), value) = N'Caso10_Reconstruccion_P09'
)
    THROW 50173, N'Este archivo requiere la base de prueba marcada por el paso 01.', 1;


-- Compruebo la base actual y abro una transacción propia para instalar las seis reglas juntas.
IF DB_NAME() <> N'DNV_Caso10_Reconstruccion' OR @@TRANCOUNT <> 0
BEGIN
    THROW 50130, N'Abre una consulta nueva en DNV_Caso10_Reconstruccion antes de ejecutar este archivo.', 1;
END;

SET XACT_ABORT ON;
SET NOCOUNT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    -- Instalo las reglas antes de cargar datos. Si ya hay filas, primero debo revisarlas.
    -- TABLOCKX mantiene la tabla reservada para esta instalación hasta terminar la transacción.
    IF EXISTS (SELECT 1 FROM dbo.Temporada WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.CicloCultivo WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Labor WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Cosecha WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.Insumo WITH (TABLOCKX, HOLDLOCK))
       OR EXISTS (SELECT 1 FROM dbo.ConsumoInsumo WITH (TABLOCKX, HOLDLOCK))
    BEGIN
        THROW 50139, N'Hay datos en tablas relacionadas. Revísalos antes de instalar estas reglas.', 1;
    END;

    -- Un trigger es una regla que SQL Server ejecuta al agregar o modificar registros.
    -- AFTER indica cuándo se comprueban los datos. Si THROW señala un problema, el cambio falla.
    -- inserted contiene todas las filas nuevas o modificadas. EXISTS detecta si alguna incumple.
    -- UPDLOCK y HOLDLOCK mantienen los datos relacionados apartados de cambios simultáneos
    -- hasta terminar la transacción. Así la regla trabaja con datos que no cambian durante la revisión.
    -- EXEC ejecuta cada CREATE TRIGGER como un bloque separado. Dentro de ese texto uso dos comillas
    -- cuando necesito escribir una comilla en el código que se guarda.

    EXEC(N'CREATE TRIGGER dbo.TR_Temporada_intervalo
ON dbo.Temporada
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- D07. Si cambio una temporada, sus ciclos deben seguir dentro de sus fechas.
    IF EXISTS (
        SELECT 1
        FROM inserted AS temporada
        JOIN dbo.CicloCultivo AS ciclo WITH (UPDLOCK, HOLDLOCK) ON ciclo.id_temporada = temporada.id_temporada
        WHERE ciclo.fecha_inicio < temporada.fecha_inicio OR ciclo.fecha_fin > temporada.fecha_fin
    )
    BEGIN
        THROW 50131, N''El cambio de temporada dejaría un ciclo fuera de sus fechas.'', 1;
    END;
END;');

    EXEC(N'CREATE TRIGGER dbo.TR_CicloCultivo_intervalos
ON dbo.CicloCultivo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- R03 y D07. Las fechas del ciclo deben quedar dentro de su temporada.
    IF EXISTS (
        SELECT 1
        FROM inserted AS ciclo
        JOIN dbo.Temporada AS temporada WITH (UPDLOCK, HOLDLOCK) ON temporada.id_temporada = ciclo.id_temporada
        WHERE ciclo.fecha_inicio < temporada.fecha_inicio OR ciclo.fecha_fin > temporada.fecha_fin
    )
    BEGIN
        THROW 50132, N''Las fechas del ciclo deben quedar dentro de su temporada.'', 1;
    END;

    -- D07. Si cambio un ciclo, sus labores y cosechas deben seguir dentro de sus fechas.
    IF EXISTS (
        SELECT 1
        FROM inserted AS ciclo
        JOIN dbo.Labor AS labor WITH (UPDLOCK, HOLDLOCK) ON labor.id_ciclo = ciclo.id_ciclo
        WHERE labor.fecha < ciclo.fecha_inicio OR labor.fecha > ciclo.fecha_fin
    )
    BEGIN
        THROW 50133, N''El cambio de ciclo dejaría una labor fuera de sus fechas.'', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS ciclo
        JOIN dbo.Cosecha AS cosecha WITH (UPDLOCK, HOLDLOCK) ON cosecha.id_ciclo = ciclo.id_ciclo
        WHERE cosecha.fecha < ciclo.fecha_inicio OR cosecha.fecha > ciclo.fecha_fin
    )
    BEGIN
        THROW 50134, N''El cambio de ciclo dejaría una cosecha fuera de sus fechas.'', 1;
    END;
END;');

    EXEC(N'CREATE TRIGGER dbo.TR_Labor_fecha
ON dbo.Labor
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- R05 y D07. La fecha de la labor debe quedar dentro del ciclo que le asigno.
    IF EXISTS (
        SELECT 1
        FROM inserted AS labor
        JOIN dbo.CicloCultivo AS ciclo WITH (UPDLOCK, HOLDLOCK) ON ciclo.id_ciclo = labor.id_ciclo
        WHERE labor.fecha < ciclo.fecha_inicio OR labor.fecha > ciclo.fecha_fin
    )
    BEGIN
        THROW 50135, N''La fecha de la labor debe quedar dentro de su ciclo.'', 1;
    END;
END;');

    EXEC(N'CREATE TRIGGER dbo.TR_Cosecha_fecha
ON dbo.Cosecha
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- R08 y D07. La fecha de la cosecha debe quedar dentro del ciclo que le asigno.
    IF EXISTS (
        SELECT 1
        FROM inserted AS cosecha
        JOIN dbo.CicloCultivo AS ciclo WITH (UPDLOCK, HOLDLOCK) ON ciclo.id_ciclo = cosecha.id_ciclo
        WHERE cosecha.fecha < ciclo.fecha_inicio OR cosecha.fecha > ciclo.fecha_fin
    )
    BEGIN
        THROW 50136, N''La fecha de la cosecha debe quedar dentro de su ciclo.'', 1;
    END;
END;');

    EXEC(N'CREATE TRIGGER dbo.TR_ConsumoInsumo_cantidad_entera
ON dbo.ConsumoInsumo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- R07 y D04. Si el insumo se mide por unidad, el consumo se registra en enteros.
    -- FLOOR da el entero hacia abajo. Un valor con decimales es distinto de ese entero.
    IF EXISTS (
        SELECT 1
        FROM inserted AS consumo
        JOIN dbo.Insumo AS insumo WITH (UPDLOCK, HOLDLOCK) ON insumo.id_insumo = consumo.id_insumo
        WHERE insumo.unidad = ''unidad'' AND consumo.cantidad <> FLOOR(consumo.cantidad)
    )
    BEGIN
        THROW 50137, N''El consumo de un insumo medido por unidad debe ser entero.'', 1;
    END;
END;');

    EXEC(N'CREATE TRIGGER dbo.TR_Insumo_conservar_unidad
ON dbo.Insumo
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- D04. inserted trae el valor nuevo y deleted trae el valor anterior de cada insumo.
    -- Conservo la unidad de un insumo cuando ya hay consumos que dependen de ella.
    IF EXISTS (
        SELECT 1
        FROM inserted AS insumo_nuevo
        JOIN deleted AS insumo_anterior ON insumo_anterior.id_insumo = insumo_nuevo.id_insumo
        JOIN dbo.ConsumoInsumo AS consumo WITH (UPDLOCK, HOLDLOCK) ON consumo.id_insumo = insumo_nuevo.id_insumo
        WHERE insumo_nuevo.unidad <> insumo_anterior.unidad
    )
    BEGIN
        THROW 50138, N''La unidad no puede cambiar porque el insumo ya tiene consumos.'', 1;
    END;
END;');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- ROLLBACK deshace esta instalación si una de las reglas no se pudo crear.
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- sys.triggers muestra los triggers instalados. Activa indica si SQL Server ejecuta la regla.
SELECT OBJECT_NAME(regla.parent_id) AS Tabla,
       regla.name AS ReglaEntreTablas,
       CASE WHEN regla.is_disabled = 0 THEN N'Sí' ELSE N'No' END AS Activa
FROM sys.triggers AS regla
WHERE OBJECT_SCHEMA_NAME(regla.parent_id) = N'dbo'
  AND regla.name IN (
      N'TR_Temporada_intervalo', N'TR_CicloCultivo_intervalos', N'TR_Labor_fecha',
      N'TR_Cosecha_fecha', N'TR_ConsumoInsumo_cantidad_entera', N'TR_Insumo_conservar_unidad'
  )
ORDER BY Tabla, ReglaEntreTablas;

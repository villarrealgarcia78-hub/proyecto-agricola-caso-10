-- P09. Copia de 02_restricciones_y_reglas.sql para DNV_Caso10_Reconstruccion.
-- Caso 10. Aplico las relaciones y las reglas que SQL Server puede comprobar en cada tabla.
-- Las reglas que comparan fechas o unidades entre tablas se aplican antes de cargar datos.
USE DNV_Caso10_Reconstruccion;
GO

-- Reviso el nombre y la marca de la base de prueba antes de ejecutar este bloque.
IF DB_NAME() <> N'DNV_Caso10_Reconstruccion' OR NOT EXISTS (
    SELECT 1 FROM sys.extended_properties
    WHERE class = 0 AND name = N'DNV_AmbitoDePrueba'
      AND CONVERT(NVARCHAR(128), value) = N'Caso10_Reconstruccion_P09'
)
    THROW 50173, N'Este archivo requiere la base de prueba marcada por el paso 01.', 1;


-- DB_NAME devuelve la base seleccionada. Detengo el script si no es la del proyecto.
IF DB_NAME() <> N'DNV_Caso10_Reconstruccion'
BEGIN
    THROW 50001, N'Este script se debe ejecutar en DNV_Caso10_Reconstruccion.', 1;
END;

-- Aplico los cambios juntos. Si un bloque falla, ROLLBACK deshace los cambios de este archivo.
-- WITH CHECK hace que SQL Server compruebe también los datos que ya estén guardados.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    -- R01. UNIQUE impide repetir el código. CHECK rechaza áreas de cero o negativas.
    -- LTRIM y RTRIM quitan espacios al inicio y al final para comprobar si queda texto.
    ALTER TABLE dbo.Predio WITH CHECK ADD
        CONSTRAINT UQ_Predio_codigo UNIQUE (codigo_predio),
        CONSTRAINT CK_Predio_textos CHECK (LTRIM(RTRIM(codigo_predio)) <> '' AND LTRIM(RTRIM(nombre)) <> N''),
        CONSTRAINT CK_Predio_area CHECK (area_ha > 0);

    -- R01. FOREIGN KEY comprueba que el predio exista. El código se puede repetir en otro predio.
    ALTER TABLE dbo.Lote WITH CHECK ADD
        CONSTRAINT FK_Lote_Predio FOREIGN KEY (id_predio) REFERENCES dbo.Predio(id_predio),
        CONSTRAINT UQ_Lote_predio_codigo UNIQUE (id_predio, codigo_lote),
        CONSTRAINT CK_Lote_textos CHECK (LTRIM(RTRIM(codigo_lote)) <> '' AND LTRIM(RTRIM(nombre)) <> N''),
        CONSTRAINT CK_Lote_area CHECK (area_ha > 0);

    -- R02. Cada código identifica un tipo de cultivo distinto.
    ALTER TABLE dbo.Cultivo WITH CHECK ADD
        CONSTRAINT UQ_Cultivo_codigo UNIQUE (codigo_cultivo),
        CONSTRAINT CK_Cultivo_textos CHECK (LTRIM(RTRIM(codigo_cultivo)) <> '' AND LTRIM(RTRIM(nombre)) <> N'');

    -- R02 y R09. Admito que la fecha de inicio y la final sean el mismo día.
    ALTER TABLE dbo.Temporada WITH CHECK ADD
        CONSTRAINT UQ_Temporada_codigo UNIQUE (codigo_temporada),
        CONSTRAINT CK_Temporada_textos CHECK (LTRIM(RTRIM(codigo_temporada)) <> '' AND LTRIM(RTRIM(nombre)) <> N''),
        CONSTRAINT CK_Temporada_fechas CHECK (fecha_fin >= fecha_inicio);

    -- R03 y R09. Los tres registros relacionados deben existir. IN limita los valores permitidos.
    -- FLOOR devuelve el entero hacia abajo. Si cuento semillas o plantas, la cantidad debe ser igual a ese entero.
    -- DEFAULT asigna Activo cuando agrego un ciclo sin escribir su estado.
    ALTER TABLE dbo.CicloCultivo WITH CHECK ADD
        CONSTRAINT FK_CicloCultivo_Lote FOREIGN KEY (id_lote) REFERENCES dbo.Lote(id_lote),
        CONSTRAINT FK_CicloCultivo_Cultivo FOREIGN KEY (id_cultivo) REFERENCES dbo.Cultivo(id_cultivo),
        CONSTRAINT FK_CicloCultivo_Temporada FOREIGN KEY (id_temporada) REFERENCES dbo.Temporada(id_temporada),
        CONSTRAINT CK_CicloCultivo_fechas CHECK (fecha_fin >= fecha_inicio),
        CONSTRAINT CK_CicloCultivo_cantidad CHECK (cantidad_sembrada > 0),
        CONSTRAINT CK_CicloCultivo_unidad CHECK (unidad_siembra IN ('semillas', 'plantas', 'kg')),
        CONSTRAINT CK_CicloCultivo_cantidad_entera CHECK (unidad_siembra = 'kg' OR cantidad_sembrada = FLOOR(cantidad_sembrada)),
        CONSTRAINT CK_CicloCultivo_estado CHECK (estado IN ('Activo', 'Finalizado', 'Cancelado')),
        CONSTRAINT DF_CicloCultivo_estado DEFAULT ('Activo') FOR estado;

    -- R04. El documento distingue a cada trabajador y su estado indica si está activo.
    ALTER TABLE dbo.Trabajador WITH CHECK ADD
        CONSTRAINT UQ_Trabajador_documento UNIQUE (documento),
        CONSTRAINT CK_Trabajador_textos CHECK (LTRIM(RTRIM(documento)) <> '' AND LTRIM(RTRIM(nombre)) <> N'' AND LTRIM(RTRIM(funcion)) <> N''),
        CONSTRAINT CK_Trabajador_estado CHECK (estado IN ('Activo', 'Inactivo'));

    -- R05. Cada labor tiene un ciclo y un trabajador. La duración en horas debe ser positiva.
    ALTER TABLE dbo.Labor WITH CHECK ADD
        CONSTRAINT FK_Labor_CicloCultivo FOREIGN KEY (id_ciclo) REFERENCES dbo.CicloCultivo(id_ciclo),
        CONSTRAINT FK_Labor_Trabajador FOREIGN KEY (id_trabajador) REFERENCES dbo.Trabajador(id_trabajador),
        CONSTRAINT CK_Labor_tipo CHECK (LTRIM(RTRIM(tipo)) <> N''),
        CONSTRAINT CK_Labor_duracion CHECK (duracion_horas > 0);

    -- R06 y R09. El costo admite cero. La disponibilidad es positiva y se cuenta sin decimales cuando uso unidad.
    ALTER TABLE dbo.Insumo WITH CHECK ADD
        CONSTRAINT UQ_Insumo_codigo UNIQUE (codigo_insumo),
        CONSTRAINT CK_Insumo_textos CHECK (LTRIM(RTRIM(codigo_insumo)) <> '' AND LTRIM(RTRIM(nombre)) <> N''),
        CONSTRAINT CK_Insumo_unidad CHECK (unidad IN ('kg', 'L', 'unidad')),
        CONSTRAINT CK_Insumo_costo CHECK (costo_unitario >= 0),
        CONSTRAINT CK_Insumo_disponibilidad CHECK (cantidad_disponible > 0),
        CONSTRAINT CK_Insumo_disponibilidad_entera CHECK (unidad <> 'unidad' OR cantidad_disponible = FLOOR(cantidad_disponible));

    -- R07 y R09. Conservo el costo por unidad aplicado a ese consumo. La cantidad usada debe ser positiva.
    ALTER TABLE dbo.ConsumoInsumo WITH CHECK ADD
        CONSTRAINT FK_ConsumoInsumo_Labor FOREIGN KEY (id_labor) REFERENCES dbo.Labor(id_labor),
        CONSTRAINT FK_ConsumoInsumo_Insumo FOREIGN KEY (id_insumo) REFERENCES dbo.Insumo(id_insumo),
        CONSTRAINT CK_ConsumoInsumo_cantidad CHECK (cantidad > 0),
        CONSTRAINT CK_ConsumoInsumo_costo CHECK (costo_unitario_aplicado >= 0);

    -- R08 y R09. Registro la cosecha en kg o t. La calidad tiene tres valores permitidos.
    -- N indica texto Unicode, igual que el tipo NVARCHAR del campo calidad.
    ALTER TABLE dbo.Cosecha WITH CHECK ADD
        CONSTRAINT FK_Cosecha_CicloCultivo FOREIGN KEY (id_ciclo) REFERENCES dbo.CicloCultivo(id_ciclo),
        CONSTRAINT CK_Cosecha_cantidad CHECK (cantidad > 0),
        CONSTRAINT CK_Cosecha_unidad CHECK (unidad IN ('kg', 't')),
        CONSTRAINT CK_Cosecha_calidad CHECK (calidad IN (N'Primera', N'Segunda', N'Industrial'));

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- XACT_STATE indica si queda una transacción abierta. THROW muestra el error original.
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;

-- Consulto el catálogo de la base para contar las restricciones creadas.
-- COUNT(*) cuenta las filas que devuelve cada consulta entre paréntesis.
SELECT (SELECT COUNT(*) FROM sys.foreign_keys WHERE is_ms_shipped = 0) AS ClavesForaneas,
       (SELECT COUNT(*) FROM sys.key_constraints WHERE type = 'UQ' AND is_ms_shipped = 0) AS Unicas,
       (SELECT COUNT(*) FROM sys.check_constraints WHERE is_ms_shipped = 0) AS Comprobaciones,
       (SELECT COUNT(*) FROM sys.default_constraints WHERE is_ms_shipped = 0) AS Predeterminados;

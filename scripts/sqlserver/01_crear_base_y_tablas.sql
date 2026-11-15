-- Caso 10. Creo la base del ejercicio y las diez tablas del modelo relacional.
-- El archivo 02 agregará las relaciones y las reglas de los datos antes de la carga.

-- master es la base desde la que pido a SQL Server que cree la base del proyecto.
USE master;
GO

-- DB_ID devuelve el identificador de la base o NULL si no la encuentra.
-- EXEC ejecuta CREATE DATABASE por separado, fuera de la transacción de las tablas.
IF DB_ID(N'DNV_Caso10') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE DNV_Caso10;');
END;
GO

-- USE selecciona la base del ejercicio. GO separa los bloques en SSMS.
USE DNV_Caso10;
GO

-- DB_NAME indica la base actual. THROW detiene este bloque con un mensaje.
IF DB_NAME() <> N'DNV_Caso10'
BEGIN
    THROW 50001, N'Selecciona la base DNV_Caso10 antes de crear las tablas.', 1;
END;

-- sys.tables contiene las tablas de esta base. EXISTS comprueba si hay alguna
-- de las tablas del caso. Si ya existe, detengo la creación para revisar la base.
IF EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE schema_id = SCHEMA_ID(N'dbo')
      AND name IN (N'Predio', N'Lote', N'Cultivo', N'Temporada', N'CicloCultivo',
                   N'Trabajador', N'Labor', N'Insumo', N'ConsumoInsumo', N'Cosecha')
)
BEGIN
    THROW 50002, N'Ya hay tablas del caso en DNV_Caso10. Revisa su estado antes de continuar.', 1;
END;

-- Agrupo la creación de tablas en una transacción. XACT_ABORT hace que SQL Server
-- deshaga esa transacción si ocurre un error de ejecución. COMMIT guarda los cambios.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Predio representa la propiedad agrícola (R01).
-- dbo agrupa las tablas dentro de la base. NOT NULL exige un valor en cada campo.
-- PRIMARY KEY identifica cada fila. IDENTITY(1,1) empieza en 1 y aumenta de uno en uno.
-- VARCHAR guarda los códigos. NVARCHAR permite nombres con tildes y otros caracteres.
-- Los tamaños siguen el diccionario. DECIMAL(12,2) admite 12 dígitos, 2 de ellos decimales.
CREATE TABLE dbo.Predio (
    id_predio INT IDENTITY(1,1) NOT NULL,
    codigo_predio VARCHAR(20) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    area_ha DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_Predio PRIMARY KEY (id_predio)
);

-- Lote identifica una parte del predio (R01). id_predio guarda el predio al que pertenece.
CREATE TABLE dbo.Lote (
    id_lote INT IDENTITY(1,1) NOT NULL,
    id_predio INT NOT NULL,
    codigo_lote VARCHAR(20) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    area_ha DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_Lote PRIMARY KEY (id_lote)
);

-- Cultivo guarda el tipo de cultivo, como maíz, para poder usarlo en varios ciclos (R02, D01).
CREATE TABLE dbo.Cultivo (
    id_cultivo INT IDENTITY(1,1) NOT NULL,
    codigo_cultivo VARCHAR(20) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Cultivo PRIMARY KEY (id_cultivo)
);

-- Temporada guarda el periodo que agrupa los ciclos (R02). DATE guarda la fecha sin hora.
CREATE TABLE dbo.Temporada (
    id_temporada INT IDENTITY(1,1) NOT NULL,
    codigo_temporada VARCHAR(20) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT PK_Temporada PRIMARY KEY (id_temporada)
);

-- CicloCultivo identifica una siembra concreta y la relaciona con su lote,
-- cultivo y temporada (R03). DECIMAL(14,3) permite hasta tres decimales en la cantidad.
CREATE TABLE dbo.CicloCultivo (
    id_ciclo INT IDENTITY(1,1) NOT NULL,
    id_lote INT NOT NULL,
    id_cultivo INT NOT NULL,
    id_temporada INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    cantidad_sembrada DECIMAL(14,3) NOT NULL,
    unidad_siembra VARCHAR(10) NOT NULL,
    estado VARCHAR(12) NOT NULL,
    CONSTRAINT PK_CicloCultivo PRIMARY KEY (id_ciclo)
);

-- Trabajador guarda los datos de la persona responsable de las labores (R04).
-- El documento es texto para conservar su forma, incluidos posibles ceros iniciales.
CREATE TABLE dbo.Trabajador (
    id_trabajador INT IDENTITY(1,1) NOT NULL,
    documento VARCHAR(25) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    funcion NVARCHAR(60) NOT NULL,
    estado VARCHAR(8) NOT NULL,
    CONSTRAINT PK_Trabajador PRIMARY KEY (id_trabajador)
);

-- Labor guarda una actividad, su ciclo y su trabajador (R05). La duración está en horas.
CREATE TABLE dbo.Labor (
    id_labor INT IDENTITY(1,1) NOT NULL,
    id_ciclo INT NOT NULL,
    id_trabajador INT NOT NULL,
    tipo NVARCHAR(40) NOT NULL,
    fecha DATE NOT NULL,
    duracion_horas DECIMAL(8,2) NOT NULL,
    CONSTRAINT PK_Labor PRIMARY KEY (id_labor)
);

-- Insumo guarda el recurso, su costo actual por unidad y su cantidad disponible (R06).
CREATE TABLE dbo.Insumo (
    id_insumo INT IDENTITY(1,1) NOT NULL,
    codigo_insumo VARCHAR(20) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    unidad VARCHAR(6) NOT NULL,
    costo_unitario DECIMAL(12,2) NOT NULL,
    cantidad_disponible DECIMAL(14,3) NOT NULL,
    CONSTRAINT PK_Insumo PRIMARY KEY (id_insumo)
);

-- ConsumoInsumo registra el uso de un insumo en una labor y el costo aplicado (R07).
-- La clave primaria usa los dos identificadores juntos. La pareja no se puede repetir.
CREATE TABLE dbo.ConsumoInsumo (
    id_labor INT NOT NULL,
    id_insumo INT NOT NULL,
    cantidad DECIMAL(14,3) NOT NULL,
    costo_unitario_aplicado DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_ConsumoInsumo PRIMARY KEY (id_labor, id_insumo)
);

-- Cosecha registra la producción de un ciclo, con su fecha, unidad y calidad (R08).
CREATE TABLE dbo.Cosecha (
    id_cosecha INT IDENTITY(1,1) NOT NULL,
    id_ciclo INT NOT NULL,
    fecha DATE NOT NULL,
    cantidad DECIMAL(14,3) NOT NULL,
    unidad VARCHAR(2) NOT NULL,
    calidad NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_Cosecha PRIMARY KEY (id_cosecha)
);

COMMIT TRANSACTION;

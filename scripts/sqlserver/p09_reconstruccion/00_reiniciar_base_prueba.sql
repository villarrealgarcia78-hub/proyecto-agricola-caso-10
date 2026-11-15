-- ADVERTENCIA DE BORRADO: al confirmar, elimino DNV_Caso10_Reconstruccion,
-- con todas sus tablas y datos. Para una primera prueba basta con ejecutar el paso 01.
-- La base de grabación DNV_Caso10 queda fuera de este archivo.
USE master;
GO

-- BIT admite 0 o 1. Dejo 0 para revisar el destino. Escribo 1 solo para borrar la base de prueba.
DECLARE @confirmarBorrado BIT = 0;

-- DB_NAME() devuelve la base actual y @@TRANCOUNT cuenta las transacciones abiertas.
IF DB_NAME() <> N'master' OR @@TRANCOUNT <> 0
    THROW 50170, N'Abre una consulta nueva en master para revisar el reinicio.', 1;

-- DROP DATABASE requiere que la sesión no abra una transacción de manera automática.
SET IMPLICIT_TRANSACTIONS OFF;
SET NOCOUNT ON;

-- DB_ID devuelve NULL si la base de prueba no existe o no aparece para mi usuario.
IF DB_ID(N'DNV_Caso10_Reconstruccion') IS NULL
BEGIN
    SELECT N'DNV_Caso10_Reconstruccion' AS BaseDePrueba,
           N'La base no aparece en esta conexión. No se borró nada.' AS Resultado;
    RETURN;
END;

-- Uso la marca que coloca el archivo 01 al crear la prueba. sp_executesql ejecuta
-- la verificación en la base de prueba y OUTPUT devuelve si encontró la marca.
DECLARE @marcaCorrecta BIT = 0;
EXEC [DNV_Caso10_Reconstruccion].sys.sp_executesql
    N'SELECT @encontrada = CASE WHEN EXISTS (
        SELECT 1 FROM sys.extended_properties
        WHERE class = 0 AND name = N''DNV_AmbitoDePrueba''
          AND CONVERT(NVARCHAR(128), value) = N''Caso10_Reconstruccion_P09''
    ) THEN 1 ELSE 0 END;',
    N'@encontrada BIT OUTPUT', @encontrada = @marcaCorrecta OUTPUT;

IF @marcaCorrecta <> 1
    THROW 50171, N'La base tiene el nombre de prueba, pero no tiene su marca. No se borró nada.', 1;

IF @confirmarBorrado <> 1 OR @confirmarBorrado IS NULL
BEGIN
    SELECT N'DNV_Caso10_Reconstruccion' AS BaseDePrueba,
           N'Vista previa. La base tiene la marca de prueba. No se borró nada.' AS Resultado;
    RETURN;
END;

-- DROP DATABASE elimina solo esta base. Si otra conexión la está usando, SQL Server
-- puede rechazar el borrado. Cierro esas pestañas antes de volver a comprobar.
DROP DATABASE [DNV_Caso10_Reconstruccion];

IF DB_ID(N'DNV_Caso10_Reconstruccion') IS NOT NULL
    THROW 50172, N'La base de prueba todavía aparece. Revisa Mensajes.', 1;

SELECT N'DNV_Caso10_Reconstruccion' AS BaseDePrueba,
       N'La base de prueba se eliminó. Ya puedo reconstruirla desde cero.' AS Resultado;

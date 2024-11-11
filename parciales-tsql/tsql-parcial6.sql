------------------------------ T-SQL - PARCIAL 6 (2024) ------------------------------

/*
    Implementar una restricción que no deje realizar operaciones masivas (operación sobre más de una fila)
    sobre la tabla cliente. En caso de que esto se intente se deberá registrar (persistir) qué operación se intentó realizar,
    en qué fecha y hora y sobre qué datos se trató de realizar.
*/

-- Creamos una estructura adicional para registrar la operación que se intentó realizar

CREATE TABLE intento_operaciones (
    id int IDENTITY(1,1) PRIMARY KEY,
    operacion VARCHAR(10),
    fecha_hora DATETIME,
)


-- Creamos el trigger

CREATE TRIGGER tr_restriccion_insert_masivo
    ON Cliente INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN TRANSACTION

    DECLARE @operacion VARCHAR(10)

    -- Definimos qué operacion se está realizando

    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        SET @operacion = 'INSERT'
    END
    ELSE IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        SET @operacion = 'DELETE'
    END
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        SET @operacion = 'UPDATE'
    END

    -- Chequeamos si se está queriendo realizar una operación masiva
    IF (SELECT COUNT(*) FROM inserted) > 1 OR (SELECT COUNT(*) FROM deleted) > 1
    BEGIN
        PRINT 'Intento de operacion masiva. Abortando operacion y registrando la misma en una estructura adicional'

        INSERT INTO intento_operaciones (operacion, fecha_hora)
            VALUES (@operacion, CURRENT_TIMESTAMP)
    END
    ELSE
    BEGIN
        PRINT 'Operacion simple';

        IF @operacion = 'INSERT'
        BEGIN
            INSERT INTO Cliente SELECT * FROM inserted;
        END

        ELSE IF @operacion = 'DELETE'
        BEGIN
            DELETE FROM Cliente WHERE clie_codigo = inserted.clie_codigo
            -- DELETE FROM Cliente WHERE clie_codigo IN (SELECT clie_codigo FROM deleted) ESTA NO TIENE MUCHO SENTIDO PORQUE PERMITE MASIVIDAD
        END

        ELSE IF @operacion = 'UPDATE'       -- Actualizamos los campos y si el inserted llega a ser null, dejamos el que tenia originalmente
        BEGIN
            UPDATE Cliente SET
                clie_razon_social = COALESCE(i.clie_razon_social, Cliente.clie_razon_social),
                clie_limite_credito = COALESCE(i.clie_limite_credito, Cliente.clie_razon_social),
                clie_domicilio = COALESCE(i.clie_domicilio, Cliente.clie_razon_social),
                clie_telefono = COALESCE(i.clie_telefono, Cliente.clie_razon_social),
                clie_vendedor = COALESCE(i.clie_vendedor, Cliente.clie_razon_social)
            FROM inserted i
            WHERE Cliente.clie_codigo = i.clie_codigo
        END

    END

COMMIT


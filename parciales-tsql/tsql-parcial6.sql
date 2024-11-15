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
    fecha_hora DATETIME
)


-- Creamos el trigger

CREATE TRIGGER tr_restriccion_insert_masivo
    ON Cliente INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN TRANSACTION

    DECLARE @operacion VARCHAR(10)

    -- Definimos qué operacion se está realizando

    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS(SELECT 1 FROM deleted)
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
                clie_razon_social = i.clie_razon_social,
                clie_limite_credito = i.clie_limite_credito,
                clie_domicilio = i.clie_domicilio,
                clie_telefono = i.clie_telefono,
                clie_vendedor = i.clie_vendedor
            FROM inserted i
            WHERE Cliente.clie_codigo = i.clie_codigo
        END

    END

COMMIT




-- OPCION 2:

CREATE TABLE auditoria_op_masivas (aud_op_id INT PRIMARY KEY IDENTITY(0, 1), aud_operacion CHAR(8), aud_fecha_hora DATETIME, aud_dato CHAR(20))

CREATE TRIGGER tg_operaciones_masivas ON Cliente
    INSTEAD OF UPDATE, INSERT, DELETE
    AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    BEGIN TRANSACTION
        -- Variables
        DECLARE @cliente CHAR(6), @razon_social CHAR(100), @telefono CHAR(100), @domicilio CHAR(100), @limite_credito DECIMAL(12, 2), @vendedor NUMERIC(6, 0)

        -- Cursor
        DECLARE clientes CURSOR FOR
            SELECT * FROM inserted

        OPEN clientes
        FETCH clientes INTO @cliente, @razon_social, @telefono, @domicilio, @limite_credito, @vendedor

        WHILE @@FETCH_STATUS = 0
            BEGIN
                IF (SELECT COUNT() FROM inserted) > 1 OR (SELECT COUNT() FROM deleted) > 1-- Inserta la operación masiva en la tabla auditoría y lanzo un error
                    BEGIN
                        IF @cliente IN (SELECT clie_codigo FROM inserted) AND @cliente IN (SELECT clie_codigo FROM deleted)
                            BEGIN
                                IF @razon_social != (SELECT clie_razon_social FROM deleted WHERE clie_codigo = @cliente)
                                    BEGIN
                                        INSERT INTO auditoria_op_masivas (aud_operacion, aud_fecha_hora, aud_dato)
                                        VALUES('UPDATE', GETDATE(), @razon_social)
                                    END
                                ELSE IF @telefono != (SELECT clie_telefono FROM deleted WHERE clie_codigo = @cliente)
                                    BEGIN
                                        INSERT INTO auditoria_op_masivas (aud_operacion, aud_fecha_hora, aud_dato)
                                        VALUES('UPDATE', GETDATE(), @telefono)
                                    END
                                ELSE IF @domicilio != (SELECT clie_domicilio FROM deleted WHERE clie_codigo = @cliente)
                                    BEGIN
                                        INSERT INTO auditoria_op_masivas (aud_operacion, aud_fecha_hora, aud_dato)
                                        VALUES('UPDATE', GETDATE(), @domicilio)
                                    END
                                ELSE IF @limite_credito != (SELECT clie_limite_credito FROM deleted WHERE clie_codigo = @cliente)
                                    BEGIN
                                        INSERT INTO auditoria_op_masivas (aud_operacion, aud_fecha_hora, aud_dato)
                                        VALUES('UPDATE', GETDATE(), @limite_credito)
                                    END
                                ELSE IF @vendedor != (SELECT clie_vendedor FROM deleted WHERE clie_codigo = @cliente)
                                    BEGIN
                                        INSERT INTO auditoria_op_masivas (aud_operacion, aud_fecha_hora, aud_dato)
                                        VALUES('UPDATE', GETDATE(), @vendedor)
                                    END;

                                THROW 50001, 'No se permiten operaciones masivas.', 1
                            END
                        ELSE IF @cliente IN (SELECT clie_codigo FROM inserted)
                            BEGIN
                                INSERT INTO auditoria_op_masivas (aud_operacion, aud_fecha_hora, aud_dato)
                                VALUES('INSERT', GETDATE(), @cliente),
                                      ('INSERT', GETDATE(), @razon_social),
                                      ('INSERT', GETDATE(), @telefono),
                                      ('INSERT', GETDATE(), @domicilio),
                                      ('INSERT', GETDATE(), @limite_credito),
                                      ('INSERT', GETDATE(), @vendedor);

                                THROW 50001, 'No se permiten operaciones masivas.', 1
                            END
                        ELSE
                            BEGIN
                                INSERT INTO auditoria_op_masivas (aud_operacion, aud_fecha_hora, aud_dato)
                                VALUES('DELETE', GETDATE(), @cliente),
                                      ('DELETE', GETDATE(), @razon_social),
                                      ('DELETE', GETDATE(), @telefono),
                                      ('DELETE', GETDATE(), @domicilio),
                                      ('DELETE', GETDATE(), @limite_credito),
                                      ('DELETE', GETDATE(), @vendedor);
                                THROW 50001, 'No se permiten operaciones masivas.', 1
                            END
                    END
                ELSE -- Realizo la operación si no es masiva
                    BEGIN
                        IF @cliente IN (SELECT clie_codigo FROM inserted) AND @cliente IN (SELECT clie_codigo FROM deleted)
                            BEGIN
                                UPDATE Cliente
                                SET clie_codigo = @cliente, clie_domicilio = @domicilio, clie_limite_credito = @limite_credito, clie_razon_social = @razon_social,
                                    clie_telefono = @telefono, clie_vendedor = @vendedor
                                WHERE clie_codigo = @cliente
                            END
                        ELSE IF @cliente IN (SELECT clie_codigo FROM inserted)
                            BEGIN
                                INSERT INTO Cliente (clie_codigo, clie_domicilio, clie_limite_credito, clie_razon_social, clie_telefono, clie_vendedor)
                                VALUES(@cliente, @domicilio, @limite_credito, @razon_social, @telefono, @vendedor)
                            END
                        ELSE
                            BEGIN
                                DELETE FROM Cliente
                                WHERE clie_codigo = @cliente
                            END
                    END

                FETCH clientes INTO @cliente, @razon_social, @telefono, @domicilio, @limite_credito, @vendedor
            END

    COMMIT TRANSACTION

    CLOSE clientes
    DEALLOCATE clientes
END





-- OTRA OPCION

--DROP TRIGGER PreventClientMassiveOperation;
CREATE TRIGGER PreventClientMassiveOperation ON Cliente
    INSTEAD OF INSERT, UPDATE, DELETE
    AS
BEGIN
    DECLARE @affected_rows INT;
    DECLARE @operation_type VARCHAR(10);
    DECLARE @data nvarchar(MAX)

    BEGIN TRANSACTION;

    IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
        BEGIN
            SET @affected_rows = (SELECT COUNT(*) FROM INSERTED);
            SET @operation_type = 'INSERT';
            SET @data = (SELECT * FROM INSERTED FOR JSON AUTO)
        END
    ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
        BEGIN
            SET @affected_rows = (SELECT COUNT(*) FROM INSERTED);
            SET @operation_type = 'UPDATE';
            SET @data = (SELECT * FROM INSERTED FOR JSON AUTO) + (SELECT * FROM DELETED FOR JSON AUTO)
        END
    ELSE
        BEGIN
            SET @affected_rows = (SELECT COUNT(*) FROM DELETED);
            SET @operation_type = 'DELETE';
            SET @data = (SELECT * FROM DELETED FOR JSON AUTO)
        END

    IF @affected_rows > 1
        BEGIN
            INSERT INTO OperationLog(operation_type, data, affected_rows, description)
            VALUES (@operation_type, @data, @affected_rows, CONCAT('Attempted massive ', @operation_type, ' on Cliente'));
            RAISERROR('No se permiten operaciones masivas en tabla Cliente', 16, 1);
        END
    ELSE
        BEGIN
            IF @operation_type = 'INSERT'
                BEGIN
                    INSERT INTO Cliente
                    SELECT * FROM INSERTED;
                END
            ELSE IF @operation_type = 'UPDATE'
                BEGIN
                    DELETE FROM Cliente
                    WHERE clie_codigo IN (SELECT clie_codigo FROM DELETED);

                    INSERT INTO Cliente
                    SELECT * FROM INSERTED;
                END
            ELSE IF @operation_type = 'DELETE'
                BEGIN
                    DELETE FROM Cliente
                    WHERE clie_codigo IN (SELECT clie_codigo FROM DELETED);
                END
        END
    COMMIT TRANSACTION;
END;



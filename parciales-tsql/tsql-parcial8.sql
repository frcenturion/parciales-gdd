------------------------------ T-SQL - PARCIAL 8 (13/11/2024) ------------------------------

/*
    Implementar un sistema de auditoría para registrar cada operación realizada en la tabla cliente. El sistema deberá
    almacenar, como mínimo, los valores (campos afectados), el tipo de operación a realizar, y la fecha y hora de
    ejecución. Solo se permitirán operaciones individuales (no masivas) sobre los registros, pero el intento de realizar
    operaciones masivas deberá ser registrado en el sistema de auditoría.
*/


-- Creamos la estructura para almacenar la información de auditoría

DROP TABLE auditoria_cliente;

CREATE TABLE auditoria_cliente (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo_operacion NVARCHAR(10),
    fecha_hora_ejecucion DATETIME,
    campos_afectados NVARCHAR(MAX),
    descripcion NVARCHAR(MAX)
);

-- Creamos un trigger sobre todos los tipos de operaciones

CREATE TRIGGER tr_auditoria_cliente ON
    Cliente INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN TRANSACTION
    -- Declaramos las variables necesarias

    DECLARE @operacion NVARCHAR(10);
    DECLARE @affected_rows INT;         -- Esto es para chequear si es o no operacion masiva
    DECLARE @fecha_hora DATETIME;
    DECLARE @data NVARCHAR(MAX);

    SET @fecha_hora = CURRENT_TIMESTAMP;

    -- Chequeamos todos los casos posibles de operaciones (INSERT, UPDATE, DELETE) y guardamos la info de auditoría

    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) -- INSERT
        BEGIN
            SET @affected_rows = (SELECT COUNT(*) FROM inserted);
            SET @operacion = 'INSERTED';
            SET @data = (SELECT * FROM inserted FOR JSON AUTO)
        END
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted) -- UPDATE
        BEGIN
            SET @affected_rows = (SELECT COUNT(*) FROM inserted);
            SET @operacion = 'UPDATE';
            SET @data = (SELECT * FROM inserted FOR JSON AUTO) + (SELECT * FROM deleted FOR JSON AUTO)
        END
     ELSE                                                                      -- DELETED
        BEGIN
            SET @affected_rows = (SELECT COUNT(*) FROM deleted);
            SET @operacion = 'DELETE';
            SET @data = (SELECT * FROM deleted FOR JSON AUTO)
        END

    IF @affected_rows > 1   -- Operacion masiva
        BEGIN
            PRINT 'Intento de operacion masiva. Abortando operacion'

            -- Guardamos la info de auditoria

            INSERT INTO auditoria_cliente (tipo_operacion, fecha_hora_ejecucion, campos_afectados, descripcion)
                VALUES (@operacion, @fecha_hora, @data, 'Intento de operacion masiva sobre Cliente')
        END
    ELSE
        BEGIN
            PRINT 'Operacion simple'

            -- Guardamos la info de auditoria
            INSERT INTO auditoria_cliente (tipo_operacion, fecha_hora_ejecucion, campos_afectados, descripcion)
                VALUES (@operacion, @fecha_hora, @data, 'Operacion simple sobre Cliente')

            IF @operacion = 'INSERTED'
                BEGIN
                    -- Insertamos el registro
                    INSERT INTO Cliente
                    SELECT * FROM inserted
                END
            ELSE IF @operacion = 'UPDATE'
                BEGIN
                    -- Updateamos el registro (DELETE + INSERT)
                    DELETE FROM Cliente
                    WHERE clie_codigo IN (SELECT clie_codigo FROM deleted)

                    INSERT INTO Cliente
                    SELECT * FROM inserted
                END
            ELSE
                BEGIN
                    -- Borramos el registro
                    DELETE FROM Cliente
                    WHERE clie_codigo IN (SELECT clie_codigo FROM deleted)      -- Aquellos registros donde el codigo de cliente coincida con el de la tabla deleted
                END
        END
COMMIT







































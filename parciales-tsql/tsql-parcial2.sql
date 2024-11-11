------------------------------ T-SQL - PARCIAL 2 (28/07/2023) ------------------------------

/*
      Suponiendo que se aplican los siguientes cambios en el modelo de datos:

      1) CREATE TABLE Provincia (id int primary key, nombre char(100));
      2) ALTER TABLE Cliente ADD pcia_id int null;

      Crear el/los objetos necesarios para implementar el concepto de FK entre Cliente y Provincia
*/

/*
    Para implementar el concepto de FK tenemos que respetar las claves de la integridad referencial:

    1. Existencia de la PK en la tabla referenciada
    2. Imposibilidad de referencias huérfanas: no puede haber un valor en la columna pcia_id de Cliente que no esté en Provincia
    3. Restricciones de eliminación o actualización en la tabla referenciada:
        - Prohibición de eliminación si existen dependencias activas o DELETE CASCADE
        - Si se actualiza el ID, debe gestionarse que las referencias en cliente sigan siendo válidas (esto es muy fino, rara vez se va a querer actualizar el ID)
*/

CREATE TABLE Provincia (id int primary key, nombre char(100));
ALTER TABLE Cliente ADD pcia_id int null;



CREATE TRIGGER tr_insert_update_fk
    ON Cliente AFTER INSERT, UPDATE
AS
BEGIN TRANSACTION

    -- Acá tenemos que chequear que en caso de querer updatear o insertar un registro, tengamos una FK válida (que exista en la tabla provincia)

    IF EXISTS ( SELECT 1
                    FROM inserted i
                    LEFT JOIN Provincia p ON i.pcia_id = p.id
                    WHERE i.pcia_id IS NOT NULL AND p.id IS NULL    -- Si existe algun caso en donde la provincia id no sea null pero el id en la tabla original si
                    )                                               -- Aca capaz que si conviene hacerlo con un cursor para mas claridad
    BEGIN
        PRINT 'La provincia referenciada en pcia_id no existe'
        ROLLBACK TRANSACTION;
    END
COMMIT


-- Variante con cursor

CREATE TRIGGER tr_insert_update_fk
    ON Cliente AFTER INSERT, UPDATE
    AS
    BEGIN TRANSACTION

    -- Acá tenemos que chequear que en caso de querer updatear o insertar un registro, tengamos una FK válida (que exista en la tabla provincia)

    DECLARE @provincia INT

    DECLARE cursor_insert_update_fk CURSOR FOR
        SELECT
            i.pcia_id
        FROM inserted i

    OPEN cursor_insert_update_fk
    FETCH cursor_insert_update_fk INTO
        @provincia
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @provincia NOT IN (SELECT id FROM Provincia)
            -- IF NOT EXISTS (SELECT 1 FROM Provincia p where p.id = @provincia)
            BEGIN
                PRINT 'La provincia referenciada en pcia_id no existe'
                ROLLBACK
            end
        END
    FETCH NEXT FROM cursor_insert_update_fk INTO @provincia

COMMIT



CREATE TRIGGER tr_delete_fk
    ON Provincia INSTEAD OF DELETE
AS
BEGIN TRANSACTION

    IF EXISTS (             -- Con esto chequeamos que exista el menos un registro de todos que este referenciado en la tabla Cliente
        SELECT 1
        FROM cliente c
                 JOIN deleted d ON c.pcia_id = d.id
    )

    BEGIN
        PRINT 'No se puede eliminar la provincia dada que la misma esta siendo referenciada en la tabla Cliente'
    END

    ELSE
    BEGIN
        PRINT 'Procediendo con la eliminacion de la/las provincias'

        DELETE FROM Provincia
        WHERE id IN (SELECT id FROM deleted)
    END
COMMIT







    
-- Otra alternativa seria hacerlo con un cursor pero es al pedo:

CREATE TRIGGER trg_prevent_delete_provincia
    ON provincia
    INSTEAD OF DELETE
    AS
BEGIN
    DECLARE @provincia_id INT;

    -- Definir un cursor para recorrer cada registro en el conjunto de `deleted`
    DECLARE cur_provincia CURSOR FOR
        SELECT id FROM deleted;

    -- Abrir el cursor
    OPEN cur_provincia;

    -- Obtener el primer registro
    FETCH NEXT FROM cur_provincia INTO @provincia_id;

    -- Iterar sobre todos los registros eliminados
    WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar si `pcia_id` en `cliente` tiene referencia al `provincia_id` actual
            IF EXISTS (SELECT 1 FROM cliente WHERE pcia_id = @provincia_id)
                BEGIN
                    -- Si hay una referencia, generar un error y cerrar el cursor
                    RAISERROR('No se puede eliminar la provincia con id %d porque está en uso en cliente.', 16, 1, @provincia_id);
                    CLOSE cur_provincia;
                    DEALLOCATE cur_provincia;
                    RETURN;
                END

            -- Pasar al siguiente registro en el cursor
            FETCH NEXT FROM cur_provincia INTO @provincia_id;
        END

    -- Cerrar y liberar el cursor si se completó sin errores
    CLOSE cur_provincia;
    DEALLOCATE cur_provincia;

    -- Realizar la eliminación de todos los registros en `deleted`
    DELETE FROM provincia WHERE id IN (SELECT id FROM deleted);
END;




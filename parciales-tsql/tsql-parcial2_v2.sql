------------------------------ T-SQL - PARCIAL 2 V2 (28/07/2023) ------------------------------

/*
      Suponiendo que se aplican los siguientes cambios en el modelo de datos:

      1) CREATE TABLE Provincia (id int primary key, nombre char(100));
      2) ALTER TABLE Cliente ADD pcia_id int null;

      Crear el/los objetos necesarios para implementar el concepto de FK entre Cliente y Provincia


      CASO EXTRA: Dada una tabla Localidad (id int, nombre char(100)), implementar el concepto de PK sin usar PK

*/

/*
    Integridad referencial:

    - Las FK de una tabla tienen que apuntar a un registro que sea PK de otra tabla o bien pueden ser NULL
    - No se puede eliminar un registro que está siendo referenciado por otra tabla a través de su FK
*/


CREATE TRIGGER tr_integridad_referencial_insert_update
    ON Cliente INSTEAD OF INSERT, UPDATE
AS
BEGIN TRANSACTION

    -- Declaro variables para captar la info del cursor
    DECLARE @clie_codigo char(6),
    @clie_razon_social char(100),
    @clie_telefono char(100),
    @clie_domicilio char(100),
    @clie_limite_credito decimal(12,2),
    @clie_vendedor numeric(6),
    @pcia_id int


    -- Armamos un cursor para recorrer todos los registros que se insertaron / updatearon
    DECLARE cur_clientes CURSOR FOR
        SELECT
            *
        FROM inserted i


    -- Para cada registro, tenemos que comprobar que la FK de cliente haga referencia a una PK valida de la tabla Cliente
    OPEN cur_clientes
    FETCH cur_clientes INTO @clie_codigo, @clie_razon_social, @clie_telefono, @clie_domicilio, @clie_limite_credito, @clie_vendedor, @pcia_id

    WHILE @@fetch_status = 0
        BEGIN

            IF @pcia_id NOT IN (SELECT id FROM Provincia) AND @pcia_id IS NOT NULL
                BEGIN
                    PRINT 'Violacion de Constraint de FK'
                    ROLLBACK TRANSACTION
                    RETURN;
                END
            ELSE
                BEGIN

                    -- En caso de que la FK sea válida, se inserta o updatea

                    IF EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 from deleted) -- UPDATE
                        BEGIN

                            DELETE FROM Cliente WHERE clie_codigo = @clie_codigo

                            INSERT INTO Cliente (clie_codigo, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor, pcia_id)
                            VALUES (@clie_codigo, @clie_razon_social, @clie_telefono, @clie_domicilio, @clie_limite_credito, @clie_vendedor, @pcia_id)

                        END
                    ELSE IF EXISTS(SELECT 1 FROM inserted) AND NOT EXISTS(SELECT 1 FROM deleted) -- INSERT
                        BEGIN

                            INSERT INTO Cliente (clie_codigo, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor, pcia_id)
                            VALUES (@clie_codigo, @clie_razon_social, @clie_telefono, @clie_domicilio, @clie_limite_credito, @clie_vendedor, @pcia_id)

                        END

                END

                FETCH NEXT FROM cur_clientes INTO @clie_codigo, @clie_razon_social, @clie_telefono, @clie_domicilio, @clie_limite_credito, @clie_vendedor, @pcia_id
        END
        CLOSE cur_clientes
        DEALLOCATE cur_clientes
COMMIT


CREATE TRIGGER tr_integridad_referencial_delete
    ON Provincia INSTEAD OF DELETE
AS
BEGIN TRANSACTION

    DECLARE @prov_id int,
        @prov_nombre char(100)


    -- Acá tenemos que chequear que los elementos que borramos de Provincia no esten en ningun registro de la tabla Cliente
    DECLARE cur_provincias_deleted CURSOR FOR
        SELECT
            *
        FROM deleted

    OPEN cur_provincias_deleted
    FETCH cur_provincias_deleted INTO @prov_id, @prov_nombre

    WHILE @@fetch_status = 0
        BEGIN

            -- Si el id de la provincia a borrar existe en algun registro de la tabla cliente, no permitimos el delete
            IF @prov_id IN (SELECT pcia_id FROM Cliente)
                BEGIN
                    PRINT 'El registro que se quiere eliminar esta siendo referenciado en la tabla cliente'
                    ROLLBACK TRANSACTION
                    RETURN;
                END
            ELSE    -- Caso contrario, dejamos borrar
                BEGIN
                    DELETE FROM Provincia WHERE pcia_id = @prov_id
                END

            FETCH NEXT FROM cur_provincias_deleted INTO @prov_id, @prov_nombre
        END

    CLOSE cur_provincias_deleted
    DEALLOCATE cur_provincias_deleted

COMMIT



-- CASO EXTRA:

/*
    Integridad de las entidades:

    - Las PK de las entidades tienen que ser únicas y no nulas

*/


CREATE TABLE Localidad (
    id int,
    nombre char(50)
)

CREATE TRIGGER tr_integridad_entidades
    ON Localidad INSTEAD OF INSERT, UPDATE
AS
BEGIN TRANSACTION

    DECLARE @id int, @nombre char(50)

    DECLARE cur_localidades CURSOR FOR
        SELECT * FROM inserted

    OPEN cur_localidades
    FETCH cur_localidades INTO @id, @nombre

    WHILE @@fetch_status = 0
        BEGIN
            -- Chequeamos que la PK que se quiere insertar sea NOT NULL y que tampoco esté repetida ya

            IF @id IS NULL OR @id IN (SELECT id FROM Localidad)
                BEGIN
                    PRINT 'La PK que quiere insertar es NULL o ya existe'
                    ROLLBACK TRANSACTION
                END
            ELSE
                BEGIN
                    -- En caso de que esté bien, updateamos o insertamos, dependiendo del caso
                    IF EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 from deleted) -- UPDATE
                        BEGIN

                            DELETE FROM Localidad WHERE id = @id

                            INSERT INTO Localidad (id, nombre)
                            VALUES (@id, @nombre)

                        END
                    ELSE IF EXISTS(SELECT 1 FROM inserted) AND NOT EXISTS(SELECT 1 FROM deleted) -- INSERT
                        BEGIN

                            INSERT INTO Localidad (id, nombre)
                            VALUES (@id, @nombre)

                        END

                END

                FETCH NEXT FROM cur_localidades INTO @id, @nombre
        END
        CLOSE cur_localidades
        DEALLOCATE cur_localidades

COMMIT



INSERT INTO Localidad (id, nombre)
    VALUES (NULL, 'Mar del Plata')












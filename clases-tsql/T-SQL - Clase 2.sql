---------------- T-SQL - CLASE 2 ----------------

/*
    - Transacciones
    - Triggers
*/

-- Transacciones


BEGIN TRANSACTION
    INSERT INTO Envases(enva_codigo, enva_detalle)
        VALUES(5, 'env 5')

    INSERT INTO Envases(enva_codigo, enva_detalle)
        VALUES(6, 'env 6')
COMMIT

BEGIN TRANSACTION
    INSERT INTO Envases(enva_codigo, enva_detalle)
    VALUES(5, 'env 5')

    INSERT INTO Envases(enva_codigo, enva_detalle)
    VALUES(6, 'env 6')
ROLLBACK

-- Se cierran con un commit o un rollback




-- Triggers

-- Caso 1: Insert
-- Quiero que cada vez que se hace una factura sobre un vendedor, o sea, cada vez que se inserte una factura, incorpore el fact_total en el campo de la comisión del empleado.

CREATE TRIGGER tr_ejemplo_empl
    ON Factura
    AFTER INSERT         -- Cuando inserte en factura
    AS
    BEGIN TRANSACTION

        DECLARE @vend NUMERIC(6,0)
        DECLARE @total DECIMAL(12,2)
        DECLARE mi_cursor CURSOR FOR        -- Acordarse que los cursores nos permiten recorrer secuencialmente una tabla fila a fila (si hago un select me traeria todas las filas)
            SELECT
                fact_vendedor,
                fact_total
            FROM INSERTED       -- Esta tabla tiene las filas que acaban de ser insertadas por la operación de insert

        OPEN mi_cursor
        FETCH mi_cursor
            INTO @vend, @total      -- Es importante que respetemos el orden que establecimos en la consulta que definimos dentro de la definición del cursor
        WHILE @@fetch_status = 0
            BEGIN
                PRINT @vend
                UPDATE Empleado SET empl_comision = empl_comision + @total
                WHERE
                    empl_codigo = @vend
                FETCH mi_cursor
                    INTO @vend, @total
            END

        CLOSE mi_cursor
        DEALLOCATE mi_cursor
    COMMIT


-- Caso 2: Delete

    CREATE TRIGGER tr_ejemplo_empl_del
        ON Factura
        AFTER DELETE          -- Cuando borre en factura
        AS
        BEGIN TRANSACTION

        DECLARE @vend NUMERIC(6,0)
        DECLARE @total DECIMAL(12,2)
        DECLARE mi_cursor CURSOR FOR        -- Acordarse que los cursores nos permiten recorrer secuencialmente una tabla fila a fila (si hago un select me traeria todas las filas)
            SELECT
                fact_vendedor,
                fact_total
            FROM DELETED       -- Esta tabla tiene las filas que acaban de ser deleteadas por la operación de insert

        OPEN mi_cursor
        FETCH mi_cursor
            INTO @vend, @total      -- Es importante que respetemos el orden que establecimos en la consulta que definimos dentro de la definición del cursor
        WHILE @@fetch_status = 0
            BEGIN
                PRINT @vend
                UPDATE Empleado SET empl_comision = empl_comision - @total
                WHERE
                    empl_codigo = @vend
                FETCH mi_cursor
                    INTO @vend, @total
            END

        CLOSE mi_cursor
        DEALLOCATE mi_cursor
        COMMIT

-- No hace falta usar el cursor, podemos usar un select

-- Caso 3: Update

        CREATE TRIGGER tr_ejemplo_empl_upd
            ON Factura
            AFTER UPDATE
            AS
            BEGIN TRANSACTION

            DECLARE @vend NUMERIC(6,0)
            DECLARE @total DECIMAL(12,2)

            DECLARE mi_cursor CURSOR FOR        -- Acordarse que los cursores nos permiten recorrer secuencialmente una tabla fila a fila (si hago un select me traeria todas las filas)
                SELECT
                    fact_vendedor,
                    -1 * fact_total         -- Cuando se trate de eliminados lo pongo en negativo para que la suma de mas abajo termine siendo una resta
                FROM DELETED       
                UNION
                SELECT
                    fact_vendedor,
                    fact_total
                FROM INSERTED


            OPEN mi_cursor
            FETCH mi_cursor
                INTO @vend, @total      -- Es importante que respetemos el orden que establecimos en la consulta que definimos dentro de la definición del cursor
            WHILE @@fetch_status = 0
                BEGIN
                    PRINT @vend
                    UPDATE Empleado SET empl_comision = empl_comision + @total
                    WHERE
                        empl_codigo = @vend
                    FETCH mi_cursor
                        INTO @vend, @total
                END

            CLOSE mi_cursor
            DEALLOCATE mi_cursor
            COMMIT


-- Este trigger me muestra las filas viejas que modifique unidas con las filas nuevas
CREATE TRIGGER tr_ejemplo_prod
ON Producto AFTER update
as
begin transaction

    select prod_codigo, prod_detalle, 'TABLA_DELETED' from deleted
    union
    select prod_codigo, prod_detalle, 'TABLA_INSERTED' from inserted

commit

SELECT * FROM Producto p

UPDATE Producto set prod_detalle = 'valor nuevo'
    WHERE
        prod_codigo IN ('00000030', '00000031')


-- Trigger INSTEAD OF

CREATE TRIGGER tr_INSTEAD_envases
    ON Envases INSTEAD OF INSERT
    AS
    BEGIN TRANSACTION
        SELECT
            'TABLA INSERTED',
            *
        FROM inserted
    COMMIT



-- Este insert no va a insertar porque tenemos el trigger de arriba
INSERT INTO Envases (enva_codigo, enva_detalle)
    VALUES (16, 'envase 16')


-- Si quisiéramos insertar deberíamos hacerlo dentro del mismo trigger:

ALTER TRIGGER tr_INSTEAD_envases
    ON Envases INSTEAD OF INSERT
    AS
    BEGIN TRANSACTION
    SELECT
        'TABLA INSERTED',
        *
    FROM inserted

    INSERT INTO Envases (enva_codigo, enva_detalle)
    SELECT
        enva_codigo, LTRIM(RTRIM(enva_detalle)) + 'TR_INSTEAD'
    FROM inserted

    COMMIT

-- Si ejecutamos dos veces el trigger va a romper por constraint de PK





------------ EJERCICIO 10 - TSQL ------------

/*
    Crear el/los objetos de base de datos que ante el intento de borrar un artículo
    verifique que no exista stock y si es así lo borre. En caso contrario que emita un
    mensaje de error.

    Vamos a necesitar:

    - Trigger con INSTEAD OF sobre la tabla Producto
    - Ante el evento DELETE
*/

-- Considerando solo aquellos que tengan entradas en la tabla de stock

-- Opción 1: usamos IN (permite borrado multiple)
CREATE TRIGGER tr_borrar_articulo
    ON Producto INSTEAD OF DELETE
AS
BEGIN TRANSACTION

    IF EXISTS (
        SELECT 1
        FROM Deleted d
        JOIN STOCK s ON d.prod_codigo = s.stoc_producto
    )
        BEGIN
           ROLLBACK;
           PRINT 'No se puede borrar el artículo porque tiene stock'
        END

    ELSE
        BEGIN
            DELETE FROM Producto
            WHERE prod_codigo IN (SELECT prod_codigo FROM Deleted)      -- Esta subconsulta me puede devolver varios

            PRINT 'Producto eliminado con éxito'
        END
COMMIT



-- Opcion 2: usamos un cursor
CREATE TRIGGER tr_borrar_articulo_2
    ON Producto INSTEAD OF DELETE
    AS
    BEGIN TRANSACTION

    DECLARE @codigo char(8)

    IF EXISTS (
        SELECT 1
        FROM Deleted d
                 JOIN STOCK s ON d.prod_codigo = s.stoc_producto
    )
        BEGIN
            ROLLBACK;
            PRINT 'No se puede borrar el artículo porque tiene stock'
        END

    ELSE
        BEGIN

            DECLARE cursor_2 CURSOR FOR
            SELECT
                d.prod_codigo
            FROM deleted d

            OPEN cursor_2
            FETCH cursor_2 INTO
                @codigo
            WHILE @@fetch_status = 0
                BEGIN
                    DELETE FROM Producto
                    WHERE prod_codigo = @codigo
                    FETCH NEXT FROM cursor_2 INTO @codigo
                END
            CLOSE cursor_2
            DEALLOCATE cursor_2
            PRINT 'Producto eliminado con éxito'
        END
    COMMIT








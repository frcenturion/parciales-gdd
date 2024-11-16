---------------- T-SQL - CLASE 4 ----------------

/*
    - Ejercicio 3 T-SQL (lo hice aparte)
    - Ejercicio 5 T-SQL
    - Ejercicio inventado T-SQL
    - Ejercicio 15 SQL (lo hice aparte)
*/


-- Ejercicio inventado:

/*
    Realizar un delete en cascada sobre la tabla cliente que se ejecute cuando un usuario ejecuta un delete.
    Esto significa que si quiero borrar un cliente me permita hacerlo borrando de las tablas adecuadas.
*/

CREATE TRIGGER tr_borrar_cliente
    ON Cliente INSTEAD OF DELETE
AS
BEGIN TRANSACTION
    DECLARE @cliente_a_borrar CHAR(6)

    DECLARE cursor_3 CURSOR FOR
        SELECT
            c.clie_codigo
        FROM Cliente c

    OPEN cursor_3
    FETCH cursor_3 INTO
        @cliente_a_borrar
    WHILE @@fetch_status = 0
        BEGIN

            -- Borramos los items factura
            DELETE FROM Item_Factura
            WHERE
                @cliente_a_borrar IN (SELECT f.fact_cliente
                                      FROM Item_Factura i JOIN Factura f ON i.item_tipo = f.fact_tipo and i.item_sucursal = f.fact_sucursal and i.item_numero = f.fact_numero)

            /*-- Borramos los items factura (opcion 2)
            DELETE FROM Item_Factura
            WHERE
               EXISTS (SELECT f.fact_cliente
                                      FROM Item_Factura i JOIN Factura f ON i.item_tipo = f.fact_tipo and i.item_sucursal = f.fact_sucursal and i.item_numero = f.fact_numero AND f.fact_cliente = @cliente_a_borrar)*/


            -- Borramos las facturas
            DELETE FROM Factura
            WHERE fact_cliente = @cliente_a_borrar

            -- Borramos el cliente
            DELETE FROM Cliente
            WHERE clie_codigo = @cliente_a_borrar



            FETCH NEXT FROM cursor_3 INTO @cliente_a_borrar
        END
COMMIT


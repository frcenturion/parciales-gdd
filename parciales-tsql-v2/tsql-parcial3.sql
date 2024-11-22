------------------------------ T-SQL - PARCIAL 3 (19/11/2022) ------------------------------

/*
    Implementar una regla de negocio en línea donde nunca una factura nueva tenga un precio de producto distinto
    al que figura en la tabla PRODUCTO. Registrar en una estructura adicional todos los casos donde se intenta
    guardar un precio distinto.
*/

DROP TABLE registros_precios_distintos

CREATE TABLE registros_precios_distintos (
    id int IDENTITY(1,1) PRIMARY KEY,
    tipo char(1),
    sucursal char(4),
    numero char(8),
    producto char(8),
    cantidad decimal(12,2),
    precio decimal(12,2),
)

DROP TRIGGER dbo.tr_restriccion_precio

CREATE TRIGGER dbo.tr_restriccion_precio
    ON Item_Factura INSTEAD OF INSERT
AS
BEGIN TRANSACTION
    DECLARE @item_tipo CHAR(1)
    DECLARE @item_sucursal CHAR(4)
    DECLARE @item_numero CHAR(8)
    DECLARE @item_producto CHAR(8)

    DECLARE @item_precio DECIMAL(12,2)
    DECLARE @item_cantidad DECIMAL(12,2)

    DECLARE cursor_1 CURSOR FOR
    SELECT
        i.item_tipo,
        i.item_sucursal,
        i.item_numero,
        i.item_producto,
        i.item_precio,
        i.item_cantidad
    FROM Inserted i

    OPEN cursor_1
    FETCH cursor_1 INTO
        @item_tipo,
        @item_sucursal,
        @item_numero,
        @item_producto,
        @item_precio,
        @item_cantidad
    WHILE @@fetch_status = 0
        BEGIN
/*            IF @item_precio NOT IN (SELECT prod_precio
                                    FROM Producto p
                                        JOIN inserted i ON i.item_producto = p.prod_codigo
                                    WHERE p.prod_codigo = i.item_precio)*/


            -- Alternativa para simplificar el chequeo con el IF
            --SET @precio_tabla_producto = (SELECT p.prod_precio FROM Producto p WHERE p.prod_codigo = @item_producto)
            --IF @precio_tabla_producto != @item_precio


            IF NOT EXISTS (SELECT 1
                        FROM Producto p
                            JOIN inserted i ON i.item_producto = p.prod_codigo
                        WHERE p.prod_precio = i.item_precio)
                BEGIN
                    PRINT 'El precio del item factura no coincide con el del producto, se registra en una estructura adicional'


                    INSERT INTO registros_precios_distintos (tipo, sucursal, numero, producto, cantidad, precio)
                    VALUES (@item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad, @item_precio)

                END
            ELSE
                BEGIN
                    PRINT 'Los precios coinciden, insertando el item factura'

                    INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                    VALUES (@item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad, @item_precio)

                    -- Ahora tenemos que actualizar la tabla factura

                    UPDATE Factura SET fact_total =
                    (
                        SELECT
                            SUM(i.item_precio * i.item_cantidad)
                        FROM Item_Factura i
                        WHERE i.item_tipo = @item_tipo AND
                              i.item_numero = @item_numero AND
                              i.item_sucursal = @item_sucursal
                        GROUP BY i.item_tipo, i.item_numero, i.item_sucursal
                    )
                    WHERE fact_tipo = @item_tipo AND
                          fact_numero = @item_numero AND
                          fact_sucursal = @item_sucursal

                END

                FETCH NEXT FROM cursor_1 INTO
                    @item_tipo,
                    @item_sucursal,
                    @item_numero,
                    @item_producto,
                    @item_precio,
                    @item_cantidad
        END

        CLOSE cursor_1
        DEALLOCATE cursor_1
COMMIT



-- Testing

SELECT * FROM Producto
SELECT * FROM Item_Factura
SELECT * FROM Factura

INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
    VALUES ('A', '0003', '00068710', '00000030', '2', '2')


-- Precio original = 24483.75

SELECT * FROM registros_precios_distintos




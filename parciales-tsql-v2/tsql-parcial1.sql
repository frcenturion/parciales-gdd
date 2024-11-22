------------------------------ T-SQL - PARCIAL 1 (12/11/2022) ------------------------------

/*
    Implementar una regla de negocio de validación en línea que permita validar el STOCK al realizarse una venta.
    Cada venta se debe descontar del depósito 00. En caso de que se venda un producto compuesto, el descuento de stock
    se debe realizar por sus componentes.
    Si no hay STOCK para ese artículo, no se deberá guardar ese artículo, pero si los otros en los cuales hay stock
    positivo.
    Es decir, solamente se deberán guardar aquellos para los cuales si hay stock, sin guardarse los que no poseen
    cantidades suficientes
*/

-- Al registrar un Item_Factura (insert) tenemos que hacer el chequeo de stock con un trigger INSTEAD OF

CREATE TRIGGER tr_validacion_venta
    ON Item_Factura INSTEAD OF INSERT
    AS
    BEGIN TRANSACTION
    DECLARE @tipo CHAR(1)
    DECLARE @sucursal CHAR(4)
    DECLARE @numero CHAR(8)
    DECLARE @producto CHAR(8)

    DECLARE @cantidad DECIMAL(12,2)
    DECLARE @precio DECIMAL(12,2)

    DECLARE cursor_validacion_venta CURSOR FOR
        SELECT
            i.item_tipo,
            i.item_sucursal,
            i.item_numero,
            i.item_producto,
            i.item_cantidad,
            i.item_precio
        FROM inserted i

    OPEN cursor_validacion_venta
    FETCH NEXT FROM cursor_validacion_venta INTO
        @tipo,
        @sucursal,
        @numero,
        @producto,
        @cantidad,
        @precio

    WHILE @@fetch_status = 0
        BEGIN
            -- Verificamos si el producto es compuesto
            -- IF EXISTS (SELECT * FROM Composicion C where C.comp_producto = @producto_codigo)
            IF @producto IN (SELECT comp_producto FROM Composicion)
                BEGIN
                    -- Producto compuesto: recorrer componentes y actualizar stock por cada uno
                    DECLARE @componente CHAR(8)
                    DECLARE @cantidad_componente DECIMAL(12,2)

                    DECLARE cursor_componente CURSOR FOR
                        SELECT
                            c.comp_componente,
                            c.comp_cantidad
                        FROM Composicion c
                        WHERE c.comp_producto = @producto

                    OPEN cursor_componente
                    FETCH NEXT FROM cursor_componente INTO
                        @componente,
                        @cantidad_componente

                    WHILE @@fetch_status = 0
                        BEGIN
                            -- Verificamos si hay suficiente stock para cada componente
                            IF @cantidad_componente <= (SELECT
                                                            s.stoc_cantidad
                                                        FROM STOCK s
                                                        WHERE s.stoc_producto = @componente AND
                                                            s.stoc_deposito = '00'
                            )
                                BEGIN

                                    PRINT 'Stock suficiente del componente' + @componente

                                    -- Actualizamos el stock del componente
                                    UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cantidad_componente
                                    WHERE stoc_producto = @componente AND stoc_deposito = '00'

                                    -- Registramos el item factura
                                    INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                                    VALUES (@tipo, @sucursal, @numero, @producto, @cantidad, @precio)
                                END
                            ELSE
                                BEGIN
                                    PRINT 'No hay suficiente stock para el componente ' + @componente
                                END

                            FETCH NEXT FROM cursor_componente INTO
                                @componente,
                                @cantidad_componente
                        END

                    CLOSE cursor_componente
                    DEALLOCATE cursor_componente
                END
            ELSE
                BEGIN
                    -- Producto simple: verificar stock y registrar
                    IF @cantidad <= (SELECT
                                         s.stoc_cantidad
                                     FROM STOCK s
                                     WHERE s.stoc_producto = @producto AND
                                         s.stoc_deposito = '00'
                    )
                        BEGIN

                            PRINT 'Stock suficiente del producto' + @producto

                            -- Actualizamos el stock
                            UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cantidad
                            WHERE stoc_producto = @producto AND stoc_deposito = '00'

                            -- Registramos el item factura
                            INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                            VALUES (@tipo, @sucursal, @numero, @producto, @cantidad, @precio)
                        END
                    ELSE
                        BEGIN
                            PRINT 'No hay suficiente stock para el producto ' + @producto
                        END
                END

            FETCH NEXT FROM cursor_validacion_venta INTO
                @tipo,
                @sucursal,
                @numero,
                @producto,
                @cantidad,
                @precio
        END

    CLOSE cursor_validacion_venta
    DEALLOCATE cursor_validacion_venta

COMMIT


SELECT
    s.stoc_cantidad
FROM STOCK s
WHERE s.stoc_producto = '00000030'  AND
 s.stoc_deposito = '00'

SELECT * FROM Item_Factura
-- Testing
-- Tenemos 10 unidades del producto 30 en el deposito 00

INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
    VALUES ('A', '0003', '00092444', '00000030', '10', '1000' )




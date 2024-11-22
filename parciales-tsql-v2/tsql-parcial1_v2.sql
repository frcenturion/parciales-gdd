------------------------------ T-SQL - PARCIAL 1 V2 (12/11/2022) ------------------------------

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

CREATE TRIGGER tr_validacion_stock_venta
    ON Item_Factura INSTEAD OF INSERT
AS
BEGIN TRANSACTION

    -- Declaramos las variables de Item_Factura que vamos a insertar
    DECLARE @tipo CHAR(1)
    DECLARE @sucursal CHAR(4)
    DECLARE @numero CHAR(8)
    DECLARE @producto CHAR(8)
    DECLARE @cantidad DECIMAL(12,2)
    DECLARE @precio DECIMAL(12,2)


    -- Como podemos tener inserciones masivas, podemos usar un cursor para recorrer cada item_factura
    DECLARE cur_item_factura CURSOR FOR
        SELECT * FROM inserted

    -- Declaramos una variable para guardarnos el stock del deposito 00
    DECLARE @stock_depo_00 DECIMAL(12,2)

    OPEN cur_item_factura
    FETCH cur_item_factura INTO @tipo, @sucursal, @numero, @producto, @cantidad, @precio

    WHILE @@fetch_status = 0
        BEGIN
            -- Primero sacamos el stock que tiene el producto en el deposito 00
            SET @stock_depo_00 = (SELECT s.stoc_cantidad FROM STOCK s
                                  WHERE s.stoc_producto = @producto AND stoc_deposito = '00' )


            -- Preguntamos si el stock es suficiente
            IF @stock_depo_00 >= @cantidad
                BEGIN
                    PRINT 'Stock suficiente, validamos la compra'

                    INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                        VALUES (@tipo, @sucursal, @numero, @producto, @cantidad, @precio)


                    -- Ahora preguntamos si es un prodcuto compuesto o no
                    IF @producto NOT IN (SELECT comp_producto FROM Composicion)
                        BEGIN
                            PRINT 'Producto simple.'

                            -- Updateamos la tabla STOCK para ese producto
                            UPDATE STOCK
                            SET stoc_cantidad = stoc_cantidad - @cantidad
                            WHERE stoc_producto = @producto AND stoc_deposito = '00'

                        END
                    ELSE        -- En caso de producto compuesto, restamos stock por cada uno de sus componentes
                        BEGIN
                            -- Asumo que si hay stock del producto compuesto en el deposito 00, necesariamente tiene que haber stock de sus componentes en el mismo

                            PRINT 'Producto compuesto. Restamos stock por cada uno de sus componentes'

                            DECLARE @componente CHAR(8)
                            DECLARE @componente_cantidad DECIMAL(12,2)

                            DECLARE cur_componentes CURSOR FOR
                                SELECT
                                    c.comp_componente,
                                    c.comp_cantidad
                                FROM Composicion c
                                WHERE c.comp_producto = @producto

                            OPEN cur_componentes
                            FETCH cur_componentes INTO @componente, @componente_cantidad

                            WHILE @@fetch_status = 0
                                BEGIN
                                    -- Actualizamos el stock por cada uno de los componentes
                                    UPDATE STOCK
                                    SET stoc_cantidad = stoc_cantidad - @componente_cantidad
                                    WHERE stoc_producto = @componente AND stoc_deposito = '00'

                                    FETCH cur_componentes INTO @componente, @componente_cantidad
                                END
                            CLOSE cur_componentes
                            DEALLOCATE cur_componentes
                        END

                END
            ELSE        -- Si no tenemos stock del producto, no permitimos que se agregue ese item factura.
                BEGIN
                    PRINT 'Stock insuficiente. No es posible realizar la compra'
                END

            FETCH cur_item_factura INTO @tipo, @sucursal, @numero, @producto, @cantidad, @precio

        END
        CLOSE cur_item_factura
        DEALLOCATE cur_item_factura
COMMIT



-- Consulta para comprobar que los productos compuestos tienen stock por si mismos
SELECT
    p.prod_detalle,
    s.stoc_cantidad,
    s.stoc_deposito
FROM Producto p
    JOIN Composicion c ON p.prod_codigo = c.comp_componente
    JOIN STOCK s ON p.prod_codigo = s.stoc_producto
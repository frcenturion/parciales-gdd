------------------------------ T-SQL - PARCIAL 5 V2 ------------------------------

/*
    El atributo clie_limite_credito, representa el monto máximo que puede venderse a un cliente en
    el mes en curso. Implementar el/los objetos necesarios para que no se permita realizar una
    venta si el monto total facturado en el mes supera el atributo clie_limite_credito. Considerar
    que esta restricción debe cumplirse siempre y validar también que no se pueda hacer una
    factura de un mes anterior.
*/

CREATE TRIGGER tr_validacion_venta
    ON Factura INSTEAD OF INSERT
AS
BEGIN TRANSACTION

    DECLARE @fact_tipo char(1),
    @fact_sucursal char(4),
    @fact_numero char(8),
    @fact_fecha smalldatetime,
    @fact_vendedor numeric(6),
    @fact_total decimal(12,2),
    @fact_total_impuestos decimal(12,2),
    @fact_cliente: char(6)


    DECLARE @monto_total_facturado_mes DECIMAL(12,2)
    DECLARE @monto_limite DECIMAL(12,2)

    DECLARE cur_item_factura CURSOR FOR
        SELECT * FROM inserted


    OPEN cur_item_factura
    FETCH cur_item_factura INTO @fact_tipo,
    @fact_sucursal ,
    @fact_numero ,
    @fact_fecha ,
    @fact_vendedor ,
    @fact_total ,
    @fact_total_impuestos

    WHILE @@fetch_status = 0
        BEGIN

            SET @monto_limite =
            (
                SELECT
                     clie_limite_credito
                 FROM Cliente
                 WHERE clie_codigo = @fact_cliente
            )


            SET @monto_total_facturado_mes =
            (
                SELECT
                    SUM(f.fact_total)
                FROM Factura f
                WHERE f.fact_cliente = @fact_cliente AND MONTH(f.fact_fecha) = @fact_fecha
            )

            -- Si el monto limite del cliente supera el total facturado por ese cliente en ese mes no se hace la venta
            IF @monto_limite >= @monto_total_facturado_mes
                BEGIN
                    PRINT 'Monto limite alcanzado, cancelando operacion'

                    ROLLBACK TRANSACTION
                END

            ELSE IF DATEDIFF(month, current_timestamp, @fact_fecha) = -1
                BEGIN
                    PRINT 'Se quiere hacer una factura del mes anterior'
                    ROLLBACK TRANSACTION
                END

            ELSE
                BEGIN
                   INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
                        VALUES (@fact_tipo, @fact_sucursal, @fact_numero, @fact_fecha, @fact_vendedor, @fact_total_impuestos, @fact_cliente)
                END


        FETCH NEXT FROM cur_item_factura INTO @fact_tipo,
            @fact_sucursal ,
            @fact_numero ,
            @fact_fecha ,
            @fact_vendedor ,
            @fact_total ,
            @fact_total_impuestos



        END
        CLOSE cur_item_factura
        DEALLOCATE cur_item_factura
COMMIT













------------------------------ T-SQL - PARCIAL 5 ------------------------------

/*
    El atributo clie_limite_credito, representa el monto máximo que puede venderse a un cliente en
    el mes en curso. Implementar el/los objetos necesarios para que no se permita realizar una
    venta si el monto total facturado en el mes supera el atributo clie_limite_credito. Considerar
    que esta restricción debe cumplirse siempre y validar también que no se pueda hacer una
    factura de un mes anterior.
*/


-- OPCION 1: Si consideramos que solo se puede cargar una venta a la vez

CREATE TRIGGER tr_validacion_factura_monto
    ON Factura INSTEAD OF INSERT
AS
BEGIN TRANSACTION
    DECLARE @monto_total_fatcurado_mes DECIMAL(12,2)
    DECLARE @limite_credito DECIMAL(12,2)

    -- Primero tenemos que buscar el monto total facturado en el mes para ese cliente
    SET @monto_total_fatcurado_mes = (SELECT
                                          SUM(f.fact_total)
                                      FROM Factura f
                                      JOIN inserted i ON i.fact_cliente = f.fact_cliente
                                      WHERE F.fact_fecha = current_timestamp
                                      )

    -- Buscamos el monto limite del cliente
    SET @limite_credito = (SELECT
                               c.clie_limite_credito
                           FROM inserted i
                           JOIN Cliente c ON i.fact_cliente = c.clie_codigo
                           )

    -- Validamos que no se haga el insert en caso de que el monto total facturado supere al limite
    IF @monto_total_fatcurado_mes >= @limite_credito
    BEGIN
         PRINT 'Ya se alcanzo el monto total facturado para el presente mes, no se realiza la venta'
    END
    ELSE
    BEGIN
       INSERT INTO Factura SELECT * FROM inserted   -- Insertamos todos los campos de la insercion
    END
COMMIT


-- OPCION 2: Si consideramos que se pueden cargar varias ventas al mismo tiempo

CREATE TRIGGER tr_validacion_factura_monto_2
    ON Factura INSTEAD OF INSERT
AS
BEGIN TRANSACTION
    DECLARE @monto_total_facturado_mes decimal(12,2)
    DECLARE @limite_credito decimal(12,2)

    DECLARE @tipo char(1)
    DECLARE @sucursal char(4)
    DECLARE @numero char(8)
    DECLARE @fecha smalldatetime
    DECLARE @vendedor numeric(6)
    DECLARE @total decimal(12,2)
    DECLARE @total_impuestos decimal(12,2)
    DECLARE @cliente char(6)


    DECLARE cursor_facturacion CURSOR FOR
        SELECT
            i.fact_tipo, i.fact_sucursal, i.fact_numero, i.fact_fecha, i.fact_vendedor, i.fact_total, i.fact_total_impuestos, i.fact_cliente
        FROM inserted i

    OPEN cursor_facturacion
    FETCH cursor_facturacion INTO
        @tipo,
        @sucursal,
        @numero,
        @fecha,
        @vendedor,
        @total,
        @total_impuestos,
        @cliente

    WHILE @@fetch_status = 0
    BEGIN

        -- Calculamos el monto total facturado para ese cliente en el mes actual
        SET @monto_total_fatcurado_mes = (SELECT SUM(f.fact_total)
                                          FROM Factura f
                                          WHERE f.fact_fecha = CURRENT_TIMESTAMP
                                            AND f.fact_cliente = @cliente)



        -- Obtenemos el limite de ese cliente
        SET @limite_credito = (SELECT c.clie_limite_credito
                               FROM Cliente c
                               WHERE c.clie_codigo = @cliente)


        -- Chequeamos que el monto de la factura no exceda el limite
        IF @monto_total_fatcurado_mes >= @limite_credito
        BEGIN
            PRINT 'Ya se alcanzo el monto total facturado para el presente mes, no se realiza la venta'
        END
        ELSE IF @fecha < CURRENT_TIMESTAMP
        BEGIN
            PRINT 'Se esta realizando una factura de un mes anterior al actual, no se procesa la venta'
        END

        ELSE
        BEGIN
            INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
                VALUES (@tipo, @sucursal, @numero, @fecha, @vendedor, @total, @total_impuestos, @cliente)
        END

        FETCH NEXT FROM cursor_facturacion INTO
            @tipo,
            @sucursal,
            @numero,
            @fecha,
            @vendedor,
            @total,
            @total_impuestos,
            @cliente

    END
COMMIT






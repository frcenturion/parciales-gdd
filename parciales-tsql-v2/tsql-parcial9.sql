------------------------------ T-SQL - PARCIAL 9 (2021) ------------------------------

/*
    2.  Realizar un stored procedure que reciba un código de producto y una fecha y devuelva la mayor cantidad de
    días consecutivos a partir de esa fecha que el producto tuvo al menos la venta de una unidad en el día, el
    sistema de ventas on line está habilitado 24-7 por lo que se deben evaluar todos los días incluyendo domingos y feriados.
*/

CREATE PROCEDURE pr_analisis_venta
    @producto CHAR(8),
    @fecha SMALLDATETIME
AS
BEGIN
    DECLARE @mayor_cantidad_dias_consecutivos INT
    DECLARE @dias_consecutivos INT
    DECLARE @fact_fecha SMALLDATETIME
    DECLARE @contador INT

    SET @mayor_cantidad_dias_consecutivos = 0
    SET @dias_consecutivos = 0 -- Arranca en 0 porque es a partir de esa fecha
    SET @contador = 1

    -- Declaramos un cursor para ir recorriendo todos los dias e ir contando los consecutivos
    DECLARE cur_facturas CURSOR FOR
        SELECT
            f.fact_fecha
        FROM Factura f
            JOIN Item_Factura if1 ON f.fact_tipo = if1.item_tipo and f.fact_sucursal = if1.item_sucursal and f.fact_numero = if1.item_numero
        WHERE f.fact_fecha >= @fecha AND if1.item_producto = @producto
        ORDER BY f.fact_fecha

    OPEN cur_facturas
    FETCH cur_facturas INTO
        @fact_fecha

    WHILE @@fetch_status = 0
    BEGIN
        IF DATEDIFF(day, @fecha, @fact_fecha) = @contador
            BEGIN
                SET @contador = @contador + 1
                SET @dias_consecutivos = @dias_consecutivos + 1
            end
        ELSE
            BEGIN
                -- En este caso ya dejamos de tener dias consecutivos
                IF @mayor_cantidad_dias_consecutivos < @dias_consecutivos
                BEGIN
                    SET @mayor_cantidad_dias_consecutivos = @dias_consecutivos
                END


                -- Reiniciamos el contador y la cantidad de dias consecutivos
                SET @contador = 1
                SET @dias_consecutivos = 0
            end
        FETCH NEXT FROM cur_facturas INTO @fact_fecha
    END

    CLOSE cur_facturas
    DEALLOCATE cur_facturas

    RETURN @mayor_cantidad_dias_consecutivos
END

------------ EJERCICIO 1 - TSQL ------------

/*
    Hacer una función que dado un artículo y un deposito devuelva un string que
    indique el estado del depósito según el artículo. Si la cantidad almacenada es
    menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
    % de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
    “DEPOSITO COMPLETO”.
*/

DROP FUNCTION estado_deposito;

CREATE FUNCTION estado_deposito(@articulo char(8), @deposito char(2))
RETURNS varchar(255)
AS
    BEGIN
        declare @estado char(50)
        declare @cantidad_almacenada decimal(12,2)
        declare @limite_ocupacion decimal(12,2)

        SELECT
            @cantidad_almacenada = s.stoc_cantidad,
            @limite_ocupacion = s.stoc_stock_maximo
        FROM STOCK s
        WHERE s.stoc_deposito = @deposito AND s.stoc_producto = @articulo

        IF @cantidad_almacenada IS NULL OR @limite_ocupacion IS NULL
            BEGIN
                set @estado = 'Deposito vacio o limite de ocupacion igual a 0'
                RETURN @estado
            END

        IF(@cantidad_almacenada < @limite_ocupacion)
            set @estado = 'OCUPACION DEL DEPOSITO ' + CAST((@cantidad_almacenada / @limite_ocupacion) * 100 AS varchar(50)) + '%'
        ELSE IF(@cantidad_almacenada >= @limite_ocupacion)
            set @estado = 'DEPOSITO COMPLETO'

        RETURN @estado
    END



SELECT dbo.estado_deposito('00000030', '00')
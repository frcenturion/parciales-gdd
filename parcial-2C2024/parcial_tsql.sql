------------------------------ TSQL - PARCIAL (16/11/2024) ------------------------------

/*
    Curso: K3673
    Alumno: Franco Ezequiel Centurión
    Profesor: Edgardo Lacquaniti
    Legajo: 1780189
*/

DROP TABLE diez_productos_mas_vendidos_por_anio

CREATE TABLE diez_productos_mas_vendidos_por_anio (
    anio INT,
    producto_codigo CHAR(8)
)

DROP PROCEDURE pr_productos_mas_vendidos

CREATE PROCEDURE pr_productos_mas_vendidos
AS
BEGIN
    -- Declaro un cursor para recorrerme todos los años del sistema
    DECLARE cur_anios CURSOR FOR
        SELECT
            DISTINCT(YEAR(fact_fecha))
        FROM Factura
        ORDER BY YEAR(fact_fecha)

    -- Declaro una variable para captar la info del cursor de los anios
    DECLARE @anio INT

    -- Declaro una variable para traerme los productos que va recorriendo el cursor
    DECLARE @producto CHAR(8)


    -- Primero abrimos el cursor para recorrer los años
    OPEN cur_anios
    FETCH cur_anios INTO @anio
    WHILE @@fetch_status = 0
        BEGIN
           -- Ahora por cada año tenemos que buscarnos los 10 productos más vendidos e ir insertándolos en nuestra tabla

        -- Declaro un cursor para traerme los 10 productos mas vendidos en un año especifico (lo traigo de mayor a menor)
            DECLARE cur_productos_mas_vendidos_por_anio CURSOR FOR
                SELECT TOP 10
                    if1.item_producto
                FROM Item_Factura if1
                    JOIN Factura f1 ON if1.item_tipo = f1.fact_tipo and if1.item_sucursal = f1.fact_sucursal and if1.item_numero = f1.fact_numero
                WHERE YEAR(f1.fact_fecha) = @anio
                GROUP BY if1.item_producto
                ORDER BY SUM(if1.item_cantidad) DESC


            OPEN cur_productos_mas_vendidos_por_anio
            FETCH cur_productos_mas_vendidos_por_anio INTO @producto
            WHILE @@fetch_status = 0
                BEGIN

                    -- Vamos insertando cada uno de los productos más vendidos
                    INSERT INTO diez_productos_mas_vendidos_por_anio (anio, producto_codigo)
                        VALUES (@anio,  @producto)

                    FETCH NEXT FROM cur_productos_mas_vendidos_por_anio INTO @producto
                END

            -- Cerramos el cursor y en la proxima vuelta abriremos uno con los productos del año siguiente
            CLOSE cur_productos_mas_vendidos_por_anio
            DEALLOCATE cur_productos_mas_vendidos_por_anio

            FETCH NEXT FROM cur_anios INTO @anio
        END
    CLOSE cur_anios
    DEALLOCATE cur_anios
END

EXEC pr_productos_mas_vendidos

-- Chequeo
SELECT * FROM diez_productos_mas_vendidos_por_anio







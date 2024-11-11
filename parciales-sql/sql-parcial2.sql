------------------------------ SQL - PARCIAL 2 ------------------------------

/*
    Realizar una consulta SQL que devuelva todos los clientes que durante 2 años consecutivos compraron al menos 5
    productos distintos. De esos clientes mostrar:

    1. El código del cliente
    2. El monto total comprado en el 2012
    3. La cantidad de unidades de productos compradas en el 2012

    El resultado debe ser ordenado por aquellos clientes que compraron solo productos compuesto en algún momento, luego
    el resto
*/

SELECT
    f1.fact_cliente as codigo_cliente,

    (
        SELECT
            ISNULL(SUM(f2.fact_total), 0)
        FROM Factura f2
        WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = f1.fact_cliente

    ) as monto_total_2012,

    (
        SELECT
            ISNULL(SUM(if2.item_cantidad), 0)
        FROM Item_Factura if2
                 JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
        WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = f1.fact_cliente

    ) as unidades_compradas_2012

FROM Factura f1
--GROUP BY f1.fact_cliente
ORDER BY f1.fact_cliente DESC

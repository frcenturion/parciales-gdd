------------------------------ SQL - PARCIAL 9 (2021) ------------------------------

/*
    1.  Armar una consulta Sql que retorne:

    - Razón social del cliente
    - Límite de crédito del cliente
    - Producto más comprado en la historia (en unidades)

    Solamente deberá mostrar aquellos clientes que tuvieron mayor cantidad de ventas en el 2012 que
    en el 2011 en cantidades y cuyos montos de ventas en dichos años sean un 30 % mayor el 2012 con
    respecto al 2011. El resultado deberá ser ordenado por código de cliente ascendente

    NOTA: No se permite el uso de sub-selects en el FROM.
*/

SELECT
    c.clie_razon_social as razon_social,
    c.clie_limite_credito as limite_credito,

    (

        SELECT TOP 1
            p2.prod_detalle
        FROM Item_Factura if2
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
            JOIN Producto p2 ON if2.item_producto = p2.prod_codigo
        WHERE f2.fact_cliente = c.clie_codigo
        GROUP BY p2.prod_detalle
        ORDER BY SUM(if2.item_cantidad) DESC

    ) as producto_mas_comprado_historia

FROM Cliente c
WHERE
    (   -- Cantidad de ventas en el 2012
        SELECT
            ISNULL(SUM(if3.item_cantidad), 0)
        FROM Item_Factura if3
            JOIN Factura f3 ON if3.item_tipo = f3.fact_tipo and if3.item_sucursal = f3.fact_sucursal and if3.item_numero = f3.fact_numero
        WHERE f3.fact_cliente = c.clie_codigo AND YEAR(f3.fact_fecha) = 2012

    ) >
    (   -- Cantidad de ventas en el 2011
        SELECT
            ISNULL(SUM(if4.item_cantidad), 0)
        FROM Item_Factura if4
            JOIN Factura f4 ON if4.item_tipo = f4.fact_tipo and if4.item_sucursal = f4.fact_sucursal and if4.item_numero = f4.fact_numero
        WHERE f4.fact_cliente = c.clie_codigo AND YEAR(f4.fact_fecha) = 2011
    )
  AND
    (
        SELECT
            ISNULL(SUM(f5.fact_total))
        FROM Factura f5
        WHERE f5.fact_cliente = c.clie_codigo AND YEAR(f5.fact_fecha) = 2012
    ) >
    (
        SELECT
            ISNULL(SUM(f5.fact_total))
        FROM Factura f5
        WHERE f5.fact_cliente = c.clie_codigo AND YEAR(f5.fact_fecha) = 2011
    ) * 1.3
GROUP BY  c.clie_razon_social, c.clie_limite_credito, c.clie_codigo
ORDER BY c.clie_codigo


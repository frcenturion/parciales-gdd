------------------------------ SQL - PARCIAL 4 (15/11/2022) ------------------------------

/*
    Realizar una consulta SQL que permita saber los clientes que compraron todos los rubros disponibles en el sistema
    en el 2012.

    De estos clientes mostrar, siempre para el 2012

    1. El código del cliente
    2. Código del producto que en cantidades más compró
    3. Nombre del producto del punto 2
    4. Cantidad de productos distintos comprados por el cliente
    5. Cantidad de productos con composición comprados por el cliente

    El resultado debe ser ordenado por razón social del cliente alfabéticamente primero y luego, los clientes que
    compraron entre un 20% y 30% del total facturado en el 2012 primero, luego, los restantes.
*/


SELECT
    c1.clie_codigo as codigo_cliente,

    (
        SELECT TOP 1
            if2.item_producto
        FROM Item_Factura if2
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = c1.clie_codigo
        GROUP BY if2.item_producto
        ORDER BY SUM(if2.item_cantidad)

    ) as cod_producto_mas_comprado,

    (
        SELECT TOP 1
            p2.prod_detalle
        FROM Item_Factura if3
            JOIN Factura f3 ON if3.item_tipo = f3.fact_tipo and if3.item_sucursal = f3.fact_sucursal and if3.item_numero = f3.fact_numero
            JOIN Producto p2 ON if3.item_producto = p2.prod_codigo
        WHERE f3.fact_cliente = c1.clie_codigo
        GROUP BY p2.prod_detalle, if3.item_producto     -- Importante agrupar por los dos
        ORDER BY SUM(if3.item_cantidad)

    ) as nombre_producto_mas_comprado,

    COUNT(DISTINCT if1.item_producto) as cantidad_productos_distintos_comprados,

    (
        SELECT
            ISNULL(SUM(if3.item_cantidad), 0)
        FROM Factura f3
            JOIN Item_Factura if3 ON f3.fact_tipo = if3.item_tipo and f3.fact_sucursal = if3.item_sucursal and f3.fact_numero = if3.item_numero
            JOIN Composicion com1 ON if3.item_producto = com1.comp_producto
        WHERE f3.fact_cliente = c1.clie_codigo
    ) as cantidad_productos_con_composicion

FROM Cliente c1
    JOIN Factura f1 ON c1.clie_codigo = f1.fact_cliente
    JOIN Item_Factura if1 ON f1.fact_tipo = if1.item_tipo and f1.fact_sucursal = if1.item_sucursal and f1.fact_numero = if1.item_numero
WHERE YEAR(f1.fact_fecha) = 2012
GROUP BY c1.clie_codigo, c1.clie_razon_social
HAVING (
            SELECT
                COUNT(DISTINCT r.rubr_id)
            FROM Rubro r                        -- Cantidad de rubros totales
        ) = (
            SELECT
                COUNT(DISTINCT r2.rubr_id)
            FROM Rubro r2
                JOIN Producto p2  ON r2.rubr_id = p2.prod_rubro
                JOIN Item_Factura if3 ON p2.prod_codigo = if3.item_producto
            WHERE if

    )
ORDER BY c1.clie_razon_social




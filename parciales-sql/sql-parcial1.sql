------------------------------ SQL - PARCIAL 1 (12/11/2022) ------------------------------

/*
    Realizar una consulta SQL que permita saber los clientes que compraron por encima del promedio de compras
    (fact_total) de todos los clientes del 2012.

    De estos clientes mostrar para el 2012:

    1. El código de cliente
    2. La razón social del cliente
    3. Código del producto que en cantidades más compró
    4. El nombre del producto del punto 3
    5. Cantidad de productos distintos comprados por el cliente
    6. Cantidad de productos con composición comprados por el cliente

    El resultado deberá ser ordenado poniendo primero a aquellos clientes que compraron más de entre 5 y 10 productos
    distintos en el 2012.
*/


SELECT
    c1.clie_codigo as codigo_cliente,
    c1.clie_razon_social as razon_social,

    (
        SELECT TOP 1
            if1.item_producto
        FROM Item_Factura if1
            JOIN Factura f2 ON if1.item_tipo = f2.fact_tipo and if1.item_sucursal = f2.fact_sucursal and if1.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = c1.clie_codigo
        GROUP BY if1.item_producto                  -- ACORDARSE DEL GROUP BY
        ORDER BY SUM(if1.item_cantidad) DESC

    ) as cod_producto_mas_comprado,

    (
        SELECT TOP 1
            p1.prod_detalle
        FROM Item_Factura if1
                JOIN Factura f2 ON if1.item_tipo = f2.fact_tipo and if1.item_sucursal = f2.fact_sucursal and if1.item_numero = f2.fact_numero
                JOIN Producto p1 ON if1.item_producto = p1.prod_codigo
        WHERE f2.fact_cliente = c1.clie_codigo
        GROUP BY p1.prod_detalle                -- Agrupamos x detalle porque queremos saber cuales son los productos mas comprados y sacar el + grande
        ORDER BY SUM(if1.item_cantidad) DESC

    ) as nom_producto_mas_comprado,

    -- Aca hay 2 opciones: JOIN con Item_Factura o subconsulta

    COUNT(DISTINCT if1.item_producto) as cant_productos_distintos_comprados ,           -- Esto me genera 3 entradas mas (66 en vez de 63) no se por qué
/*    (

    ) as cantidad_productos_distintos*/


    (
        SELECT
            COUNT(comp1.comp_producto)
        FROM Item_Factura if2
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
            JOIN Producto p1 ON if2.item_producto = p1.prod_codigo
            JOIN Composicion comp1 ON p1.prod_codigo = comp1.comp_componente
        WHERE f2.fact_cliente = c1.clie_codigo
        GROUP BY f2.fact_cliente                    -- Agrupamos x cliente porque queremos hacer un COUNT x cliente

    ) as cant_productos_composicion_comprados_1,

    (
        SELECT
            SUM(if2.item_cantidad)
        FROM Item_Factura if2
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
            JOIN Producto p1 ON if2.item_producto = p1.prod_codigo
            JOIN Composicion comp1 ON p1.prod_codigo = comp1.comp_componente
        WHERE f2.fact_cliente = c1.clie_codigo
        GROUP BY f2.fact_cliente                    -- Agrupamos x cliente porque queremos hacer un COUNT x cliente

    ) as cant_productos_composicion_comprados_2




FROM Factura f1
    JOIN Cliente c1 ON f1.fact_cliente = c1.clie_codigo
    JOIN Item_Factura if1 ON f1.fact_tipo = if1.item_tipo and f1.fact_sucursal = if1.item_sucursal and f1.fact_numero = if1.item_numero
WHERE YEAR(f1.fact_fecha) = 2012
GROUP BY c1.clie_razon_social, c1.clie_codigo
HAVING SUM(f1.fact_total) >
    (
        SELECT
            AVG(f2.fact_total)
        FROM Factura f2
        WHERE YEAR(f2.fact_fecha) = 2012        -- Promedio de compras de todos los clientes de 2012
    )
ORDER BY
    CASE
        WHEN COUNT(DISTINCT if1.item_producto) BETWEEN 5 AND 10
        THEN 1
        ELSE 0
    END

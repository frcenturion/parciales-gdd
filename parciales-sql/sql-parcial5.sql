------------------------------ SQL - PARCIAL 5 ------------------------------

/*
    Realizar una consulta SQL que retorne, para cada producto que no fue vendido en el 2012, la
    siguiente información:

    a) Detalle del producto.
    b) Rubro del producto.
    c) Cantidad de productos que tiene el rubro.
    d) Precio máximo de venta en toda la historia, sino tiene ventas en la historia, mostrar 0.

    El resultado deberá mostrar primero aquellos productos que tienen composición.

    Nota: No se permite el uso de sub-selects en el FROM ni funciones definidas por el usuario para este
    punto.
*/

SELECT
    p1.prod_detalle as detalle_producto,
    r1.rubr_detalle as rubro,

    (
        SELECT
            COUNT(p2.prod_detalle)
        FROM Producto p2
            JOIN Rubro r2 ON p2.prod_rubro = r2.rubr_id
        WHERE r2.rubr_id = r1.rubr_id
        GROUP BY r2.rubr_id

    ) as cantidad_productos_rubro,

    ISNULL(MAX(if1.item_precio), 0) as precio_maximo_historia

FROM Producto p1
    JOIN Rubro r1 ON p1.prod_rubro = r1.rubr_id
    LEFT JOIN Item_Factura if1 ON p1.prod_codigo = if1.item_producto
    LEFT JOIN Factura f1 ON if1.item_tipo = f1.fact_tipo and if1.item_sucursal = f1.fact_sucursal and if1.item_numero = f1.fact_numero
WHERE YEAR(f1.fact_fecha) != 2012 OR f1.fact_fecha IS NULL   -- Le agrego el ISNULL para incluir los que nunca fueron vendidos
GROUP BY p1.prod_detalle, p1.prod_codigo, r1.rubr_detalle, r1.rubr_id
ORDER BY
    (
        SELECT
            p2.prod_codigo
        FROM Producto p2
            JOIN Composicion c1 ON p2.prod_codigo = c1.comp_componente
        WHERE p2.prod_codigo = p1.prod_codigo
        GROUP BY p2.prod_codigo
    )




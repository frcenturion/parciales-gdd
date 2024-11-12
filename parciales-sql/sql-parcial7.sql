------------------------------ SQL - PARCIAL 7 (Simulacro 2024) ------------------------------

/*
    Realizar una consulta SQL que muestre aquellos productos que tengan
    entre 2 y 4 componentes distintos a nivel producto y cuyos
    componentes no fueron todos vendidos (todos) en 2012 pero si en el          El todos me indica que es un where.
    2011.

    De estos productos mostrar:
    i. El código de producto.
    ii. El nombre del producto.
    iii. El precio máximo al que se vendió en 2011 el producto.

    El resultado deberá ser ordenado por cantidad de unidades vendidas
    del producto en el 2011.
*/

----------------- Consulta principal -----------------

SELECT
    p1.prod_codigo as codigo_producto,
    p1.prod_detalle as nombre_producto,

    (
        SELECT
            MAX(if2.item_precio)
        FROM Item_Factura if2
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
        WHERE YEAR(f2.fact_fecha) = 2011 AND if2.item_producto = p1.prod_codigo
        GROUP BY if2.item_producto

    ) as precio_maximo_2011

FROM Producto p1
JOIN Composicion c1 ON p1.prod_codigo = c1.comp_componente
WHERE c1.comp_componente  IN (SELECT
                                     p2.prod_codigo
                                 FROM Producto p2
                                 JOIN Item_Factura it2 ON p2.prod_codigo = it2.item_producto
                                 JOIN Factura f1 ON it2.item_tipo = f1.fact_tipo and it2.item_sucursal = f1.fact_sucursal and it2.item_numero = f1.fact_numero
                                 WHERE YEAR(f1.fact_fecha) != 2012 AND YEAR(f1.fact_fecha) = 2011)
/*    AND c1.comp_componente IN (SELECT
                                   p2.prod_codigo
                               FROM Producto p2
                                        JOIN Item_Factura it2 ON p2.prod_codigo = it2.item_producto
                                        JOIN Factura f1 ON it2.item_tipo = f1.fact_tipo and it2.item_sucursal = f1.fact_sucursal and it2.item_numero = f1.fact_numero
                               WHERE YEAR(f1.fact_fecha) = 2011)*/
GROUP BY p1.prod_detalle, p1.prod_codigo
HAVING COUNT(DISTINCT c1.comp_componente) BETWEEN 2 AND 4     -- Esto va en el having porque tenemos que contar los componentes de cada producto agrupado
ORDER BY (

     SELECT
         SUM(it2.item_cantidad)
     FROM Producto p2
              JOIN Item_Factura it2 ON p2.prod_codigo = it2.item_producto
              JOIN Factura f1 ON it2.item_tipo = f1.fact_tipo and it2.item_sucursal = f1.fact_sucursal and it2.item_numero = f1.fact_numero
     WHERE YEAR(f1.fact_fecha) = 2011 AND p2.prod_codigo = p1.prod_codigo
     GROUP BY p2.prod_codigo

        )



----------------- Consultas auxiliares -----------------


-- Precio máximo al que se vendió un producto en 2011

SELECT
    if2.item_producto,
    MAX(if2.item_precio)
FROM Item_Factura if2
    JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
WHERE YEAR(f2.fact_fecha) = 2011
GROUP BY if2.item_producto


--

SELECT
    p.prod_codigo,
    p.prod_detalle
FROM Producto p
    JOIN Composicion c ON p.prod_codigo = c.comp_componente
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
    JOIN Factura f ON it.item_tipo = f.fact_tipo and it.item_sucursal = f.fact_sucursal and it.item_numero = f.fact_numero
WHERE it.item_producto = c.comp_componente
GROUP BY p.prod_codigo, p.prod_detalle



-- Productos vendidos en el 2012

SELECT
    p2.prod_codigo,
    YEAR(f1.fact_fecha)
FROM Producto p2
         JOIN Item_Factura it2 ON p2.prod_codigo = it2.item_producto
         JOIN Factura f1 ON it2.item_tipo = f1.fact_tipo and it2.item_sucursal = f1.fact_sucursal and it2.item_numero = f1.fact_numero
WHERE YEAR(f1.fact_fecha) = 2011
--GROUP BY p2.prod_codigo, YEAR(f1.fact_fecha)
ORDER BY p2.prod_codigo


-- Cantidad de productos vendidos en el 2011
SELECT
    SUM(it2.item_cantidad)
FROM Producto p2
         JOIN Item_Factura it2 ON p2.prod_codigo = it2.item_producto
         JOIN Factura f1 ON it2.item_tipo = f1.fact_tipo and it2.item_sucursal = f1.fact_sucursal and it2.item_numero = f1.fact_numero
WHERE YEAR(f1.fact_fecha) = 2011
GROUP BY p2.prod_codigo
ORDER BY p2.prod_codigo

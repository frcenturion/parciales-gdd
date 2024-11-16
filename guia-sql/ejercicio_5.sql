------------ EJERCICIO 5 ------------

/*
    Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
    stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
    fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.
*/


-- En la subconsulta tenemos que obtener los productos que egresaron en 2011, junto con su cantidad de egresos

SELECT
    p.prod_codigo,
    p.prod_detalle,
    sum(it.item_cantidad) AS cantidad_egresos
FROM Producto p
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
    JOIN Factura f ON it.item_tipo = f.fact_tipo and it.item_sucursal = f.fact_sucursal and it.item_numero = f.fact_numero
WHERE YEAR(f.fact_fecha) = '2012'
GROUP BY p.prod_codigo, p.prod_detalle
HAVING
    sum(it.item_cantidad) >
    (
        SELECT
            sum(it2.item_cantidad) AS egresos_2011
        FROM Item_Factura it2
            JOIN Factura f2 ON it2.item_tipo = f2.fact_tipo and it2.item_sucursal = f2.fact_sucursal and it2.item_numero = f2.fact_numero
        WHERE YEAR(f2.fact_fecha) = '2011' AND it2.item_producto = p.prod_codigo
    )




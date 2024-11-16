------------ EJERCICIO 11 ------------

/*
    Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
    productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
    ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
    solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
    el año 2012.
*/

SELECT
    fam.fami_detalle,
    count(distinct (p.prod_codigo)) AS cantidad_diferentes_productos_vendidos,
    sum(fac.fact_total) AS total_sin_impuestos
FROM Familia fam
    JOIN Producto p ON fam.fami_id = p.prod_familia
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
    JOIN Factura fac ON it.item_tipo = fac.fact_tipo and it.item_sucursal = fac.fact_sucursal and it.item_numero = fac.fact_numero
WHERE YEAR(fac.fact_fecha) = '2012'
GROUP BY fam.fami_detalle
HAVING sum(fac.fact_total) > '20000'
ORDER BY count(distinct (p.prod_codigo)) DESC

-- La condición de venta superior lo pongo en el having porque me pide sobre las FAMILIAS, que es justamente lo que estamos agrupando


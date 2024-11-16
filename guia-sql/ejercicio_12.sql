------------ EJERCICIO 12 ------------

/*
    Mostrar nombre de producto, cantidad de clientes distintos que lo compraron importe
    promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
    producto y stock actual del producto en todos los depósitos.

    Se deberán mostrar aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
    ordenarse de mayor a menor por monto vendido del producto.
*/

SELECT
    p.prod_detalle,
    count(distinct (f.fact_cliente)) AS cantidad_distinta_clientes,
    avg(it.item_precio) AS importe_promedio,
    count(s.stoc_deposito) AS cantidad_depositos,
    sum(s.stoc_cantidad) AS stock_actual_total
FROM Producto p
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
    JOIN Factura f ON it.item_tipo = f.fact_tipo and it.item_sucursal = f.fact_sucursal and it.item_numero = f.fact_numero
    JOIN STOCK s ON p.prod_codigo = s.stoc_producto
WHERE year(f.fact_fecha) = '2012'
GROUP BY p.prod_detalle
ORDER BY
    avg(it.item_precio) DESC






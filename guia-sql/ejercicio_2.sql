------------ EJERCICIO 2 ------------

/*
    Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por cantidad vendida.
*/

-- Los artículos vendidos son aquellos productos que aparezcan en un item factura, que a su vez estan en una factura, en donde tenemos la fecha

SELECT * FROM Producto;
SELECT * FROM Item_Factura;
SELECT * FROM Factura;

SELECT
    p.prod_codigo,
    p.prod_detalle,
    YEAR(f.fact_fecha) as anio_venta,
    sum(it.item_cantidad) as cantidad_vendida
FROM Producto p
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
    JOIN Factura f ON it.item_tipo = f.fact_tipo and it.item_sucursal = f.fact_sucursal and it.item_numero = f.fact_numero
WHERE YEAR(f.fact_fecha) = '2012'
GROUP BY p.prod_codigo, p.prod_detalle, YEAR(f.fact_fecha)







------------ EJERCICIO 7 ------------

/*
    Generar una consulta que muestre para cada artículo código, detalle, mayor precio
    menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
    10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
    stock.
*/

SELECT * FROM Producto p;
SELECT * FROM STOCK s ORDER BY s.stoc_cantidad;

SELECT
    p.prod_codigo,
    p.prod_detalle,
    max(it.item_precio) AS mayor_precio,
    min(it.item_precio) AS menor_precio,
    (max(it.item_precio) - min(it.item_precio)) AS diferencia_precio
FROM Producto p
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
    JOIN STOCK s ON p.prod_codigo = s.stoc_producto
WHERE s.stoc_cantidad > '0'
GROUP BY p.prod_codigo, p.prod_detalle


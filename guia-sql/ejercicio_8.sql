------------ EJERCICIO 8 ------------

/*
    Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
    artículo, stock del depósito que más stock tiene.
*/

SELECT
    p.prod_detalle,
    max(s.stoc_cantidad) AS mayor_stock
FROM Producto p
    JOIN STOCK s ON p.prod_codigo = s.stoc_producto
    JOIN DEPOSITO d ON s.stoc_deposito = d.depo_codigo
GROUP BY p.prod_detalle



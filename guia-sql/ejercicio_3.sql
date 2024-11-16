------------ EJERCICIO 3 ------------

/*
    Realizar una consulta que muestre código de producto, nombre de producto y el stock
    total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
    nombre del artículo de menor a mayor.
*/

SELECT
    p.prod_codigo,
    p.prod_detalle,
    isnull(sum(s.stoc_cantidad), 0) as stock_producto
FROM Producto p
    LEFT JOIN STOCK s ON p.prod_codigo = s.stoc_producto
GROUP BY p.prod_codigo, p.prod_detalle
ORDER BY p.prod_detalle DESC
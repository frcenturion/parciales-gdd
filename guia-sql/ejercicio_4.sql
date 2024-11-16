------------ EJERCICIO 4 ------------

/*
     Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
    artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
    promedio por depósito sea mayor a 100.
*/

-- La cantidad de articulos por depósito nos lo dice la tabla STOCK


SELECT
    p.prod_codigo,
    p.prod_detalle,
    isnull(count(c.comp_producto), 0) as cantidad_articulos
FROM Producto p
    LEFT JOIN Composicion c ON p.prod_codigo = c.comp_componente
    JOIN STOCK s ON p.prod_codigo = s.stoc_producto
GROUP BY p.prod_codigo, p.prod_detalle
HAVING
    avg(s.stoc_cantidad) > '100'
ORDER BY cantidad_articulos DESC



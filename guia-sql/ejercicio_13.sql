------------ EJERCICIO 13 ------------

/*
    Realizar una consulta que retorne para cada producto que posea composición nombre
    del producto, precio del producto, precio de la sumatoria de los precios por la cantidad de los productos que lo componen.

    Solo se deberán mostrar los productos que estén
    compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
    cantidad de productos que lo componen.
*/

-- Al hacer un join de productos y composicion obtenemos aquellos que tienen composicion

-- Si tomamos los productos por separados, me dan distintos al precio del combo, el combo es mas barato

SELECT
    prod_codigo,
    prod_detalle
FROM Producto
WHERE prod_codigo = '00001104'

SELECT comp_producto FROM Composicion;

SELECT
    p.prod_codigo,
    p.prod_detalle
FROM Producto p
JOIN Composicion c
    ON p.prod_codigo = c.comp_producto


SELECT
    Combo.prod_detalle,
    Combo.prod_precio AS precio_combo,
    sum(Componente.prod_precio * c.comp_cantidad) AS precio_total_combo
FROM Producto Combo
    JOIN Composicion c ON Combo.prod_codigo = c.comp_producto
    JOIN Producto Componente ON Componente.prod_codigo = c.comp_componente
GROUP BY Combo.prod_detalle, Combo.prod_precio
HAVING sum(c.comp_cantidad) > 2
ORDER BY sum(c.comp_cantidad)






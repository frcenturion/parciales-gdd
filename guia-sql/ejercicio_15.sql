------------ EJERCICIO 15 ------------

/*
    Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
    (en la misma factura) más de 500 veces. El resultado debe mostrar el código y
    descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
    juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
    juntos dichos productos. Los distintos pares no deben retornarse más de una vez.

    Ejemplo de lo que retornaría la consulta:
    PROD1 DETALLE1 PROD2 DETALLE2 VECES
    1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
    1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2
*/


/*
    NOTAS:

    - La cantidad de veces que se vende un producto está reflejada por una entrada en item factura, o sea, si yo tengo una entrada de un producto X
    en la tabla Item_Factura, eso quiere decir que se vendio una vez.
*/


SELECT
    p1.prod_codigo,
    p1.prod_detalle,
    p2.prod_codigo,
    p2.prod_detalle,
    count(*) as veces
FROM Item_Factura i1
JOIN Item_Factura i2 ON
    i1.item_numero = i2.item_numero AND
    i1.item_sucursal = i2.item_sucursal AND
    i1.item_tipo = i2.item_tipo AND
    i1.item_producto > i2.item_producto         -- Aca tendria que ser != pero al poner esto me muestra los pares de forma conmutativa (ver chat de whatsapp)
JOIN Producto p1 ON i1.item_producto = p1.prod_codigo
JOIN Producto p2 ON i2.item_producto = p2.prod_codigo
GROUP BY p1.prod_codigo, p1.prod_detalle, p2.prod_codigo, p2.prod_detalle
HAVING COUNT(*) > 488
ORDER BY veces DESC





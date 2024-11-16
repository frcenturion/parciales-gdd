------------ EJERCICIO 6 ------------

/*
    Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
    rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
    tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.
*/

-- Por cantidad de artículos de un rubro entiendo a la cantidad NO en stock, sino cuantos productos tiene ese rubro
-- Para lo del stock mayor al articulo podemos usar una subconsulta -> tiene que estar en el WHERE porque la distinción es por artículo, no por grupo de artículos

SELECT
    r.rubr_id,
    r.rubr_detalle,
    count(p.prod_codigo) AS cantidad_articulos,
    sum(s.stoc_cantidad) AS stock_total_rubro
FROM Rubro r
    JOIN Producto p ON r.rubr_id = p.prod_rubro
    JOIN STOCK s ON p.prod_codigo = s.stoc_producto
WHERE s.stoc_cantidad >
       (
            SELECT
                s2.stoc_cantidad
            FROM STOCK s2
            WHERE s2.stoc_producto = '00000000' AND s2.stoc_deposito = '00'

        )
GROUP BY r.rubr_id, r.rubr_detalle
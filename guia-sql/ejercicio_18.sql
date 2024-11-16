------------ EJERCICIO 18 ------------

/*
    Escriba una consulta que retorne una estadística de ventas para todos los rubros.

    La consulta debe retornar:

    DETALLE_RUBRO: Detalle del rubro
    VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
    PROD1: Código del producto más vendido de dicho rubro
    PROD2: Código del segundo producto más vendido de dicho rubro
    CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30 días

    La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
    por cantidad de productos diferentes vendidos del rubro.
*/

SELECT
    r.rubr_detalle AS detalle_rubro,
    SUM(it.item_precio * it.item_cantidad) AS ventas,

    ISNULL((
        SELECT TOP 1
            p2.prod_codigo
        FROM Producto p2 JOIN Item_Factura it2 ON p2.prod_codigo = it2.item_producto
        WHERE r.rubr_id = p2.prod_rubro
        GROUP BY p2.prod_codigo
        ORDER BY SUM(it2.item_cantidad) DESC
    ), 0) AS prod1,

    ISNULL((
        SELECT

    ), 0) AS prod2
FROM Rubro r
    JOIN Producto p ON r.rubr_id = p.prod_rubro
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
GROUP BY r.rubr_detalle



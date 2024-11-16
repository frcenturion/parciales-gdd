------------ EJERCICIO 17 ------------

/*
    Escriba una consulta que retorne una estadística de ventas por año y mes para cada producto.
    La consulta debe retornar:

    PERIODO: Año y mes de la estadística con el formato YYYYMM
    PROD: Código de producto
    DETALLE: Detalle del producto
    CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
    VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo pero del año anterior
    CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el periodo

    La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada por periodo y código de producto
*/

SELECT
    FORMAT(f.fact_fecha, 'yyyy-MM') AS periodo,
    p.prod_codigo AS prod,
    p.prod_detalle AS detalle,
    SUM(it.item_cantidad) AS cantidad_vendida,
    ISNULL((
        SELECT
            SUM(it2.item_cantidad)
        FROM Item_Factura it2 JOIN Factura f2 ON it2.item_tipo = f2.fact_tipo and it2.item_sucursal = f2.fact_sucursal and it2.item_numero = f2.fact_numero
        WHERE YEAR(f2.fact_fecha) = (YEAR(f.fact_fecha) - 1) AND MONTH(f2.fact_fecha) = MONTH(f.fact_fecha)
    ),0) AS ventas_anio_ant,
    COUNT(f.fact_numero) AS cant_facturas
FROM Producto p
    JOIN Item_Factura it ON p.prod_codigo = it.item_producto
    JOIN Factura f ON it.item_tipo = f.fact_tipo and it.item_sucursal = f.fact_sucursal and it.item_numero = f.fact_numero
GROUP BY f.fact_fecha, p.prod_codigo, p.prod_detalle
ORDER BY FORMAT(f.fact_fecha, 'yyyy-MM'), p.prod_codigo



------------------------------ SQL - PARCIAL 6 (2024) ------------------------------

/*
    Sabiendo que un producto recurrente es aquel producto que al menos
    se compró durante 6 meses en el último año.
    Realizar una consulta SQL que muestre los clientes que tengan
    productos recurrentes y de estos clientes mostrar:

    i. El código de cliente.
    ii. El nombre del producto más comprado del cliente.
    iii. La cantidad comprada total del cliente en el último año.

    Ordenar el resultado por el nombre del cliente alfabéticamente.
*/

----------------- Consulta principal -----------------

SELECT
    c1.clie_razon_social as nombre_cliente,
    f1.fact_cliente as codigo_cliente,

    (
        SELECT TOP 1
            p1.prod_detalle
        FROM Item_Factura if1
        JOIN Factura f2 ON if1.item_tipo = f2.fact_tipo and if1.item_sucursal = f2.fact_sucursal and if1.item_numero = f2.fact_numero
        JOIN Producto p1 ON if1.item_producto = p1.prod_codigo
        WHERE f2.fact_cliente = f1.fact_cliente     -- Con esto lo linkeamos con lo de afuera
        GROUP BY if1.item_producto, p1.prod_detalle
        ORDER BY COUNT(if1.item_producto) DESC      -- Interpreto que el producto mas comprado es el que mas ocurrencias tiene, no el que mayor cantidad comprada

    ) as nombre_producto_mas_comprado,

    (
        SELECT
            SUM(if1.item_cantidad)
        FROM Item_Factura if1
        JOIN Factura f2 ON if1.item_tipo = f2.fact_tipo and if1.item_sucursal = f2.fact_sucursal and if1.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = f1.fact_cliente AND f2.fact_fecha >= DATEADD(YEAR, -1, (SELECT MAX(fact_fecha) FROM Factura)) -- Estamos diciendo que l fecha sea mayor o igual a el año - 1

    ) as cantidad_comprada_total

FROM Factura f1
JOIN Cliente c1 ON f1.fact_cliente = c1.clie_codigo
JOIN Item_Factura if2 ON f1.fact_tipo = if2.item_tipo and f1.fact_sucursal = if2.item_sucursal and f1.fact_numero = if2.item_numero
WHERE if2.item_producto IN (SELECT item_producto FROM Item_Factura WHERE fact_fecha >= DATEADD(MONTH, -6, (SELECT MAX(fact_fecha) FROM Factura)))
GROUP BY f1.fact_cliente, c1.clie_razon_social
ORDER BY c1.clie_razon_social




----------------- Consultas auxiliares -----------------

-- Producto mas comprado por el cliente

SELECT TOP 1
    P1.prod_detalle,
    COUNT(if1.item_producto)
FROM Item_Factura if1
JOIN Factura f1 ON if1.item_tipo = f1.fact_tipo and if1.item_sucursal = f1.fact_sucursal and if1.item_numero = f1.fact_numero
JOIN Producto p1 ON if1.item_producto = p1.prod_codigo
WHERE f1.fact_cliente = 01804
GROUP BY if1.item_producto, P1.prod_detalle
ORDER BY COUNT(if1.item_producto) DESC


-- Cantidad total comprada por el cliente

SELECT
    SUM(if1.item_cantidad)
FROM Item_Factura if1
         JOIN Factura f2 ON if1.item_tipo = f2.fact_tipo and if1.item_sucursal = f2.fact_sucursal and if1.item_numero = f2.fact_numero
WHERE f2.fact_cliente = 01804


-- Productos recurrentes son aquellos que pertenecen a los que fueron comprados en los ultimos 6 meses

SELECT
    if1.item_producto
FROM Item_Factura if1
    JOIN Factura f2 ON if1.item_tipo = f2.fact_tipo and if1.item_sucursal = f2.fact_sucursal and if1.item_numero = f2.fact_numero
WHERE if1.item_producto IN (SELECT item_producto FROM Item_Factura WHERE fact_fecha >= DATEADD(MONTH, -6, CURRENT_TIMESTAMP))
GROUP BY if1.item_producto





------------------------------ SQL - PARCIAL 8 (13/11/2024) ------------------------------

/*
    Realizar una consulta SQL que muestre, para los clientes que compraron únicamente en años pares, la siguiente
    información:

    1. Número de fila
    2. El código del cliente
    3. El nombre del producto más comprado por el cliente
    4. La cantidad total comprada por el cliente en el último año

    El resultado debe estar ordenado en función de la cantidad máxima comprada por cliente, de mayor a menor.
*/


SELECT

    ROW_NUMBER() OVER (ORDER BY MAX(if1.item_cantidad) DESC) as numero_fila,        -- Usamos el mismo ORDER BY que abajo

    f1.fact_cliente as codigo_cliente,

    (
        SELECT TOP 1
            p2.prod_detalle
        FROM Factura f2
            JOIN Item_Factura if2 ON f2.fact_tipo = if2.item_tipo and f2.fact_sucursal = if2.item_sucursal and f2.fact_numero = if2.item_numero
            JOIN Producto p2 ON if2.item_producto = p2.prod_codigo
        WHERE f2.fact_cliente = f1.fact_cliente
        GROUP BY p2.prod_detalle
        ORDER BY SUM(if2.item_cantidad)

    ) as producto_mas_comprado,

    -- Aca pense en NO hacer una subconsulta pero tendria que cambiar el WHERE de afuera
    -- Entiendo que es la cantidad total de TODOS los productos, no del producto del punto anterior
    (
        SELECT
            SUM(if3.item_cantidad)
        FROM Factura f3
            JOIN Item_Factura if3 ON f3.fact_tipo = if3.item_tipo and f3.fact_sucursal = if3.item_sucursal and f3.fact_numero = if3.item_numero
        WHERE f3.fact_cliente = f1.fact_cliente AND YEAR(f3.fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)       -- Último año

    ) as cantidad_total_comprada_ultimo_anio

FROM Factura f1
    JOIN Item_Factura if1 ON f1.fact_tipo = if1.item_tipo and f1.fact_sucursal = if1.item_sucursal and f1.fact_numero = if1.item_numero
WHERE YEAR(f1.fact_fecha) % 2 = 0 -- Años pares
GROUP BY f1.fact_cliente
--ORDER BY f1.fact_cliente
ORDER BY MAX(if1.item_cantidad) DESC            -- Entiendo a cantidad maxima como la cantidad maxima de algun item de la factura que haya comprado



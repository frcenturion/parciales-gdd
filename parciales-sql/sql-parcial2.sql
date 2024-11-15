------------------------------ SQL - PARCIAL 2 (28/07/2023) ------------------------------

/*
    Realizar una consulta SQL que devuelva todos los clientes que durante 2 años consecutivos compraron al menos 5
    productos distintos. De esos clientes mostrar:

    1. El código del cliente
    2. El monto total comprado en el 2012
    3. La cantidad de unidades de productos compradas en el 2012

    El resultado debe ser ordenado por aquellos clientes que compraron solo productos compuesto en algún momento, luego
    el resto
*/


SELECT
    f1.fact_cliente as codigo_cliente,

    (

        SELECT
            ISNULL(SUM(f2.fact_total),0)
        FROM Factura f2
        WHERE f2.fact_cliente = f1.fact_cliente AND YEAR(f2.fact_fecha) = 2012
        GROUP BY f2.fact_cliente

    ) as monto_total_2012,

    (
        SELECT
            SUM(if1.item_cantidad)
        FROM Item_Factura if1
            JOIN Factura f3 ON if1.item_tipo = f3.fact_tipo and if1.item_sucursal = f3.fact_sucursal and if1.item_numero = f3.fact_numero
        WHERE f3.fact_cliente = f1.fact_cliente AND YEAR(f3.fact_fecha) = 2012
        GROUP BY f3.fact_cliente

    ) as cantidad_unidades_2012

FROM Factura f1
GROUP BY f1.fact_cliente
/*HAVING
    (
        -- Esta consulta me devuelve la cantidad de productos comprados en años consecutivos, si la mayor cantidad es mayor a 4 pasa el criterio

        SELECT TOP 1
            COUNT(DISTINCT if3.item_producto) + COUNT(DISTINCT if2.item_producto)
        FROM Factura f3
            JOIN Item_Factura if3 ON f3.fact_tipo = if3.item_tipo and f3.fact_sucursal = if3.item_sucursal and f3.fact_numero = if3.item_numero
            JOIN Factura f2 ON f2.fact_cliente = f3.fact_cliente        -- Solo queremos que la otra factura sea del mismo cliente que la primera
            JOIN Item_Factura if2 ON f2.fact_tipo = if2.item_tipo and f2.fact_sucursal = if2.item_sucursal and f2.fact_numero = if2.item_numero
        WHERE f3.fact_cliente = f1.fact_cliente AND DATEDIFF(year, f3.fact_fecha, f2.fact_fecha) = 1 AND if3.item_producto > if2.item_producto  -- Le pongo el > para que no me agarre pares conmutativos
        GROUP BY YEAR(f2.fact_fecha), YEAR(f3.fact_fecha)
        ORDER BY COUNT(DISTINCT if3.item_producto) + COUNT(DISTINCT if2.item_producto) DESC

    ) > 9*/     -- Mayor a 9 porque estoy considerando la suma de productos comprados en los dos años consecutivos

HAVING
    (
        -- Productos distintos comprados en un año
        SELECT
            COUNT(DISTINCT if3.item_producto)
        FROM Factura f3
            JOIN Item_Factura if3 ON f3.fact_tipo = if3.item_tipo and f3.fact_sucursal = if3.item_sucursal and f3.fact_numero = if3.item_numero
        WHERE f3.fact_cliente = f1.fact_cliente AND YEAR(f3.fact_fecha) = YEAR(f1.fact_fecha)       -- Pedimos que el cliente y el año coincidan con la de afuera

    ) > 4
        AND
    (
        -- Productos distintos comprados en un año consecutivo al de la factura del cliente
        SELECT
            COUNT(DISTINCT if3.item_producto)
        FROM Factura f3
             JOIN Item_Factura if3 ON f3.fact_tipo = if3.item_tipo and f3.fact_sucursal = if3.item_sucursal and f3.fact_numero = if3.item_numero
        WHERE f3.fact_cliente = f1.fact_cliente AND (YEAR(f3.fact_fecha) = YEAR(f1.fact_fecha) + 1 OR YEAR(f3.fact_fecha) = YEAR(f1.fact_fecha) - 1)

    ) > 4
ORDER BY
    CASE
        WHEN f1.fact_cliente IN (
            SELECT
                f4.fact_cliente
            FROM Factura f4
                JOIN Item_Factura if4 ON f4.fact_tipo = if4.item_tipo and f4.fact_sucursal = if4.item_sucursal and f4.fact_numero = if4.item_numero
                --WHERE if4.item_producto IN (SELECT comp_producto FROM Composicion)    -- Con esto nos ahorramos el JOIN de abajo
                JOIN Composicion c1 ON c1.comp_producto = if4.item_producto
            ) THEN 1
            ELSE 0
    END







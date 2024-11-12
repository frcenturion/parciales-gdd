------------------------------ SQL - PARCIAL 3 (19/11/2022) ------------------------------

/*
    Realizar una consulta SQL que permita saber los clientes que compraron en el 2012 al menos 1 unidad de todos los
    productos compuestos

    De estos clientes mostrar, siempre para el 2012

    1. El código del cliente
    2. Código del producto que en cantidades más compró
    3. El número de fila según el orden establecido con un alias llamado ORDINAL
    4. Cantidad de productos distintos comprados por el cliente
    5. Monto total comprado

    El resultado debe ser ordenado por razón social del cliente alfabéticamente primero y luego, los clientes que
    compraron entre un 20% y 30% del total facturado en el 2012 primero, luego, los restantes.
*/

SELECT
    c1.clie_codigo,

    (
        SELECT TOP 1
            it1.item_producto
        FROM Item_Factura it1
            JOIN Factura f1 ON it1.item_tipo = f1.fact_tipo and it1.item_sucursal = f1.fact_sucursal and it1.item_numero = f1.fact_numero
            WHERE f1.fact_cliente = c1.clie_codigo
        GROUP BY it1.item_producto
        ORDER BY SUM(it1.item_cantidad) DESC

    ) as codigo_producto_mas_comprado,

    -- numero de fila

    COUNT(DISTINCT it1.item_producto) as cantidad_productos_distintos,

    SUM(f1.fact_total) as monto_total_comprado


FROM Cliente c1
    JOIN Factura f1 ON c1.clie_codigo = f1.fact_cliente
    JOIN Item_Factura it1 ON f1.fact_tipo = it1.item_tipo and f1.fact_sucursal = it1.item_sucursal and f1.fact_numero = it1.item_numero
    LEFT JOIN Composicion com ON com.comp_producto = it1.item_producto
WHERE YEAR(f1.fact_fecha) = 2012
GROUP BY c1.clie_codigo, c1.clie_razon_social
HAVING
    (
        SELECT COUNT(DISTINCT c.comp_producto)
        FROM Composicion C
    ) = COUNT(DISTINCT com.comp_producto)    -- Estamos pidiendo que la cantidad de productos compuestos que compro el cliente sea igual al total de productos compuestos que hay en la tabla
ORDER BY c1.clie_razon_social,
        CASE
             WHEN SUM(f1.fact_total) BETWEEN (SELECT
                                                  0.2 * SUM(f3.fact_total)
                                              FROM Factura f3
                                              WHERE YEAR(f3.fact_fecha) = 2012) AND (SELECT
                                                                                        0.3 * SUM(f3.fact_total)
                                                                                     FROM Factura f3
                                                                                     WHERE YEAR(f3.fact_fecha) = 2012) THEN 0
             ELSE 1
        END



-- Todos los productos compuestos
SELECT *
FROM Producto p1
    JOIN Composicion c1 ON p1.prod_codigo = c1.comp_componente
ORDER BY p1.prod_codigo


-- Total facturado 2012
SELECT
    0.3 * SUM(f1.fact_total)
FROM Factura f1
WHERE YEAR(f1.fact_fecha) = 2012

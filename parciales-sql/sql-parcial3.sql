------------------------------ SQL - PARCIAL 3 ------------------------------

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
    f1.fact_cliente as codigo_cliente,

    (
        SELECT TOP 1
            if1.item_producto
        FROM Item_Factura if1
            JOIN Factura f2 ON if1.item_tipo = f2.fact_tipo and if1.item_sucursal = f2.fact_sucursal and if1.item_numero = f2.fact_numero
        WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = f1.fact_cliente
        GROUP BY if1.item_producto
        ORDER BY SUM(if1.item_cantidad) DESC

    ) as producto_mas_comprado,

    --ROW_NUMBER() over () AS ORDINAL

    COUNT(DISTINCT it2.item_producto) as cantidad_productos_distintos,

    SUM(f1.fact_total) as monto_total_comprado,

    COUNT(DISTINCT c.comp_producto) as cantidad_productos_composicion_comprados  -- Esto tiene que ser igual a la cantidad total para determinar que compro 1 de cada

FROM Factura f1
    JOIN Item_Factura it2 ON f1.fact_tipo = it2.item_tipo and f1.fact_sucursal = it2.item_sucursal and f1.fact_numero = it2.item_numero
    LEFT JOIN Composicion c ON c.comp_producto = it2.item_producto
    JOIN Cliente cli ON f1.fact_cliente = cli.clie_codigo
WHERE YEAR(f1.fact_fecha) = 2012
GROUP BY f1.fact_cliente
HAVING
    (
        SELECT
            COUNT(DISTINCT c.comp_producto)
        FROM Composicion c
           ) = COUNT(DISTINCT c.comp_producto)



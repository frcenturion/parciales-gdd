------------ EJERCICIO 14 ------------

/*
   Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que debe retornar son:

    Código del cliente
    Cantidad de veces que compro en el último año
    Promedio por compra en el último año
    Cantidad de productos diferentes que compro en el último año
    Monto de la mayor compra que realizo en el último año

    Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en  el último año.
    No se deberán visualizar NULLs en ninguna columna
*/

-- La cantidad de veces que compro en el ultimo año está dado por la cantidad de facturas que tiene

SELECT
    f.fact_cliente AS codigo_cliente,
    count(f.fact_cliente) AS cantidad_compras,
    avg(f.fact_total) AS promedio_compra,
    count(distinct(it.item_producto)) AS cantidad_productos_diferentes,
    max(f.fact_total) AS monto_mayor_compra
FROM Factura f
    JOIN Item_Factura it ON f.fact_tipo = it.item_tipo and f.fact_sucursal = it.item_sucursal and f.fact_numero = it.item_numero
WHERE YEAR(f.fact_fecha) =
        (
            SELECT MAX(YEAR(f2.fact_fecha)) FROM Factura f2
        )
GROUP BY f.fact_cliente
ORDER BY count(f.fact_cliente)


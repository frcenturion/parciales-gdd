------------------------------ SQL - PARCIAL (16/11/2024) ------------------------------

/*
    Curso: K3673
    Alumno: Franco Ezequiel Centurión
    Profesor: Edgardo Lacquaniti
    Legajo: 1780189
*/

SELECT
    ROW_NUMBER() over (ORDER BY SUM(if1.item_cantidad) DESC) as numero_fila,
    c1.clie_codigo as codigo_cliente,
    c1.clie_razon_social as nombre_cliente,

    SUM(if1.item_cantidad) as cantidad_total_comprada,

    (
        SELECT TOP 1
            r1.rubr_detalle     -- Categoria más comprada (agarre el detalle pero también podría haber agarrado el id)
        FROM Factura f2
            JOIN Item_Factura if2 ON f2.fact_tipo = if2.item_tipo and f2.fact_sucursal = if2.item_sucursal and f2.fact_numero = if2.item_numero
            JOIN Producto p1 ON if2.item_producto = p1.prod_codigo
            JOIN Rubro r1 ON p1.prod_rubro = r1.rubr_id
        WHERE f2.fact_cliente = c1.clie_codigo AND YEAR(f2.fact_fecha) = 2012
        GROUP BY r1.rubr_id, r1.rubr_detalle
        ORDER BY SUM(if2.item_cantidad)

    ) as categoria_mas_comprada_2012

FROM Cliente c1
    JOIN Factura f1 ON c1.clie_codigo = f1.fact_cliente
    JOIN Item_Factura if1 ON f1.fact_tipo = if1.item_tipo and f1.fact_sucursal = if1.item_sucursal and f1.fact_numero = if1.item_numero
GROUP BY c1.clie_codigo, c1.clie_razon_social
HAVING
    (
        SELECT COUNT(DISTINCT r2.rubr_id)
        FROM Rubro r2
            JOIN Producto p2 ON r2.rubr_id = p2.prod_rubro
            JOIN Item_Factura if2 ON p2.prod_codigo = if2.item_producto
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = c1.clie_codigo AND YEAR(f2.fact_fecha) = 2012

        ) > 3       -- Compro en más de 3 rubros diferentes en el 2012
        AND
        NOT EXISTS( SELECT                      -- No existe una factura de ese cliente que haya sido emitida en un año impar (o sea, todas las compras fueron en años pares)
                        1
                    FROM Factura f3
                    WHERE f3.fact_cliente = c1.clie_codigo AND YEAR(f3.fact_fecha) % 2 != 0)

ORDER BY SUM(if1.item_cantidad) DESC


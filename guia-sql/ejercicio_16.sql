------------ EJERCICIO 16 ------------

/*
    Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
    en la empresa, se pide una consulta SQL que retorne aquellos clientes cuyas ventas son
    inferiores a 1/3 del promedio de ventas del producto que más se vendió en el 2012.
    Además mostrar
    1. Nombre del Cliente
    2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
    3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
    mostrar solamente el de menor código) para ese cliente.
    Aclaraciones:
    La composición es de 2 niveles, es decir, un producto compuesto solo se compone de
    productos no compuestos.
    Los clientes deben ser ordenados por código de provincia ascendente.
*/

SELECT
    c.clie_razon_social
FROM Cliente c
    JOIN Factura f ON c.clie_codigo = f.fact_cliente
HAVING count(f.fact_cliente) <
        (
            SELECT
                AVG()
            FROM Factura f2 JOIN Item_Factura it ON f2.fact_tipo = it.item_tipo and f2.fact_sucursal = it.item_sucursal and f2.fact_numero = it.item_numero
            WHERE YEAR(f2.fact_fecha) = '2012'

        )



--  Promedio de ventas del producto mas vendido del 2012



SELECT TOP 1
    SUM(it.item_cantidad)
FROM Factura f2 JOIN Item_Factura it ON f2.fact_tipo = it.item_tipo and f2.fact_sucursal = it.item_sucursal and f2.fact_numero = it.item_numero
WHERE YEAR(f2.fact_fecha) = '2012'
GROUP BY it.item_producto
ORDER BY SUM(it.item_cantidad) DESC



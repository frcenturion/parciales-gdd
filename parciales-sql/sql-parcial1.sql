------------------------------ SQL - PARCIAL 1 ------------------------------

/*
    Realizar una consulta SQL que permita saber los clientes que compraron por encima del promedio de compras
    (fact_total) de todos los clientes del 2012.

    De estos clientes mostrar para el 2012:

    1. El código de cliente
    2. La razón social del cliente
    3. Código del producto que en cantidades más compró
    4. El nombre del producto del punto 3
    5. Cantidad de productos distintos comprados por el cliente
    6. Cantidad de productos con composición comprados por el cliente

    El resultado deberá ser ordenado poniendo primero a aquellos clientes que compraron más de entre 5 y 10 productos
    distintos en el 2012.
*/


-- Consulta para obtener el promedio de compras de todos los clientes del 2012

SELECT
    AVG(f.fact_total) as promedio_compras
FROM Factura f
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY f.fact_cliente, f.fact_total
ORDER BY f.fact_cliente

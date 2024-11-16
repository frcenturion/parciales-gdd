------------ EJERCICIO 1 ------------

/*
    Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
    igual a $ 1000 ordenado por código de cliente.
*/

SELECT * FROM Cliente;

SELECT
    c.clie_codigo,
    c.clie_razon_social,
    c.clie_limite_credito
FROM Cliente c
WHERE c.clie_limite_credito >= '1000'
ORDER BY c.clie_codigo


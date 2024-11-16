------------ EJERCICIO 9 ------------

/*
    Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
    mismo y la cantidad de depósitos que ambos tienen asignados
*/

SELECT
    j.empl_codigo AS codigo_jefe,
    e.empl_codigo AS codigo_subordinado,
    e.empl_nombre AS nombre_subordinado,
    count(d.depo_encargado) AS cantidad_depositos_jefe
FROM Empleado j
    JOIN Empleado e ON e.empl_codigo = j.empl_codigo
    LEFT JOIN DEPOSITO d ON j.empl_codigo = d.depo_encargado
GROUP BY j.empl_codigo, e.empl_codigo, e.empl_nombre


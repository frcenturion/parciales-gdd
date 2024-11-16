------------ EJERCICIO 3 - TSQL ------------

/*
    Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
    en caso que sea necesario. Se sabe que debería existir un único gerente general
    (debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
    sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
    mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la empresa.
    Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
    de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
    de empleados que había sin jefe antes de la ejecución
*/

SELECT * FROM Empleado

-- Empleados SIN jefe
SELECT
    e.empl_nombre,
    e.empl_apellido,
    e.empl_salario,
    e.empl_ingreso
FROM Empleado e
WHERE e.empl_jefe IS NULL

-- Solo tenemos 1 empleado sin JEFE, que es el gerente general, por ende no va a ser necesario corregir la tabla


-- Vamos a armar un procedure que corrija la tabla en caso de ser necesario
    -- OUTPUT es como un return

DROP PROCEDURE dbo.corregir_empleados_sin_jefe

CREATE PROCEDURE dbo.corregir_empleados_sin_jefe
AS
BEGIN
    DECLARE @cantidad INT
    DECLARE @codigo_gerente_general NUMERIC(6)

    SELECT
        @cantidad = COUNT(*)
    FROM Empleado e
    WHERE e.empl_jefe IS NULL

    IF @cantidad > 1
    BEGIN
        SELECT TOP 1
            @codigo_gerente_general = e.empl_codigo
        FROM Empleado e
        WHERE e.empl_jefe IS NULL
        ORDER BY e.empl_salario DESC, e.empl_ingreso


        UPDATE Empleado
        SET empl_jefe = @codigo_gerente_general
        WHERE empl_jefe IS NULL AND empl_codigo != @codigo_gerente_general
    END
    RETURN @cantidad
END


-- Test

DECLARE @empleados INT
EXEC @empleados = dbo.corregir_empleados_sin_jefe
SELECT @empleados AS empleadosSinJefesAntes


---------------- T-SQL - CLASE 1 ----------------

/*
    - Sintaxis
    - Vistas
    - Funciones
    - Cursores
*/



-- Primer programa

BEGIN

    declare @var1 char(100)
    declare @var2 int

    set @var2 = 1 + 2
    set @var1 = 'Hola mundo'

    print @var2
    print @var1

END


-- Programa usando las tablas

BEGIN

    declare @v_cod char(5)
    declare @v_nombre char(100)

    set @v_cod = '00000'

    select
        @v_nombre = clie_razon_social   -- La asignación la hacemos en el mismo select
    from Cliente
    where
        clie_codigo = @v_cod


    print @v_nombre

END

-- Sentencia IF

BEGIN

    IF(SELECT COUNT(*) FROM Cliente) > 1000
        begin
            print 'hay mas de 1000 clientes'
        end
    ELSE
        begin
            print 'hay menos de 1000 clientes'
        end

END


-- Sentencia WHILE

BEGIN

    declare @var int
    set @var = 1

    while @var <= 100
        begin
            print @var
            set @var = @var + 1
        end

END

-- Vistas

CREATE VIEW VIEW_EJEMPLO (COD, NOMBRE, TOTAL)
AS
    SELECT
        c.clie_codigo,
        c.clie_razon_social,
        SUM(fact_total)

    FROM Cliente c
        JOIN Factura f ON c.clie_codigo = f.fact_cliente
    GROUP BY c.clie_codigo, c.clie_razon_social

SELECT * FROM VIEW_EJEMPLO
WHERE
    cod = '00000'

-- Alter view

ALTER VIEW VIEW_EJEMPLO (COD, NOMBRE, TOTAL)
AS
    SELECT
        c.clie_codigo,
        c.clie_razon_social,
        f.fact_total
    FROM Cliente c
        JOIN Factura f ON c.clie_codigo = f.fact_cliente



-- Update sobre la vista como si fuera una tabla

UPDATE VIEW_EJEMPLO
    SET
        nombre = 'Modificado por view'
    WHERE
        COD = '00000'

-- Cuando tiro un update sobre una vista, si el campo es de una tabla simple, y puede detectar univocamente a la fila, me va a modificar la tabla original
-- Puede identificar univocamente cuando no tenemos funciones de grupo, distinct, etc.

-- Funciones

-- Funcion que devuelve un escalar

CREATE FUNCTION fnc_cuadrado(@param1 decimal(12,2))
RETURNS decimal(14,4)
AS
    BEGIN
        declare @result decimal(12,2)

        set @result = @param1 * @param1
        return @result
    END

-- Se puede usar asi o bien como cualquier otra funcion que usaríamos en una query

SELECT dbo.fnc_cuadrado(12)

SELECT
    clie_codigo,
    dbo.fnc_cuadrado(clie_limite_credito),
    clie_limite_credito
FROM Cliente c

-- Funcion que devuelve una tabla
CREATE FUNCTION fnc_tabla1(@codigo char(6))
RETURNS TABLE
AS
    RETURN (SELECT * FROM Cliente WHERE clie_codigo != @codigo)

-- Estas se tienen que usar en el from, en un IN o en un exists, porque devuelven una tabla
SELECT * FROM dbo.fnc_tabla1('00000')
ORDER BY
    clie_razon_social DESC

-- Cursores

DECLARE @cod char(5)
DECLARE @nombre char(100)

-- Creación de un cursor
DECLARE mi_cursor CURSOR FOR
    SELECT
        c.clie_codigo,
        c.clie_razon_social
    FROM Cliente c
    ORDER BY
        clie_codigo DESC

-- Estamos creando un puntero que va a apuntar a esa consulta SQL


OPEN mi_cursor
FETCH mi_cursor into @cod, @nombre

WHILE @@FETCH_STATUS = 0    -- Devuelve 0 si el FETCH anterior cayo en una fila
BEGIN
    PRINT @nombre
    FETCH mi_cursor into @cod, @nombre
END
CLOSE mi_cursor
DEALLOCATE mi_cursor -- Free

-- Hacer update con cursor
DECLARE mi_cursor2 CURSOR FOR
    SELECT
        c.clie_codigo,
        c.clie_razon_social
    FROM Cliente c
    ORDER BY
        clie_codigo DESC
    FOR UPDATE OF
        clie_razon_social

WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @cod = '00000'
            UPDATE Cliente SET clie_razon_social = 'CAMBIADO FOR UPDATE CURSOR' WHERE CURRENT OF mi_cursor2
        PRINT @nombre
        FETCH mi_cursor into @cod, @nombre
    END
CLOSE mi_cursor
DEALLOCATE mi_cursor -- Free
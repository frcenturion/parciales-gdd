CREATE TRIGGER tr_actualizar_comisiones_masivas
ON Empleado
AFTER UPDATE
AS
BEGIN
    -- Declaración de variables para capturar datos de cada empleado actualizado
    DECLARE @emp_id INT,
            @nuevo_porcentaje DECIMAL(5, 2),
            @fac_fecha DATE,
            @inicio_mes DATE,
            @fin_mes DATE;

    -- Declaración del cursor para recorrer los empleados afectados por el UPDATE
    DECLARE cur_empleados CURSOR FOR
    SELECT
        emp_id,
        emp_porcentaje_comision
    FROM INSERTED;

    -- Abrir el cursor
    OPEN cur_empleados;

    FETCH NEXT FROM cur_empleados INTO @emp_id, @nuevo_porcentaje;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Determinar las facturas del empleado afectado
        DECLARE cur_facturas CURSOR FOR
        SELECT f.fac_fecha
        FROM Factura f
        WHERE f.emp_id = @emp_id;

        -- Abrir cursor para las facturas del empleado
        OPEN cur_facturas;
        FETCH NEXT FROM cur_facturas INTO @fac_fecha;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Calcular el inicio y fin del mes correspondiente a la fecha de la factura
            SET @inicio_mes = DATEFROMPARTS(YEAR(@fac_fecha), MONTH(@fac_fecha), 1);
            SET @fin_mes = DATEADD(MONTH, 1, @inicio_mes);

            -- Actualizar las comisiones del empleado para facturas dentro del mes correspondiente
            UPDATE c
            SET com_monto = f.fac_monto_total * (@nuevo_porcentaje / 100)
            FROM Comision c
            JOIN Factura f ON c.fac_id = f.fac_id
            WHERE c.emp_id = @emp_id
              AND f.fac_fecha >= @inicio_mes
              AND f.fac_fecha < @fin_mes;

            FETCH NEXT FROM cur_facturas INTO @fac_fecha;
        END;

        -- Cerrar y desasignar el cursor de facturas
        CLOSE cur_facturas;
        DEALLOCATE cur_facturas;

        -- Continuar con el siguiente empleado
        FETCH NEXT FROM cur_empleados INTO @emp_id, @nuevo_porcentaje;
    END;

    -- Cerrar y desasignar el cursor de empleados
    CLOSE cur_empleados;
    DEALLOCATE cur_empleados;


















-- Procedure para registrar la info dada una factura
CREATE PROCEDURE registrar_comision
AS
BEGIN

    -- Hacemos un cursor para recorrer todas las facturas del sistema
    DECLARE cur_facturas CURSOR FOR
        SELECT
            f.fact_tipo,
            f.fact_sucursal,
            f.fact_numero,
            f.fact_vendedor,
            f.fact_total
        FROM Factura f


    -- Declaramos variables para captar la info de factura
    DECLARE @fact_tipo char(1),
        @fact_sucursal char(4),
        @fact_numero char(8),
        @fact_vendedor numeric(6),
        @fact_total decimal(12,2),
        @fact_fecha smalldatetime

    DECLARE @porcentaje_comision decimal(12,2)

    -- Recorremos el cursor y vamos almacenando en nuestra tabla toda la info
    OPEN cur_facturas
    FETCH cur_facturas INTO @fact_tipo, @fact_sucursal, @fact_numero, @fact_vendedor, @fact_total, @fact_fecha

    WHILE @@fetch_status = 0
        BEGIN

            -- Buscamos la comision del vendedor asociado a la factura
            SET @porcentaje_comision = (SELECT empl_comision FROM Empleado WHERE empl_codigo = @fact_vendedor)

            -- Insertamos
            INSERT INTO Comision_Vendedor (vendedor_id, porcentaje_comision, fact_tipo, fact_sucursal, fact_numero, fact_fecha, comision)
            VALUES (@fact_vendedor, @porcentaje_comision, @fact_tipo, @fact_sucursal, @fact_numero, @fact_fecha, @porcentaje_comision * @fact_total)

            FETCH NEXT FROM cur_facturas INTO  @fact_tipo, @fact_sucursal, @fact_numero, @fact_vendedor, @fact_total, @fact_fecha
        END
END
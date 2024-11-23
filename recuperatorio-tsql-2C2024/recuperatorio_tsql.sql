------------------------------ TSQL - PRIMER RECUPERATORIO (23/11/2024) ------------------------------

/*
    Curso: K3673
    Alumno: Franco Ezequiel Centurión
    Profesor: Edgardo Lacquaniti
    Legajo: 1780189
*/

-- Tabla para registrar las comisiones de los vendedores por cada factura
CREATE TABLE Comision_Vendedor  (

    -- Informacion relevante de la factura
    fact_tipo char(1),
    fact_sucursal char(4),
    fact_numero char(8),
    fact_fecha smalldatetime,

    -- Informacion relevante del vendedor
    vendedor_id numeric(6),
    porcentaje_comision decimal(12,2),
    comision decimal(12,2)  -- Este es calculable

    -- Ponemos como PK la factura y vendedor
    CONSTRAINT PK_Comision_Vendedor PRIMARY KEY (fact_tipo, fact_sucursal, fact_numero, vendedor_id)
)


-- Trigger para cargar las comisiones en nuestra tabla ante una venta
CREATE TRIGGER tr_factura
    ON Factura AFTER INSERT
AS
BEGIN TRANSACTION

    -- Declaramos variables para captar la info de factura
    DECLARE @fact_tipo char(1),
        @fact_sucursal char(4),
        @fact_numero char(8),
        @fact_vendedor numeric(6),
        @fact_total decimal(12,2),
        @fact_fecha smalldatetime

    DECLARE @porcentaje_comision decimal(12,2)

    -- Cuando se emite una factura, tenemos que almacenar la informacion en la tabla
    DECLARE cur_facturas CURSOR FOR
        SELECT
            i.fact_tipo,
            i.fact_sucursal,
            i.fact_numero,
            i.fact_vendedor,
            i.fact_total,
            i.fact_fecha
        FROM inserted i


    OPEN cur_facturas
    FETCH cur_facturas INTO @fact_tipo, @fact_sucursal, @fact_numero, @fact_vendedor, @fact_total, @fact_fecha
    WHILE @@fetch_status = 0
        BEGIN

            -- Buscamos la comision del vendedor que emite la factura
            SET @porcentaje_comision = (SELECT empl_comision FROM Empleado WHERE empl_codigo = @fact_vendedor)

            -- Insertamos la información en nuestra tabla
            INSERT INTO Comision_Vendedor (vendedor_id, porcentaje_comision, fact_tipo, fact_sucursal, fact_numero, fact_fecha, comision)
            VALUES (@fact_vendedor, @porcentaje_comision, @fact_tipo, @fact_sucursal, @fact_numero, @fact_fecha, @porcentaje_comision * @fact_total)

            -- Pasamos a la siguiente factura
            FETCH NEXT FROM cur_facturas INTO @fact_tipo, @fact_sucursal, @fact_numero, @fact_vendedor, @fact_total, @fact_fecha
        END
    CLOSE cur_facturas
    DEALLOCATE cur_facturas
COMMIT


-- Trigger para manejar los UPDATE en la comisión de los Empleados
CREATE TRIGGER tr_cambios_comision
    ON Empleado AFTER UPDATE
AS
BEGIN TRANSACTION

    -- Cuando se produce un UPDATE en el Vendedor (y en particular en la comision) hay que actualizar en nuestra tabla
    -- las comisiones de las facturas del mes actual (mes en el que se ejecuta el trigger)
    DECLARE @fecha_actual smalldatetime
    DECLARE @fact_fecha smalldatetime

    SET @fecha_actual = CURRENT_TIMESTAMP       -- Tomamos el mes actual

    DECLARE cur_empleados CURSOR FOR
        SELECT
            i.empl_codigo,
            i.empl_comision
        FROM inserted i


    DECLARE @empl_codigo numeric(6),
        @empl_comision decimal(12,2)


    -- Vamos recorriendo uno por uno los empleados que se actualizaron
    OPEN cur_empleados
    FETCH cur_empleados INTO @empl_codigo, @empl_comision
    WHILE @@fetch_status = 0
        BEGIN

            -- Si la comision nueva es distinta a la comision que tenia antes, se modifico la comision y se debe actualizar
            IF @empl_comision != (SELECT empl_comision FROM deleted WHERE empl_codigo = @empl_codigo)
                BEGIN
                    -- Determinamos las facturas que tiene asociado el empleado afectado en nuestra tabla
                    DECLARE cur_factura_tabla CURSOR FOR
                     SELECT
                        cv.fact_fecha -- Solo nos importa tomar la fecha de la factura para comparar
                    FROM Comision_Vendedor cv
                    WHERE cv.vendedor_id = @empl_codigo

                    -- Abrir cursor para las facturas del empleado en nuestra tabla
                    OPEN cur_factura_tabla
                    FETCH NEXT FROM cur_factura_tabla INTO @fact_fecha;

                    WHILE @@FETCH_STATUS = 0
                    BEGIN

                        -- Actualizar las comisiones del empleado para facturas dentro del mes correspondiente
                        UPDATE cv
                        SET cv.porcentaje_comision = @empl_comision
                        FROM Comision_Vendedor cv
                        WHERE MONTH(cv.fact_fecha) = MONTH(CURRENT_TIMESTAMP) AND YEAR(cv.fact_fecha) = YEAR(CURRENT_TIMESTAMP)

                        FETCH NEXT FROM cur_factura_tabla INTO @fact_fecha;
                    END;


                    CLOSE cur_factura_tabla
                    DEALLOCATE cur_factura_tabla
            END

            -- Vamos con el siguiente empleado
            FETCH NEXT FROM cur_empleados INTO @empl_codigo, @empl_comision

        END

    CLOSE cur_empleados
    DEALLOCATE cur_empleados
COMMIT


-- Vistas
CREATE VIEW vw_porcentaje_y_comision_factura (factura, porcentaje_comision, comision)
AS
    SELECT
        cv.fact_numero,
        cv.porcentaje_comision,
        cv.comision
    FROM Comision_Vendedor cv
GO

CREATE VIEW vw_acumulado_mensual_comisiones (mes, anio, vendedor, acumulado_mensual)
AS
    SELECT
        MONTH(cv.fact_fecha),
        YEAR(cv.fact_fecha),
        cv.vendedor_id,
        SUM(cv.comision)
    FROM Comision_Vendedor cv
    GROUP BY MONTH(cv.fact_fecha), YEAR(cv.fact_fecha), cv.vendedor_id
GO

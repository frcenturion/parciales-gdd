---------------- T-SQL - CLASE 3 ----------------

/*
    - Ejercicio inventado por el profesor
    - Ejercicio 10 (este lo hago en otro archivo)
*/


-- EJERCICIO 1 (inventado por el profesor) --

/*
    Crear el/los objetos de base de datos que ante la venta del producto '00000030' registre en una estructura adicional
    el mes, año y la cantidad de ese producto que se está comprando por mes y año

    Vamos a descomponer el problema en varios pasos:

    1) Entender lo que pide

    2) Que tipo de trigger me conviene y sobre qué evento y tabla

        - AFTER
        - INSERT
        - item_factura: item_factura es la tabla donde se registra la venta, por ende es de ahi donde tenemos que generar el trigger.

        Para nosotros la venta se concreta con el insert.


    3) Que otros objetos necesito para poder desarrollarlo

        Necesitamos una estructura adicional, en este caso, una tabla.

        CREATE TABLE vta_30 (mes int, anio int, cantidad decimal(12,2))

        CURSOR: Usamos un cursor porque podemos insertar varios registros en una misma operacion de insert

    4) Desarrollo

    5) Testing
*/

SELECT * FROM Item_Factura it
WHERE it.item_numero = '00000030'



-- Creamos la estructura adicional


CREATE TABLE vta_producto_30 (
    mes int not null,
    anio int not null,
    cantidad decimal(12,2)
)

ALTER TABLE vta_producto_30 ADD PRIMARY KEY (mes, anio)     -- le agregamos PK


CREATE TRIGGER tr_venta_prod_30
    ON Item_Factura AFTER insert
AS
BEGIN TRANSACTION

    declare @mes int
    declare @anio int
    declare @cantidad decimal(12,2)

    DECLARE mi_cursor CURSOR FOR
        SELECT
            year(f.fact_fecha),
            month(f.fact_fecha),
            sum(i.item_cantidad)
        FROM INSERTED i
        JOIN Factura f ON
            f.fact_numero = i.item_numero AND
            f.fact_sucursal = i.item_sucursal AND
            f.fact_tipo = i.item_tipo
        WHERE i.item_producto = '00001415'
        GROUP BY month(f.fact_fecha), year(f.fact_fecha)


    OPEN mi_cursor
    FETCH mi_cursor INTO
        @mes,
        @anio,
        @cantidad
    WHILE @@fetch_status = 0
        BEGIN
            UPDATE vta_producto_30
                SET cantidad = cantidad + @cantidad
            WHERE
                mes = @mes AND
                anio = @anio

            IF @@rowcount = 0     -- Esto nos devuelve la cantidad de filas afectadas por la operacion -> si es 0, significa que no hay nada que actualizar y tenemos que insertar
                INSERT INTO vta_producto_30 (mes, anio, cantidad)
                    VALUES (@mes, @anio, @cantidad)
        END
    CLOSE mi_cursor
    DEALLOCATE mi_cursor
COMMIT;






-- Esta es la consulta que me devuelve, por cada uno de los item producto, la cantidad vendida en un determinado mes y año
SELECT
    month(f.fact_fecha) as 'mes',
    year(f.fact_fecha) as 'anio',
    sum(it.item_cantidad) as 'cantidad'
FROM Item_Factura it
    JOIN Factura f on it.item_tipo = f.fact_tipo and it.item_sucursal = f.fact_sucursal and it.item_numero = f.fact_numero
WHERE it.item_producto = '00001415'
GROUP BY month(f.fact_fecha), year(f.fact_fecha)
ORDER BY 2, 1

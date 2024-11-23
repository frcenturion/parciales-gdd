------------------------------ T-SQL - PARCIAL 4 V2 (15/11/2022) ------------------------------

/*
    Implementar una regla de negocio en línea que al realizar una venta (SOLO INSERCIÓN) permita componer los productos
    descompuestos, es decir, si se guardan en la factura 2 hamb. 2 papas 2 gasesosas se deberá guardar en la factura 2 COMBO1.
    Si 1 COMBO1 equivale a: 1 hamb. 1 papa y 1 gaseosa.

    Nota: considerar que cada vez que se guardan los items, se mandan todos los productos de ese item a la vez, y no de
    manera parcial.
*/

CREATE TRIGGER tr_composicion_productos
    ON Item_Factura INSTEAD OF INSERT
AS
BEGIN TRANSACTION

    -- Buscamos e insertamos los combos que se pueden formar
    INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
    SELECT
        i.item_tipo,
        i.item_sucursal,
        i.item_numero,
        c.comp_producto AS item_producto, -- Código del combo
        FLOOR(MIN(i.item_cantidad / c.comp_cantidad)) AS item_cantidad, -- Cantidad de combos
        p.prod_precio AS item_precio -- Precio del combo desde Producto
    FROM inserted i
             JOIN Composicion c ON i.item_producto = c.comp_componente
             JOIN Producto p ON c.comp_producto = p.prod_codigo
    GROUP BY i.item_tipo, i.item_sucursal, i.item_numero, c.comp_producto, p.prod_precio
    HAVING FLOOR(MIN(i.item_cantidad / c.comp_cantidad)) > 0;

    -- Una vez que insertamos en Item_Factura todos los combos, tenemos que procesar uno por uno los productos insertados para insertar los restantes o aquellos que no forman parte
    -- del combo

    DECLARE @item_tipo char,
            @item_sucursal char(4),
            @item_numero char(8),
            @item_producto char(8),
            @item_cantidad decimal(12, 2),
            @item_precio decimal(12, 2),
            @combo_cantidad decimal(12, 2);


    DECLARE cur_inserted CURSOR FOR
        SELECT i.item_tipo, i.item_sucursal, i.item_numero, i.item_producto, i.item_cantidad, i.item_precio
        FROM inserted i;

    OPEN cur_inserted;

    FETCH NEXT FROM cur_inserted INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad, @item_precio;

    WHILE @@FETCH_STATUS = 0
        BEGIN

            -- Calcular cuántas unidades de este producto se usaron en combos
            SELECT @combo_cantidad = SUM(FLOOR(@item_cantidad / c.comp_cantidad) * c.comp_cantidad)
            FROM Composicion c
            WHERE c.comp_componente = @item_producto;

            -- Insertar los sobrantes si quedan
            IF (@item_cantidad - ISNULL(@combo_cantidad, 0)) > 0
                BEGIN
                    INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                    VALUES (@item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad - ISNULL(@combo_cantidad, 0), @item_precio);
                END

            FETCH NEXT FROM cur_inserted INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad, @item_precio;
        END

    CLOSE cur_inserted;
    DEALLOCATE cur_inserted;

COMMIT;

SELECT * FROM Item_Factura

SELECT * FROM Composicion


INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
    VALUES ('A', '0003', '00092444', '00001123', 3, 100.54),
           ('A', '0003', '00092444', '00001109', 1, 100.55),
            ('A', '0003', '00092444', '00000030', 1, 100.55)


SELECT * FROM Producto


select * from Item_Factura where item_producto = '00001104'

    select * from Item_Factura where item_producto = '00001123'

    select * from Item_Factura where item_producto = '00000030'


select
    *
from Factura
    JOIN Item_Factura ON Factura.fact_tipo = Item_Factura.item_tipo and Factura.fact_sucursal = Item_Factura.item_sucursal and Factura.fact_numero = Item_Factura.item_numero
where fact_tipo = 'A' AND fact_sucursal = '0003' AND fact_numero = '00092444'




-- EN CASO DE QUE ME PIDAN HACERLO POR CADA FACTURA, PUEDO HACER UN PROCEDURE Y LLAMARLO X CADA FACTURA

CREATE PROCEDURE sp_componer_productos_factura @fact_tipo char(1),
    @fact_sucursal char(4),
    @fact_numero char(8)
AS
BEGIN


    -- Buscamos e insertamos los combos que se pueden formar para los item_factura de esa factura
    INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
    SELECT
        i.item_tipo,
        i.item_sucursal,
        i.item_numero,
        c.comp_producto AS item_producto, -- Código del combo
        FLOOR(MIN(i.item_cantidad / c.comp_cantidad)) AS item_cantidad, -- Cantidad de combos
        p.prod_precio AS item_precio -- Precio del combo desde Producto
    FROM Item_Factura i
             JOIN Composicion c ON i.item_producto = c.comp_componente
             JOIN Producto p ON c.comp_producto = p.prod_codigo
    WHERE i.item_numero = @fact_numero AND i.item_sucursal = @fact_sucursal AND i.item_tipo = @fact_tipo
    GROUP BY i.item_tipo, i.item_sucursal, i.item_numero, c.comp_producto, p.prod_precio
    HAVING FLOOR(MIN(i.item_cantidad / c.comp_cantidad)) > 0;


    -- Una vez que insertamos en Item_Factura todos los combos, tenemos que procesar uno por uno los items para restar aquellos que fueron usados en combos

    DECLARE @item_tipo char,
        @item_sucursal char(4),
        @item_numero char(8),
        @item_producto char(8),
        @item_cantidad decimal(12, 2),
        @item_precio decimal(12, 2),
        @cantidad_usada decimal(12, 2);


    DECLARE cur_items_factura CURSOR FOR
        SELECT i.item_tipo, i.item_sucursal, i.item_numero, i.item_producto, i.item_cantidad, i.item_precio
        FROM Item_Factura i
        WHERE i.item_tipo = @fact_tipo AND
        i.item_sucursal = @fact_sucursal AND
        i.item_numero = @fact_numero

    OPEN cur_items_factura;

    FETCH NEXT FROM cur_items_factura INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad, @item_precio;

    WHILE @@FETCH_STATUS = 0
        BEGIN

            -- Calcular la cantidad usada en combos
            SELECT @cantidad_usada = SUM(FLOOR(i.item_cantidad / c.comp_cantidad) * c.comp_cantidad)
            FROM Item_Factura i
                     JOIN Composicion c ON i.item_producto = c.comp_componente
            WHERE i.item_producto = @item_producto
              AND i.item_tipo = @fact_tipo
              AND i.item_sucursal = @fact_sucursal
              AND i.item_numero = @fact_numero;

            -- Restar las cantidades usadas
            IF (@item_cantidad - ISNULL(@cantidad_usada, 0)) > 0
                BEGIN
                    UPDATE Item_Factura
                    SET item_cantidad = @item_cantidad - @cantidad_usada
                    WHERE item_producto = @item_producto
                      AND item_tipo = @fact_tipo
                      AND item_sucursal = @fact_sucursal
                      AND item_numero = @fact_numero;
                END
            ELSE        -- En caso de que sea menor o igual a 0, eliminamos el componente directamente
                BEGIN
                    DELETE FROM Item_Factura
                    WHERE item_producto = @item_producto
                      AND item_tipo = @fact_tipo
                      AND item_sucursal = @fact_sucursal
                      AND item_numero = @fact_numero;
                END

            FETCH NEXT FROM cur_items_factura INTO @item_producto, @item_cantidad;
        END

    CLOSE cur_items_factura;
    DEALLOCATE cur_items_factura;

END







DECLARE @fact_tipo char(1), @fact_sucursal char(4), @fact_numero char(8);

DECLARE cur_facturas CURSOR FOR
    SELECT fact_tipo, fact_sucursal, fact_numero
    FROM Factura;

    OPEN cur_facturas;

    FETCH NEXT FROM cur_facturas INTO @fact_tipo, @fact_sucursal, @fact_numero;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC sp_componer_productos_factura @fact_tipo, @fact_sucursal, @fact_numero;

            FETCH NEXT FROM cur_facturas INTO @fact_tipo, @fact_sucursal, @fact_numero;
        END;

    CLOSE cur_facturas;
    DEALLOCATE cur_facturas;



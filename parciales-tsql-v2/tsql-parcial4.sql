------------------------------ T-SQL - PARCIAL 4 (15/11/2022) ------------------------------

/*
    Implementar una regla de negocio en línea que al realizar una venta (SOLO INSERCIÓN) permita componer los productos
    descompuestos, es decir, si se guardan en la factura 2 hamb. 2 papas 2 gasesos se deberá guardar en la factura 2 COMBO1.
    Si 1 COMBO1 equivale a: 1 hamb. 1 papa y 1 gaseosa.

    Nota: considerar que cada vez que se guardan los items, se mandan todos los productos de ese item a la vez, y no de
    manera parcial.
*/


CREATE TRIGGER tr_generador_combo
    ON Item_Factura INSTEAD OF INSERT
AS
BEGIN TRANSACTION

    DECLARE @combo CHAR(8)
    DECLARE @cantidad_combos INT
    DECLARE @precio_combo DECIMAL(12,2)

    DECLARE @item_tipo CHAR(1)
    DECLARE @item_sucursal CHAR(4)
    DECLARE @item_numero CHAR(8)

    DECLARE @item_producto CHAR(8)
    DECLARE @item_cantidad DECIMAL(12,2)
    DECLARE @item_precio DECIMAL(12,2)

    -- Cursos para recorrerme los productos que NO sean compuestos de otros productos (los compuestos se agrupan en el proximo cursor)
        DECLARE cur_prod_normal CURSOR FOR
            SELECT
                *
            FROM inserted i
            WHERE i.item_producto NOT IN (SELECT comp_componente FROM Composicion)      -- Que no sea un componente


    -- En el insert tengo TODOS los productos, pero algunos de ellos pueden formar un combo
    -- Lo que tendria que hacer es chequear qué combos puedo formar y en qué cantidad

    -- Cursor para recorrerme los productos que tienen composicion (o sea, los posibles combos)
    DECLARE cur_combo CURSOR FOR
        SELECT
            c.comp_producto         -- Seleccionamos los productos que tengan compuestos
        FROM inserted i
            JOIN Composicion c ON c.comp_componente = i.item_producto
        WHERE i.item_cantidad >= c.comp_cantidad                -- Y cuya cantidad insertada sea mayor o igual a los que requiere
        GROUP BY c.comp_producto
        HAVING COUNT(*) = (SELECT COUNT(*) FROM Composicion c2 WHERE c2.comp_producto = c.comp_producto)    -- Que el numero de componentes de la insercion coincida con el numero de componentes necesarios para el combo

    OPEN cur_combo
    FETCH cur_combo INTO @combo
    WHILE @@fetch_status = 0
        BEGIN

            SELECT
                i.item_tipo = @item_tipo,
                i.item_sucursal = @item_sucursal,
                i.item_numero = @item_numero
            FROM inserted i
                WHERE i.item_producto = @combo


            -- Buscamos la cantidad de combos
            SET @cantidad_combos = (SELECT
                                        MIN(FLOOR(i2.item_cantidad / c2.comp_cantidad))
                                    FROM inserted i2
                                        JOIN Composicion c2 ON c2.comp_producto = i2.item_producto
                                    WHERE i2.item_cantidad >= c2.comp_cantidad AND c2.comp_producto = @combo)

            -- Seteamos el precio del combo
            SET @precio_combo = @cantidad_combos * (SELECT prod_precio FROM Producto WHERE prod_codigo = @combo)

            -- Insertamos en Item_Factura la fila con el combo
            INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                VALUES (@item_tipo, @item_sucursal, @item_numero, @combo, @cantidad_combos, @precio_combo)


            FETCH NEXT FROM cur_combo INTO @Combo

        END

        CLOSE cur_combo
        DEALLOCATE cur_combo


        -- Ahora recorremos los demás productos que no sean componentes de otro

        -- etc.


COMMIT
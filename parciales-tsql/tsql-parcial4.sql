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
    DECLARE @cantidad_combos int
    DECLARE @combo char(8)


    -- Hacer un cursor que recorra los insertados agrupados por combos

    DECLARE cursor_producto CURSOR FOR
        SELECT
            c1.comp_producto
        FROM inserted i
        JOIN Composicion c1 ON i.item_producto = c1.comp_componente
        WHERE i.item_cantidad >= c1.comp_cantidad
        GROUP BY c1.comp_producto
        having COUNT(*) = (select COUNT(*) from Composicion as C2 where C2.comp_producto= C1.comp_producto)





    -- Sacar cuantos combos podemos armar teniendo en cuenta el producto limitante

    SELECT
        @cantidad_combos = MIN(FLOOR(i.item_cantidad / c1.comp_cantidad))
    FROM inserted i
    JOIN Composicion c1 ON i.item_producto = c1.comp_componente
    WHERE i.item_cantidad >= c1.comp_cantidad



    -- Armamos el combo y lo insertamos



COMMIT



INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
    VALUES
        ('A', '003', '1', '00000030', '2', '3000'),
        ('A', '003', '1', '00000030', '2', '3000')



SELECT
    MIN(FLOOR(it.item_cantidad / c1.comp_cantidad))
FROM Item_Factura it
         JOIN Composicion c1 ON it.item_producto = c1.comp_componente
WHERE it.item_cantidad >= c1.comp_cantidad




SELECT
    comp_producto
FROM Item_Factura it
         JOIN Composicion c1 ON it.item_producto = c1.comp_componente
WHERE it.item_cantidad >= c1.comp_cantidad
GROUP BY comp_producto
having COUNT(*) = (select COUNT(*) from Composicion as C2 where C2.comp_producto= C1.comp_producto)
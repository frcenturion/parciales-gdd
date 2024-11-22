------------------------------ T-SQL - PARCIAL 10 (20/11/2024) ------------------------------

/*
    Se detectó un error en el proceso de registro de ventas, donde se almacenaron productos compuestos en lugar de sus
    componentes individuales. Para solucionar este problema se debe:

        1. Diseñar e implementar los objetos necesarios para reorganizar las ventas tal como están registradas
        actualmente

        2. Desagregar los productos compuestos vendidos en sus componentes individuales, asegurando que cada venta
        refleje correctamente los elementos que la componen.

        3. Garantizar que la base de datos quede consistente y alineada con las especificaciones requeridas para el
        manejo de los productos
*/

-- Procedure para, dado un Item_Factura, descomponerlo en sus componentes
DROP PROCEDURE pr_descomponer_producto_compuesto

CREATE PROCEDURE pr_descomponer_producto_compuesto
    @item_tipo CHAR(1),
    @item_sucursal CHAR(4),
    @item_numero CHAR(8),
    @item_producto CHAR(8),
    @item_cantidad DECIMAL(12,2)
AS
BEGIN

    DECLARE @componente CHAR(8)
    DECLARE @cantidad_componente CHAR(8)
    DECLARE @precio_componente CHAR(8)

    -- Dado un producto de un Item_Factura, tenemos que buscar sus componentes de ese producto compuesto
    DECLARE cur_componentes CURSOR FOR
        SELECT
            c.comp_componente,
            p.prod_precio,
            c.comp_cantidad
        FROM Composicion c
            JOIN Producto p ON c.comp_componente = p.prod_codigo
        WHERE c.comp_producto = @item_producto      -- Pedimos que el producto compuesto sea el del Item_Factura

    -- Una vez que tenemos los componentes del producto, borramos el producto compuesto del Item_Factura
    DELETE FROM Item_Factura
        WHERE item_producto = @item_producto
            AND item_tipo = @item_tipo
            AND item_sucursal = @item_sucursal
            AND item_numero = @item_numero


    -- Abrimos el cursor para recorrer los componentes del producto y los vamos insertando en el Item_Factura
    OPEN cur_componentes
    FETCH cur_componentes INTO @componente, @precio_componente, @cantidad_componente

    WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Insertamos en ese mismo Item_Factura todos los componentes del producto compuesto, con su respectiva cantidad
            INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                    VALUES (@item_tipo, @item_sucursal, @item_numero, @componente, (@cantidad_componente * @item_cantidad), @precio_componente)


            FETCH NEXT FROM cur_componentes INTO @componente, @precio_componente, @cantidad_componente
        END
    CLOSE cur_componentes
    DEALLOCATE cur_componentes

END


-- Procedure para descomponer los productos compuestos de cada uno de los items factura del sistema

CREATE PROCEDURE pr_actualizar_items_factura
AS
BEGIN
    -- Declaramos variables para captar la info del cursor
    DECLARE @item_tipo CHAR(1),
        @item_sucursal CHAR(4),
        @item_numero CHAR(8),
        @item_producto CHAR(8),
        @item_cantidad DECIMAL(12,2)

    -- Creamos un cursor para recorrernos todos los Item_Factura que tengan productos compuestos del sistema
    DECLARE cur_items_factura CURSOR FOR
        SELECT
            it.item_tipo,
            it.item_sucursal,
            it.item_numero,
            it.item_producto,
            it.item_cantidad
        FROM Item_Factura it
        WHERE it.item_producto IN (SELECT comp_producto FROM Composicion)
--            JOIN Composicion c ON c.comp_producto = it.item_producto
--        GROUP BY it.item_producto, it.item_cantidad, it.item_numero, it.item_sucursal, it.item_tipo

    -- Abrimos el cursor y por cada Item_Factura compuesto, llamamos al procedure para descomponerlo en sus componentes
    OPEN cur_items_factura
    FETCH cur_items_factura INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad

    WHILE @@fetch_status = 0
        BEGIN

            -- Por cada Item_Factura, llamamos al procedure
            EXEC pr_descomponer_producto_compuesto @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad

            FETCH NEXT FROM cur_items_factura INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad
        END

    CLOSE cur_items_factura
    DEALLOCATE cur_items_factura

END


-- Trigger para asegurarnos que cada vez que se inserte o actualice un Item_Factura compuesto, se descomponga en sus componentes

CREATE TRIGGER tr_descomponer_productos ON
    Item_Factura INSTEAD OF INSERT                       -- No le pongo after porque si no entraria en bucle
AS
BEGIN TRANSACTION

    -- Declaramos variables para captar la info del cursor
    DECLARE @item_tipo CHAR(1),
            @item_sucursal CHAR(4),
            @item_numero CHAR(8),
            @item_producto CHAR(8),
            @item_cantidad DECIMAL(12,2),
            @item_precio DECIMAL(12,2)

    -- Creamos un cursor para recorrernos todos los Item_Factura (no solo los que tengan compuestos
    DECLARE cur_items_factura CURSOR FOR
        SELECT
            it.item_tipo,
            it.item_sucursal,
            it.item_numero,
            it.item_producto,
            it.item_cantidad,
            it.item_precio
        FROM inserted it


    -- Abrimos el cursor y por cada Item_Factura compuesto, llamamos al procedure para descomponerlo en sus componentes en caso de que sea compuesto
    OPEN cur_items_factura
    FETCH cur_items_factura INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad

    WHILE @@fetch_status = 0
        BEGIN

            IF @item_producto IN (SELECT comp_producto FROM Composicion)
                BEGIN
                    -- En caso de que sea compuesto, descomponemos e insertamos
                    EXEC pr_descomponer_producto_compuesto @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad
                END
            ELSE
                BEGIN
                    -- En caso de que no sea compuesto, simplemente insertamos el Item_Factura, sin descomponer nada
                    INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
                        VALUES (@item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad, @item_precio)
                END

            FETCH NEXT FROM cur_items_factura INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad
        END

    CLOSE cur_items_factura
    DEALLOCATE cur_items_factura
COMMIT







SELECT * FROM Composicion WHERE comp_producto = '00001104'

SELECT * FROM Producto WHERE prod_codigo = '00001104'

SELECT * FROM Item_Factura


INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
    VALUES ('A', '0003','00092444', '00001104', 2, 10.54)



SELECT * FROM Composicion WHERE comp_producto = '00001104'




SELECT prod_precio FROM Producto WHERE prod_codigo = '00001415'

SELECT * FROM Item_Factura


EXEC pr_descomponer_producto_compuesto 'A', '0003', '00092444', '00001104', '2'


SELECT * FROM Item_Factura WHERE item_numero = '00092444'



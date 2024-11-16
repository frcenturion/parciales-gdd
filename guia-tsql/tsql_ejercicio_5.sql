------------ EJERCICIO 5 - TSQL ------------

/*
    Realizar un procedimiento que complete con los datos existentes en el modelo
    provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
    Create table Fact_table
    ( anio char(4),
    mes char(2),
    familia char(3),
    rubro char(4),
    zona char(3),
    cliente char(6),
    producto char(8),
    cantidad decimal(12,2),
    monto decimal(12,2)
    )
    Alter table Fact_table
    Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)
*/

-- Primero creamos la tabla que nos dan

DROP TABLE Fact_table

Create table Fact_table
( anio char(4) not null,
  mes char(2) not null,
  familia char(3) not null,
  rubro char(4) not null,
  zona char(3) not null,
  cliente char(6) not null,
  producto char(8) not null,
  cantidad decimal(12,2),
  monto decimal(12,2)
)

Alter table Fact_table
    ADD CONSTRAINT PK_Fact_table primary key(anio,mes,familia,rubro,zona,cliente,producto)

-- Ahora creamos el procedimiento

CREATE PROCEDURE completar_tabla_hechos
AS
BEGIN

    DELETE Fact_table



END
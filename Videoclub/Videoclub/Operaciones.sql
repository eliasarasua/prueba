-- MODIFICACION ALBA
--seleccion de todos los atributos de la tabla clientes
SELECT * FROM Cliente 
SELECT * FROM Cliente WHERE dni = '123145'

SELECT * FROM Alquiler
SELECT * FROM Alquiler WHERE precio > 2.75

--join de la tabla cliente y la tabla alquiler (solo los clientes que ya han alquilado algo)
SELECT * FROM Cliente C
INNER JOIN Alquiler A
ON C.idCliente = A.idCliente 

--left join de clientes y alquier (en este caso aparece lo mismo porque todos los clientes han alquilado, 
--sino los valores de alquier saldrian en null)
--INSERT INTO Cliente (nombre, apellido, dni, telefono, cuenta) VALUES ('Pedro', 'Garcia','783940','635448912', 0)
SELECT * FROM Cliente C
LEFT JOIN Alquiler A
ON C.idCliente = A.idCliente 

--en este caso se unen los clientes con alquiler (solo los que han hecho alquileres) porque ademas se hace un join con las peliculas
SELECT * FROM Cliente C
LEFT JOIN Alquiler A
ON C.idCliente = A.idCliente 
RIGHT JOIN Pelicula P
ON P.idPelicula = A.idPelicula 

--modificar el telefono de un cliente concreto (por su nombre y apellido)
UPDATE cliente SET telefono = '674559566' WHERE nombre = 'Lucas' and apellido = 'Roiz'

--añadir una nueva reserva a alquiler
INSERT INTO Alquiler (idCliente,idPelicula,fechaInicio,fechaFin,precio)
	VALUES (1,3, '20191201 23:12', '20191206 23:12',3.75 )

--Añadir el nombre de los clientes en alquiler
UPDATE Alquiler SET Alquiler.nombreCliente = nombre FROM Cliente WHERE Alquiler.idCliente = Cliente.idCliente

--contar cuantos clientes te han alquilado pelis
SELECT COUNT(DISTINCT dni) AS numClientes FROM Cliente, Alquiler WHERE Alquiler.idCliente = Cliente.idCliente 

--quienes son los clientes que han alquilado y cuantas veces
SELECT cliente.nombre AS Nombre, COUNT(alquiler.nombreCliente) AS numAlquileres FROM Cliente, Alquiler WHERE Alquiler.idCliente = Cliente.idCliente GROUP BY Cliente.nombre

--QUÉ clientes te han alquilado pelis en octubre 
SELECT nombrecliente FROM Cliente, Alquiler WHERE Alquiler.idCliente = Cliente.idCliente 
	AND fechaInicio > '20191001' AND fechaFin < '20191031'
	GROUP BY nombreCliente 

 --Cuantos clientes han alquilado pelis en diciembre
 SELECT count(DISTINCT dni) AS numAlqDiciembre FROM Cliente, Alquiler WHERE Alquiler.idCliente = Cliente.idCliente 
	AND fechaInicio > '20191201' AND fechaFin < '20191231'
	
--obtener el dinero que ha pagado cada cliente
SELECT nombreCliente, SUM(precio) FROM Alquiler, Cliente 
	WHERE Alquiler.idCliente = Cliente.idCliente 
	GROUP BY Alquiler.nombreCliente

-- actualizar el dinero que se ha ido gastando cada cliente en su cuenta (historial)
SELECT * FROM Cliente
UPDATE Cliente 
	SET Cliente.cuenta = (
		SELECT sum(precio) 
		FROM Alquiler
		WHERE Alquiler.idCliente = Cliente.idCliente
		)

--obtener el numero de dias que se ha alquilado una pelicula por cliente
SELECT * FROM Alquiler
SELECT Pelicula.nombre AS Pelicula, Alquiler.nombreCliente AS Cliente, DATEDIFF(day,fechaInicio, fechaFin) AS numDiasAlquiler 
	FROM Alquiler, Cliente, Pelicula 
	WHERE Cliente.idCliente = Alquiler.idCliente and Alquiler.idPelicula = Pelicula.idPelicula
	
--Ahora vamos a añadir ese valor a la tabla alquiler
ALTER TABLE Alquiler ADD diasAlquiler int NULL
ALTER TABLE Alquiler ADD penalizacion tinyint NULL

--INSERTAMOS LOS DATOS
UPDATE Alquiler SET diasAlquiler = DATEDIFF(day, fechaInicio,fechaFin) FROM Alquiler 

--Penalizacion 
UPDATE Alquiler SET precio = precio + 1 WHERE diasAlquiler > 6
UPDATE Alquiler SET penalizacion = 1 WHERE diasAlquiler > 6 
UPDATE Alquiler SET penalizacion = 0 WHERE diasAlquiler <= 6

-------------------------- procedure, pero no es como, darle otra vuelta ----------------------
--para modificar si hay penalizacion o no segun los diasAlquiler y el idAlquiler
SELECT * FROM Alquiler
EXEC alquiler_penalizacion 2,11

ALTER PROC alquiler_penalizacion (
	@idAlquiler int,
	@diasAlquiler int)
AS
SET NOCOUNT ON
IF EXISTS (SELECT * FROM Alquiler WHERE idAlquiler = @idAlquiler)
	IF @diasAlquiler > 6
		UPDATE Alquiler SET penalizacion = 1 WHERE idAlquiler = @idAlquiler
	ELSE
		UPDATE Alquiler SET penalizacion = 0 WHERE idAlquiler = @idAlquiler


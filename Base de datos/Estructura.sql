-- Proyecto: BuscadorInmuebles
-- Versi�n: 20180909

---- SECCI�N: Base de datos
-- 1. Crea la base de datos.
CREATE DATABASE BuscadorInmuebles
GO
-- 2. Empieza a usar la base de datos.
USE BuscadorInmuebles
GO

---- SECCI�N: Credenciales para el servicio web
-- 1. Crea el inicio de sesi�n con una contrase�a segura.
CREATE LOGIN [BuscadorInmuebles.Web] WITH PASSWORD = '%019ef9234a92cc55551a7d$'
-- 2. Crea un usuario en la base de datos para el inicio de sesi�n creado anteriormente.
CREATE USER [BuscadorInmuebles.Web] FOR LOGIN [BuscadorInmuebles.Web]
-- 3. Asigna el permiso de ejecuci�n de procedimientos almacenados al usuario creado anteriormente.
GRANT EXEC TO [BuscadorInmuebles.Web]
GO

-- SECCI�N: Tablas de la base de datos
-- 1. Crea las tablas que no dependan de otras.
CREATE TABLE Caracter�sticaInmueble
(
	C�digo TINYINT NOT NULL IDENTITY(1, 1),
	Descripci�n VARCHAR(64) NOT NULL,
	Est�Activo BIT NOT NULL,
	CONSTRAINT PK_Caracter�sticaInmueble PRIMARY KEY (C�digo),
	CONSTRAINT UQ_Caracter�sticaInmueble_Descripci�n UNIQUE (Descripci�n)
)
ALTER TABLE Caracter�sticaInmueble ADD CONSTRAINT DF_Caracter�sticaInmueble_Est�Activo DEFAULT 1 FOR [Est�Activo]
CREATE TABLE TipoInmueble
(
	C�digo TINYINT NOT NULL IDENTITY(1, 1),
	Descripci�n VARCHAR(64) NOT NULL,
	Est�Activo BIT NOT NULL,
	CONSTRAINT PK_TipoInmueble PRIMARY KEY (C�digo),
	CONSTRAINT UQ_TipoInmueble_Descripci�n UNIQUE (Descripci�n)
)
ALTER TABLE TipoInmueble ADD CONSTRAINT DF_TipoInmueble_Est�Activo DEFAULT 1 FOR Est�Activo
CREATE TABLE Ubigeo
(
	C�digo CHAR(6) NOT NULL,
	Nombre VARCHAR(64) NOT NULL,
	CONSTRAINT PK_Ubigeo PRIMARY KEY (C�digo)
)
GO
-- 2. Crea una tabla que depende de las anteriores.
CREATE TABLE Inmueble
(
	C�digo INT NOT NULL IDENTITY(1, 1),
	Nombre VARCHAR(64) NOT NULL,
	Tipo TINYINT NOT NULL,
	Ubigeo CHAR(6) NOT NULL,
	FechaRegistro DATETIME NOT NULL,
	Est�Activo BIT NOT NULL,
	CONSTRAINT PK_Inmueble PRIMARY KEY (C�digo),
	CONSTRAINT FK_Inmueble_Tipo FOREIGN KEY (Tipo) REFERENCES TipoInmueble(C�digo),
	CONSTRAINT FK_Inmueble_Ubigeo FOREIGN KEY (Ubigeo) REFERENCES Ubigeo(C�digo)
)
ALTER TABLE Inmueble ADD CONSTRAINT DF_Inmueble_FechaRegistro DEFAULT GETUTCDATE() FOR FechaRegistro
ALTER TABLE Inmueble ADD CONSTRAINT DF_Inmueble_Est�Activo DEFAULT 1 FOR Est�Activo
GO
-- 3. Crea una tabla que depende de las anteriores.
CREATE TABLE DetalleInmuebleCaracter�sticas
(
	Inmueble INT NOT NULL,
	Caracter�sticaInmueble TINYINT NOT NULL,
	Valor VARCHAR(128) NOT NULL,
	CONSTRAINT PK_DetalleInmuebleCaracter�sticas PRIMARY KEY (Inmueble, Caracter�sticaInmueble),
	CONSTRAINT FK_DetalleInmuebleCaracter�sticas_Inmueble FOREIGN KEY (Inmueble) REFERENCES Inmueble(C�digo),
	CONSTRAINT FK_DetalleInmuebleCaracter�sticas_Caracter�sticaInmueble FOREIGN KEY (Caracter�sticaInmueble) REFERENCES Caracter�sticaInmueble(C�digo)
)
GO

---- SECCI�N: Procedimientos almacenados

---- Tabla: Caracter�sticaInmueble
-- Procedimiento: Actualizar un registro de Caracter�sticaInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado), 3 (Descripci�n no �nica).
CREATE PROCEDURE ActualizarCaracter�sticaInmueble @C�digo TINYINT, @Descripci�n VARCHAR(64), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE Caracter�sticaInmueble SET Descripci�n = @Descripci�n WHERE C�digo = @C�digo
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 0
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_Caracter�sticaInmueble_Descripci�n%' SET @C�digoResultado = 3
		ELSE SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Desactivar un registro de Caracter�sticaInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE DesactivarCaracter�sticaInmueble @C�digo TINYINT, @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE Caracter�sticaInmueble SET Est�Activo = 0 WHERE C�digo = @C�digo
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de Caracter�sticaInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarCaracter�sticaInmueble @C�digo TINYINT, @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE Caracter�sticaInmueble WHERE C�digo = @C�digo AND Est�Activo = 0
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en Caracter�sticaInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Descripci�n no �nica).
CREATE PROCEDURE InsertarCaracter�sticaInmueble @Descripci�n VARCHAR(64), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO Caracter�sticaInmueble (Descripci�n) VALUES (@Descripci�n)
		SET @C�digoResultado = 1
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_Caracter�sticaInmueble_Descripci�n%' SET @C�digoResultado = 2
		ELSE SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar registros de Caracter�sticaInmueble
CREATE PROCEDURE ListarCaracter�sticaInmueble AS
SELECT C�digo, Descripci�n, Est�Activo
FROM Caracter�sticaInmueble
GO
-- Procedimiento: Obtener un registro de Caracter�sticaInmueble
CREATE PROCEDURE ObtenerCaracter�sticaInmueble @C�digo TINYINT AS
SELECT C�digo, Descripci�n
FROM Caracter�sticaInmueble
WHERE C�digo = @C�digo
GO

---- Tabla: DetalleInmuebleCaracter�sticas
-- Procedimiento: Actualizar un registro de DetalleInmuebleCaracter�sticas
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado)
CREATE PROCEDURE ActualizarDetalleInmuebleCaracter�sticas @Inmueble INT, @Caracter�sticaInmueble TINYINT, @Valor VARCHAR(128), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE DetalleInmuebleCaracter�sticas SET Valor = @Valor WHERE Inmueble = @Inmueble AND Caracter�sticaInmueble = @Caracter�sticaInmueble
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de DetalleInmuebleCaracter�sticas
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarDetalleInmuebleCaracter�sticas @Inmueble INT, @Caracter�sticaInmueble TINYINT, @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE DetalleInmuebleCaracter�sticas WHERE Inmueble = @Inmueble AND Caracter�sticaInmueble = @Caracter�sticaInmueble
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en DetalleInmuebleCaracter�sticas
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido)
CREATE PROCEDURE InsertarDetalleInmuebleCaracter�sticas @Inmueble INT, @Caracter�sticaInmueble TINYINT, @Valor VARCHAR(128), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO DetalleInmuebleCaracter�sticas (Inmueble, Caracter�sticaInmueble, Valor) VALUES (@Inmueble, @Caracter�sticaInmueble, @Valor)
		SET @C�digoResultado = 1
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar detalle de caracter�sticas de un inmueble
CREATE PROCEDURE ListarDetalleInmuebleCaracter�sticas @Inmueble INT AS
SELECT Caracter�sticaInmueble.Descripci�n [Nombre],
	   DetalleInmuebleCaracter�sticas.Valor
FROM DetalleInmuebleCaracter�sticas
JOIN Caracter�sticaInmueble ON DetalleInmuebleCaracter�sticas.Caracter�sticaInmueble = Caracter�sticaInmueble.C�digo
WHERE DetalleInmuebleCaracter�sticas.Inmueble = @Inmueble
GO
-- Procedimiento: Obtener un registro de DetalleInmuebleCaracter�sticas
CREATE PROCEDURE ObtenerDetalleInmuebleCaracter�sticas @Inmueble INT, @Caracter�sticaInmueble TINYINT AS
SELECT Caracter�sticaInmueble.C�digo [Caracter�sticaC�digo],
	   Caracter�sticaInmueble.Descripci�n [Caracter�stica],
	   DetalleInmuebleCaracter�sticas.Valor
FROM DetalleInmuebleCaracter�sticas
JOIN Caracter�sticaInmueble ON DetalleInmuebleCaracter�sticas.Caracter�sticaInmueble = Caracter�sticaInmueble.C�digo
WHERE DetalleInmuebleCaracter�sticas.Inmueble = @Inmueble AND Caracter�sticaInmueble = @Caracter�sticaInmueble
GO

---- Tabla: Inmueble
-- Procedimiento: Actualizar un registro de Inmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado)
CREATE PROCEDURE ActualizarInmueble @C�digo INT, @Nombre VARCHAR(64), @Tipo TINYINT, @Ubigeo CHAR(6), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE Inmueble SET Nombre = @Nombre, Tipo = @Tipo, Ubigeo = @Ubigeo WHERE C�digo = @C�digo
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 0
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Desactivar un registro de Inmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE DesactivarInmueble @C�digo INT, @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE Inmueble SET Est�Activo = 0 WHERE C�digo = @C�digo
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de Inmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarInmueble @C�digo INT, @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE Inmueble WHERE C�digo = @C�digo AND Est�Activo = 0
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en Inmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido)
CREATE PROCEDURE InsertarInmueble @Nombre VARCHAR(64), @Tipo TINYINT, @Ubigeo CHAR(6), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO Inmueble (Nombre, Tipo, Ubigeo) VALUES (@Nombre, @Tipo, @Ubigeo)
		SET @C�digoResultado = 1
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar registros de Inmueble
CREATE PROCEDURE ListarInmueble AS
SELECT Inmueble.C�digo,
	   Inmueble.Nombre,
	   TipoInmueble.Descripci�n [Tipo],
	   Distrito.Nombre [Distrito],
	   Provincia.Nombre [Provincia],
	   Departamento.Nombre [Departamento],
	   Inmueble.FechaRegistro
FROM Inmueble
JOIN TipoInmueble ON Inmueble.Tipo = TipoInmueble.C�digo
JOIN Ubigeo [Distrito] ON Distrito.C�digo = Inmueble.Ubigeo
JOIN Ubigeo [Provincia] ON Provincia.C�digo = SUBSTRING(Inmueble.Ubigeo, 1, 4) + '00'
JOIN Ubigeo [Departamento] ON Provincia.C�digo = SUBSTRING(Inmueble.Ubigeo, 1, 2) + '0000'
GO
-- Procedimiento: Obtener un registro de Inmueble
CREATE PROCEDURE ObtenerInmueble @C�digo INT AS
SELECT Inmueble.C�digo,
	   Inmueble.Nombre,
	   TipoInmueble.C�digo [TipoC�digo],
	   TipoInmueble.Descripci�n [Tipo],
	   Distrito.C�digo [DistritoC�digo],
	   Distrito.Nombre [Distrito],
	   Provincia.C�digo [ProvinciaC�digo],
	   Provincia.Nombre [Provincia],
	   Departamento.C�digo [DepartamentoC�digo],
	   Departamento.Nombre [Departamento],
	   Inmueble.FechaRegistro
FROM Inmueble
JOIN TipoInmueble ON Inmueble.Tipo = TipoInmueble.C�digo
JOIN Ubigeo [Distrito] ON Distrito.C�digo = Inmueble.Ubigeo
JOIN Ubigeo [Provincia] ON Provincia.C�digo = SUBSTRING(Inmueble.Ubigeo, 1, 4) + '00'
JOIN Ubigeo [Departamento] ON Provincia.C�digo = SUBSTRING(Inmueble.Ubigeo, 1, 2) + '0000'
WHERE Inmueble.C�digo = @C�digo
GO

---- Tabla: TipoInmueble
-- Procedimiento: Actualizar un registro de TipoInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado), 3 (Descripci�n no �nica).
CREATE PROCEDURE ActualizarTipoInmueble @C�digo TINYINT, @Descripci�n VARCHAR(64), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE TipoInmueble SET Descripci�n = @Descripci�n WHERE C�digo = @C�digo
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 0
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_TipoInmueble_Descripci�n%' SET @C�digoResultado = 3
		ELSE SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Desactivar un registro de TipoInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE DesactivarTipoInmueble @C�digo TINYINT, @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE TipoInmueble SET Est�Activo = 0 WHERE C�digo = @C�digo
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de TipoInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarTipoInmueble @C�digo TINYINT, @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE TipoInmueble WHERE C�digo = @C�digo AND Est�Activo = 0
		IF @@ROWCOUNT = 1 SET @C�digoResultado = 1
		ELSE SET @C�digoResultado = 2
	END TRY
	BEGIN CATCH
		SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en TipoInmueble
-- C�digos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Descripci�n no �nica).
CREATE PROCEDURE InsertarTipoInmueble @Descripci�n VARCHAR(64), @C�digoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO TipoInmueble (Descripci�n) VALUES (@Descripci�n)
		SET @C�digoResultado = 1
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_TipoInmueble_Descripci�n%' SET @C�digoResultado = 2
		ELSE SET @C�digoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar registros de TipoInmueble
CREATE PROCEDURE ListarTipoInmueble AS
SELECT C�digo, Descripci�n, Est�Activo
FROM TipoInmueble
GO
-- Procedimiento: Obtener un registro de TipoInmueble
CREATE PROCEDURE ObtenerTipoInmueble @C�digo TINYINT AS
SELECT C�digo, Descripci�n
FROM TipoInmueble
WHERE C�digo = @C�digo
GO

-- Tabla: Ubigeo
-- Procedimiento: Lista los departamentos
CREATE PROCEDURE ListarDepartamentos AS
SELECT SUBSTRING(C�digo, 1, 2) [C�digo],
	   Nombre
FROM Ubigeo
WHERE C�digo LIKE '[0-9][0-9]0000'
GO
-- Procedimiento: Lista los distritos de un departamento y una provincia
CREATE PROCEDURE ListarDistritos @C�digoDepartamento CHAR(2), @C�digoProvincia CHAR(2) AS
SELECT SUBSTRING(C�digo, 5, 2) [C�digo],
	   Nombre
FROM Ubigeo
WHERE C�digo LIKE @C�digoDepartamento + @C�digoProvincia + '[0-9][0-9]'
GO
-- Procedimiento: Lista las provincias de un departamento
CREATE PROCEDURE ListarProvincias @C�digoDepartamento CHAR(2) AS
SELECT SUBSTRING(C�digo, 3, 2) [C�digo],
	   Nombre
FROM Ubigeo
WHERE C�digo LIKE @C�digoDepartamento + '[0-9][0-9]00'
GO
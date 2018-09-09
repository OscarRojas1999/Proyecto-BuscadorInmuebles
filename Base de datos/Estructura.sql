-- Proyecto: BuscadorInmuebles
-- Versión: 20180909

---- SECCIÓN: Base de datos
-- 1. Crea la base de datos.
CREATE DATABASE BuscadorInmuebles
GO
-- 2. Empieza a usar la base de datos.
USE BuscadorInmuebles
GO

---- SECCIÓN: Credenciales para el servicio web
-- 1. Crea el inicio de sesión con una contraseña segura.
CREATE LOGIN [BuscadorInmuebles.Web] WITH PASSWORD = '%019ef9234a92cc55551a7d$'
-- 2. Crea un usuario en la base de datos para el inicio de sesión creado anteriormente.
CREATE USER [BuscadorInmuebles.Web] FOR LOGIN [BuscadorInmuebles.Web]
-- 3. Asigna el permiso de ejecución de procedimientos almacenados al usuario creado anteriormente.
GRANT EXEC TO [BuscadorInmuebles.Web]
GO

-- SECCIÓN: Tablas de la base de datos
-- 1. Crea las tablas que no dependan de otras.
CREATE TABLE CaracterísticaInmueble
(
	Código TINYINT NOT NULL IDENTITY(1, 1),
	Descripción VARCHAR(64) NOT NULL,
	EstáActivo BIT NOT NULL,
	CONSTRAINT PK_CaracterísticaInmueble PRIMARY KEY (Código),
	CONSTRAINT UQ_CaracterísticaInmueble_Descripción UNIQUE (Descripción)
)
ALTER TABLE CaracterísticaInmueble ADD CONSTRAINT DF_CaracterísticaInmueble_EstáActivo DEFAULT 1 FOR [EstáActivo]
CREATE TABLE TipoInmueble
(
	Código TINYINT NOT NULL IDENTITY(1, 1),
	Descripción VARCHAR(64) NOT NULL,
	EstáActivo BIT NOT NULL,
	CONSTRAINT PK_TipoInmueble PRIMARY KEY (Código),
	CONSTRAINT UQ_TipoInmueble_Descripción UNIQUE (Descripción)
)
ALTER TABLE TipoInmueble ADD CONSTRAINT DF_TipoInmueble_EstáActivo DEFAULT 1 FOR EstáActivo
CREATE TABLE Ubigeo
(
	Código CHAR(6) NOT NULL,
	Nombre VARCHAR(64) NOT NULL,
	CONSTRAINT PK_Ubigeo PRIMARY KEY (Código)
)
GO
-- 2. Crea una tabla que depende de las anteriores.
CREATE TABLE Inmueble
(
	Código INT NOT NULL IDENTITY(1, 1),
	Nombre VARCHAR(64) NOT NULL,
	Tipo TINYINT NOT NULL,
	Ubigeo CHAR(6) NOT NULL,
	FechaRegistro DATETIME NOT NULL,
	EstáActivo BIT NOT NULL,
	CONSTRAINT PK_Inmueble PRIMARY KEY (Código),
	CONSTRAINT FK_Inmueble_Tipo FOREIGN KEY (Tipo) REFERENCES TipoInmueble(Código),
	CONSTRAINT FK_Inmueble_Ubigeo FOREIGN KEY (Ubigeo) REFERENCES Ubigeo(Código)
)
ALTER TABLE Inmueble ADD CONSTRAINT DF_Inmueble_FechaRegistro DEFAULT GETUTCDATE() FOR FechaRegistro
ALTER TABLE Inmueble ADD CONSTRAINT DF_Inmueble_EstáActivo DEFAULT 1 FOR EstáActivo
GO
-- 3. Crea una tabla que depende de las anteriores.
CREATE TABLE DetalleInmuebleCaracterísticas
(
	Inmueble INT NOT NULL,
	CaracterísticaInmueble TINYINT NOT NULL,
	Valor VARCHAR(128) NOT NULL,
	CONSTRAINT PK_DetalleInmuebleCaracterísticas PRIMARY KEY (Inmueble, CaracterísticaInmueble),
	CONSTRAINT FK_DetalleInmuebleCaracterísticas_Inmueble FOREIGN KEY (Inmueble) REFERENCES Inmueble(Código),
	CONSTRAINT FK_DetalleInmuebleCaracterísticas_CaracterísticaInmueble FOREIGN KEY (CaracterísticaInmueble) REFERENCES CaracterísticaInmueble(Código)
)
GO

---- SECCIÓN: Procedimientos almacenados

---- Tabla: CaracterísticaInmueble
-- Procedimiento: Actualizar un registro de CaracterísticaInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado), 3 (Descripción no única).
CREATE PROCEDURE ActualizarCaracterísticaInmueble @Código TINYINT, @Descripción VARCHAR(64), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE CaracterísticaInmueble SET Descripción = @Descripción WHERE Código = @Código
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 0
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_CaracterísticaInmueble_Descripción%' SET @CódigoResultado = 3
		ELSE SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Desactivar un registro de CaracterísticaInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE DesactivarCaracterísticaInmueble @Código TINYINT, @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE CaracterísticaInmueble SET EstáActivo = 0 WHERE Código = @Código
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de CaracterísticaInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarCaracterísticaInmueble @Código TINYINT, @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE CaracterísticaInmueble WHERE Código = @Código AND EstáActivo = 0
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en CaracterísticaInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Descripción no única).
CREATE PROCEDURE InsertarCaracterísticaInmueble @Descripción VARCHAR(64), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO CaracterísticaInmueble (Descripción) VALUES (@Descripción)
		SET @CódigoResultado = 1
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_CaracterísticaInmueble_Descripción%' SET @CódigoResultado = 2
		ELSE SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar registros de CaracterísticaInmueble
CREATE PROCEDURE ListarCaracterísticaInmueble AS
SELECT Código, Descripción, EstáActivo
FROM CaracterísticaInmueble
GO
-- Procedimiento: Obtener un registro de CaracterísticaInmueble
CREATE PROCEDURE ObtenerCaracterísticaInmueble @Código TINYINT AS
SELECT Código, Descripción
FROM CaracterísticaInmueble
WHERE Código = @Código
GO

---- Tabla: DetalleInmuebleCaracterísticas
-- Procedimiento: Actualizar un registro de DetalleInmuebleCaracterísticas
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado)
CREATE PROCEDURE ActualizarDetalleInmuebleCaracterísticas @Inmueble INT, @CaracterísticaInmueble TINYINT, @Valor VARCHAR(128), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE DetalleInmuebleCaracterísticas SET Valor = @Valor WHERE Inmueble = @Inmueble AND CaracterísticaInmueble = @CaracterísticaInmueble
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de DetalleInmuebleCaracterísticas
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarDetalleInmuebleCaracterísticas @Inmueble INT, @CaracterísticaInmueble TINYINT, @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE DetalleInmuebleCaracterísticas WHERE Inmueble = @Inmueble AND CaracterísticaInmueble = @CaracterísticaInmueble
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en DetalleInmuebleCaracterísticas
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido)
CREATE PROCEDURE InsertarDetalleInmuebleCaracterísticas @Inmueble INT, @CaracterísticaInmueble TINYINT, @Valor VARCHAR(128), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO DetalleInmuebleCaracterísticas (Inmueble, CaracterísticaInmueble, Valor) VALUES (@Inmueble, @CaracterísticaInmueble, @Valor)
		SET @CódigoResultado = 1
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar detalle de características de un inmueble
CREATE PROCEDURE ListarDetalleInmuebleCaracterísticas @Inmueble INT AS
SELECT CaracterísticaInmueble.Descripción [Nombre],
	   DetalleInmuebleCaracterísticas.Valor
FROM DetalleInmuebleCaracterísticas
JOIN CaracterísticaInmueble ON DetalleInmuebleCaracterísticas.CaracterísticaInmueble = CaracterísticaInmueble.Código
WHERE DetalleInmuebleCaracterísticas.Inmueble = @Inmueble
GO
-- Procedimiento: Obtener un registro de DetalleInmuebleCaracterísticas
CREATE PROCEDURE ObtenerDetalleInmuebleCaracterísticas @Inmueble INT, @CaracterísticaInmueble TINYINT AS
SELECT CaracterísticaInmueble.Código [CaracterísticaCódigo],
	   CaracterísticaInmueble.Descripción [Característica],
	   DetalleInmuebleCaracterísticas.Valor
FROM DetalleInmuebleCaracterísticas
JOIN CaracterísticaInmueble ON DetalleInmuebleCaracterísticas.CaracterísticaInmueble = CaracterísticaInmueble.Código
WHERE DetalleInmuebleCaracterísticas.Inmueble = @Inmueble AND CaracterísticaInmueble = @CaracterísticaInmueble
GO

---- Tabla: Inmueble
-- Procedimiento: Actualizar un registro de Inmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado)
CREATE PROCEDURE ActualizarInmueble @Código INT, @Nombre VARCHAR(64), @Tipo TINYINT, @Ubigeo CHAR(6), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE Inmueble SET Nombre = @Nombre, Tipo = @Tipo, Ubigeo = @Ubigeo WHERE Código = @Código
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 0
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Desactivar un registro de Inmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE DesactivarInmueble @Código INT, @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE Inmueble SET EstáActivo = 0 WHERE Código = @Código
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de Inmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarInmueble @Código INT, @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE Inmueble WHERE Código = @Código AND EstáActivo = 0
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en Inmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido)
CREATE PROCEDURE InsertarInmueble @Nombre VARCHAR(64), @Tipo TINYINT, @Ubigeo CHAR(6), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO Inmueble (Nombre, Tipo, Ubigeo) VALUES (@Nombre, @Tipo, @Ubigeo)
		SET @CódigoResultado = 1
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar registros de Inmueble
CREATE PROCEDURE ListarInmueble AS
SELECT Inmueble.Código,
	   Inmueble.Nombre,
	   TipoInmueble.Descripción [Tipo],
	   Distrito.Nombre [Distrito],
	   Provincia.Nombre [Provincia],
	   Departamento.Nombre [Departamento],
	   Inmueble.FechaRegistro
FROM Inmueble
JOIN TipoInmueble ON Inmueble.Tipo = TipoInmueble.Código
JOIN Ubigeo [Distrito] ON Distrito.Código = Inmueble.Ubigeo
JOIN Ubigeo [Provincia] ON Provincia.Código = SUBSTRING(Inmueble.Ubigeo, 1, 4) + '00'
JOIN Ubigeo [Departamento] ON Provincia.Código = SUBSTRING(Inmueble.Ubigeo, 1, 2) + '0000'
GO
-- Procedimiento: Obtener un registro de Inmueble
CREATE PROCEDURE ObtenerInmueble @Código INT AS
SELECT Inmueble.Código,
	   Inmueble.Nombre,
	   TipoInmueble.Código [TipoCódigo],
	   TipoInmueble.Descripción [Tipo],
	   Distrito.Código [DistritoCódigo],
	   Distrito.Nombre [Distrito],
	   Provincia.Código [ProvinciaCódigo],
	   Provincia.Nombre [Provincia],
	   Departamento.Código [DepartamentoCódigo],
	   Departamento.Nombre [Departamento],
	   Inmueble.FechaRegistro
FROM Inmueble
JOIN TipoInmueble ON Inmueble.Tipo = TipoInmueble.Código
JOIN Ubigeo [Distrito] ON Distrito.Código = Inmueble.Ubigeo
JOIN Ubigeo [Provincia] ON Provincia.Código = SUBSTRING(Inmueble.Ubigeo, 1, 4) + '00'
JOIN Ubigeo [Departamento] ON Provincia.Código = SUBSTRING(Inmueble.Ubigeo, 1, 2) + '0000'
WHERE Inmueble.Código = @Código
GO

---- Tabla: TipoInmueble
-- Procedimiento: Actualizar un registro de TipoInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado), 3 (Descripción no única).
CREATE PROCEDURE ActualizarTipoInmueble @Código TINYINT, @Descripción VARCHAR(64), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE TipoInmueble SET Descripción = @Descripción WHERE Código = @Código
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 0
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_TipoInmueble_Descripción%' SET @CódigoResultado = 3
		ELSE SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Desactivar un registro de TipoInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE DesactivarTipoInmueble @Código TINYINT, @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		UPDATE TipoInmueble SET EstáActivo = 0 WHERE Código = @Código
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Eliminar un registro de TipoInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Registro no encontrado).
CREATE PROCEDURE EliminarTipoInmueble @Código TINYINT, @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		DELETE TipoInmueble WHERE Código = @Código AND EstáActivo = 0
		IF @@ROWCOUNT = 1 SET @CódigoResultado = 1
		ELSE SET @CódigoResultado = 2
	END TRY
	BEGIN CATCH
		SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Insertar un registro en TipoInmueble
-- Códigos de resultado: 1 (Procesado correctamente), 0 (Error desconocido), 2 (Descripción no única).
CREATE PROCEDURE InsertarTipoInmueble @Descripción VARCHAR(64), @CódigoResultado TINYINT OUTPUT AS
BEGIN
	BEGIN TRY
		INSERT INTO TipoInmueble (Descripción) VALUES (@Descripción)
		SET @CódigoResultado = 1
	END TRY
	BEGIN CATCH
		IF ERROR_MESSAGE() LIKE '%UQ_TipoInmueble_Descripción%' SET @CódigoResultado = 2
		ELSE SET @CódigoResultado = 0
	END CATCH
END
GO
-- Procedimiento: Listar registros de TipoInmueble
CREATE PROCEDURE ListarTipoInmueble AS
SELECT Código, Descripción, EstáActivo
FROM TipoInmueble
GO
-- Procedimiento: Obtener un registro de TipoInmueble
CREATE PROCEDURE ObtenerTipoInmueble @Código TINYINT AS
SELECT Código, Descripción
FROM TipoInmueble
WHERE Código = @Código
GO

-- Tabla: Ubigeo
-- Procedimiento: Lista los departamentos
CREATE PROCEDURE ListarDepartamentos AS
SELECT SUBSTRING(Código, 1, 2) [Código],
	   Nombre
FROM Ubigeo
WHERE Código LIKE '[0-9][0-9]0000'
GO
-- Procedimiento: Lista los distritos de un departamento y una provincia
CREATE PROCEDURE ListarDistritos @CódigoDepartamento CHAR(2), @CódigoProvincia CHAR(2) AS
SELECT SUBSTRING(Código, 5, 2) [Código],
	   Nombre
FROM Ubigeo
WHERE Código LIKE @CódigoDepartamento + @CódigoProvincia + '[0-9][0-9]'
GO
-- Procedimiento: Lista las provincias de un departamento
CREATE PROCEDURE ListarProvincias @CódigoDepartamento CHAR(2) AS
SELECT SUBSTRING(Código, 3, 2) [Código],
	   Nombre
FROM Ubigeo
WHERE Código LIKE @CódigoDepartamento + '[0-9][0-9]00'
GO
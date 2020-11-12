/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 13.5 		*/
/*  Created On : 12-nov.-2020 5:01:04 p. m. 				*/
/*  DBMS       : MySql 						*/
/* ---------------------------------------------------- */

SET FOREIGN_KEY_CHECKS=0 
;

/* Drop Tables */

DROP TABLE IF EXISTS `Apartamento` CASCADE
;

DROP TABLE IF EXISTS `Configuraciones` CASCADE
;

DROP TABLE IF EXISTS `Copropiedad` CASCADE
;

DROP TABLE IF EXISTS `Menu` CASCADE
;

DROP TABLE IF EXISTS `Pagos` CASCADE
;

DROP TABLE IF EXISTS `Parqueadero` CASCADE
;

DROP TABLE IF EXISTS `Registro_Uso` CASCADE
;

DROP TABLE IF EXISTS `registro_visitantes` CASCADE
;

DROP TABLE IF EXISTS `Turno` CASCADE
;

DROP TABLE IF EXISTS `Usuario` CASCADE
;

DROP TABLE IF EXISTS `Vehiculo` CASCADE
;

/* Create Tables */

CREATE TABLE `Apartamento`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_copropiedad` INT NOT NULL,
	`bloque` VARCHAR(50) NOT NULL,
	`apartamento` VARCHAR(50) NOT NULL,
	CONSTRAINT `PK_Apartamento` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que guarda los apartamentos asociados a los usuarios'

;

CREATE TABLE `Configuraciones`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_copropiedad` INT NOT NULL,
	`peso_maximo` DOUBLE(10,2) NOT NULL,
	`ejes_maximos` DOUBLE(10,2) NOT NULL,
	`dia_arqueo` VARCHAR(10) NOT NULL,
	`dia_alertas` VARCHAR(10) NOT NULL,
	`n_parqueaderos_carro` INT NOT NULL,
	`n_parqueaderos_moto` INT NOT NULL,
	`n_parqueaderos_carro_vis` INT NOT NULL,
	`n_parqueaderos_moto_vis` INT NOT NULL,
	`n_parqueaderos_bicicleta` INT NOT NULL,
	`n_parqueaderos_bicicleta_vis` INT NOT NULL,
	`tipo_pago_visitante` VARCHAR(10) NOT NULL COMMENT 'Hora, dia o minuto',
	`valor_pago_visitante` DOUBLE(10,2) NOT NULL,
	`tiempo_gracia` INT NOT NULL,
	`encabezado_recibo` VARCHAR(256) NOT NULL,
	`texto_responsabilidad` VARCHAR(256) NOT NULL,
	`pie_pagina_recibo` VARCHAR(256) NOT NULL,
	CONSTRAINT `PK_Configuraciones` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que guarda las configuraciones iniciales hechas por administración para la total configuracion de los parqueaderos.'

;

CREATE TABLE `Copropiedad`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_administrador` INT NULL,
	`nombre` VARCHAR(50) NOT NULL,
	`direccion` VARCHAR(50) NOT NULL,
	`habilitada` TINYINT NOT NULL,
	CONSTRAINT `PK_Copropiedad` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que maneja las copropiedades en la aplicación'

;

CREATE TABLE `Menu`
(
	`id_menu` INT NOT NULL AUTO_INCREMENT,
	`id_padre` INT NULL,
	`nombre` VARCHAR(50) NOT NULL,
	`tipo_usuario` CHAR(1) NOT NULL,
	`tiene_hijos` TINYINT NULL,
	`mostrar` TINYINT NULL,
	CONSTRAINT `PK_Menu` PRIMARY KEY (`id_menu` ASC)
)
COMMENT = 'Tabla para manejar el arbol de menus de acuerdo al tipo de usuario.'

;

CREATE TABLE `Pagos`
(
	`id` INT NOT NULL,
	`id_usuario` INT NOT NULL,
	`id_parqueadero` INT NOT NULL,
	`fecha_pago` DATE NOT NULL,
	CONSTRAINT `PK_Pagos` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que registra las fechas de pago de los parqueaderos'

;

CREATE TABLE `Parqueadero`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_copropiedad` INT NOT NULL,
	`id_usuario` INT NULL,
	`codigo` VARCHAR(50) NOT NULL,
	`area` DOUBLE(10,2) NOT NULL,
	`peso_admitido` DOUBLE(10,2) NOT NULL,
	`ejes_admitidos` INT NOT NULL,
	`codigo_barras` VARCHAR(50) NOT NULL,
	`admite_carro` BOOL NOT NULL,
	`admite_moto` BOOL NOT NULL,
	`admite_bicicleta` BOOL NOT NULL,
	`tipo` VARCHAR(10) NOT NULL,
	`esta_libre` BOOL NOT NULL DEFAULT True,
	`esta_asignado` BOOL NOT NULL DEFAULT False,
	CONSTRAINT `PK_Parqueadero` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que guarda los datos de los parqueaderos existentes que hay en la copropiedad'

;

CREATE TABLE `Registro_Uso`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_vehiculo` INT NOT NULL,
	`fecha_ingreso` DATE NOT NULL,
	`fecha_salida` DATE NULL,
	`hora_ingreso` TIME NOT NULL,
	`hora_salida` TIME NULL,
	CONSTRAINT `PK_Registro_Uso` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que guarda el registro de uso de un parqueadero, es decir, la fecha y hora de entrada de un vehiculo y la fecha y hora de salida del mismo'

;

CREATE TABLE `registro_visitantes`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_parqueadero` INT NOT NULL,
	`nombre_responsable` VARCHAR(50) NOT NULL,
	`tipo_vehiculo` VARCHAR(50) NOT NULL,
	`marca` VARCHAR(50) NOT NULL,
	`color` VARCHAR(50) NOT NULL,
	`foto` VARCHAR(256) NULL,
	`fecha_entrada` DATE NOT NULL,
	`hora_entrada` TIME NOT NULL,
	`fecha_salida` DATE NULL,
	`hora_salida` TIME NULL,
	CONSTRAINT `PK_registro_visitantes` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que guarda el registro de entrada y salida de los visitantes'

;

CREATE TABLE `Turno`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_usuario` INT NOT NULL,
	`fecha_entrada` DATE NOT NULL,
	`fecha_salida` DATE NULL,
	`hora_entrada` TIME NOT NULL,
	`hora_salida` TIME NULL,
	`dinero_inicial` DOUBLE(10,2) NOT NULL,
	`dinero_final` DOUBLE(10,2) NOT NULL,
	CONSTRAINT `PK_Turno` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla para registrar la información de los turnos de los guardias'

;

CREATE TABLE `Usuario`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_copropiedad` INT NOT NULL,
	`id_apartamento` INT NULL,
	`usuario` VARCHAR(50) NULL,
	`password` VARCHAR(512) NULL,
	`tipo_usuario` CHAR(1) NOT NULL,
	`nombres` VARCHAR(50) NOT NULL,
	`apellidos` VARCHAR(50) NOT NULL,
	`tipo_identificacion` VARCHAR(3) NOT NULL,
	`identificacion` BIGINT NOT NULL,
	`telefono` INT NOT NULL,
	`celular` BIGINT NOT NULL,
	`email` VARCHAR(50) NOT NULL,
	`sancionado` BOOL NOT NULL DEFAULT False,
	`al_dia` BOOL NOT NULL DEFAULT True,
	CONSTRAINT `PK_Usuario` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que guarda la información de los usuarios registrados en la aplicacion'

;

CREATE TABLE `Vehiculo`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`id_propietario` INT NOT NULL,
	`id_parqueadero` INT NULL,
	`marca` VARCHAR(50) NOT NULL,
	`modelo` VARCHAR(50) NOT NULL,
	`tipo` VARCHAR(50) NOT NULL,
	`color` VARCHAR(50) NOT NULL,
	`peso` DOUBLE(10,2) NOT NULL,
	`numero_ejes` VARCHAR(50) NOT NULL,
	`carta_propiedad` VARCHAR(256) NOT NULL,
	`soat` VARCHAR(256) NOT NULL,
	`imagen` VARCHAR(256) NOT NULL,
	`fecha_vencimiento_soat` DATE NOT NULL,
	CONSTRAINT `PK_Vehiculo` PRIMARY KEY (`id` ASC)
)
COMMENT = 'Tabla que guarda la información de los vehiculos registrados por los usuarios'

;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE `Apartamento` 
 ADD INDEX `IXFK_Apartamento_Copropiedad` (`id_copropiedad` ASC)
;

ALTER TABLE `Configuraciones` 
 ADD CONSTRAINT `UK_copropiedad` UNIQUE (`id_copropiedad` ASC)
;

ALTER TABLE `Configuraciones` 
 ADD CONSTRAINT `CK_dia_arqueo` CHECK (dia_arqueo IN ('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO'))
;

ALTER TABLE `Configuraciones` 
 ADD CONSTRAINT `CK_dia_alertas` CHECK (dia_alertas IN ('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO'))
;

ALTER TABLE `Configuraciones` 
 ADD CONSTRAINT `CK_tipo_pago_visitante` CHECK (tipo_pago_visitante IN ('MINUTO','HORA','DIA'))
;

ALTER TABLE `Configuraciones` 
 ADD INDEX `IXFK_Configuraciones_Copropiedad` (`id_copropiedad` ASC)
;

ALTER TABLE `Copropiedad` 
 ADD CONSTRAINT `UK_nombre` UNIQUE (`nombre` ASC)
;

ALTER TABLE `Copropiedad` 
 ADD CONSTRAINT `UK_administrador` UNIQUE (`id_administrador` ASC)
;

ALTER TABLE `Copropiedad` 
 ADD INDEX `IXFK_Copropiedad_Usuario` (`id_administrador` ASC)
;

ALTER TABLE `Menu` 
 ADD CONSTRAINT `CK_Tipo_usuario` CHECK (tipo_usuario IN ('A','C','G','R'))
;

ALTER TABLE `Menu` 
 ADD INDEX `IXFK_Menu_Menu` (`id_padre` ASC)
;

ALTER TABLE `Pagos` 
 ADD INDEX `IXFK_Pagos_Parqueadero` (`id_parqueadero` ASC)
;

ALTER TABLE `Pagos` 
 ADD INDEX `IXFK_Pagos_Usuario` (`id_usuario` ASC)
;

ALTER TABLE `Parqueadero` 
 ADD CONSTRAINT `UK_codigo` UNIQUE (`codigo` ASC)
;

ALTER TABLE `Parqueadero` 
 ADD CONSTRAINT `UK_codigo_barras` UNIQUE (`codigo_barras` ASC)
;

ALTER TABLE `Parqueadero` 
 ADD CONSTRAINT `CK_tipo` CHECK (tipo IN ('RESIDENTE','VISITANTE'))
;

ALTER TABLE `Parqueadero` 
 ADD INDEX `IXFK_Parqueadero_Copropiedad` (`id_copropiedad` ASC)
;

ALTER TABLE `Parqueadero` 
 ADD INDEX `IXFK_Parqueadero_Usuario` (`id_usuario` ASC)
;

ALTER TABLE `Registro_Uso` 
 ADD INDEX `IXFK_Registro_Uso_Vehiculo` (`id_vehiculo` ASC)
;

ALTER TABLE `registro_visitantes` 
 ADD CONSTRAINT `CK_tipo_vehiculo` CHECK (tipo_vehiculo in ('CARRO','MOTO','BICICLETA'))
;

ALTER TABLE `registro_visitantes` 
 ADD INDEX `IXFK_registro_visitantes_Parqueadero` (`id_parqueadero` ASC)
;

ALTER TABLE `Turno` 
 ADD INDEX `IXFK_Turno_Usuario` (`id_usuario` ASC)
;

ALTER TABLE `Usuario` 
 ADD CONSTRAINT `UK_usuario` UNIQUE (`usuario` ASC)
;

ALTER TABLE `Usuario` 
 ADD CONSTRAINT `UK_identificacion` UNIQUE (`identificacion` ASC)
;

ALTER TABLE `Usuario` 
 ADD CONSTRAINT `CK_tipo_identificacion` CHECK (tipo_identificacion IN ('CC','CE'))
;

ALTER TABLE `Usuario` 
 ADD CONSTRAINT `CK_tipo_usuario` CHECK (tipo_usuario IN ('A','R','G'))
;

ALTER TABLE `Usuario` 
 ADD INDEX `IXFK_Usuario_Copropiedad` (`id_copropiedad` ASC)
;

ALTER TABLE `Vehiculo` 
 ADD CONSTRAINT `CK_tipo` CHECK (tipo in ('CARRO','MOTO','BICICLETA'))
;

ALTER TABLE `Vehiculo` 
 ADD INDEX `IXFK_Vehiculo_Parqueadero` (`id_parqueadero` ASC)
;

ALTER TABLE `Vehiculo` 
 ADD INDEX `IXFK_Vehiculo_Usuario` (`id_propietario` ASC)
;

/* Create Foreign Key Constraints */

ALTER TABLE `Apartamento` 
 ADD CONSTRAINT `FK_Apartamento_Copropiedad`
	FOREIGN KEY (`id_copropiedad`) REFERENCES `Copropiedad` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Configuraciones` 
 ADD CONSTRAINT `FK_Configuraciones_Copropiedad`
	FOREIGN KEY (`id_copropiedad`) REFERENCES `Copropiedad` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Copropiedad` 
 ADD CONSTRAINT `FK_Copropiedad_Usuario`
	FOREIGN KEY (`id_administrador`) REFERENCES `Usuario` (`id`) ON DELETE Set Null ON UPDATE Set Null
;

ALTER TABLE `Menu` 
 ADD CONSTRAINT `FK_Menu_Menu`
	FOREIGN KEY (`id_padre`) REFERENCES `Menu` (`id_menu`) ON DELETE Set Null ON UPDATE Set Null
;

ALTER TABLE `Pagos` 
 ADD CONSTRAINT `FK_Pagos_Parqueadero`
	FOREIGN KEY (`id_parqueadero`) REFERENCES `Parqueadero` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Pagos` 
 ADD CONSTRAINT `FK_Pagos_Usuario`
	FOREIGN KEY (`id_usuario`) REFERENCES `Usuario` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Parqueadero` 
 ADD CONSTRAINT `FK_Parqueadero_Copropiedad`
	FOREIGN KEY (`id_copropiedad`) REFERENCES `Copropiedad` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Parqueadero` 
 ADD CONSTRAINT `FK_Parqueadero_Usuario`
	FOREIGN KEY (`id_usuario`) REFERENCES `Usuario` (`id`) ON DELETE Set Null ON UPDATE Set Null
;

ALTER TABLE `Registro_Uso` 
 ADD CONSTRAINT `FK_Registro_Uso_Vehiculo`
	FOREIGN KEY (`id_vehiculo`) REFERENCES `Vehiculo` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `registro_visitantes` 
 ADD CONSTRAINT `FK_registro_visitantes_Parqueadero`
	FOREIGN KEY (`id_parqueadero`) REFERENCES `Parqueadero` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Turno` 
 ADD CONSTRAINT `FK_Turno_Usuario`
	FOREIGN KEY (`id_usuario`) REFERENCES `Usuario` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Usuario` 
 ADD CONSTRAINT `FK_Usuario_Apartamento`
	FOREIGN KEY (`id_apartamento`) REFERENCES `Apartamento` (`id`) ON DELETE Set Null ON UPDATE Set Null
;

ALTER TABLE `Usuario` 
 ADD CONSTRAINT `FK_Usuario_Copropiedad`
	FOREIGN KEY (`id_copropiedad`) REFERENCES `Copropiedad` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

ALTER TABLE `Vehiculo` 
 ADD CONSTRAINT `FK_Vehiculo_Parqueadero`
	FOREIGN KEY (`id_parqueadero`) REFERENCES `Parqueadero` (`id`) ON DELETE Set Null ON UPDATE Set Null
;

ALTER TABLE `Vehiculo` 
 ADD CONSTRAINT `FK_Vehiculo_Usuario`
	FOREIGN KEY (`id_propietario`) REFERENCES `Usuario` (`id`) ON DELETE Cascade ON UPDATE Cascade
;

SET FOREIGN_KEY_CHECKS=1 
;

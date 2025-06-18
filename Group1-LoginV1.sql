-- ================================================================
-- SCRIPT DE CREACIÓN DEL ESQUEMA DE BASE DE DATOS ACTUALIZADO
-- Autor: Experto en SQL
-- Descripción: Este script crea las tablas para un sistema
-- de gestión de personal, separando los datos personales
-- de los datos laborales para una mejor normalización.
-- Motor de BD asumido: PostgreSQL (por el uso de SERIAL y BYTEA)
-- ================================================================

-- Se recomienda ejecutar estas sentencias dentro de una transacción
-- BEGIN;

-- ===================================================
-- GRUPO 1: TABLAS DE CATÁLOGO O DE CONSULTA (LOOKUP)
-- Estas tablas almacenan opciones predefinidas para evitar
-- la redundancia y los errores de tipeo.
-- ===================================================

-- Tabla: positions
-- Almacena los diferentes puestos de trabajo disponibles.
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE
);

-- Tabla: time_zones
-- Almacena las zonas horarias para los empleados.
CREATE TABLE time_zones (
    time_zone_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla: employee_status
-- Define el estado de un empleado (ej: Activo, Inactivo, De vacaciones).
CREATE TABLE employee_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);


-- ===================================================
-- GRUPO 2: TABLA DE ENTIDAD PRINCIPAL
-- ===================================================

-- Tabla: person
-- Contiene la información demográfica y personal de un individuo,
-- que puede ser un empleado o cualquier otra persona en el sistema.
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    second_last_name VARCHAR(50),
    birth_date DATE NOT NULL,
    phone VARCHAR(20) UNIQUE, -- VARCHAR es mejor para teléfonos por prefijos, guiones, etc.
    ssn VARCHAR(15),          -- Número de Seguro Social, como texto para no perder ceros iniciales.
    photo BYTEA               -- Para almacenar datos binarios de una imagen (BLOB en otros sistemas).
);


-- ===================================================
-- GRUPO 3: TABLA DE RELACIÓN
-- Conecta las entidades y catálogos.
-- ===================================================

-- Tabla: employees
-- Contiene información específica del rol laboral de una persona.
-- Vincula una persona con su puesto, estado, y otros detalles laborales.
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL,
    hire_date DATE NOT NULL,
    status_id INT,
    position_id INT,
    time_zone_id INT,

    -- Definición de las claves foráneas para garantizar la integridad referencial
    CONSTRAINT fk_person
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON DELETE CASCADE, -- Si se elimina la persona, se elimina su registro de empleado.

    CONSTRAINT fk_position
        FOREIGN KEY (position_id) REFERENCES positions(position_id)
        ON DELETE SET NULL, -- Si se elimina un puesto, el campo en empleado se vuelve nulo.

    CONSTRAINT fk_status
        FOREIGN KEY (status_id) REFERENCES employee_status(status_id)
        ON DELETE SET NULL, -- Si se elimina un estado, el campo en empleado se vuelve nulo.

    CONSTRAINT fk_time_zone
        FOREIGN KEY (time_zone_id) REFERENCES time_zones(time_zone_id)
        ON DELETE SET NULL -- Si se elimina una zona horaria, el campo en empleado se vuelve nulo.
);

-- COMMIT;

-- Final del script. La base de datos está lista para ser poblada.

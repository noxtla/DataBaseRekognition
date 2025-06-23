-- ================================================================
--
--             ESQUEMA DE BASE DE DATOS COMPLETO (FUTURO)
--
-- Este script define la estructura completa y normalizada para
-- todos los módulos planificados del sistema. Incluye mejoras
-- en consistencia, integridad de datos y documentación.
--
-- ================================================================

BEGIN;

-- ===================================================
-- GRUPO 1: TABLAS DE CATÁLOGO (LOOKUP TABLES)
-- Almacenan opciones predefinidas para garantizar la consistencia.
-- ===================================================

CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employee_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE license_types (
    license_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE document_types (
    document_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE attendance_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE vehicle_types (
    vehicle_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE fuel_types (
    fuel_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE maintenance_types (
    maintenance_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE tool_types (
    tool_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);


-- ===================================================
-- GRUPO 2: ENTIDADES PRINCIPALES
-- Representan los objetos centrales del sistema.
-- ===================================================

CREATE TABLE persons (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    second_last_name VARCHAR(50),
    birth_date DATE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    ssn VARCHAR(15) UNIQUE,
    photo BYTEA
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL UNIQUE,
    hire_date DATE NOT NULL,
    CONSTRAINT fk_employees_person
        FOREIGN KEY (person_id) REFERENCES persons(person_id)
        ON DELETE CASCADE
);

CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    address TEXT,
    coordinates POINT -- Usar tipo de dato geoespacial si se necesita.
);

CREATE TABLE crews (
    crew_id SERIAL PRIMARY KEY,
    crew_name VARCHAR(50) NOT NULL UNIQUE,
    location_id INT,
    CONSTRAINT fk_crews_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
        ON DELETE SET NULL
);

CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    plate VARCHAR(20) NOT NULL UNIQUE,
    vin VARCHAR(17) UNIQUE, -- Vehicle Identification Number
    vehicle_type_id INT,
    fuel_type_id INT,
    purchase_date DATE,
    assigned_to_employee_id INT,
    CONSTRAINT fk_vehicles_type
        FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types(vehicle_type_id) ON DELETE SET NULL,
    CONSTRAINT fk_vehicles_fuel_type
        FOREIGN KEY (fuel_type_id) REFERENCES fuel_types(fuel_type_id) ON DELETE SET NULL,
    CONSTRAINT fk_vehicles_employee
        FOREIGN KEY (assigned_to_employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

CREATE TABLE tools (
    tool_id SERIAL PRIMARY KEY,
    tool_name VARCHAR(100) NOT NULL,
    serial_number VARCHAR(100) UNIQUE,
    tool_type_id INT,
    purchase_date DATE,
    CONSTRAINT fk_tools_type
        FOREIGN KEY (tool_type_id) REFERENCES tool_types(tool_type_id) ON DELETE SET NULL
);


-- ===================================================
-- GRUPO 3: TABLAS DE RELACIÓN E HISTORIAL
-- Conectan entidades y registran eventos a lo largo del tiempo.
-- ===================================================

-- Historial de puestos de un empleado
CREATE TABLE employee_position_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    position_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT fk_eph_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_eph_position FOREIGN KEY (position_id) REFERENCES positions(position_id) ON DELETE RESTRICT
);

-- Historial de estados de un empleado (Activo, Vacaciones, etc.)
CREATE TABLE employee_status_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    status_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT fk_esh_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_esh_status FOREIGN KEY (status_id) REFERENCES employee_status(status_id) ON DELETE RESTRICT
);

-- Licencias de un empleado
CREATE TABLE licenses (
    license_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    license_type_id INT NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    expiration_date DATE NOT NULL,
    CONSTRAINT fk_licenses_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_licenses_type FOREIGN KEY (license_type_id) REFERENCES license_types(license_type_id) ON DELETE RESTRICT
);

-- Documentos DOT de un empleado
CREATE TABLE dot_documents (
    document_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    document_type_id INT NOT NULL,
    file_content BYTEA,
    issue_date DATE,
    expiration_date DATE,
    CONSTRAINT fk_dot_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_dot_type FOREIGN KEY (document_type_id) REFERENCES document_types(document_type_id) ON DELETE RESTRICT
);

-- Asignación de empleados a cuadrillas (crews)
CREATE TABLE employee_crews (
    employee_crew_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    crew_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    CONSTRAINT fk_ec_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_ec_crew FOREIGN KEY (crew_id) REFERENCES crews(crew_id) ON DELETE CASCADE
);

-- Registro diario de asistencia
CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status_id INT NOT NULL,
    check_in TIMESTAMPTZ,
    check_out TIMESTAMPTZ,
    CONSTRAINT fk_attendance_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_status FOREIGN KEY (status_id) REFERENCES attendance_status(status_id) ON DELETE RESTRICT
);

-- Historial de mantenimiento de vehículos
CREATE TABLE maintenance_history (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    maintenance_type_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    cost NUMERIC(10, 2),
    description TEXT,
    CONSTRAINT fk_mh_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    CONSTRAINT fk_mh_type FOREIGN KEY (maintenance_type_id) REFERENCES maintenance_types(maintenance_type_id) ON DELETE RESTRICT
);

-- Historial de odómetro de vehículos
CREATE TABLE vehicle_odometer_history (
    id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    reading_date DATE NOT NULL,
    odometer_value INT NOT NULL,
    CONSTRAINT fk_voh_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

-- Asignación de herramientas a empleados o vehículos
CREATE TABLE tool_assignments (
    assignment_id SERIAL PRIMARY KEY,
    tool_id INT NOT NULL,
    employee_id INT, -- Puede ser asignada a un empleado
    vehicle_id INT,  -- O a un vehículo
    date_assigned DATE NOT NULL,
    date_returned DATE,
    CONSTRAINT fk_ta_tool FOREIGN KEY (tool_id) REFERENCES tools(tool_id) ON DELETE CASCADE,
    CONSTRAINT fk_ta_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_ta_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    CONSTRAINT chk_assignment_target CHECK (employee_id IS NOT NULL OR vehicle_id IS NOT NULL)
);

-- Historial de ubicación de un vehículo
CREATE TABLE vehicle_location_history (
    id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    location_id INT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    CONSTRAINT fk_vlh_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    CONSTRAINT fk_vlh_location FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

COMMIT;

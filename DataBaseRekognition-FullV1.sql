-- ============================================
-- PERSONAS Y EMPLEADOS
-- ============================================

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    second_last_name VARCHAR(50),
    birth_date DATE NOT NULL,
    phone VARCHAR(20),
    ssn VARCHAR(15),
    photo BYTEA
);

CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE employee_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    person_id INT REFERENCES person(person_id),
    hire_date DATE NOT NULL,
    status_id INT REFERENCES employee_status(status_id)
);

CREATE TABLE employee_position_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    position_id INT REFERENCES positions(position_id),
    start_date DATE NOT NULL,
    end_date DATE
);

-- ============================================
-- LICENCIAS Y DOCUMENTACIÓN DOT
-- ============================================

CREATE TABLE license_types (
    license_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE licenses (
    license_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    license_type_id INT REFERENCES license_types(license_type_id),
    license_number VARCHAR(50) NOT NULL,
    expiration_date DATE NOT NULL
);

CREATE TABLE document_types (
    document_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE dot_documents (
    document_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    document_type_id INT REFERENCES document_types(document_type_id),
    file BYTEA,
    expiration_date DATE
);

-- ============================================
-- ASISTENCIA Y CREWS
-- ============================================

CREATE TABLE crew (
    crew_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location_id INT
);

CREATE TABLE employee_crew (
    employee_crew_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    crew_id INT REFERENCES crew(crew_id),
    assigned_date DATE NOT NULL
);

CREATE TABLE attendance_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    date DATE NOT NULL,
    status_id INT REFERENCES attendance_status(status_id),
    check_in TIME,
    check_out TIME
);

-- ============================================
-- VEHÍCULOS Y MANTENIMIENTO
-- ============================================

CREATE TABLE vehicle_type (
    vehicle_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE fuel_type (
    fuel_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    plate VARCHAR(20) NOT NULL,
    vehicle_type_id INT REFERENCES vehicle_type(vehicle_type_id),
    fuel_type_id INT REFERENCES fuel_type(fuel_type_id),
    purchase_date DATE,
    assigned_to_employee INT REFERENCES employee(employee_id)
);

CREATE TABLE maintenance_type (
    maintenance_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicle(vehicle_id),
    maintenance_type_id INT REFERENCES maintenance_type(maintenance_type_id),
    date DATE NOT NULL,
    cost NUMERIC(10, 2),
    description TEXT
);

CREATE TABLE vehicle_odometer_history (
    id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicle(vehicle_id),
    date DATE NOT NULL,
    odometer INT NOT NULL
);

-- ============================================
-- HERRAMIENTAS
-- ============================================

CREATE TABLE tool_type (
    tool_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE tool (
    tool_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    serial_number VARCHAR(100),
    tool_type_id INT REFERENCES tool_type(tool_type_id),
    purchase_date DATE
);

CREATE TABLE tool_assignment (
    assignment_id SERIAL PRIMARY KEY,
    tool_id INT REFERENCES tool(tool_id),
    employee_id INT REFERENCES employee(employee_id),
    date_assigned DATE,
    date_returned DATE
);

CREATE TABLE tool_location (
    tool_location_id SERIAL PRIMARY KEY,
    tool_id INT REFERENCES tool(tool_id),
    vehicle_id INT REFERENCES vehicle(vehicle_id),
    location_description TEXT
);

-- ============================================
-- UBICACIÓN
-- ============================================

CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    address TEXT
);

CREATE TABLE vehicle_location_history (
    id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicle(vehicle_id),
    location_id INT REFERENCES location(location_id),
    start_date DATE NOT NULL,
    end_date DATE
);

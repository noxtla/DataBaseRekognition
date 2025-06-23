-- ================================================================
--
--                       DATABASE SCHEMA
--
-- This script creates the complete table structure for the
-- Noxtla Database Rekognition system. It is designed to be
-- executed on a clean PostgreSQL database.
--
-- ================================================================

BEGIN;

-- ===================================================
-- GRUPO 1: LOOKUP TABLES
-- These tables store predefined options to ensure data consistency.
-- ===================================================

-- Stores the different job positions available.
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE
);

-- Stores time zones to handle employee location differences.
CREATE TABLE time_zones (
    time_zone_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Defines the employment status of an employee (e.g., Active, Inactive).
CREATE TABLE employee_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Defines the possible statuses for a daily attendance record.
CREATE TABLE attendance_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);


-- ===================================================
-- GRUPO 2: CORE ENTITY TABLES
-- ===================================================

-- Stores personal and demographic information for an individual.
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    second_last_name VARCHAR(50),
    birth_date DATE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    ssn VARCHAR(15),
    photo BYTEA
);


-- ===================================================
-- GRUPO 3: RELATIONAL AND TRANSACTIONAL TABLES
-- ===================================================

-- Stores employment-specific data, linking a person to their job role.
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL,
    hire_date DATE NOT NULL,
    status_id INT,
    position_id INT,
    time_zone_id INT,

    CONSTRAINT fk_person
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON DELETE CASCADE, -- If a person is deleted, their employee record is also deleted.

    CONSTRAINT fk_status
        FOREIGN KEY (status_id) REFERENCES employee_status(status_id)
        ON DELETE SET NULL, -- If a status is deleted, the employee's status becomes NULL.

    CONSTRAINT fk_position
        FOREIGN KEY (position_id) REFERENCES positions(position_id)
        ON DELETE SET NULL, -- If a position is deleted, the employee's position becomes NULL.

    CONSTRAINT fk_time_zone
        FOREIGN KEY (time_zone_id) REFERENCES time_zones(time_zone_id)
        ON DELETE SET NULL -- If a time zone is deleted, the employee's time zone becomes NULL.
);

-- Stores daily attendance records for each employee.
CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status_id INT REFERENCES attendance_status(status_id) ON DELETE SET NULL,
    check_in TIME,
    check_out TIME
);

-- Stores system- or user-generated notifications for employees.
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    sender_employee_id INT REFERENCES employees(employee_id) ON DELETE SET NULL,
    recipient_employee_id INT NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    subject VARCHAR(255) NOT NULL,
    content TEXT,
    ui_color VARCHAR(7),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


COMMIT;

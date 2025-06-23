-- ================================================================
--
--                        INITIAL DATA
--
-- This script populates the database with initial seed data.
-- It should be executed after the schema.sql script.
--
-- ================================================================

BEGIN;

-- Populate lookup tables first.

-- Table: attendance_status
INSERT INTO attendance_status (status_id, name) VALUES
(1, 'Present'),
(2, 'Absent'),
(3, 'Late'),
(4, 'On Leave'),
(5, 'Remote Work'),
(6, 'Sick Leave'),
(7, 'Half Day'),
(8, 'Holiday')
ON CONFLICT (name) DO NOTHING;

-- Table: time_zones
INSERT INTO time_zones (name) VALUES
('America/New_York'),
('America/Mexico_City')
ON CONFLICT (name) DO NOTHING;

-- Table: positions
INSERT INTO positions (position_name) VALUES
('General Former'),
('Groundman'),
('Trimer'),
('Former')
ON CONFLICT (position_name) DO NOTHING;

-- Table: employee_status
INSERT INTO employee_status (name) VALUES
('Active'),
('Inactive')
ON CONFLICT (name) DO NOTHING;


-- Populate core entity tables.

-- Table: person
-- Note: person_id 6 (Samuel Segura) is intentionally omitted as per deletion logs.
INSERT INTO person (person_id, first_name, middle_name, last_name, second_last_name, birth_date, phone, ssn) VALUES
(1, 'Jesus', 'Salvador', 'Cortes', 'Gutierrez', '1996-09-24', '3313277149', '1230'),
(2, 'David', NULL, 'Reyes', NULL, '2004-09-22', '6149716963', '5555'),
(3, 'Carlos', NULL, 'Chinchilla', NULL, '2000-05-16', '7868528175', '7777'),
(4, 'Edwin', NULL, 'Rodriguez', NULL, '1995-10-20', '9372045558', '6666'),
(5, 'Jose', 'Martin', 'Segura', 'Murillo', '1995-01-20', '3324911134', '9999'),
(7, 'Daniel', NULL, 'Beltran', 'Roman', '1985-12-04', '3311976666', '8888'),
(8, 'Jesus', NULL, 'De la torre', 'Valdez', '1985-01-09', '3312794875', '2222')
ON CONFLICT (person_id) DO NOTHING;


-- Populate relational tables last.

-- Table: employees
INSERT INTO employees (person_id, hire_date, status_id, position_id, time_zone_id) VALUES
(1, '2025-09-02', (SELECT status_id FROM employee_status WHERE name = 'Active'), (SELECT position_id FROM positions WHERE position_name = 'General Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(2, CURRENT_DATE, (SELECT status_id FROM employee_status WHERE name = 'Active'), (SELECT position_id FROM positions WHERE position_name = 'Groundman'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(3, CURRENT_DATE, (SELECT status_id FROM employee_status WHERE name = 'Active'), (SELECT position_id FROM positions WHERE position_name = 'Trimer'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(4, CURRENT_DATE, (SELECT status_id FROM employee_status WHERE name = 'Active'), (SELECT position_id FROM positions WHERE position_name = 'Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(5, CURRENT_DATE, NULL, (SELECT position_id FROM positions WHERE position_name = 'Groundman'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')),
(7, CURRENT_DATE, NULL, (SELECT position_id FROM positions WHERE position_name = 'Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')),
(8, CURRENT_DATE, NULL, (SELECT position_id FROM positions WHERE position_name = 'General Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City'));

COMMIT;

/*Todo el alter va aca arriba*/
ALTER TABLE person
ADD CONSTRAINT unique_phone ;



/*Grupo 1 Creacion de tablas*/

-- ============================
-- GRUPO 1: Personas y Empleados
-- GRUPO 1.1 Attendance
-- Aqui los puros esquemas
-- ============================

-- Tabla: person
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    second_last_name VARCHAR(50),
    birth_date DATE NOT NULL,
    phone VARCHAR(20) UNIQUE (phone),
    ssn VARCHAR(15),
    photo BYTEA
);




-- Tabla: positions
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL
);


-- Tabla: time_zones
CREATE TABLE time_zones (
    time_zone_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Tabla: employee
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES person(person_id),
    hire_date DATE NOT NULL,
    status_id INT, -- Puedes enlazar con una tabla employee_status si lo necesitas
    position_id INT REFERENCES positions(position_id),
    time_zone_id INT REFERENCES time_zones(time_zone_id)
);


/*Nuevas tablas para attendance*/
CREATE TABLE attendance_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    date DATE NOT NULL,
    status_id INT REFERENCES attendance_status(status_id),
    check_in TIME,
    check_out TIME
);



/*Mas tablas*/



-- ==========================================================
-- NUEVA TABLA: NOTIFICACIONES (Basada en tu requerimiento)
-- ==========================================================
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    
    -- Quién manda la notificación. Si es NULL, es una notificación del sistema.
    sender_employee_id INT REFERENCES employees(employee_id), 
    
    -- Quién recibe la notificación. Siempre es un empleado.
    recipient_employee_id INT NOT NULL REFERENCES employees(employee_id),
    
    -- Título o asunto de la notificación, como se ve en la imagen.
    subject VARCHAR(255) NOT NULL,
    
    -- Contenido o cuerpo del mensaje. TEXT para no tener límite de caracteres.
    content TEXT,
    
    -- Color para el indicador visual (el punto), ej: '#FF5733'.
    ui_color VARCHAR(7),
    
    -- Columna para saber si la notificación fue leída (el círculo en tu imagen).
    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    -- Fecha y hora exacta de la publicación. Fundamental para el "hace N minutos/días".
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);




/*Todos los datos*/

/*Datos para asistencia*/


truncate table attendance_status;

INSERT INTO attendance_status (status_id, name)
VALUES
(1, 'Present'),         -- Asistió
(2, 'Absent'),          -- Ausente
(3, 'Late'),            -- Tarde
(4, 'On Leave'),        -- Permiso
(5, 'Remote Work'),     -- Trabajo remoto
(6, 'Sick Leave'),      -- Baja por enfermedad
(7, 'Half Day'),        -- Medio día
(8, 'Holiday');         -- Día festivo


-- Insertar time_zones
INSERT INTO time_zones (name) VALUES
  ('America/New_York'),
  ('America/Mexico_City');

-- Insertar positions
INSERT INTO positions (position_name) VALUES
  ('General Former'),
  ('Groundman'),
  ('Trimer'),
  ('Former');

-- Insertar personas
INSERT INTO person (first_name, middle_name, last_name, second_last_name, birth_date, phone, ssn) VALUES
  ('Jesus', 'Salvador', 'Cortes', 'Gutierrez', '1996-09-24', '3313277149', '1230'),
  ('David', NULL, 'Reyes', NULL, '2004-09-22', '6149716963', '5555'),
  ('Carlos', NULL, 'Chinchilla', NULL, '2000-05-16', '7868528175', '7777'),
  ('Edwin', NULL, 'Rodriguez', NULL, '1995-10-20', '9372045558', '6666'),
  ('Jose', 'Martin', 'Segura', 'Murillo', '1995-01-20', '3324911134', '9999'),
  ('Samuel', NULL, 'Segura', 'Garcia', '1995-04-21', '3314611703', '4444'),
  ('Daniel', NULL, 'Beltran', 'Roman', '1985-12-04', '3311976666', '8888'),
  ('Jesus', NULL, 'De la torre', 'Valdez', '1985-01-09', '3312794875', '2222');

-- Insertar empleados
INSERT INTO employee (person_id, hire_date, position_id, time_zone_id) VALUES
  (
    1,
    '2025-09-02',
    (SELECT position_id FROM positions WHERE position_name = 'General Former'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')
  ),
  (
    2,
    CURRENT_DATE,
    (SELECT position_id FROM positions WHERE position_name = 'Groundman'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')
  ),
  (
    3,
    CURRENT_DATE,
    (SELECT position_id FROM positions WHERE position_name = 'Trimer'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')
  ),
  (
    4,
    CURRENT_DATE,
    (SELECT position_id FROM positions WHERE position_name = 'Former'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')
  ),
  (
    5,
    CURRENT_DATE,
    (SELECT position_id FROM positions WHERE position_name = 'Groundman'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')
  ),
  (
    6,
    CURRENT_DATE,
    (SELECT position_id FROM positions WHERE position_name = 'Trimer'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')
  ),
  (
    7,
    CURRENT_DATE,
    (SELECT position_id FROM positions WHERE position_name = 'Former'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')
  ),
  (
    8,
    CURRENT_DATE,
    (SELECT position_id FROM positions WHERE position_name = 'General Former'),
    (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')
  );


/*Consulta*/

SELECT
  CONCAT_WS(' ', p.first_name, p.middle_name, p.last_name, p.second_last_name) AS full_name,
  pos.position_name,
  p.phone,
  p.ssn,
  p.birth_date,
  tz.name AS time_zone
FROM public.person p
JOIN public.employees e ON p.person_id = e.person_id
JOIN public.positions pos ON e.position_id = pos.position_id
LEFT JOIN public.time_zones tz ON e.time_zone_id = tz.time_zone_id
WHERE p.phone = '3312734875';


UPDATE person
SET phone = '3312734875'
WHERE first_name = 'Jesus' AND last_name = 'De la torre';



CREATE TABLE employee_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO employee_status (name)
VALUES 
    ('Active'),
    ('Inactive');



UPDATE employees
SET status_id = (SELECT status_id FROM employee_status WHERE name = 'Active')
WHERE person_id IN (
    SELECT person_id FROM person WHERE first_name = 'David' -- person_id 2 [3, 4]
    UNION
    SELECT person_id FROM person WHERE first_name = 'Carlos' -- person_id 3 [5, 6]
    UNION
    SELECT person_id FROM person WHERE first_name = 'Edwin' -- person_id 4 [5, 6]
    UNION
    SELECT person_id FROM person WHERE first_name = 'Jesus' AND middle_name = 'Salvador' AND last_name = 'Cortes' -- person_id 1 [3, 4]
);

SELECT * from person;
SELECT * from employees;


SELECT
    CONCAT_WS(' ', p.first_name, p.middle_name, p.last_name, p.second_last_name) AS full_name, -- Concatenación de nombres para nombre completo [7]
    pos.position_name, -- Nombre del puesto del empleado [2]
    p.phone, -- Número de teléfono de la persona [7]
    p.ssn, -- Número de seguridad social de la persona [7]
    p.birth_date, -- Fecha de nacimiento de la persona [7]
    tz.name AS time_zone, -- Nombre de la zona horaria [7]
    es.name AS status -- Nombre del estado del empleado (Activo/Inactivo) [2]
FROM public.person p
JOIN public.employees e ON p.person_id = e.person_id -- Une persona con empleado [7]
JOIN public.positions pos ON e.position_id = pos.position_id -- Une empleado con puesto [2]
LEFT JOIN public.time_zones tz ON e.time_zone_id = tz.time_zone_id -- Une empleado con zona horaria (LEFT JOIN para permitir nulos) [2]
JOIN public.employee_status es ON e.status_id = es.status_id -- Une empleado con el estado del empleado (para filtrar por 'Activo') [2]
WHERE es.name = 'Active'; -- Filtra solo los empleados que tienen el estado 'Active' [2]


SELECT
  CONCAT_WS(' ', p.first_name, p.middle_name, p.last_name, p.second_last_name) AS full_name,
  p.phone
FROM public.person p
WHERE p.phone = '3313277149';



-- Primero, identificamos el person_id(s) que corresponden a Samuel Segura Garcia con posición 'Trimmer'

    SELECT p.person_id
    FROM person p
    JOIN employees e ON p.person_id = e.person_id
    JOIN positions pos ON e.position_id = pos.position_id
    WHERE p.first_name = 'Samuel'
      AND pos.position_name = 'Trimer';

-- Eliminamos de employees
DELETE FROM employees
WHERE person_id  = 6;

-- Eliminamos de person
DELETE FROM person
WHERE person_id  = 6;

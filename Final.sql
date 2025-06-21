-- ================================================
-- ESQUEMAS COMPLETOS - CREACIÓN DE BASE DE DATOS
-- ================================================

-- Tabla: person
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

-- Tabla: employee_status
CREATE TABLE employee_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Tabla: employees
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES person(person_id),
    hire_date DATE NOT NULL,
    status_id INT REFERENCES employee_status(status_id),
    position_id INT REFERENCES positions(position_id),
    time_zone_id INT REFERENCES time_zones(time_zone_id)
);

-- Tabla: attendance_status
CREATE TABLE attendance_status (
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Tabla: attendance
CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    date DATE NOT NULL,
    status_id INT REFERENCES attendance_status(status_id),
    check_in TIME,
    check_out TIME
);

-- Tabla: notifications
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    sender_employee_id INT REFERENCES employees(employee_id),
    recipient_employee_id INT NOT NULL REFERENCES employees(employee_id),
    subject VARCHAR(255) NOT NULL,
    content TEXT,
    ui_color VARCHAR(7),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);



-- ========================
-- INSERTS DE DATOS
-- ========================

-- Tabla: attendance_status
TRUNCATE TABLE attendance_status;
INSERT INTO attendance_status (status_id, name)
VALUES
(1, 'Present'),
(2, 'Absent'),
(3, 'Late'),
(4, 'On Leave'),
(5, 'Remote Work'),
(6, 'Sick Leave'),
(7, 'Half Day'),
(8, 'Holiday');

-- Tabla: time_zones
INSERT INTO time_zones (name) VALUES
('America/New_York'),
('America/Mexico_City');

-- Tabla: positions
INSERT INTO positions (position_name) VALUES
('General Former'),
('Groundman'),
('Trimer'),
('Former');

-- Tabla: person
INSERT INTO person (first_name, middle_name, last_name, second_last_name, birth_date, phone, ssn) VALUES
('Jesus', 'Salvador', 'Cortes', 'Gutierrez', '1996-09-24', '3313277149', '1230'),
('David', NULL, 'Reyes', NULL, '2004-09-22', '6149716963', '5555'),
('Carlos', NULL, 'Chinchilla', NULL, '2000-05-16', '7868528175', '7777'),
('Edwin', NULL, 'Rodriguez', NULL, '1995-10-20', '9372045558', '6666'),
('Jose', 'Martin', 'Segura', 'Murillo', '1995-01-20', '3324911134', '9999'),
('Samuel', NULL, 'Segura', 'Garcia', '1995-04-21', '3314611703', '4444'),
('Daniel', NULL, 'Beltran', 'Roman', '1985-12-04', '3311976666', '8888'),
('Jesus', NULL, 'De la torre', 'Valdez', '1985-01-09', '3312794875', '2222');

-- Tabla: employees
INSERT INTO employees (person_id, hire_date, position_id, time_zone_id) VALUES
(1, '2025-09-02', (SELECT position_id FROM positions WHERE position_name = 'General Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(2, CURRENT_DATE, (SELECT position_id FROM positions WHERE position_name = 'Groundman'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(3, CURRENT_DATE, (SELECT position_id FROM positions WHERE position_name = 'Trimer'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(4, CURRENT_DATE, (SELECT position_id FROM positions WHERE position_name = 'Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/New_York')),
(5, CURRENT_DATE, (SELECT position_id FROM positions WHERE position_name = 'Groundman'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')),
(6, CURRENT_DATE, (SELECT position_id FROM positions WHERE position_name = 'Trimer'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')),
(7, CURRENT_DATE, (SELECT position_id FROM positions WHERE position_name = 'Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City')),
(8, CURRENT_DATE, (SELECT position_id FROM positions WHERE position_name = 'General Former'), (SELECT time_zone_id FROM time_zones WHERE name = 'America/Mexico_City'));

-- Tabla: employee_status
INSERT INTO employee_status (name)
VALUES 
('Active'),
('Inactive');



/*El trigger*/


-- ==========================================================
-- TRIGGER PARA NOTIFICACIONES DE ASISTENCIA
-- ==========================================================

-- Paso 1: Crear la función que generará la notificación.
-- Esta función se ejecutará cada vez que el trigger se dispare.

CREATE OR REPLACE FUNCTION fn_create_attendance_notification()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertamos una nueva fila en la tabla 'notifications'.
    INSERT INTO notifications (
        sender_employee_id,    -- NULL porque es una notificación del sistema.
        recipient_employee_id, -- El ID del empleado que acaba de registrar su asistencia.
        subject,               -- Título de la notificación.
        content,               -- Cuerpo del mensaje.
        ui_color,              -- Color para el indicador visual.
        is_read                -- Por defecto se crea como no leída (false).
    )
    VALUES (
        NULL,                                  -- Enviado por el "Sistema".
        NEW.employee_id,                       -- 'NEW' se refiere a la fila que se acaba de insertar en 'attendance'.
        'Asistencia Registrada Exitosamente',  -- Asunto claro y conciso.
        'Tu check-in del día ha sido registrado. ¡Que tengas un excelente día!', -- Contenido amigable.
        '#28a745',                             -- Un color verde para indicar éxito.
        FALSE
    );

    -- Para triggers 'AFTER', el valor de retorno se ignora, pero es buena práctica devolver NEW.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Paso 2: Crear el trigger y vincularlo a la tabla 'attendance'.
-- Se ejecutará DESPUÉS (AFTER) de cada INSERT en la tabla.

CREATE TRIGGER trg_after_attendance_insert
AFTER INSERT ON attendance
FOR EACH ROW
EXECUTE FUNCTION fn_create_attendance_notification();


/*Test*/

INSERT INTO attendance (employee_id, date, status_id, check_in, check_out)
VALUES (
    (SELECT e.employee_id 
     FROM employees e
     JOIN person p ON e.person_id = p.person_id
     WHERE p.phone = 3313277149),
    $2,
    1,
    $3,
    NULL
);


INSERT INTO attendance (employee_id, date, status_id, check_in, check_out)
VALUES (
    (SELECT e.employee_id 
     FROM employees e
     JOIN person p ON e.person_id = p.person_id
     WHERE p.phone = '3313277149'), -- OJO: Es buena práctica tratar el teléfono como texto
    '2023-10-27',  -- Parámetro $2
    1,
    '09:01:15',    -- Parámetro $3
    NULL
);



/*La consulta notificacion*/

SELECT 
    n.*
FROM 
    notifications n
JOIN 
    employees e ON n.recipient_employee_id = e.employee_id
JOIN 
    person p ON e.person_id = p.person_id
WHERE 
    p.phone = '3313277149'
ORDER BY 
    n.created_at DESC;

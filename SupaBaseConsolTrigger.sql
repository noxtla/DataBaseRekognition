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

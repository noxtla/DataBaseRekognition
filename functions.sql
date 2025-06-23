-- ================================================================
--
--                 DATABASE FUNCTIONS AND TRIGGERS
--
-- This script contains all procedural logic for the database,
-- including functions and triggers.
--
-- ================================================================

BEGIN;

-- ==========================================================
-- TRIGGER FOR ATTENDANCE NOTIFICATIONS
-- ==========================================================

-- STEP 1: Create the function that will be executed by the trigger.
-- This function creates a new notification record whenever an employee
-- checks in.

CREATE OR REPLACE FUNCTION fn_create_attendance_notification()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new row into the 'notifications' table.
    INSERT INTO notifications (
        sender_employee_id,    -- NULL, indicating a system-generated notification.
        recipient_employee_id, -- The ID of the employee who just registered their attendance.
        subject,               -- The title of the notification.
        content,               -- The body of the message.
        ui_color,              -- A color for the UI indicator.
        is_read                -- Default is FALSE.
    )
    VALUES (
        NULL,
        NEW.employee_id,
        'Asistencia Registrada Exitosamente',
        'Tu check-in del día ha sido registrado. ¡Que tengas un excelente día!',
        '#28a745', -- Green for success
        FALSE
    );

    -- The return value is ignored for AFTER triggers, but it is
    -- good practice to return NEW.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- STEP 2: Create the trigger and attach it to the 'attendance' table.
-- This trigger will fire automatically AFTER each new row is inserted.

CREATE TRIGGER trg_after_attendance_insert
AFTER INSERT ON attendance
FOR EACH ROW
EXECUTE FUNCTION fn_create_attendance_notification();


COMMIT;

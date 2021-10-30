-- Basic

CREATE OR REPLACE PROCEDURE clear_serial()
AS $$
BEGIN
ALTER SEQUENCE Employees_eid_seq RESTART WITH 1;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delete_all()
AS $$
BEGIN
DELETE FROM Joins;
DELETE FROM Updates;
DELETE FROM Meetings;
DELETE FROM Meeting_Rooms;
DELETE FROM Health_Declaration;
DELETE FROM Senior;
DELETE FROM Booker;
DELETE FROM Junior;
DELETE FROM Manager;
DELETE FROM PhoneNumbers;
DELETE FROM Employees;
DELETE FROM Departments;
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE add_department 
        (IN dept_id INTEGER, IN dept_name TEXT)
    AS $$
    BEGIN
        INSERT INTO Departments (did, dname) VALUES (dept_id, dept_name);
    END
    $$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE remove_department
        (IN dept_id INTEGER)
    AS $$
    BEGIN
        DELETE FROM Departments WHERE did = dept_id; 
    END
    $$ LANGUAGE plpgsql;

-- Done
-- added dept_id parameter
CREATE OR REPLACE PROCEDURE add_room
        (IN floor_no INTEGER, room_no INTEGER, room_name TEXT, room_capacity INTEGER, dept_id INTEGER, eid INTEGER)
    AS $$
    BEGIN
        INSERT INTO Meeting_Rooms (room, floor_no, rname, did) VALUES (room_no, floor_no, room_name, dept_id);
        INSERT INTO Updates (floor_no, room, update_date, new_capacity, eid) VALUES (floor_no, room_no, CURRENT_DATE, room_capacity, eid);
    END
    $$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE change_capacity 
        (IN floor_no INTEGER, room_no INTEGER, new_date DATE, capacity INTEGER, eid INTEGER)
    AS $$ 
    BEGIN
        INSERT INTO Updates (floor_no, room, update_date, new_capacity, eid) VALUES (floor_no, room_no, new_date, capacity, eid);
    END
    $$ LANGUAGE plpgsql;

-- Done
-- added this procedure

CREATE OR REPLACE PROCEDURE add_phone_number (IN employee_id INTEGER, IN phone_number INTEGER, IN phone_type TEXT) AS $$
        BEGIN
            INSERT INTO PhoneNumbers (eid, phone_number, phone_type) VALUES (employee_id, phone_number, phone_type);
        END
        $$ LANGUAGE plpgsql;

-- Done
-- added phone_type parameter
CREATE OR REPLACE PROCEDURE add_employee
        (IN employee_name TEXT, IN phone_number INTEGER, IN phone_type TEXT, IN kind TEXT, IN department_id INTEGER)
    AS $$
    DECLARE 
        employee_id INTEGER;
        formatted_name TEXT;
    BEGIN
        --ERROR need change generated email to be unique
        formatted_name := REPLACE(employee_name, ' ', '_');
        INSERT INTO Employees (did, ename) VALUES (department_id, employee_name) RETURNING eid INTO employee_id;
        UPDATE Employees SET email = CONCAT(formatted_name, '_', employee_id, '@bluewhale.org') WHERE eid = employee_id;

        IF kind = 'junior' THEN
            INSERT INTO Junior VALUES (employee_id);
        ELSIF kind = 'senior' THEN
            INSERT INTO Booker VALUES (employee_id);
            INSERT INTO Senior VALUES (employee_id);
        ELSIF kind = 'manager' THEN 
            INSERT INTO Booker VALUES (employee_id);
            INSERT INTO Manager VALUES (employee_id);
        END IF;
        CALL add_phone_number(employee_id, phone_number, phone_type);
    END
    $$ LANGUAGE plpgsql;
    
-- Done 
CREATE OR REPLACE PROCEDURE remove_employee
        (IN employee_id INTEGER, IN date_of_resignation DATE)
    AS $$ 
    BEGIN
        UPDATE Employees SET resigned_date = date_of_resignation WHERE eid = employee_id;

        -- WE ARE DIRECTLY DELETING INSTEAD OF CALLING UNBOOKROOM BECAUSE ITS EASIER
        DELETE 
        FROM Meetings m
        WHERE m.booker_eid = employee_id
        AND m.meeting_date > CURRENT_DATE;

        UPDATE Meetings m
        SET m.approver_id = NULL
        WHERE m.approver_eid = employee_id
        AND m.meeting_date > CURRENT_DATE;

        -- WE ARE DIRECTLY DELETING INSTEAD OF CALLING LEAVE MEETING BECAUSE ITS EASIER
        DELETE  
        FROM Joins j
        WHERE j.eid = employee_id
        AND j.meeting_date > CURRENT_DATE;
    END
    $$ LANGUAGE plpgsql;

-- Core
-- Done
CREATE OR REPLACE FUNCTION search_room  -- start/end hour means th
    (IN capacity INTEGER, IN search_date DATE, IN start_hour TIME, IN end_hour TIME) 
    RETURNS TABLE(rm_floor_no INTEGER, rm_no INTEGER, rm_dept_id INTEGER, rm_capacity INTEGER) AS $$
    BEGIN 
    --ERROR: update date might be in the future, so have to max before or equal to current_date
    RETURN QUERY
      WITH rooms_with_enough_capacity AS (
        SELECT floor_no, room, did
        WHERE (room, floor_no) IN (
            SELECT room, floor_no 
            FROM Updates
            WHERE update_date <= search_date
            GROUP BY room, floor_no
            HAVING MAX(new_capacity) >= capacity
        )
      )
      --find rooms with enough capacity available in the specified period
      SELECT *
      FROM rooms_with_enough_capacity
      -- FROM rooms_with_enough_capacity r, Meeting_Rooms mr
      WHERE NOT EXISTS (
        SELECT 1
        FROM Meetings m
        WHERE m.meeting_date = search_date   --e.g. 1230->1330 -- 1300
        AND m.start_time >= start_hour  -- >= start_hour - 59 minutes? NEED CHANGE PROBABLY
        AND m.start_time < end_hour
      );
    END
    $$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE book_room
    (IN floor_no INTEGER, IN room_no INTEGER, IN meeting_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
AS $$
BEGIN
-- Conditions for successful booking:
-- 1. Employee is Booker (Enforced by FK reference to Booker table)
-- 2. Room is available (Enforced by PK being room, floor_no, date, start_time))
-- 3. Employee is not having a fever (Enforced by trigger)
-- 4. Employee is not resigned (Enforced by trigger)

    WHILE (start_hour < end_hour) LOOP
        INSERT INTO Meetings (floor_no, room, meeting_date, start_time, meeting_date, booker_eid, approver_eid) VALUES (floor_no, room_no, meeting_date, start_hour, meeting_date, employee_id, NULL);
        start_hour := start_hour + interval '1 hour';
    END LOOP;

    --CONSTRAINT 18: BOOKER ALSO JOINS MEETING
    call join_meeting(floor_no, room_no, meeting_date, start_hour, end_hour, employee_id);
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE unbook_room
        (IN floor_no INTEGER, IN room_no INTEGER, IN meeting_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
    AS $$
    DECLARE 
        booker_eid INTEGER;
    BEGIN
        SELECT m.booker_eid INTO booker_eid
        FROM Meetings m
        WHERE m.room = room.no
        AND m.floor_no = floor_no
        AND m.meeting_date = meeting_date
        AND m.start_time = start_hour;

        IF booker_eid <> employee_id THEN
            RAISE NOTICE 'Error: Only the booker of the meeting is allowed to unbook the room';
            RETURN;
        END IF;

        DELETE FROM Meetings m
        WHERE m.floor_no = floor_no 
        AND m.room = room_no 
        AND m.meeting_date = meeting_date
        AND m.start_time >= start_hour 
        AND m.start_time < end_hour 
        AND m.booker_eid = eid;

        DELETE FROM Joins j
        WHERE j.room = room_no
        AND j.floor_no = floor_no
        AND j.meeting_date = meeting_date
        AND j.start_time >= start_hour
        AND j.start_time < end_hour;
    END
    $$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE join_meeting
    (IN floor_no INTEGER, IN room_no INTEGER, IN meeting_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
    AS $$
    BEGIN
        -- NEED TO CHECK IF THE PERSON JOINING CAN JOIN (CANNOT BE APPROVED MEETING)
    WHILE (start_hour < end_hour) LOOP
        INSERT INTO Joins (room, floor_no, meeting_date, start_time, eid) VALUES (room_no, floor_no, meeting_date, start_hour, employee_id);
        start_hour := start_hour + interval '1 hour';
    END LOOP;

    END
    $$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE leave_meeting (
    IN floor_no INTEGER,
    IN room_no INTEGER,
    IN meeting_date DATE,
    IN start_hour TIME,
    IN end_hour TIME,
    IN employee_id INTEGER
    )
AS $$
BEGIN
    DELETE FROM Joins j 
    WHERE j.floor_no = floor_no 
    AND j.room_no = room_no
    AND j.meeting_date = meeting_date
    AND start_time BETWEEN start_hour AND end_hour;
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE approve_meeting (
    IN floor_no INTEGER, 
    IN room_no INTEGER, 
    IN meeting_date DATE, 
    IN start_hour TIME, 
    IN end_hour TIME,
    IN employee_id INTEGER,
    IN decision BOOLEAN
) AS $$
BEGIN
    IF decision IS TRUE THEN
        UPDATE Meetings m SET approver_eid = employee_id WHERE m.floor_no = floor_no
        AND m.room_no = room_no
        AND m.meeting_date = meeting_date
        AND m.start_time BETWEEN start_hour AND end_hour - interval '1 hour';
    ELSIF decision IS FALSE THEN
        CALL reject_meeting(floor_no, room_no, meeting_date, start_hour, end_hour);
    END IF;
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE reject_meeting (
    IN floor_no INTEGER, IN room_no INTEGER, IN meeting_date DATE, IN start_hour TIME, IN end_hour TIME
) AS $$
BEGIN
    DELETE FROM Meetings m WHERE m.floor_no = floor_no
    AND m.room_no = room_no
    AND m.meeting_date = meeting_date
    AND start_time BETWEEN start_hour AND end_hour;
END
$$ LANGUAGE plpgsql;
-- Health
 
-- Done 
-- fever boolean implemented in triggers
CREATE OR REPLACE PROCEDURE declare_health
    (IN employee_id INTEGER, declaration_date DATE, temp NUMERIC)
AS $$
BEGIN
    INSERT INTO Health_Declaration (eid, hd_date, temp, fever) VALUES (employee_id, declaration_date, temp, FALSE);
END
$$ LANGUAGE plpgsql;

/*
CREATE OR REPLACE FUNCTION contact_tracing 
 (IN employee_id INTEGER)
RETURNS TABLE(contacts INTEGER) AS $$
DECLARE
    Bookings CURSOR FOR 
        SELECT room, floor_no, meeting_date, start_time 
        FROM Meetings
        WHERE booker_eid = employee.id;
    Attended_Rooms CURSOR FOR
        SELECT room, floor_no 
        FROM Joins
        WHERE eid = employee_id
        AND meeting_date ;
BEGIN
    DELETE * 
    FROM Joins 
    WHERE eid = employee.id
    AND meeting_date > CURRENT_DATE;
    FOR b IN (SELECT * FROM Bookings) LOOP
        DELETE FROM Meetings m WHERE 
        m.floor_no = b.floor_no
        AND m.room = b.room
        AND m.meeting_date = b.meeting_date
        AND m.start_time = b.start_time
    END LOOP;
    FOR a in (SELECT * FROM Attended_Rooms) LOOP
        SELECT eid INTO TABLE FROM Joins j WHERE
        room j.room = a.room
        AND j.floor = a.floor;
    
END
$$ LANGUAGE plpgsql;

-- Admin

CREATE OR REPLACE FUNCTION non_compliance
    (IN starting_date DATE, OUT end_date DATE) 
RETURNS TABLE (
    employee_id INTEGER,
    number_of_days INTEGER
) AS $$
BEGIN 
    -- how tf do u do dis
END
$$ LANGUAGE plpgsql;
*/
-- Done
CREATE OR REPLACE FUNCTION view_booking_report
    (IN start_on DATE, eid INTEGER)
RETURNS RECORD AS $$
BEGIN
    SELECT floor_no, room AS room_no, meeting_date, start_time AS start_hour, (approver_eid IS NOT NULL) AS is_approved
    FROM Meeting
    WHERE booker_eid = eid AND start_time >= start_on
    ORDER BY meeting_date, start_time ASC;
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE FUNCTION view_future_meeting
    (IN date_start DATE, employee_id INTEGER)
RETURNS RECORD AS $$
BEGIN
    SELECT floor_no, room AS room_no, meeting_date, start_time AS start_hour
    FROM Joins
    WHERE eid = employee_id AND meeting_date >= date_start
    ORDER BY meeting_date, start_time ASC;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION view_manager_report
    (IN date_start DATE, employee_id INTEGER)
RETURNS RECORD AS $$
    
$$ LANGUAGE plpgsql;

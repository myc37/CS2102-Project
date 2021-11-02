 n- Basic

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
DELETE FROM Phone_Numbers;
DELETE FROM Employees;
DELETE FROM Departments;
END
$$ LANGUAGE plpgsql;

-- Done!
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

-- Done!
-- added dept_id parameter
CREATE OR REPLACE PROCEDURE add_room
        (IN floor_no INTEGER, room_no INTEGER, room_name TEXT, room_capacity INTEGER, dept_id INTEGER, eid INTEGER)
    AS $$
    BEGIN
        INSERT INTO Meeting_Rooms (room, floor_no, rname, did) VALUES (room_no, floor_no, room_name, dept_id);
        INSERT INTO Updates (floor_no, room, update_date, new_capacity, eid) VALUES (floor_no, room_no, CURRENT_DATE, room_capacity, eid);
    END
    $$ LANGUAGE plpgsql;

-- Done!
CREATE OR REPLACE PROCEDURE change_capacity 
        (IN floor_number INTEGER, room_number INTEGER, new_date DATE, capacity INTEGER, employee_id INTEGER)
    AS $$ 
    BEGIN
    IF ((floor_number, room_number, new_date) NOT IN (Select floor_no, room, update_date from Updates)) THEN
        INSERT INTO Updates (floor_no, room, update_date, new_capacity, eid) VALUES (floor_number, room_number, new_date, capacity, employee_id);
    ELSE
        UPDATE Updates 
        SET new_capacity = capacity, eid = employee_id 
        WHERE floor_no = floor_number 
        AND room = room_number 
        AND update_date = new_date;
    END IF;
    END
    $$ LANGUAGE plpgsql;

-- Done!
-- added this procedure
CREATE OR REPLACE PROCEDURE add_phone_number (IN employee_id INTEGER, IN phone_number INTEGER, IN phone_type TEXT) AS $$
        BEGIN
            INSERT INTO Phone_Numbers (eid, phone_number, phone_type) VALUES (employee_id, phone_number, phone_type);
        END
        $$ LANGUAGE plpgsql;

-- Done!
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
            -- INSERT INTO Booker VALUES (employee_id);
            INSERT INTO Senior VALUES (employee_id);
        ELSIF kind = 'manager' THEN 
            -- INSERT INTO Booker VALUES (employee_id);
            INSERT INTO Manager VALUES (employee_id);
        END IF;
        CALL add_phone_number(employee_id, phone_number, phone_type);
    END
    $$ LANGUAGE plpgsql;
    
-- Done!
CREATE OR REPLACE PROCEDURE remove_employee
        (IN employee_id INTEGER, IN date_of_resignation DATE)
    AS $$ 
    BEGIN
        UPDATE Employees SET resigned_date = date_of_resignation WHERE eid = employee_id;

        -- WE ARE DIRECTLY DELETING INSTEAD OF CALLING UNBOOKROOM BECAUSE ITS EASIER
        DELETE 
        FROM Meetings m
        WHERE m.booker_eid = employee_id
        AND ((m.meeting_date = CURRENT_DATE AND m.start_time > CURRENT_TIME) OR (m.meeting_date > CURRENT_DATE));

        UPDATE Meetings m2
        SET m2.approver_eid = NULL
        WHERE m2.approver_eid = employee_id
        AND ((m2.meeting_date = CURRENT_DATE AND m2.start_time > CURRENT_TIME) OR (m2.meeting_date > CURRENT_DATE));


        -- WE ARE DIRECTLY DELETING INSTEAD OF CALLING LEAVE MEETING BECAUSE ITS EASIER
        DELETE  
        FROM Joins j
        WHERE j.eid = employee_id
        AND ((j.meeting_date = CURRENT_DATE AND j.start_time > CURRENT_TIME) OR (j.meeting_date > CURRENT_DATE));

        -- Delete all future change_capacities initiated by the employee that is resigning
        DELETE
        FROM Updates u
        WHERE u.approver_eid = emplotee_id
        AND ((u.meeting_date = CURRENT_DATE AND u.start_time > CURRENT_TIME) OR (u.meeting_date > CURRENT_DATE));

    END
    $$ LANGUAGE plpgsql;

-- Core
-- Done!
CREATE OR REPLACE FUNCTION search_room  -- start/end hour means th
    (IN capacity INTEGER, IN search_date DATE, IN start_hour TIME, IN end_hour TIME) 
    RETURNS TABLE(rm_floor_no INTEGER, rm_no INTEGER, rm_dept_id INTEGER, rm_capacity INTEGER) AS $$
    BEGIN 
    --ERROR: update date might be in the future, so have to max before or equal to current_date
    IF (start_hour > end_hour) THEN 
        RAISE NOTICE 'Error: start time cannot be later than end time';
        RETURN;
    END IF;
    RETURN QUERY
       WITH rooms_with_enough_capacity AS (
        SELECT u.floor_no, u.room, u.new_capacity
        FROM Updates u NATURAL JOIN (
          SELECT room, floor_no, MAX(update_date) as update_date
          FROM Updates
          WHERE update_date <= search_date
          GROUP BY room, floor_no  
        ) AS latest_updates
        WHERE u.new_capacity >= capacity),
        --
      --find rooms with enough capacity available in the specified period
      partial_answer AS (
        SELECT *
        FROM rooms_with_enough_capacity r
        WHERE (floor_no, room) NOT IN 
        (SELECT floor_no, room
            FROM Meetings m
            WHERE m.meeting_date = search_date
            AND m.start_time > start_hour - interval '1 hour'
            AND m.start_time < end_hour        
        )
      )
      SELECT p.floor_no, p.room, mr.did, p.new_capacity
      FROM partial_answer p INNER JOIN Meeting_Rooms mr ON 
      p.floor_no = mr.floor_no AND p.room = mr.room;
      
    END
    $$ LANGUAGE plpgsql;

/*
    SELECT * FROM Updates u 
    WHERE update_date >= ALL(SELECT u2.update_date 
    FROM Updates u2 WHERE u.room = u2.room AND 
    u.floor_no = u2.floor_no)
*/
-- Done!
    CREATE OR REPLACE PROCEDURE book_room
        (IN floor_number INTEGER, IN room_number INTEGER, IN meet_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
    AS $$
    DECLARE
        starting_time TIME;
    BEGIN
        -- Conditions for successful booking:
        -- 1. Employee is Booker (Enforced by FK reference to Booker table)
        -- 2. Room is available (Enforced by PK being room, floor_no, date, start_time))
        -- 3. Employee is not having a fever (Enforced by trigger)
        -- 4. Employee is not resigned (Enforced by trigger)

        IF (start_hour > end_hour) THEN
            RAISE NOTICE 'Error: start time cannot be later than end time';
            RETURN;
        ELSE 
                starting_time := start_hour;
            WHILE (start_hour < end_hour) LOOP
                INSERT INTO Meetings (floor_no, room, meeting_date, start_time, booker_eid, approver_eid) VALUES (floor_number, room_number, meet_date, start_hour, employee_id, NULL);
                start_hour := start_hour + interval '1 hour';
            END LOOP;
            CALL join_meeting(floor_number, room_number, meet_date, starting_time, end_hour, employee_id);
        END IF;
    END
    $$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE unbook_room
        (IN floor_number INTEGER, IN room_number INTEGER, IN meet_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
    AS $$
    DECLARE 
        booker_eid INTEGER;
    BEGIN
        SELECT m.booker_eid INTO booker_eid
        FROM Meetings m
        WHERE m.room = room_number
        AND m.floor_no = floor_number
        AND m.meeting_date = meet_date
        AND m.start_time = start_hour;

        IF booker_eid <> employee_id THEN
            RAISE EXCEPTION USING
                errcode:= 'NOSBT',
                message:= 'Error: Only the booker of the meeting is allowed to unbook the room';
        END IF;

        -- DELETE FROM Joins j
        -- WHERE j.room = room_number
        -- AND j.floor_no = floor_number
        -- AND j.meeting_date = meeting_date
        -- AND j.start_time >= start_hour
        -- AND j.start_time < end_hour;

        DELETE FROM Meetings m
        WHERE m.floor_no = floor_number 
        AND m.room = room_number 
        AND m.meeting_date = meet_date
        AND m.start_time >= start_hour 
        AND m.start_time < end_hour 
        AND m.booker_eid = employee_id;
    END
    $$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE join_meeting
    (IN floor_number INTEGER, IN room_no INTEGER, IN meet_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
    AS $$
    DECLARE is_approved BOOLEAN;
    BEGIN

    SELECT (approver_eid IS NOT NULL) INTO is_approved 
    FROM Meetings m 
    WHERE m.floor_no = floor_number 
    AND m.room = room_noe
    AND m.meeting_date = meeting_date
    AND m.start_time = start_hour;

    IF (is_approved IS TRUE) THEN
        RAISE EXCEPTION USING
            errcode='JNAPR',
            message='Error: Cannot join approved meeting';
    END IF;
    

    WHILE (start_hour < end_hour) LOOP
        INSERT INTO Joins (room, floor_no, meeting_date, start_time, eid) VALUES (room_no, floor_number, meet_date, start_hour, employee_id);
        start_hour := start_hour + interval '1 hour';
    END LOOP;
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE leave_meeting (
    IN floor_number INTEGER,
    IN room_number INTEGER,
    IN meet_date DATE,
    IN start_hour TIME,
    IN end_hour TIME,
    IN employee_id INTEGER
    )
AS $$
BEGIN
    DELETE FROM Joins j 
    WHERE j.floor_no = floor_number 
    AND j.room = room_number
    AND j.meeting_date = meet_date
    AND j.start_time >= start_hour
    AND j.start_time < end_hour
    AND j.eid = employee_id
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE approve_meeting (
    IN floor_number INTEGER, 
    IN room_number INTEGER, 
    IN meet_date DATE, 
    IN start_hour TIME, 
    IN end_hour TIME,
    IN employee_id INTEGER
) AS $$
BEGIN
    UPDATE Meetings m SET approver_eid = employee_id
    WHERE m.floor_no = floor_number
    AND m.room = room_number
    AND m.meeting_date = meet_date
    AND m.start_time >= start_hour 
    AND m.start_time < end_hour;
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE PROCEDURE reject_meeting (
    IN floor_number INTEGER, IN room_number INTEGER, IN meet_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER
) AS $$
DECLARE 
    mgr_dept INTEGER;
    rm_dept INTEGER;
BEGIN
    -- Employee is a manager
    IF (employee_id NOT IN (SELECT eid FROM Manager)) THEN
        RAISE EXCEPTION USING
            errcode= 'NOMGR',
            message= 'Error: Non manager cannot approve or reject meeting';
    END IF;

    -- Employee is in the same department
    SELECT did INTO mgr_dept
    FROM Employees
    WHERE eid = employee_id
    
    IF (mgr_dept <> rm_dept) THEN 
        RAISE EXCEPTION USING
            errcode='DIFFD'
            message='Error: Manager can only approve or reject meetings in the same department';
    END IF;
            

    DELETE FROM Meetings m
    WHERE m.floor_no = floor_number
    AND m.room = room_number
    AND m.meeting_date = meet_date
    AND m.start_time >= start_hour
    AND m.start_time < end_hour;
END
$$ LANGUAGE plpgsql;
-- Health
 
-- Done 
-- fever boolean implemented in triggers
CREATE OR REPLACE PROCEDURE declare_health
    (IN employee_id INTEGER, declaration_date DATE, temp NUMERIC)
AS $$
BEGIN
    --- Constraint 31:
    INSERT INTO Health_Declaration (eid, hd_date, temp, fever) VALUES (employee_id, declaration_date, temp, temp > 37.5);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION contact_tracing
    (IN employee_id INTEGER)
RETURNS TABLE (close_contact_eid INTEGER) AS $$
DECLARE hasFever BOOLEAN;
BEGIN
    ALTER TABLE Joins DISABLE TRIGGER valid_leave_meeting;
    SELECT hd.fever INTO hasFever
    FROM Health_Declaration hd
    WHERE hd.eid = employee_id AND hd.hd_date = CURRENT_DATE; 

    IF hasFever IS TRUE THEN
        -- 3. Find all employees in the same approved meeting room from the past 3 days
        -- Return all the employees that were in close contact
        RETURN QUERY
        WITH past_3D_meeting_rooms AS ( -- APPROVED meetings from past 3 days that i was in
            SELECT j.room, j.floor_no, j.start_time, j.meeting_date
            FROM Joins j JOIN Meetings m
            ON (j.room = m.room
            AND j.floor_no = m.floor_no
            AND j.meeting_date = m.meeting_date
            AND j.start_time = m.start_time)
            WHERE j.eid = employee_id
            AND j.meeting_date >= CURRENT_DATE - interval '3 days'
            AND j.meeting_date <= CURRENT_DATE
            AND m.approver_eid IS NOT NULL
        ), close_contact_employees AS (
            SELECT j2.eid as close_contact_eid
            FROM Joins j2
            WHERE (j2.room, j2.floor_no, j2.start_time, j2.meeting_date) in (SELECT * FROM past_3D_meeting_rooms)
            AND employee_id <> j2.eid
        ) 
        SELECT * FROM close_contact_employees;

        WITH past_3D_meeting_rooms AS ( -- APPROVED meetings from past 3 days that i was in
            SELECT j.room, j.floor_no, j.start_time, j.meeting_date
            FROM Joins j JOIN Meetings m
            ON (j.room = m.room
            AND j.floor_no = m.floor_no
            AND j.meeting_date = m.meeting_date
            AND j.start_time = m.start_time)
            WHERE j.eid = employee_id
            AND j.meeting_date >= CURRENT_DATE - interval '3 days'
            AND j.meeting_date <= CURRENT_DATE
            AND m.approver_eid IS NOT NULL
        ), close_contact_employees AS (
            SELECT j2.eid as close_contact_eid
            FROM Joins j2
            WHERE (j2.room, j2.floor_no, j2.start_time, j2.meeting_date) in (SELECT * FROM past_3D_meeting_rooms)
            AND employee_id <> j2.eid
        ) 
        -- 3.1. Remove these employees who were close contacted from meetings for next 7 days
        DELETE FROM Joins WHERE eid IN (SELECT * FROM close_contact_employees)
        AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE))
        AND meeting_date <= CURRENT_DATE + interval '7 days';

        -- 2. Remove this employee from all future meetings
        DELETE FROM Joins WHERE eid = employee_id AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE)); 

          WITH past_3D_meeting_rooms AS ( -- APPROVED meetings from past 3 days that i was in
            SELECT j.room, j.floor_no, j.start_time, j.meeting_date
            FROM Joins j JOIN Meetings m
            ON (j.room = m.room
            AND j.floor_no = m.floor_no
            AND j.meeting_date = m.meeting_date
            AND j.start_time = m.start_time)
            WHERE j.eid = employee_id
            AND j.meeting_date >= CURRENT_DATE - interval '3 days'
            AND j.meeting_date <= CURRENT_DATE
            AND m.approver_eid IS NOT NULL
        ), close_contact_employees AS (
            SELECT j2.eid as close_contact_eid
            FROM Joins j2
            WHERE (j2.room, j2.floor_no, j2.start_time, j2.meeting_date) in (SELECT * FROM past_3D_meeting_rooms)
            AND employee_id <> j2.eid
        ) 
        -- 0.
        DELETE FROM Meetings WHERE booker_eid IN (SELECT * FROM close_contact_employees) AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE)) AND (meeting_date <= CURRENT_DATE + 7);

        -- 1. Cancel all future bookings that this employee has made
        DELETE FROM Meetings WHERE booker_eid = employee_id AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE));  
    ELSE 
		RAISE NOTICE 'Employee does not have a fever';
    END IF;
    ALTER TABLE Joins ENABLE TRIGGER valid_leave_meeting;
END
$$ LANGUAGE plpgsql;

-- Admin


-- done!
CREATE OR REPLACE FUNCTION non_compliance
    (IN starting_date DATE, IN end_date DATE) 
RETURNS TABLE(
    employee_id INTEGER,
    number_of_days INTEGER
) AS $$
DECLARE 
    num_days INT := end_date - starting_date + 1;
BEGIN
RETURN QUERY
    WITH partial_declaration_count AS ( 
        SELECT eid
        FROM Health_Declaration 
        WHERE hd_date >= starting_date
        AND hd_date <= end_date 
    ), employed AS ( 
        SELECT eid
        FROM Employees
        WHERE resigned_date IS NULL
    ), declaration_count AS (
        SELECT employed.eid, COUNT(dc.eid) as declare_count
        FROM partial_declaration_count dc NATURAL RIGHT JOIN employed
        GROUP BY employed.eid
    )
    SELECT dc.eid AS employee_id, (num_days - dc.declare_count)::INTEGER AS number_of_days
    FROM declaration_count dc
    WHERE num_days - dc.declare_count > 0
    ORDER BY num_days DESC;
END
$$ LANGUAGE plpgsql;

-- Done!
CREATE OR REPLACE FUNCTION view_booking_report
    (IN start_on DATE, eid INTEGER)
RETURNS TABLE(floor_number INTEGER, room_number INTEGER, meeting_date DATE, start_hour TIME, is_approved BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT m.floor_no, m.room, m.meeting_date, m.start_time, (m.approver_eid IS NOT NULL) AS is_approved
    FROM Meetings m
    WHERE m.booker_eid = eid 
    AND m.meeting_date >= start_on
    ORDER BY m.meeting_date, m.start_time ASC; 
END
$$ LANGUAGE plpgsql;

-- Done
CREATE OR REPLACE FUNCTION view_future_meeting
    (IN date_start DATE, employee_id INTEGER)
RETURNS TABLE(floor_number INTEGER, room_number INTEGER, meeting_date DATE, start_time TIME) AS $$
BEGIN
    RETURN QUERY
    SELECT j.floor_no, j.room, j.meeting_date, j.start_time
    FROM Joins j
    WHERE j.eid = employee_id 
    AND j.meeting_date >= date_start
    AND EXISTS (SELECT 1
                FROM Meetings m 
                WHERE m.floor_no = j.floor_no
                AND m.room = j.room
                AND m.meeting_date = j.meeting_date
                AND m.start_time = j.start_time      
                AND approver_eid IS NOT NULL          
                )
    ORDER BY j.meeting_date, j.start_time ASC;
END
$$ LANGUAGE plpgsql;

--done!
CREATE OR REPLACE FUNCTION view_manager_report
    (IN date_start DATE, manager_id INTEGER)
RETURNS TABLE (floor_number INTEGER, room_number INTEGER, meeting_date DATE, start_time TIME, employee_id INTEGER) AS $$
DECLARE
    dept_id INTEGER;
BEGIN
    IF (NOT EXISTS (SELECT 1 FROM Manager WHERE eid = manager_id)) THEN
        RAISE NOTICE 'Error: Employee is not a manager';
        RETURN;
    END IF;
    SELECT did INTO dept_id FROM Employees WHERE eid = manager_id;
    RETURN QUERY
    SELECT m.floor_no, m.room, m.meeting_date, m.start_time, m.booker_eid 
    FROM Meetings m
    WHERE dept_id = (SELECT did FROM Meeting_Rooms mr 
                    WHERE mr.floor_no = m.floor_no
                    AND mr.room = m.room)
    AND m.meeting_date >= date_start
    AND m.approver_eid IS NULL;
END 
$$ LANGUAGE plpgsql;

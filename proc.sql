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

CREATE OR REPLACE PROCEDURE add_department 
        (IN dept_id INTEGER, IN dept_name TEXT)
    AS $$
    BEGIN
        ALTER TABLE Departments DISABLE TRIGGER protect_departments;
        INSERT INTO Departments (did, dname) VALUES (dept_id, dept_name);
        ALTER TABLE Departments ENABLE TRIGGER protect_departments;
    END
    $$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE remove_department
        (IN dept_id INTEGER)
    AS $$
    BEGIN
        ALTER TABLE Departments DISABLE TRIGGER protect_departments;
        DELETE FROM Departments WHERE did = dept_id; 
        ALTER TABLE Departments ENABLE TRIGGER protect_departments;
    END
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_room
        (IN floor_no INTEGER, room_no INTEGER, room_name TEXT, room_capacity INTEGER, dept_id INTEGER, eid INTEGER)
    AS $$
    BEGIN
        ALTER TABLE Meeting_Rooms DISABLE TRIGGER protect_meeting_rooms;
        ALTER TABLE Updates DISABLE TRIGGER protect_updates;
        INSERT INTO Meeting_Rooms (room, floor_no, rname, did) VALUES (room_no, floor_no, room_name, dept_id);
        INSERT INTO Updates (floor_no, room, update_date, new_capacity, eid) VALUES (floor_no, room_no, CURRENT_DATE, room_capacity, eid);
        ALTER TABLE Meeting_Rooms ENABLE TRIGGER protect_meeting_rooms;
        ALTER TABLE Updates ENABLE TRIGGER protect_updates;
    END
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE change_capacity 
        (IN floor_number INTEGER, room_number INTEGER, new_date DATE, capacity INTEGER, employee_id INTEGER)
    AS $$ 
    BEGIN
        ALTER TABLE Updates DISABLE TRIGGER protect_updates;
        IF ((floor_number, room_number, new_date) NOT IN (Select floor_no, room, update_date from Updates)) THEN
            INSERT INTO Updates (floor_no, room, update_date, new_capacity, eid) VALUES (floor_number, room_number, new_date, capacity, employee_id);
        ELSE
            UPDATE Updates 
            SET new_capacity = capacity, eid = employee_id 
            WHERE floor_no = floor_number 
            AND room = room_number 
            AND update_date = new_date;
        END IF;
        ALTER TABLE Updates ENABLE TRIGGER protect_updates;
    END
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_phone_number (IN employee_id INTEGER, IN phone_number INTEGER, IN phone_type TEXT) AS $$
        BEGIN
            ALTER TABLE Phone_Numbers DISABLE TRIGGER protect_phone_numbers;
            INSERT INTO Phone_Numbers (eid, phone_number, phone_type) VALUES (employee_id, phone_number, phone_type);
            ALTER TABLE Phone_Numbers ENABLE TRIGGER protect_phone_numbers;
        END
        $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_employee
        (IN employee_name TEXT, IN phone_number INTEGER, IN phone_type TEXT, IN kind TEXT, IN department_id INTEGER)
    AS $$
    DECLARE 
        employee_id INTEGER;
        formatted_name TEXT;
    BEGIN
        formatted_name := REPLACE(employee_name, ' ', '_');
        ALTER TABLE Employees DISABLE TRIGGER protect_employees;  
        INSERT INTO Employees (did, ename) VALUES (department_id, employee_name) RETURNING eid INTO employee_id;
        UPDATE Employees SET email = CONCAT(formatted_name, '_', employee_id, '@bluewhale.org') WHERE eid = employee_id;
        ALTER TABLE Employees ENABLE TRIGGER protect_employees;  
        IF kind = 'junior' THEN
            ALTER TABLE Junior DISABLE TRIGGER protect_junior;
            INSERT INTO Junior VALUES (employee_id);
            ALTER TABLE Junior ENABLE TRIGGER protect_junior;
        ELSIF kind = 'senior' THEN
            ALTER TABLE Booker DISABLE TRIGGER protect_booker;
            ALTER TABLE Senior DISABLE TRIGGER protect_senior;
            INSERT INTO Senior VALUES (employee_id);
            ALTER TABLE Booker ENABLE TRIGGER protect_booker;
            ALTER TABLE Senior ENABLE TRIGGER protect_senior;
        ELSIF kind = 'manager' THEN 
            ALTER TABLE Booker DISABLE TRIGGER protect_booker;
            ALTER TABLE Manager DISABLE TRIGGER protect_manager;
            INSERT INTO Manager VALUES (employee_id);
            ALTER TABLE Booker ENABLE TRIGGER protect_booker;
            ALTER TABLE Manager ENABLE TRIGGER protect_manager;
        END IF;
        CALL add_phone_number(employee_id, phone_number, phone_type);
    END
    $$ LANGUAGE plpgsql;
    
CREATE OR REPLACE PROCEDURE remove_employee
        (IN employee_id INTEGER, IN date_of_resignation DATE)
    AS $$ 
    BEGIN
        ALTER TABLE Employees DISABLE TRIGGER protect_employees;  
        UPDATE Employees SET resigned_date = date_of_resignation WHERE eid = employee_id;
        ALTER TABLE Employees ENABLE TRIGGER protect_employees;  
        ALTER TABLE Joins DISABLE TRIGGER protect_joins;
        ALTER TABLE Meetings DISABLE TRIGGER protect_meetings;  
        DELETE 
        FROM Meetings m
        WHERE m.booker_eid = employee_id
        AND ((m.meeting_date = CURRENT_DATE AND m.start_time > CURRENT_TIME) OR (m.meeting_date > CURRENT_DATE));

        UPDATE Meetings m2
        SET approver_eid = NULL
        WHERE m2.approver_eid = employee_id
        AND ((m2.meeting_date = CURRENT_DATE AND m2.start_time > CURRENT_TIME) OR (m2.meeting_date > CURRENT_DATE));
        ALTER TABLE Joins ENABLE TRIGGER protect_joins;
        ALTER TABLE Meetings ENABLE TRIGGER protect_meetings; 

        ALTER TABLE Joins DISABLE TRIGGER protect_joins; 
        DELETE  
        FROM Joins j
        WHERE j.eid = employee_id
        AND ((j.meeting_date = CURRENT_DATE AND j.start_time > CURRENT_TIME) OR (j.meeting_date > CURRENT_DATE));
        ALTER TABLE Joins ENABLE TRIGGER protect_joins; 

        ALTER TABLE Updates DISABLE TRIGGER protect_updates; 
        DELETE
        FROM Updates u
        WHERE u.eid = employee_id
        AND u.update_date > CURRENT_DATE;
        ALTER TABLE Updates ENABLE TRIGGER protect_updates; 
    END
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_room  
    (IN capacity INTEGER, IN search_date DATE, IN start_hour TIME, IN end_hour TIME) 
    RETURNS TABLE(rm_floor_no INTEGER, rm_no INTEGER, rm_dept_id INTEGER, rm_capacity INTEGER) AS $$
    BEGIN 
    
    IF (start_hour > end_hour) THEN 
        RAISE EXCEPTION USING
            errcode='SHAEH',
            message='Error: Start time was after end time';
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
            RAISE EXCEPTION USING 
                errcode='SHAEH',
                message='Error: Start hour is after end hour';
        ELSE 
            starting_time := start_hour;
            ALTER TABLE Meetings DISABLE TRIGGER protect_meetings; 
            WHILE (start_hour < end_hour) LOOP
                INSERT INTO Meetings (floor_no, room, meeting_date, start_time, booker_eid, approver_eid) VALUES (floor_number, room_number, meet_date, start_hour, employee_id, NULL);
                start_hour := start_hour + interval '1 hour';
            END LOOP;
            ALTER TABLE Meetings ENABLE TRIGGER protect_meetings;
            CALL join_meeting(floor_number, room_number, meet_date, starting_time, end_hour, employee_id);
        END IF;
    END
    $$ LANGUAGE plpgsql;

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

        ALTER TABLE Joins DISABLE TRIGGER protect_joins;
        ALTER TABLE Meetings DISABLE TRIGGER protect_meetings;
        DELETE FROM Meetings m
        WHERE m.floor_no = floor_number 
        AND m.room = room_number 
        AND m.meeting_date = meet_date
        AND m.start_time >= start_hour 
        AND m.start_time < end_hour 
        AND m.booker_eid = employee_id;
        ALTER TABLE Joins ENABLE TRIGGER protect_joins;
        ALTER TABLE Meetings ENABLE TRIGGER protect_meetings;
    END
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE join_meeting
    (IN floor_number INTEGER, IN room_no INTEGER, IN meet_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
    AS $$
    DECLARE is_approved BOOLEAN;
    BEGIN

    SELECT (approver_eid IS NOT NULL) INTO is_approved 
    FROM Meetings m 
    WHERE m.floor_no = floor_number 
    AND m.room = room_no
    AND m.meeting_date = meeting_date
    AND m.start_time = start_hour;

    IF (is_approved IS TRUE) THEN
        RAISE EXCEPTION USING
            errcode='JNAPR',
            message='Error: Cannot join approved meeting';
    END IF;
    
    ALTER TABLE Joins DISABLE TRIGGER protect_joins;
    WHILE (start_hour < end_hour) LOOP
        INSERT INTO Joins (room, floor_no, meeting_date, start_time, eid) VALUES (room_no, floor_number, meet_date, start_hour, employee_id);
        start_hour := start_hour + interval '1 hour';
    END LOOP;
    ALTER TABLE Joins ENABLE TRIGGER protect_joins;
END
$$ LANGUAGE plpgsql;

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
    ALTER TABLE Joins DISABLE TRIGGER protect_joins;
    DELETE FROM Joins j 
    WHERE j.floor_no = floor_number 
    AND j.room = room_number
    AND j.meeting_date = meet_date
    AND j.start_time >= start_hour
    AND j.start_time < end_hour
    AND j.eid = employee_id;
    ALTER TABLE Joins ENABLE TRIGGER protect_joins;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE approve_meeting (
    IN floor_number INTEGER, 
    IN room_number INTEGER, 
    IN meet_date DATE, 
    IN start_hour TIME, 
    IN end_hour TIME,
    IN employee_id INTEGER
) AS $$
DECLARE
    meeting_exists BOOLEAN;
BEGIN
    ALTER TABLE Meetings DISABLE TRIGGER protect_meetings;
    UPDATE Meetings m SET approver_eid = employee_id
    WHERE m.floor_no = floor_number
    AND m.room = room_number
    AND m.meeting_date = meet_date
    AND m.start_time >= start_hour 
    AND m.start_time < end_hour;
    ALTER TABLE Meetings ENABLE TRIGGER protect_meetings;
END
$$ LANGUAGE plpgsql;

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
    WHERE eid = employee_id;
    
    IF (mgr_dept <> rm_dept) THEN 
        RAISE EXCEPTION USING
            errcode='DIFFD',
            message='Error: Manager can only approve or reject meetings in the same department';
    END IF;
            
    ALTER TABLE Joins DISABLE TRIGGER protect_joins;
    ALTER TABLE Meetings DISABLE TRIGGER protect_meetings;
    DELETE FROM Meetings m
    WHERE m.floor_no = floor_number
    AND m.room = room_number
    AND m.meeting_date = meet_date
    AND m.start_time >= start_hour
    AND m.start_time < end_hour;
    ALTER TABLE Joins ENABLE TRIGGER protect_joins;
    ALTER TABLE Meetings ENABLE TRIGGER protect_meetings;
END
$$ LANGUAGE plpgsql;

-- Health 
-- fever boolean implemented in triggers
CREATE OR REPLACE PROCEDURE declare_health
    (IN employee_id INTEGER, declaration_date DATE, temp NUMERIC)
AS $$
BEGIN
    --- Constraint 31:
    ALTER TABLE Health_Declaration DISABLE TRIGGER protect_health_declaration;
    INSERT INTO Health_Declaration (eid, hd_date, temp) VALUES (employee_id, declaration_date, temp);
    ALTER TABLE Health_Declaration ENABLE TRIGGER protect_health_declaration;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION contact_tracing
    (IN employee_id INTEGER)
RETURNS TABLE (close_contact_eid INTEGER) AS $$
DECLARE hasFever BOOLEAN;
BEGIN
    ALTER TABLE Joins DISABLE TRIGGER valid_leave_meeting;
    ALTER TABLE Joins DISABLE TRIGGER booker_cannot_leave;
    SELECT (hd.temp > 37.5) INTO hasFever
    FROM Health_Declaration hd
    WHERE hd.eid = employee_id AND hd.hd_date = CURRENT_DATE; 

    IF hasFever IS TRUE THEN
        -- 3. Find all employees in the same approved meeting room from the past 3 days
        -- Return all the employees that were in close contact
        ALTER TABLE Joins DISABLE TRIGGER protect_joins;
        ALTER TABLE Meetings DISABLE TRIGGER protect_meetings;
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

          WITH past_3D_meeting_rooms AS ( -- APPROVED meetings from past 3 days that I was in
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
        DELETE FROM Meetings WHERE booker_eid IN (SELECT * FROM close_contact_employees) AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE)) AND (meeting_date <= CURRENT_DATE + 7);

        -- 1. Cancel all future bookings that this employee has made
        DELETE FROM Meetings WHERE booker_eid = employee_id AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE));  
        ALTER TABLE Meetings ENABLE TRIGGER protect_meetings;
        ALTER TABLE Joins ENABLE TRIGGER protect_joins;
    ELSE 
		RAISE NOTICE 'Employee does not have a fever';
    END IF;
    ALTER TABLE Joins ENABLE TRIGGER valid_leave_meeting;
    ALTER TABLE Joins ENABLE TRIGGER booker_cannot_leave;
END
$$ LANGUAGE plpgsql;

-- Admin
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

CREATE OR REPLACE FUNCTION view_manager_report
    (IN date_start DATE, manager_id INTEGER)
RETURNS TABLE (floor_number INTEGER, room_number INTEGER, meeting_date DATE, start_time TIME, employee_id INTEGER) AS $$
DECLARE
    dept_id INTEGER;
BEGIN
    IF (NOT EXISTS (SELECT 1 FROM Manager WHERE eid = manager_id)) THEN
        RAISE EXCEPTION USING
            errcode='NOMGR',
            message='Error: Employee is not a manager';
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

-- Triggers
CREATE OR REPLACE FUNCTION auto_add_booker() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Booker (eid) VALUES (NEW.eid);
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_add_senior_booker
AFTER INSERT ON Senior 
FOR EACH ROW EXECUTE FUNCTION auto_add_booker();

CREATE TRIGGER auto_add_manager_booker
AFTER INSERT ON Manager 
FOR EACH ROW EXECUTE FUNCTION auto_add_booker();

--- Constraint 12: Enforces the ISA No Overlap Constraint between Junior and Booker
CREATE OR REPLACE FUNCTION junior_not_booker() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN 
	SELECT COUNT(eid) INTO count FROM Booker WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN 
        RAISE EXCEPTION USING
            errcode='JBISA',
            message='Error: Employee is already a Booker, cannot be a Junior';
        RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER junior_ISA
BEFORE INSERT OR UPDATE ON Junior
FOR EACH ROW EXECUTE FUNCTION junior_not_booker();

--- Constraint 12: Enforces the ISA No Overlap Constraint between Junior and Booker
CREATE OR REPLACE FUNCTION booker_not_junior() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN
	SELECT COUNT(eid) INTO count FROM Junior WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN
        RAISE EXCEPTION USING
            errcode='BJISA',
            message='Error: Employee is already a Junior, cannot be a Booker';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER booker_ISA
BEFORE INSERT ON Booker
FOR EACH ROW EXECUTE FUNCTION booker_not_junior();

--- Constraint 12: Enforces that an employee cannot be both a manager and a senior
CREATE OR REPLACE FUNCTION senior_not_manager() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN
	SELECT COUNT(eid) INTO count FROM Manager WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN
        RAISE EXCEPTION USING
            errcode = 'SMISA', 
            message = 'Error: Employee is already a Manager, cannot be a Senior';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER senior_ISA
BEFORE INSERT ON Senior 
FOR EACH ROW EXECUTE FUNCTION senior_not_manager();

--- Constraint 12: Enforces that an employee cannot be both a manager and a senior
CREATE OR REPLACE FUNCTION manager_not_senior() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN
	SELECT COUNT(eid) INTO count FROM Senior WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN
        RAISE EXCEPTION USING 
            errcode = 'MSISA',
            message = 'Error: Employee is already a Senior, cannot be a Manager';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER manager_ISA
BEFORE INSERT ON Manager
FOR EACH ROW EXECUTE FUNCTION manager_not_senior();

--- Constraint 16 && Constraint 34: 
CREATE OR REPLACE FUNCTION booker_nofever_noresign() RETURNS TRIGGER AS $$
DECLARE
    fever BOOLEAN;
    resigned BOOLEAN;
BEGIN
    SELECT (hd.temp > 37.5) INTO fever
    FROM Health_Declaration hd
    WHERE hd.eid = NEW.booker_eid
    AND hd.hd_date = CURRENT_DATE;

    SELECT e.resigned_date IS NOT NULL INTO resigned
    FROM Employees e
    WHERE e.eid = NEW.booker_eid;

    IF fever IS TRUE THEN
        RAISE EXCEPTION USING
            errcode='BNFNR',
            message='Error: Employees that have a fever are not permitted to book a room.';
        RETURN NULL;
	END IF;

    IF resigned IS TRUE THEN
        RAISE EXCEPTION USING
            errcode='BNFNR',
            message='Error: Employees that have a resigned are not permitted to book a room.';
        RETURN NULL;
	END IF;

    RETURN NEW;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER booker_nofever_noresign
BEFORE
INSERT ON Meetings
FOR EACH ROW EXECUTE FUNCTION booker_nofever_noresign();

--- Constraint 34:
CREATE OR REPLACE FUNCTION approver_noresign() RETURNS TRIGGER AS $$
DECLARE
    resigned BOOLEAN;
BEGIN
    SELECT e.resigned_date IS NOT NULL INTO resigned
    FROM Employees e
    WHERE e.eid = NEW.approver_eid;

    IF resigned IS TRUE THEN
        RAISE EXCEPTION USING
            errcode='APPNR',
            message='Error: Employees that have resigned are not permitted to approve a meeting.';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER approver_noresign
BEFORE
UPDATE ON Meetings
FOR EACH ROW EXECUTE FUNCTION approver_noresign();
 
--- CONSTRAINT 19
CREATE OR REPLACE FUNCTION reject_fever_join() RETURNS TRIGGER AS $$
DECLARE
    hasFever BOOLEAN;
BEGIN 
    SELECT (hd.temp > 37.5) INTO hasFever
    FROM Health_Declaration hd
    WHERE hd.eid = NEW.eid
    AND hd.hd_date = CURRENT_DATE;

    IF (hasFever IS TRUE) THEN
        RAISE EXCEPTION USING
            errcode='FVRNJ',
            message='Error: Employee has a fever and is thus not allowed to join any meetings';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fever_cannot_join
BEFORE INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION reject_fever_join();

--- CONSTRAINT 21
CREATE OR REPLACE FUNCTION reject_approval_diff_dept() RETURNS TRIGGER AS $$
DECLARE
    manager_did INTEGER;
    meeting_did INTEGER;
BEGIN
    SELECT e.did into manager_did
    FROM Employees e
    WHERE e.eid = NEW.approver_eid;

    SELECT m.did INTO meeting_did
    FROM Meeting_Rooms m
    WHERE m.room = OLD.room
    AND m.floor_no = OLD.floor_no;

    IF (NEW.approver_eid NOT IN (SELECT eid FROM Manager)) THEN 
        RAISE EXCEPTION USING
            errcode='NOMGR',
            message='Error: Approver is not a manager';
        RETURN NULL;
    END IF;
    IF (manager_did <> meeting_did) THEN
        RAISE EXCEPTION USING
            errcode='DIFFD',
            message='Error: Approver belongs to a different department than the meeting room.';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER approve_same_dept
BEFORE
UPDATE ON Meetings
FOR EACH ROW EXECUTE FUNCTION reject_approval_diff_dept();

--- CONSTRAINT 22
CREATE OR REPLACE FUNCTION stop_second_approval() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION USING
        errcode='2APPR',
        message='Error: Cannot approve a meeting that is already approved.';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER approve_once_only
BEFORE
UPDATE ON Meetings
FOR EACH ROW WHEN (OLD.approver_eid IS NOT NULL) EXECUTE FUNCTION stop_second_approval();

--- Constraint 23
-- ensure that approver id changes approver id for all time blocks
CREATE OR REPLACE FUNCTION no_participants_after_approved() RETURNS TRIGGER AS $$
BEGIN
    IF ((SELECT approver_eid FROM Meetings m WHERE NEW.room = m.room AND NEW.floor_no = m.floor_no AND NEW.meeting_date = m.meeting_date AND NEW.start_time = m.start_time) IS NOT NULL) THEN
        RAISE EXCEPTION USING
            errcode='JAFTA',
            message='Error: Meeting has already been approved, no new participants can be added.';
        RETURN NULL;
    ELSE
        RETURN NEW;
	END IF;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER no_participants_after_approved
BEFORE INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION no_participants_after_approved();

-- cannot leave if approved
CREATE OR REPLACE FUNCTION check_leave_meeting() RETURNS TRIGGER AS $$
DECLARE
	resigned DATE;
	has_fever BOOLEAN;
    approver_id INTEGER;
    is_in_past BOOLEAN;
BEGIN
	SELECT e.resigned_date INTO resigned FROM Employees e WHERE e.eid = OLD.eid;

	SELECT (hd.temp > 37.5) INTO has_fever FROM Health_Declaration hd WHERE hd.hd_date = OLD.meeting_date AND eid = OLD.eid;

    SELECT m.approver_eid INTO approver_id FROM Meetings m WHERE m.room = OLD.room 
    AND m.floor_no = OLD.floor_no 
    AND m.meeting_date = OLD.meeting_date 
    AND m.start_time = OLD.start_time;

    SELECT COUNT(*) > 0 INTO is_in_past
    FROM Meetings m 
    WHERE m.room = OLD.room
    AND m.floor_no = OLD.floor_no
    AND m.meeting_date = OLD.meeting_date
    AND m.start_time = OLD.start_time
    AND (m.meeting_date < CURRENT_DATE OR
    m.meeting_date = CURRENT_DATE AND m.start_time < CURRENT_TIME);

	
    IF ((has_fever IS TRUE OR resigned IS NOT NULL OR approver_id IS NULL) AND is_in_past IS FALSE) THEN
		RETURN OLD;
	ELSE
        RAISE EXCEPTION USING
            errcode='CNLVM',
            message='Error: No valid reason to leave meeting';
		RETURN NULL;

	END IF;
END
$$LANGUAGE plpgsql;

CREATE TRIGGER valid_leave_meeting
BEFORE DELETE ON Joins
FOR EACH ROW EXECUTE FUNCTION check_leave_meeting();

--- Constraint 24
-- Only manager from same department as meeting room may change meeting room capacity
CREATE OR REPLACE FUNCTION same_manager_change_capacity() RETURNS TRIGGER AS $$
DECLARE 
	room_department_id INTEGER;
 	manager_department_id INTEGER;
BEGIN
    SELECT mr.did FROM Meeting_Rooms mr WHERE NEW.room = mr.room AND NEW.floor_no = mr.floor_no INTO room_department_id;
    SELECT e.did FROM Employees e WHERE NEW.eid = e.eid INTO manager_department_id;
    IF (room_department_id <> manager_department_id) THEN
RAISE EXCEPTION USING
            errcode='SMGRC',
            message='Error: Only manager from the department can change meeting room capacity';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER same_manager_change_capacity
BEFORE INSERT OR UPDATE ON Updates
FOR EACH ROW EXECUTE FUNCTION same_manager_change_capacity();

--- Constraint 25
CREATE OR REPLACE FUNCTION booking_only_future() RETURNS TRIGGER AS $$
BEGIN
    IF ((NEW.meeting_date < CURRENT_DATE) OR (NEW.meeting_date = CURRENT_DATE AND NEW.start_time < CURRENT_TIME)) THEN
        RAISE EXCEPTION USING
            errcode='OBFMT',
            message='Error: Bookings can only be made in the future';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER booking_only_future
BEFORE
INSERT ON Meetings
FOR EACH ROW EXECUTE FUNCTION booking_only_future();

--- Constraint 26:
CREATE OR REPLACE FUNCTION check_join_meeting_date() RETURNS TRIGGER AS $$
BEGIN
    IF ((NEW.meeting_date < CURRENT_DATE) OR (NEW.meeting_date = CURRENT_DATE AND NEW.start_time < CURRENT_TIME)) THEN
        RAISE EXCEPTION USING
            errcode='OJFMT',
            message='Error: Cannot join past meeting';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER only_join_future_meetings
BEFORE
INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION check_join_meeting_date();

--- Constraint: Only can join meeting if capacity is not full
CREATE OR REPLACE FUNCTION full_capacity_on_join() RETURNS TRIGGER AS $$
DECLARE
    max_capacity INTEGER;
    current_capacity INTEGER;
BEGIN
    SELECT u.new_capacity INTO max_capacity
    FROM Updates u NATURAL JOIN (
        SELECT room, floor_no, MAX(update_date) as update_date
        FROM Updates
        WHERE update_date <= NEW.meeting_date
        AND room = NEW.room
        AND floor_no = NEW.floor_no
        GROUP BY room, floor_no  
    ) as latest_updates;
    

    SELECT COUNT(*) INTO current_capacity
    FROM Joins j
    WHERE j.room = NEW.room
    AND j.floor_no = NEW.floor_no
    AND j.meeting_date = NEW.meeting_date
    AND j.start_time = NEW.start_time;

    IF (max_capacity = current_capacity) THEN
        RAISE EXCEPTION USING
            errcode='FULLR',
            message='Error: Cannot join meeting that is full';
    ELSE
        RETURN NEW;
    END IF;

END
$$ LANGUAGE plpgsql;

CREATE TRIGGER full_capacity_on_join
BEFORE
INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION full_capacity_on_join();

--- Constraint 27:
CREATE OR REPLACE FUNCTION check_approve_meeting_date() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION USING
        errcode='OAFMT',
        message='Error: Cannot approve past meeting';
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER only_approve_future_meetings
BEFORE
UPDATE ON Meetings
FOR EACH ROW WHEN (OLD.meeting_date < CURRENT_DATE OR (OLD.meeting_date = CURRENT_DATE AND OLD.start_time < CURRENT_TIME)) EXECUTE FUNCTION check_approve_meeting_date();

-- To call contact_tracing automatically upon declaring a fever
CREATE OR REPLACE FUNCTION contact_trace_on_fever() RETURNS TRIGGER AS $$
BEGIN
    PERFORM contact_tracing(NEW.eid);
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER contact_trace_on_fever
AFTER INSERT ON Health_Declaration
FOR EACH ROW WHEN (NEW.temp > 37.5) EXECUTE FUNCTION contact_trace_on_fever();

-- can declare health for today only: not for old dates or future dates
CREATE OR REPLACE FUNCTION no_future_hd() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION USING
        errcode='NOFHD',
        message='Error: Can only make a health declaration for the current date';
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_future_hd
BEFORE INSERT ON Health_Declaration
FOR EACH ROW WHEN (NEW.hd_date > CURRENT_DATE)
EXECUTE FUNCTION no_future_hd();

-- Meeting room dynamics
CREATE OR REPLACE FUNCTION remove_overloaded_room_after_update() RETURNS TRIGGER AS $$
BEGIN
    ALTER TABLE Joins DISABLE TRIGGER protect_joins;
    ALTER TABLE Meetings DISABLE TRIGGER protect_meetings;
    WITH overloaded_rooms AS (
        SELECT j.floor_no, j.room, j.meeting_date, j.start_time FROM Joins j
        WHERE j.floor_no = NEW.floor_no 
        AND j.room = NEW.room
        AND j.meeting_date > NEW.update_date
        GROUP BY (j.floor_no, j.room, j.meeting_date, j.start_time)
        HAVING COUNT(*) > NEW.new_capacity
    )
    DELETE FROM Meetings m
    WHERE (m.floor_no, m.room, m.meeting_date, m.start_time) 
    IN (SELECT * FROM overloaded_rooms);
    ALTER TABLE Joins ENABLE TRIGGER protect_joins;
    ALTER TABLE Meetings ENABLE TRIGGER protect_meetings;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER remove_overloaded_room_after_update
AFTER INSERT OR UPDATE ON Updates -- NEW (room, floor, meet_date, update_date, new_capacity)
FOR EACH ROW EXECUTE FUNCTION remove_overloaded_room_after_update();

CREATE OR REPLACE FUNCTION valid_meeting() RETURNS TRIGGER AS $$
DECLARE 
    num_blocking_meetings INTEGER;
BEGIN 
    SELECT COUNT(*) INTO num_blocking_meetings
    FROM Meetings m 
    WHERE m.floor_no =  NEW.floor_no
    AND m.room = NEW.room
    AND m.meeting_date = NEW.meeting_date
    AND m.start_time > NEW.start_time - interval '1 hour'
    AND m.start_time < NEW.start_time + interval '1 hour';
    
    IF (num_blocking_meetings > 0) THEN
        RAISE EXCEPTION USING
            errcode='INVMT',
            message='Error: Cannot book meeting at this time due to clashes';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END 
$$ LANGUAGE plpgsql;

CREATE TRIGGER valid_meeting
BEFORE INSERT ON Meetings
FOR EACH ROW EXECUTE FUNCTION valid_meeting();


CREATE OR REPLACE FUNCTION no_declare_cannot_join() RETURNS TRIGGER AS $$
DECLARE
    declared_today BOOLEAN;
BEGIN
    SELECT INTO declared_today EXISTS (SELECT 1 FROM Health_Declaration hd WHERE hd.eid = NEW.eid AND hd.hd_date = CURRENT_DATE);
    IF (declared_today IS FALSE) THEN
        RAISE EXCEPTION USING
            errcode='NHDNJ',
            message=format('Error: Employee %s did not declare health today and hence cannot join a meeting', NEW.eid);
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_declare_cannot_join
BEFORE INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION no_declare_cannot_join();


CREATE OR REPLACE FUNCTION no_declare_cannot_book() RETURNS TRIGGER AS $$
DECLARE 
    declared_today BOOLEAN;
BEGIN
    SELECT INTO declared_today EXISTS (SELECT 1 FROM Health_Declaration hd WHERE hd.eid = NEW.booker_eid AND hd.hd_date = CURRENT_DATE);
    IF (declared_today IS FALSE) THEN
        RAISE EXCEPTION USING
            errcode='NHDNB',
            message=format('Error: Employee %s did not declare health today and hence cannot book a meeting', NEW.booker_eid);
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_declare_cannot_book
BEFORE INSERT ON Meetings
FOR EACH ROW EXECUTE FUNCTION no_declare_cannot_book();

CREATE OR REPLACE FUNCTION no_empty_updates() RETURNS TRIGGER AS $$
DECLARE 
    update_count INTEGER;
BEGIN
    RAISE NOTICE 'TESTING';
    SELECT COUNT(*) INTO update_count 
    FROM Updates u 
    WHERE u.room = NEW.room 
    AND u.floor_no = NEW.floor_no;
    IF (update_count = 1) THEN
        RAISE EXCEPTION USING
            errcode='CNTDU', -- can't delete update
            message=format('Error: Cannot delete Update if this is the only update for this room');
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_empty_updates 
BEFORE DELETE ON Updates
FOR EACH ROW EXECUTE FUNCTION no_empty_updates();

CREATE OR REPLACE FUNCTION booker_cannot_leave() RETURNS TRIGGER AS $$
DECLARE
    is_booker BOOLEAN;
BEGIN
    SELECT (OLD.eid = m.booker_eid) INTO is_booker
    FROM Meetings m
    WHERE m.floor_no = OLD.floor_no
    AND m.room = OLD.room
    AND m.meeting_date = OLD.meeting_date
    AND m.start_time = OLD.start_time;

    IF (is_booker IS TRUE) THEN 
        RAISE EXCEPTION USING
            errcode='BKRNL',
            message='Error: Booker cannot leave meeting. Use unbook_room routine instead';
        RETURN NULL;
    ELSE 
        RETURN OLD;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER booker_cannot_leave
BEFORE DELETE ON Joins
FOR EACH ROW EXECUTE FUNCTION booker_cannot_leave();


-- block manual changes
CREATE OR REPLACE FUNCTION block_manual_changes() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION USING
        errcode='NOMCH',
        message='Error: Please use the provided routines to make changes to the database';
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER protect_departments
BEFORE INSERT OR UPDATE OR DELETE ON Departments
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_employees
BEFORE INSERT OR UPDATE OR DELETE ON Employees
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_phone_numbers
BEFORE INSERT OR UPDATE OR DELETE ON Phone_Numbers
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_junior
BEFORE INSERT OR UPDATE OR DELETE ON Junior
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_booker
BEFORE INSERT OR UPDATE OR DELETE ON Booker
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_senior
BEFORE INSERT OR UPDATE OR DELETE ON Senior
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_manager
BEFORE INSERT OR UPDATE OR DELETE ON Manager
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_health_declaration
BEFORE INSERT OR UPDATE OR DELETE ON Health_Declaration
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_meeting_rooms
BEFORE INSERT OR UPDATE OR DELETE ON Meeting_Rooms
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_updates
BEFORE INSERT OR UPDATE OR DELETE ON Updates
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_meetings
BEFORE INSERT OR UPDATE OR DELETE ON Meetings
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();

CREATE TRIGGER protect_joins
BEFORE INSERT OR UPDATE OR DELETE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_manual_changes();




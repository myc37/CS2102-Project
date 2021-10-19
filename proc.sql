-- Basic

CREATE OR REPLACE PROCEDURE add_department 
        (IN dept_id INTEGER, IN dept_name TEXT)
    AS $$
    BEGIN
        INSERT INTO Departments VALUES (dept_id, dept_name);
    END
    $$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE remove_department
        (IN dept_id INTEGER)
    AS $$
    BEGIN
        DELETE FROM Departments WHERE did = dept_id; 
    END
    $$ LANGUAGE plpgsql;

-- added dept_id parameter
CREATE OR REPLACE PROCEDURE add_room
        (IN floor_no INTEGER, room_no INTEGER, room_name TEXT, room_capacity INTEGER, dept_id INTEGER)
    AS $$
    BEGIN
        INSERT INTO Meeting_Rooms (room, floor_no, rname) VALUES (room_no, floor_no, room_name, dept_id);
        INSERT INTO Updates (floor_no, room, new_date, new_capacity) VALUES (floor_no, room_no, CURRENT_DATE, room_capacity)
    END
    $$ LANGUAGE plpgsql
    
CREATE OR REPLACE PROCEDURE change_capacity 
        (IN floor_no INTEGER, room_no INTEGER, new_date DATE, capacity INTEGER)
    AS $$ 
    BEGIN
        INSERT INTO Updates (floor_no, room, update_date, new_capacity) VALUES (floor_no, room_no, new_date, capacity);
    END
    $$ LANGUAGE plpgsql


-- added phone_type parameter
CREATE OR REPLACE PROCEDURE add_employee
        (IN employee_name TEXT, IN phone_number INTEGER, IN phone_type TEXT, IN kind TEXT, IN department_id INTEGER)
    AS $$
    DECLARE 
        id INTEGER;
    BEGIN
        SELECT COUNT(*) + 1 INTO employee_id FROM Employees; 
        INSERT INTO Employees (eid, did, email, ename) VALUES (employee_id, department_id, CONCAT(employee_name, '@bluewhale.org') , employee_name);

        IF kind = 'junior' THEN
            INSERT INTO Junior VALUES (employee_id);
        ELSIF kind = 'senior' THEN
            INSERT INTO Booker VALUES (employee_id);
            INSERT INTO Senior VALUES (employee_id);
        ELSIF kind = 'manager' THEN 
            INSERT INTO Booker VALUES (employee_id);
            INSERT INTO Manager VALUES (employee_id);
            
        CALL add_phone_number(employee_id, phone_number, phone_type);
    END
    $$ LANGUAGE plpgsql

-- added this procedure
CREATE OR REPLACE PROCEDURE add_phone_number
            (IN employee_id INTEGER, IN phone_number INTEGER, IN phone_type TEXT)
        AS $$
        BEGIN     
            INSERT INTO PhoneNumbers VALUES (employee_id, phone_number, phone_type)
        END
        $$ LANGUAGE plpgsql
    

CREATE OR REPLACE PROCEDURE remove_employee
        (IN employee_id INTEGER, IN date_of_resignation DATE)
    AS $$
    BEGIN
        UPDATE Employees SET resigned_date = date_of_resignation WHERE eid = employee_id;
    END
    $$ LANGUAGE plpgsql

-- Core

CREATE OR REPLACE FUNCTION search_room  -- start/end hour means th
    (IN capacity INTEGER, IN search_date DATE, IN start_hour TIME, IN end_hour TIME) 
    RETURNS SETOF RECORD AS $$
    BEGIN 
      WITH rooms_with_enough_capacity AS (
        SELECT u.room, u.floor_no, u.new_capacity
        FROM Updates u, (
          SELECT room, floor_no, MAX(update_date) as update_date
          FROM Updates
          GROUP BY room, floor_no  
        ) AS latest_updates
        WHERE u.room = latest_updates.room
        AND u.floor_no = latest_updates.floor_no
        AND u.update_date = latest_updates.update_date
        AND u.new_capacity >= capacity
      )
      --find rooms with enough capacity available in the specified period
      SELECT r.floor_number, r.room, mr.did, r.capacity
      FROM rooms_with_enough_capacity r, Meeting_Rooms mr
      WHERE r.room = mr.room
      AND mr.floor_number = mr.floor_number
      AND NOT EXISTS (
        SELECT 1
        FROM Sessions
        WHERE session_date = search_date   --e.g. 1230->1330 -- 1300
        AND session_time >= start_hour -- >= start_hour - 59 minutes? LOL 
        AND session_time < end_hour
        AND room = r.room
        AND floor_number = r.floor_number
      )
    END
    $$ LANGUAGE plpgsql
  
CREATE OR REPLACE PROCEDURE book_room
    (IN floor_no INTEGER, IN room_no INTEGER, IN meeting_date DATE, IN start_hour TIME, IN end_hour TIME, IN employee_id INTEGER)
    AS $$
    BEGIN
    -- NEED TO CHECK CONDITIONS: IF employee IS BOOKER, IF room is available, IF employee has no fever
        WHILE start_hour < end_hour LOOP
            INSERT INTO Meetings (floor_no, room, meeting_date, start_time, meeting_date) VALUES (floor_no, room_no, meeting_date, start_hour, meeting_date);
            start_hour + interval '1 hour';
        END LOOP;
    END
    $$ LANGUAGE plpgsql 

CREATE OR REPLACE PROCEDURE unbook_room
        (IN floor_no INTEGER, IN room_no INTEGER, IN meeting_date DATE, IN start_hour TIMESTAMP, IN end_hour TIMESTAMP, IN employee_id INTEGER)
    AS $$
    BEGIN
        DELETE FROM Meetings m
        WHERE m.floor_no = floor_no 
        AND m.room = room_no 
        AND m.meeting_date = meeting_date
        AND m.start_time >= start_hour 
        AND m.start_time < end_hour 
        AND m.booker_eid = eid

        DELETE FROM Joins j
        WHERE j.room = room_no
        AND j.floor_no = floor_no
        AND j.meeting_date = meeting_date
        AND j.start_time >= start_hour
        AND j.start_time < end_hour
    END
    $$ LANGUAGE plpgsql

CREATE OR REPLACE PROCEDURE join_meeting
    (IN floor_no INTEGER, IN room_no INTEGER, IN meeting_date DATE, IN start_hour TIMESTAMP, IN end_hour TIMESTAMP, IN employee_id INTEGER)
    AS $$
    BEGIN
            

    END
    $$ LANGUAGE plpgsql


CREATE OR REPLACE PROCEDURE leave_meeting



CREATE OR REPLACE PROCEDURE approve_meeting

-- Health
 
-- fever boolean implemented in triggers
CREATE OR REPLACE PROCEDURE declare_health
    (IN employee_id INTEGER, declaration_date DATE, temp NUMERIC)
AS $$
BEGIN
    INSERT INTO Health_Declaration (eid, hd_date, temp, fever) VALUES (employee_id, declaration_date, temp, temp > 37.5);
END
$$ LANGUAGE plpgsql

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
    DELETE * FROM Joins WHERE eid = employee.id;
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
$$ LANGUAGE plpgsql

-- Admin

CREATE OR REPLACE FUNCTION non_compliance

CREATE OR REPLACE FUNCTION view_booking_report
    (IN start_on DATE, eid INTEGER)
RETURNS RECORD AS $$
    SELECT floor_no, room AS room_no, meeting_date, start_time AS start_hour, (approver_eid IS NOT NULL) AS is_approved
    FROM Meeting
    WHERE booker_eid = eid AND start_time >= start_on
    ORDER BY meeting_date, start_time ASC
$$ LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION view_future_meeting
    (IN date_start DATE, employee_id INTEGER)
RETURNS RECORD AS $$
    SELECT floor_no, room AS room_no, meeting_date, start_time AS start_hour
    FROM Joins
    WHERE eid = employee_id AND meeting_date >= date_start
    ORDER BY meeting_date, start_time ASC
$$ LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION view_manager_report
    (IN date_start DATE, employee_id INTEGER)
RETURNS RECORD AS $$

    
$$ LANGUAGE plpgsql

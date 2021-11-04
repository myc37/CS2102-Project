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

CREATE TRIGGER approve_once_only
BEFORE
UPDATE ON Meetings
FOR EACH ROW WHEN (OLD.approver_eid IS NOT NULL) EXECUTE FUNCTION stop_second_approval();

--- Constraint 23
CREATE OR REPLACE FUNCTION no_participants_after_approved() RETURNS TRIGGER AS $$
BEGIN
    IF ((SELECT approver_eid FROM Meetings m WHERE NEW.room = m.room AND NEW.floor_no = m.floor_no AND NEW.meeting_date = m.meeting_date AND NEW.start_time = m.start_time) IS NOT NULL) THEN
        RAISE EXCEPTION USING
            errcode='JAFTA',
            message='Error: Meeting has already been approved, no new participants can be added.';
        RETURN NULL;
        RETURN NEW;
	END IF;
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
CREATE OR REPLACE FUNCTION same_manager_change_capacity() RETURNS TRIGGER AS $$
DECLARE 
	room_department_id INTEGER;
 	manager_department_id INTEGER;
BEGIN
    SELECT mr.did FROM Meeting_Rooms mr WHERE NEW.room = mr.room AND NEW.floor_no = mr.floor_no INTO room_department_id;
    SELECT e.did FROM Employees e WHERE NEW.eid = e.eid INTO manager_department_id;
    IF (room_department_id <> manager_department_id) THEN
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

--- Constraint 25 Booking can only be made for future meetings
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

--- Constrain 27:
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

















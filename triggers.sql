CREATE OR REPLACE FUNCTION auto_add_booker() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Booker (eid) VALUES (NEW.eid);
    RETURN;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_add_senior_booker
AFTER INSERT ON Senior 
FOR EACH ROW EXECUTE FUNCTION auto_add_booker();

CREATE TRIGGER auto_add_manager_booker
AFTER INSERT ON Manager 
FOR EACH ROW EXECUTE FUNCTION auto_add_booker();

--- Constraint 12: Enforces the ISA No Overlap Constraint between Junior and Booker
-- Works
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
-- Works
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


CREATE OR REPLACE TRIGGER booker_ISA
BEFORE INSERT ON Booker
FOR EACH ROW EXECUTE FUNCTION booker_not_junior();

--- Constraint 12: Enforces that an employee cannot be both a manager and a senior
-- Works
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


CREATE OR REPLACE TRIGGER senior_ISA
BEFORE INSERT ON Senior 
FOR EACH ROW EXECUTE FUNCTION senior_not_manager();

--- Constraint 12: Enforces that an employee cannot be both a manager and a senior
-- Works
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


CREATE OR REPLACE TRIGGER manager_ISA
BEFORE INSERT ON Manager
FOR EACH ROW EXECUTE FUNCTION manager_not_senior();

--- Constraint 16 && Constraint 34:
--SYNTAX WORKS 
CREATE OR REPLACE FUNCTION booker_nofever_noresign() RETURNS TRIGGER AS $$
DECLARE
    fever BOOLEAN;
    resigned BOOLEAN;
BEGIN
    SELECT hd.fever 
    FROM Health_Declaration hd
    WHERE hd.eid = NEW.booker_eid
    AND hd.hd_date = CURRENT_DATE INTO fever;

    SELECT e.resigned_date IS NOT NULL
    FROM Employees e
    WHERE e.eid = NEW.booker_eid INTO resigned;

    IF fever IS TRUE THEN
        RAISE NOTICE 'Error: Employees that have a fever are not permitted to book a room.';
        RETURN NULL;
	END IF;

    IF resigned IS TRUE THEN
        RAISE NOTICE 'Error: Employees that have resigned are not permitted to book a room.';
        RETURN NULL;
	END IF;

    RETURN NEW;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER booker_nofever_noresign
BEFORE
INSERT ON Meetings
FOR EACH ROW EXECUTE FUNCTION booker_nofever_noresign();

--- Constraint 34:
-- SYNTAX WORKS
CREATE OR REPLACE FUNCTION approver_noresign() RETURNS TRIGGER AS $$
DECLARE
    resigned BOOLEAN;
BEGIN
    SELECT e.resigned_date IS NOT NULL INTO resigned
    FROM Employees e
    WHERE e.eid = NEW.approver_eid;

    IF resigned IS TRUE THEN
        RAISE NOTICE 'Error: Employees that have resigned are not permitted to approve a meeting.';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER approver_noresign
BEFORE
UPDATE ON Meetings
FOR EACH ROW EXECUTE FUNCTION approver_noresign();

--fever today, but booked meeting in one month's time? still can't join?
 --- CONSTRAINT 19
--
CREATE OR REPLACE OR REPLACE FUNCTION reject_fever_join() RETURNS TRIGGER AS $$
DECLARE
    hasFever BOOLEAN;
BEGIN
    SELECT fever INTO hasFever
    FROM Health_Declaration
    WHERE eid = NEW.eid
    AND hd_date = CURRENT_DATE;

    IF (hasFever) THEN
        RAISE NOTICE 'Error: employee has a fever';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER fever_cannot_join
BEFORE
INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION reject_fever_join();

--- CONSTRAINT 21
--Syntax works
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


CREATE OR REPLACE TRIGGER approve_same_dept
BEFORE
UPDATE ON Meetings
FOR EACH ROW EXECUTE FUNCTION reject_approval_diff_dept();

--- CONSTRAINT 22
-- Syntax Works
CREATE OR REPLACE FUNCTION stop_second_approval() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION USING
        errcode='2APPR',
        message='Error: Cannot approve a meeting that is already approved.';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER approve_once_only
BEFORE
UPDATE ON Meetings
FOR EACH ROW WHEN (OLD.approver_eid IS NOT NULL) EXECUTE FUNCTION stop_second_approval();

--- Constraint 23
-- ensure that approver id changes approver id for all time blocks
-- Syntax works
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
--Syntax works
CREATE OR REPLACE FUNCTION check_leave_meeting() RETURNS TRIGGER AS $$
DECLARE
	resigned DATE;
	has_fever BOOLEAN;
    approver_id INTEGER;
BEGIN
	SELECT e.resigned_date INTO resigned FROM Employees e WHERE e.eid = OLD.eid;
	SELECT hd.fever INTO has_fever FROM Health_Declaration hd WHERE hd.hd_date = OLD.meeting_date AND eid = OLD.eid;
    SELECT m.approver_eid INTO approver_id FROM Meetings m WHERE m.room = OLD.room 
    AND m.floor_no = OLD.floor_no 
    AND m.meeting_date = OLD.meeting_date 
    AND m.start_time = OLD.start_time;
	
    IF (has_fever IS TRUE OR resigned IS NOT NULL OR approver_id IS NULL) THEN
		RETURN OLD;
	ELSE
        RAISE NOTICE 'Error: No valid reason to leave meeting';
		RETURN NULL;

	END IF;
END
$$LANGUAGE plpgsql;

CREATE TRIGGER valid_leave_meeting
BEFORE DELETE ON Joins
FOR EACH ROW EXECUTE FUNCTION check_leave_meeting();

--- Constraint 24
-- Only manager from same department as meeting room may change meeting room capacity
-- How does the trigger get the manager_id?
-- Syntax works
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

--Constraint 24

CREATE OR REPLACE FUNCTION only_manager_change_capacity() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.eid NOT IN (SELECT eid FROM Manager)) THEN
        RAISE EXCEPTION USING
            errcode='OMGRC',
            message='Error: Non-Managers cannot change room capacity';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER only_manager_change_capacity
BEFORE INSERT OR UPDATE ON Updates
FOR EACH ROW EXECUTE FUNCTION only_manager_change_capacity();



--- Constraint 25
-- Booking can only be made for future meetings
-- Syntax works
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
--Syntax works
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
--Syntax works
CREATE OR REPLACE FUNCTION full_capacity_on_join() RETURNS TRIGGER AS $$
DECLARE
    max_capacity INTEGER;
    current_capacity INTEGER;
BEGIN
    SELECT u.new_capacity INTO max_capacity
    FROM Updates u
    WHERE NEW.floor_no = u.floor_no
    AND NEW.room = u.room
    AND u.update_date >= (SELECT u2.update_date FROM Updates u2 WHERE u2.floor_no = NEW.floor_no AND u2.room = NEW.room);

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
--Syntax works
CREATE OR REPLACE FUNCTION check_approve_meeting_date() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION USING
        errcode='OAFMT',
        message='Error: Cannot approve past meeting';
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER only_approve_future_meetings
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
FOR EACH ROW WHEN (NEW.fever IS TRUE) EXECUTE FUNCTION contact_trace_on_fever();


--- Constraint 12: Enforces the ISA No Overlap Constraint between Junior and Booker
-- Works
CREATE OR REPLACE FUNCTION junior_not_booker() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN 
	SELECT COUNT(eid) INTO count FROM Booker WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN 
        RAISE NOTICE 'Error: Employee is already a Booker, cannot be a Junior'; 
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
        RAISE NOTICE 'Error: Employee is already a Junior, cannot be a Booker';
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
        RAISE NOTICE 'Error: Employee is already a Manager, cannot be a Senior';
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
        RAISE NOTICE 'Error: Employee is already a Senior, cannot be a Manager';
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
    AND hd.date = CURRENT_DATE INTO fever;

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
CREATE OR REPLACE OR REPLACE FUNCTION approver_noresign() RETURNS TRIGGER AS $$
DECLARE
    resigned BOOLEAN;
BEGIN
    SELECT e.resigned_date IS NOT NULL 
    FROM Employees e
    WHERE e.eid = NEW.approver_eid INTO resigned;

    IF resigned IS TRUE THEN
        RAISE NOTICE 'Error: Employees that have resigned are not permitted to approve a meeting.';
        RETURN NULL;
	END IF;

    RETURN NEW;
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
    IF (NEW.eid IS NOT NULL) THEN  
        RETURN NULL;
    END IF;

    SELECT did into manager_did
    FROM Employees
    WHERE eid = NEW.eid;

    SELECT did INTO meeting_did
    FROM Meeting_Rooms
    WHERE room = OLD.room
    AND floor_no = OLD.floor_no;

    IF (manager_did <> meeting_did) THEN
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
        RAISE NOTICE 'Error: Meeting has already been approved, no new participants can be added.';
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
BEGIN
	SELECT resigned_date INTO resigned FROM Employees WHERE eid = OLD.eid;
	SELECT fever INTO has_fever FROM Health_Declaration WHERE hd_date = OLD.meeting_date;
	IF (has_fever IS FALSE OR resigned IS NOT NULL OR OLD.approver_eid IS NOT NULL) THEN
		RAISE NOTICE 'Error: No valid reason to leave meeting';
		RETURN NULL;
	ELSE
		RETURN OLD;
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
        RAISE NOTICE 'Error: Only manager from the department can change meeting room capacity';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER same_manager_change_capacity
BEFORE
INSERT ON Updates
FOR EACH ROW EXECUTE FUNCTION same_manager_change_capacity();

--- Constraint 25
-- Booking can only be made for future meetings
-- Syntax works
CREATE OR REPLACE FUNCTION booking_only_future() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.start_date > CURRENT_DATE) THEN
        RAISE NOTICE 'Error: Bookings can only be made for future dates';
        RETURN NULL;
    ELSE
        RETURN NULL;
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
    IF (NEW.meeting_date < CURRENT_DATE) THEN -- joining past meeting
        RAISE NOTICE 'Error: Cannot join past meeting';
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

--- Constrain 27:
--Syntax works
CREATE OR REPLACE FUNCTION check_approve_meeting_date() RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.meeting_date < CURRENT_DATE) THEN -- approving past meeting
        RAISE NOTICE 'Error: Cannot approve past meeting';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER only_approve_future_meetings
BEFORE
UPDATE ON Meetings
FOR EACH ROW EXECUTE FUNCTION check_approve_meeting_date();

--- Constraint 31:
--Syntax works
CREATE OR REPLACE FUNCTION check_temperature() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.temperature > 37.5) THEN
        NEW.fever := TRUE;
    ELSE
        NEW.fever := FALSE;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_fever
BEFORE
INSERT ON Health_Declaration
FOR EACH ROW EXECUTE FUNCTION check_temperature();
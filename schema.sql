-- Done
CREATE TABLE Departments ( 
	did INTEGER, 
	dname text, 
	PRIMARY KEY (did)
);

-- Done
CREATE TABLE Employees (
	eid SERIAL,
	did integer NOT NULL,
	email text UNIQUE,
	ename text,	
	resigned_date date,
	PRIMARY KEY (eid),
	FOREIGN KEY (did) REFERENCES Departments (did) -- Works In Relation
);

-- Done
-- Assumptions:
-- 1. Employees can share the same home/office/mobile numbers
CREATE TABLE Phone_Numbers (
	eid integer NOT NULL,
	phone_number INTEGER,
	phone_type TEXT,
	PRIMARY KEY(eid, phone_type),
	CONSTRAINT valid_phone_type CHECK (phone_type IN ('Home', 'Office', 'Mobile')),
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);

-- Done
CREATE TABLE Junior (
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

-- Done
CREATE TABLE Booker ( 
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

-- Done	
CREATE TABLE Senior (
	eid INTEGER PRIMARY KEY, 
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

-- Done
CREATE TABLE Manager ( 
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

-- Done
-- Assumption: only one health declaration taken a day for each employee
CREATE TABLE Health_Declaration (
	eid integer NOT NULL,
	hd_date DATE,
	temp NUMERIC,
	fever boolean,
	PRIMARY KEY (eid, hd_date),
	FOREIGN KEY (eid) REFERENCES Employees (eid),
	CONSTRAINT valid_temperature CHECK (temp BETWEEN 34 AND 43)
);

-- Done
CREATE TABLE Meeting_Rooms (
	room integer,
	floor_no integer,
	rname text,
	did integer NOT NULL,
	PRIMARY KEY (room, floor_no),
	FOREIGN KEY (did) REFERENCES Departments (did) -- Located In Relation
);
-- [ ]unresolved: meeting room must be related to at least one update (the initial one presumably) 
CREATE TABLE Updates (
	room integer,
	floor_no integer,
	update_date date,
	new_capacity integer NOT NULL,
	eid integer, -- why is this PK
	PRIMARY KEY (room, floor_no, update_date),
	FOREIGN KEY (room, floor_no) REFERENCES Meeting_Rooms (room, floor_no),
	FOREIGN KEY (eid) REFERENCES Manager (eid)
);
-- [ ]unresolved: session must be related to at least one join
CREATE TABLE Meetings (
	room integer,
	floor_no integer,
	meeting_date date,
	start_time TIME,
	booker_eid integer NOT NULL,
	approver_eid integer,
	PRIMARY KEY (room, floor_no, start_time, meeting_date),
	FOREIGN KEY (booker_eid) REFERENCES Booker (eid), -- Books Relation
	FOREIGN KEY (approver_eid) REFERENCES Manager (eid) -- Approves Relation
);

CREATE OR REPLACE TABLE Joins (
	room integer, 
	floor_no integer, 
	meeting_date date, 
	start_time TIME,
	eid integer,
	PRIMARY KEY (room, floor_no, meeting_date, start_time, eid),
	FOREIGN KEY (room, floor_no, meeting_date, start_time) REFERENCES Meetings (room, floor_no, meeting_date, start_time) ON DELETE CASCADE,
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);

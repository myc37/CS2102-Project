DROP TABLE IF EXISTS Joins;
DROP TABLE IF EXISTS Meetings;
DROP TABLE IF EXISTS Updates;
DROP TABLE IF EXISTS Meeting_Rooms;
DROP TABLE IF EXISTS Health_Declaration;
DROP TABLE IF EXISTS Manager;
DROP TABLE IF EXISTS Senior;
DROP TABLE IF EXISTS Booker;
DROP TABLE IF EXISTS Junior;
DROP TABLE IF EXISTS Phone_Numbers;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Departments;

CREATE TABLE Departments ( 
	did INTEGER, 
	dname TEXT, 
	PRIMARY KEY (did)
);

CREATE TABLE Employees (
	eid SERIAL,
	did INTEGER NOT NULL,
	email TEXT UNIQUE,
	ename TEXT,	
	resigned_date DATE,
	PRIMARY KEY (eid),
	FOREIGN KEY (did) REFERENCES Departments (did) 
);

-- Assumptions:
-- 1. Employees can share the same home/office/mobile numbers
CREATE TABLE Phone_Numbers (
	eid INTEGER NOT NULL,
	phone_number INTEGER,
	phone_type TEXT,
	PRIMARY KEY(eid, phone_type),
	CONSTRAINT valid_phone_type CHECK (phone_type IN ('Home', 'Office', 'Mobile')),
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE Junior (
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE Booker ( 
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE Senior (
	eid INTEGER PRIMARY KEY, 
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE Manager ( 
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

-- Assumption: only one health declaration taken a day for each employee
CREATE TABLE Health_Declaration (
	eid INTEGER NOT NULL,
	hd_date DATE,
	temp NUMERIC,
	PRIMARY KEY (eid, hd_date),
	FOREIGN KEY (eid) REFERENCES Employees (eid),
	CONSTRAINT valid_temperature CHECK (temp BETWEEN 34 AND 43)
);

CREATE TABLE Meeting_Rooms (
	room INTEGER,
	floor_no INTEGER,
	rname TEXT,
	did INTEGER NOT NULL,
	PRIMARY KEY (room, floor_no),
	FOREIGN KEY (did) REFERENCES Departments (did) 
);

CREATE TABLE Updates (
	room INTEGER,
	floor_no INTEGER,
	update_date DATE,
	new_capacity INTEGER NOT NULL,
	eid INTEGER, 
	PRIMARY KEY (room, floor_no, update_date),
	FOREIGN KEY (room, floor_no) REFERENCES Meeting_Rooms (room, floor_no),
	FOREIGN KEY (eid) REFERENCES Manager (eid)
);

CREATE TABLE Meetings (
	room INTEGER,
	floor_no INTEGER,
	meeting_date DATE,
	start_time TIME,
	booker_eid INTEGER NOT NULL,
	approver_eid INTEGER,
	PRIMARY KEY (room, floor_no, start_time, meeting_date),
	FOREIGN KEY (booker_eid) REFERENCES Booker (eid), 
	FOREIGN KEY (approver_eid) REFERENCES Manager (eid) 
);

CREATE TABLE Joins (
	room INTEGER, 
	floor_no INTEGER, 
	meeting_date DATE, 
	start_time TIME,
	eid INTEGER,
	PRIMARY KEY (room, floor_no, meeting_date, start_time, eid),
	FOREIGN KEY (room, floor_no, meeting_date, start_time) REFERENCES Meetings (room, floor_no, meeting_date, start_time) ON DELETE CASCADE,
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);

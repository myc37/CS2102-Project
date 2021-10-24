CREATE OR REPLACE TABLE Employees (
	eid INTEGER,
	did INTEGER NOT NULL,
	email TEXT UNIQUE,
	ename TEXT,	
	resigned_date DATE,
	PRIMARY KEY (eid),
	FOREIGN KEY (did) REFERENCES Departments (did) -- Works In Relation
);

-- Assumptions:
-- 1. Employees can share the same home/office/mobile numbers
CREATE OR REPLACE TABLE Phone_Numbers (
	eid INTEGER,
	phone_type TEXT,
	phone_number INTEGER,
	PRIMARY KEY(eid, phone_type),
	CONSTRAINT valid_phone_type CHECK (phone_type IN ('Home', 'Office', 'Mobile')),
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);

CREATE OR REPLACE TABLE Junior (
	eid INTEGER PRIMARY KEY
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
;

CREATE OR REPLACE TABLE Booker ( 
	eid INTEGER PRIMARY KEY
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
)
	
CREATE OR REPLACE TABLE Senior (
	eid INTEGER PRIMARY KEY  
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE Manager ( 
	eid INTEGER PRIMARY KEY
	FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

-- Assumption: only one health declaration taken a day for each employee
CREATE OR REPLACE TABLE Health_Declaration (
	eid integer NOT NULL,
	hd_date DATE,
	temp NUMERIC,
	fever boolean,
	PRIMARY KEY (eid, hd_date),
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);

CREATE OR REPLACE TABLE Departments (
	did INTEGER,
	dname TEXT,
	PRIMARY KEY (did)
);

CREATE OR REPLACE TABLE Meeting_Rooms (
	room INTEGER,
	floor_no INTEGER,
	rname TEXT,
	did INTEGER NOT NULL,
	PRIMARY KEY (room, floor_no),
	FOREIGN KEY (did) REFERENCES Departments (did) -- Located In Relation
);
-- [ ]unresolved: meeting room must be related to at least one update (the initial one presumably) 
CREATE OR REPLACE TABLE Updates (
	room integer,
	floor_no integer,
	update_date date,
	new_capacity integer,
	eid integer,
	PRIMARY KEY (eid, room, floor_no, update_date),
	FOREIGN KEY (room, floor_no) REFERENCES Meeting_Rooms (room, floor_no),
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);
-- [ ]unresolved: session must be related to at least one join
CREATE OR REPLACE TABLE Meetings (
	room INTEGER,
	floor_no INTEGER,
	meeting_date DATE,
	start_time TIME,
	booker_eid INTEGER NOT NULL,
	approver_eid INTEGER,
	PRIMARY KEY (room, floor_no, start_time, meeting_date),
	FOREIGN KEY (booker_eid) REFERENCES Booker (eid), -- Books Relation
	FOREIGN KEY (approver_eid) REFERENCES Manager (eid), -- Approves Relation
	CONSTRAINT valid_date CHECK (meeting_date > CURRENT_DATE OR meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME)
);

CREATE OR REPLACE TABLE Joins (
	room INTEGER, 
	floor_no INTEGER, 
	meeting_date DATE, 
	start_time TIME,
	eid INTEGER,
	PRIMARY KEY (room, floor_no, meeting_date, start_time, eid),
	FOREIGN KEY (room, floor_no, meeting_date, start_time) REFERENCES Meetings (room, floor_no, meeting_date, start_time),
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);

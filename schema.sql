CREATE OR REPLACE TABLE Employees (
	eid integer,
	did integer NOT NULL,
	email text UNIQUE,
	ename text,	
	resigned_date date,
	PRIMARY KEY (eid),
	FOREIGN KEY (did) REFERENCES Departments (did) -- Works In Relation
);

-- Assumptions:
-- 1. Employees can share the same home/office/mobile numbers
CREATE OR REPLACE TABLE PhoneNumbers (
	eid integer NOT NULL,
	phone_number INTEGER,
	phone_type TEXT,
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
	did integer,
	dname text,
	PRIMARY KEY (did)
);

CREATE OR REPLACE TABLE Meeting_Rooms (
	room integer,
	floor_no integer,
	rname text,
	did integer NOT NULL,
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
	FOREIGN KEY (room, floor_no, meeting_date, start_time) REFERENCES Sessions (room, floor_no, meeting_date, start_time),
	FOREIGN KEY (eid) REFERENCES Employees (eid)
);

-- BASIC FUNCTIONALITY TEST CASES

CREATE OR REPLACE PROCEDURE test_all() AS $$
BEGIN
    CALL basic_func();
    CALL core_func();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE basic_func() AS $$
BEGIN
    CALL tc0();
    RAISE NOTICE 'BASIC FUNCTIONALITY TESTS
    ';
    CALL tc1();
    CALL tc2();
    CALL tc3();
    CALL tc4();
    CALL tc5();
    CALL tc6();
    CALL tc7();
    CALL tc8();
    CALL tc9();
    CALL tc10();
    CALL tc11();
    CALL tc12();
    CALL tc13();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc0() AS $$
BEGIN
    ALTER TABLE Joins DISABLE TRIGGER valid_leave_meeting; 
    CALL delete_all();
    CALL clear_serial();
    ALTER TABLE Joins ENABLE TRIGGER valid_leave_meeting;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc1() AS $$
BEGIN
    RAISE NOTICE 'Test 1 - add_department routine:';
    CALL add_department(1, 'Marketing');
    CALL add_department(2, 'Human Resources');
    CALL add_department(3, 'Operations');
    CALL add_department(4, 'Finance');
    CALL add_department(5, 'Sales');
    CALL add_department(6, 'Technology');
    CALL add_department(7, 'Legal');
    CALL add_department(8, 'Welfare');
    CALL add_department(9, 'General Management');
    CALL add_department(10, 'Research and Development');
    CALL add_department(11, 'Biology');
    ASSERT (SELECT COUNT (*) FROM Departments) = 11, 'Test 1 Failure';
    RAISE NOTICE 'Test 1 Success: Populated the database with 11 departments'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc2() AS $$
BEGIN
    RAISE NOTICE 'Test 2 - Constraint 4 Unique Department ID & Constraint 5 Department Name:';
    CALL add_department(1, 'Marketing'); 
    RAISE NOTICE 'Test 2 Failure';
    EXCEPTION 
        WHEN sqlstate '23505' THEN
        RAISE NOTICE 'Test 2 Success: Constraint 4 & Constraint 5 Enforced';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc3() AS $$
BEGIN
    RAISE NOTICE 'Test 3 - remove_department routine:';
    CALL remove_department(11);
    ASSERT (SELECT COUNT (*) FROM Departments) = 10, 'Test 3 Failure';
    RAISE NOTICE 'Test 3 Success: Removed department with ID = 11 resulting in 10 departments'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc4() AS $$
BEGIN
    RAISE NOTICE 'Test 4 - add_employee routine:';
    CALL add_employee('Adel Stannislawski', 44898478, 'Office', 'junior', 2);
    CALL add_employee('Kleon Delve', 46379749, 'Mobile', 'manager', 1); -- 2
    CALL add_employee('Teador Fawthorpe', 21028980, 'Office', 'senior', 4);
    CALL add_employee('Merna Bloomer', 78268285, 'Home', 'junior', 3);
    CALL add_employee('Codie Duncklee', 89071609, 'Home', 'junior', 8);
    CALL add_employee('Edmund Statersfield', 61148294, 'Mobile', 'senior', 6);
    CALL add_employee('Kenny Ramlot', 65054090, 'Office', 'junior', 2);
    CALL add_employee('Gibb Pingston', 62065539, 'Mobile', 'junior', 5);
    CALL add_employee('Bobbi Vassel', 18640729, 'Mobile', 'junior', 9);
    CALL add_employee('Celeste Lapwood', 62816604, 'Mobile', 'manager', 1);
    CALL add_employee('Josias Treleaven', 95818211, 'Office', 'junior', 8);
    CALL add_employee('Clarisse Risdall', 96967250, 'Home', 'senior', 8);
    CALL add_employee('Beale Bawme', 21288745, 'Mobile', 'junior', 7);
    CALL add_employee('Muire Ninotti', 93040433, 'Mobile', 'junior', 6);
    CALL add_employee('Bronson Culvey', 57265070, 'Mobile', 'manager', 5);
    CALL add_employee('Kata Blackley', 37999721, 'Office', 'junior', 6);
    CALL add_employee('Riva Sproston', 69971566, 'Mobile', 'manager', 1);
    CALL add_employee('Sauveur Shea', 63428144, 'Home', 'junior', 5);
    CALL add_employee('Freddie Tucsell', 93423271, 'Home', 'senior', 6);
    CALL add_employee('Piper Iacobetto', 21948233, 'Office', 'junior', 8);
    CALL add_employee('Danella Deards', 32316264, 'Home', 'junior', 8);
    CALL add_employee('Jeralee Caro', 51038543, 'Home', 'junior', 9);
    CALL add_employee('Emeline Farres', 16561840, 'Home', 'manager', 10);
    CALL add_employee('Ichabod Worsnup', 33500383, 'Office', 'manager', 2);
    CALL add_employee('Conny Mapplethorpe', 72930447, 'Mobile', 'manager', 8);
    CALL add_employee('Vitia Dumbrall', 31543261, 'Home', 'junior', 8);
    CALL add_employee('Cristal Letson', 48502603, 'Mobile', 'manager', 2);
    CALL add_employee('Bobinette Godwyn', 42328649, 'Home', 'manager', 3);
    CALL add_employee('Myrah Blackaby', 47890737, 'Mobile', 'junior', 3);
    CALL add_employee('Rosabelle Notti', 91024806, 'Home', 'senior', 6);
    CALL add_employee('Beatrice Griffey', 65040656, 'Home', 'junior', 8);
    CALL add_employee('Janeczka Stotherfield', 92235630, 'Home', 'junior', 1);
    CALL add_employee('Lea Church', 54850716, 'Home', 'senior', 4); -- 33
    CALL add_employee('Lorrayne Looks', 98837351, 'Mobile', 'junior', 2);
    CALL add_employee('Calypso Radish', 89986912, 'Home', 'junior', 5);
    CALL add_employee('Gretna Kyndred', 73249693, 'Home', 'senior', 3);
    CALL add_employee('Traver Isham', 74385806, 'Home', 'manager', 3);
    CALL add_employee('Carleen Ingley', 37900287, 'Mobile', 'senior', 5);
    CALL add_employee('Greggory Zorzenoni', 56306723, 'Home', 'manager', 8); --39
    CALL add_employee('Susy Conahy', 51990787, 'Mobile', 'junior', 7);
    CALL add_employee('Winnah Elliston', 36496732, 'Office', 'senior', 2);
    CALL add_employee('Ludvig Littlekit', 38207086, 'Mobile', 'junior', 6);
    CALL add_employee('Horton Hartless', 42739165, 'Mobile', 'manager', 5); --43
    CALL add_employee('Euphemia Whitehall', 17904175, 'Home', 'manager', 3); --44
    CALL add_employee('Reinold Steckings', 47932326, 'Mobile', 'junior', 10);
    CALL add_employee('Cathyleen Pisco', 76463281, 'Mobile', 'junior', 3);
    CALL add_employee('Jillene Forber', 37671928, 'Mobile', 'junior', 3);
    CALL add_employee('Melany Colafate', 47824416, 'Mobile', 'senior', 1);
    CALL add_employee('Nan Greatrakes', 56611631, 'Office', 'junior', 10);
    CALL add_employee('Rodi Iglesia', 54368932, 'Home', 'junior', 6);
    CALL add_employee('Armand Cordet', 19426453, 'Home', 'senior', 6);
    CALL add_employee('Tobe Peltz', 28875827, 'Mobile', 'senior', 6);
    CALL add_employee('Georgeanna Honnan', 83487111, 'Mobile', 'junior', 2);
    CALL add_employee('Jaimie Kunkel', 69086006, 'Home', 'junior', 4);
    CALL add_employee('Nicol Breeder', 28982840, 'Home', 'manager', 3); --55
    CALL add_employee('Isiahi Ravens', 96280530, 'Home', 'junior', 3);
    CALL add_employee('Brenn Hanson', 84728506, 'Office', 'junior', 1);
    CALL add_employee('Kalina Freke', 42353856, 'Mobile', 'manager', 6); --58
    CALL add_employee('Ricoriki Glabach', 13980002, 'Home', 'junior', 3);
    CALL add_employee('Vassili Crevagh', 71470882, 'Office', 'manager', 10); --60
    CALL add_employee('Townie Areles', 65781233, 'Home', 'junior', 10);
    CALL add_employee('Hendrika Dimberline', 39727217, 'Mobile', 'junior', 3);
    CALL add_employee('Batsheva Domm', 59619705, 'Home', 'junior', 4);
    CALL add_employee('Jacklyn Blackford', 71617821, 'Mobile', 'senior', 7);
    CALL add_employee('Raine Stutard', 41352823, 'Mobile', 'senior', 8);
    CALL add_employee('Aprilette Drydale', 15339847, 'Mobile', 'manager', 3); --66
    CALL add_employee('Dorey Engeham', 37002828, 'Home', 'junior', 3);
    CALL add_employee('Winifield Berkely', 59536362, 'Home', 'senior', 9);
    CALL add_employee('Justin Gladdifh', 91575847, 'Home', 'junior', 7);
    CALL add_employee('Bear Drowsfield', 24412590, 'Office', 'junior', 3);
    CALL add_employee('Jesse Rundle', 12622916, 'Home', 'manager', 4); --71
    CALL add_employee('Donelle Crosdill', 87558621, 'Home', 'senior', 6);
    CALL add_employee('Graeme Maycock', 32395385, 'Office', 'junior', 8);
    CALL add_employee('Bryn Ruse', 29342869, 'Mobile', 'senior', 5);
    CALL add_employee('Meade Cathesyed', 62736690, 'Mobile', 'manager', 2); --75
    CALL add_employee('Agustin Cush', 79311993, 'Mobile', 'senior', 4);
    CALL add_employee('Maddi Bridge', 46168298, 'Home', 'senior', 5);
    CALL add_employee('Mozelle Rillstone', 88186249, 'Office', 'manager', 9); --78
    CALL add_employee('Iolanthe Bottby', 70297362, 'Office', 'manager', 10); --79
    CALL add_employee('Wittie Ojeda', 91131012, 'Office', 'senior', 1);
    CALL add_employee('Ardis Kluger', 69054152, 'Mobile', 'senior', 9);
    CALL add_employee('Ezmeralda Coiley', 27921573, 'Home', 'manager', 7); --82
    CALL add_employee('Gail Hogbourne', 81363582, 'Home', 'junior', 10);
    CALL add_employee('Dylan Kleyn', 96822568, 'Home', 'junior', 3);
    CALL add_employee('Alice Van Bruggen', 38252339, 'Home', 'junior', 2);
    CALL add_employee('Bart Arrigucci', 10327828, 'Mobile', 'senior', 1);
    CALL add_employee('Jedediah Mogra', 22038728, 'Mobile', 'manager', 10); --87
    CALL add_employee('Kelwin Manktelow', 19724323, 'Home', 'junior', 7);
    CALL add_employee('Almeda Luckey', 31376128, 'Mobile', 'junior', 4);
    CALL add_employee('Cori Rodenhurst', 81090806, 'Mobile', 'junior', 10);
    CALL add_employee('Gabriell Bermingham', 38993954, 'Mobile', 'senior', 1);
    CALL add_employee('Dani Lawden', 60272991, 'Office', 'junior', 3);
    CALL add_employee('Clarey Coat', 58433815, 'Home', 'junior', 3);
    CALL add_employee('Sheridan Valance', 74796539, 'Office', 'junior', 9);
    CALL add_employee('Reeta Tippin', 61960301, 'Home', 'senior', 1);
    CALL add_employee('Eldin Krug', 30538788, 'Mobile', 'junior', 5);
    CALL add_employee('Carri Dower', 27969971, 'Mobile', 'junior', 10);
    CALL add_employee('Tab Lay', 52693691, 'Mobile', 'junior', 4);
    CALL add_employee('Ivonne Batchelder', 92713176, 'Mobile', 'senior', 7);
    CALL add_employee('Ranee Ziebart', 32335633, 'Home', 'junior', 6);
    CALL add_employee('To be deleted', 12345678, 'Home', 'junior', 1);
    ASSERT (SELECT COUNT (*) FROM Employees) = 101, 'Test 4 Failure';
    RAISE NOTICE 'Test 4 Success: Populated the database with 101 employees'; 
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc5() AS $$
BEGIN
    RAISE NOTICE 'Test 5 - Constraint 1 Unique Employee ID:';
    INSERT INTO Employees (eid, did, email, ename, resigned_date) VALUES (1, 1, 'Adel_Stannislawski_1@bluewhale.org', 'Adel Stannislawski', NULL);
    RAISE NOTICE 'Test 5 Failure';
    EXCEPTION 
        WHEN sqlstate '23505' THEN
        RAISE NOTICE 'Test 5 Success: Constraint 1 Unique Employee ID Enforced'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc6() AS $$
BEGIN
    RAISE NOTICE 'Test 6 - Constraint 2 Unique Email Address:';
    UPDATE Employees SET email = 'Adel_Stannislawski_1@bluewhale.org' WHERE eid = 2; 
    RAISE NOTICE 'Test 6 Failure';
    EXCEPTION 
        WHEN sqlstate '23505' THEN
        RAISE NOTICE 'Test 6 Success: Constraint 2 Unique Email Enforced'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc7() AS $$
BEGIN
    CALL tc7_1();
    CALL tc7_2();
    CALL tc7_3();
    CALL tc7_4();
    CALL tc7_5();
    CALL tc7_6();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc7_1() AS $$
DECLARE senior_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO senior_count FROM Senior;
    RAISE NOTICE 'Test 7.1 - Constraint 12 Employee must be one of each kind - Adding a Junior into Senior:';
    INSERT INTO Senior (eid) VALUES (1); -- Employee is a junior
    ASSERT ((SELECT COUNT (*) FROM Senior) = senior_count), 'Test 7.1 Failure';
    EXCEPTION 
        WHEN sqlstate 'BJISA' THEN
        RAISE NOTICE 'Test 7.1 Success'; 

END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc7_2() AS $$
DECLARE manager_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO manager_count FROM Manager;
    RAISE NOTICE 'Test 7.2 - Constraint 12 Employee must be one of each kind - Adding a Junior into Manager';
    INSERT INTO Manager (eid) VALUES (1); -- Employee is a junior
    ASSERT ((SELECT COUNT(*) FROM Manager) = manager_count), 'Test 7.2 Failure';
    EXCEPTION 
        WHEN sqlstate 'BJISA' THEN
        RAISE NOTICE 'Test 7.2 Success'; 

END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc7_3() AS $$
DECLARE junior_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO junior_count FROM Junior;
    RAISE NOTICE 'Test 7.3 - Constraint 12 Employee must be one of each kind - Adding a Senior into Junior:';
    INSERT INTO Junior (eid) VALUES (77); -- Employee is a Senior
    RAISE NOTICE 'Test 7.3 Failure';
    ASSERT ((SELECT COUNT(*) FROM Junior) = junior_count),'Test 7.3 Failure';
    EXCEPTION 
        WHEN sqlstate 'JBISA' THEN
        RAISE NOTICE 'Test 7.3 Success'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc7_4() AS $$
DECLARE manager_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO manager_count FROM Manager;
    RAISE NOTICE 'Test 7.4 - Constraint 12 Employee must be one of each kind - Already a Senior into Manager';
    INSERT INTO Manager (eid) VALUES (77); -- Employee is a Senior
    ASSERT ((SELECT COUNT(*) FROM Manager) = manager_count), 'Test 7.4 Failure';
    EXCEPTION 
        WHEN sqlstate 'MSISA' THEN
        RAISE NOTICE 'Test 7.4 Success'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc7_5() AS $$
DECLARE junior_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO junior_count FROM Junior;
    RAISE NOTICE 'Test 7.5 - Constraint 12 Employee must be one of each kind - Adding a Manager into Junior:';
    INSERT INTO Junior (eid) VALUES (82); -- Employee is a Manager
    ASSERT ((SELECT COUNT(*) FROM Junior) = junior_count),'Test 7.5 Failure';
    EXCEPTION 
        WHEN sqlstate 'JBISA' THEN
        RAISE NOTICE 'Test 7.5 Success'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc7_6() AS $$
DECLARE senior_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO senior_count FROM Senior;
    RAISE NOTICE 'Test 7.6 - Constraint 12 Employee must be one of each kind - Already a Manager into Senior';
    INSERT INTO Senior (eid) VALUES (82); -- Employee is a Manager
    ASSERT ((SELECT COUNT(*) FROM Senior) = senior_count), 'Test 7.6 Failure';
    EXCEPTION 
        WHEN sqlstate 'SMISA' THEN
        RAISE NOTICE 'Test 7.6 Success'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc8() AS $$
DECLARE non_resigned INTEGER;
DECLARE employee_resigned_date DATE;
BEGIN
    SELECT COUNT(*) INTO non_resigned FROM Employees WHERE resigned_date IS NULL ;
    RAISE NOTICE 'Test 8 - remove_employee routine';
    CALL remove_employee(101, CURRENT_DATE);
    SELECT resigned_date INTO employee_resigned_date FROM Employees WHERE eid = 101; 
    IF employee_resigned_date IS NOT NULL THEN
        RAISE NOTICE 'Test 8 Success: Remove Employee is Functional';
    ELSE
        RAISE NOTICE 'Test 8 Failure';
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc9() AS $$
DECLARE phone_rows INTEGER;
BEGIN
    RAISE NOTICE 'Test 9 - add_phone_number routine (Helper routine)';
    CALL add_phone_number(1, 83948244, 'Home');
    SELECT COUNT(*) INTO phone_rows FROM Phone_Numbers WHERE eid = 1;
    ASSERT (phone_rows != 1), 'Test 9 Failure';
    RAISE NOTICE 'Test 9 Success: Adding Phone Number is Functional';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc10() AS $$
DECLARE phone_rows INTEGER;
BEGIN
    SELECT COUNT(*) FROM Phone_Numbers INTO phone_rows;
    RAISE NOTICE 'Test 10 - Primary Constraint (eid, phone_type) in Phone_Numbers';
    INSERT INTO Phone_Numbers VALUES (1, 917824, 'Office');
    ASSERT ((SELECT COUNT(*) FROM Phone_Numbers) = phone_rows), 'Test 10 Failure';
    EXCEPTION
        WHEN sqlstate '23505' THEN 
        RAISE NOTICE 'Test 10 Success: Primary Key Constraint of Phone_Numbers'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc11() AS $$
DECLARE phone_rows INTEGER;
BEGIN
    SELECT COUNT(*) FROM Phone_Numbers INTO phone_rows;
    RAISE NOTICE 'Test 11 - Foreign Key Constraint Phone_Numbers (eid)';
    INSERT INTO Phone_Numbers VALUES (5000, 917824, 'Office');
    ASSERT ((SELECT COUNT(*) FROM Phone_Numbers) = phone_rows), 'Test 11 Failure';
    EXCEPTION
        WHEN sqlstate '23503' THEN 
        RAISE NOTICE 'Test 11 Success: Foreign Key Constraint (eid) of Phone_Numbers'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc12() AS $$
BEGIN
    RAISE NOTICE 'Test 12 - add_room routine:';
    CALL add_room(1, 1, 'Room 1-1', 5, 1, 2);
    CALL add_room(1, 2, 'Room 1-2', 5, 1, 10);
    CALL add_room(2, 1, 'Room 2-1', 5, 2, 75);
    CALL add_room(3, 1, 'Room 3-1', 5, 3, 66);
    CALL add_room(4, 1, 'Room 4-1', 5, 4, 71);
    CALL add_room(5, 1, 'Room 5-1', 5, 5, 43);
    CALL add_room(6, 1, 'Room 6-1', 5, 6, 58);
    CALL add_room(7, 1, 'Room 7-1', 5, 7, 82);
    CALL add_room(8, 1, 'Room 8-1', 5, 8, 39);
    CALL add_room(9, 1, 'Room 9-1', 5, 9, 78);
    CALL add_room(10, 1, 'Room 10-1', 5, 10, 79);
    CALL add_room(10, 2, 'Room 10-2', 5, 10, 87);
    CALL add_room(10, 3, 'Room 10-3', 5, 10, 87);
    ASSERT (SELECT COUNT(*) FROM Meeting_Rooms) = 13, 'Test 12 Failure';
    RAISE NOTICE 'Test 12 Success: Populated the database with 13 meeting rooms with an initial capacity of 5'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc13() AS $$
BEGIN
    CALL tc13_1();
    CALL tc13_2();
    CALL tc13_3();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc13_1() AS $$
    DECLARE new_cap INTEGER;
BEGIN
    RAISE NOTICE 'Test 13.1 - Constraint 24 Only manager from the same department can change capacity:';
    CALL change_capacity(1,1,CURRENT_DATE, 8,10); -- 10 is a Manager from Dept 1
    SELECT u.new_capacity INTO new_cap
    FROM Updates u
    WHERE u.eid = 10
    AND u.room = 1
    AND u.floor_no = 1
    AND u.update_date = CURRENT_DATE;
    ASSERT (new_cap = 8), 'Test 13.1 Failure';
    RAISE NOTICE 'Test 13.1 Success: Capacity for Room 1-1 changed from 5 to 8'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc13_2() AS $$
    DECLARE new_cap INTEGER;
BEGIN
    RAISE NOTICE 'Test 13.2 - Constraint 24 Only manager from the same department can change capacity - Non manager:';
    CALL change_capacity(1,1,CURRENT_DATE, 8,57); -- 57 is a Junior from Dept 1
    SELECT u.new_capacity INTO new_cap
    FROM Updates u
    WHERE u.eid = 57
    AND u.room = 1
    AND u.floor_no = 1
    AND u.update_date = CURRENT_DATE;
    ASSERT (new_cap IS NULL), 'Test 13.2 Failure';
    EXCEPTION 
        WHEN sqlstate 'OMGRC' THEN
        RAISE NOTICE 'Test 13.2 Success: Non manager is unable to change the capacity'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc13_3() AS $$
    DECLARE new_cap INTEGER;
BEGIN
    RAISE NOTICE 'Test 13.3 - Constraint 24 Only manager from the same department can change capacity - Different department:';
    CALL change_capacity(1,1,CURRENT_DATE, 8,24); -- 24 is a Manager from Dept 2
    SELECT u.new_capacity INTO new_cap
    FROM Updates u
    WHERE u.eid = 24
    AND u.room = 1
    AND u.floor_no = 1
    AND u.update_date = CURRENT_DATE;
    ASSERT (new_cap IS NULL), 'Test 13.3 Failure';
    EXCEPTION 
        WHEN sqlstate 'SMGRC' THEN
        RAISE NOTICE 'Test 13.3 Success: Manager from different department is unable to change the capacity
        '; 
END
$$ LANGUAGE plpgsql;

-- CORE FUNCTIONALITY

CREATE OR REPLACE PROCEDURE core_func() AS $$
BEGIN
    RAISE NOTICE 'CORE FUNCTIONALITY TESTS
    ';

    CALL tc14(); 
    CALL tc15();
    CALL tc16();
    CALL tc17(); 
    CALL tc18();
    CALL tc19();    
    CALL tc20();
    CALL tc21();
    CALL tc22();
    CALL tc23();
    CALL tc24(); 
    CALL tc25();
    CALL tc26();
    CALL tc27(); 
    CALL tc28();
    CALL tc29();    
    CALL tc30();
    CALL tc31();
    CALL tc32();
    CALL tc33();
    CALL tc34();
    CALL tc35();

    -- Search room ()
    -- Book room ()
    -- Unbook room ()
    -- Join meeting ()
    -- Leave meeting ()
    -- Approve meeting (Cannot join after approved, cannot leave after approved, cannot unbook room after approved)
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc14() AS $$
DECLARE
    free_rooms INTEGER;
BEGIN
    RAISE NOTICE 'Test 14 - search_room routine:';
    SELECT COUNT(*) INTO free_rooms
    FROM search_room(5, CURRENT_DATE, CURRENT_TIME::TIME, (CURRENT_TIME::TIME + INTERVAL '1 HOUR')::TIME);
    ASSERT (free_rooms = 13), 'Test 14 Failure';
    RAISE NOTICE 'Test 14 Success: Found 13 available rooms with capacity of at least 5 currently'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc15() AS $$
DECLARE
    free_rooms INTEGER;
BEGIN
    RAISE NOTICE 'Test 15 - search_room routine:';
    SELECT COUNT(*) INTO free_rooms
    FROM search_room(8, CURRENT_DATE, CURRENT_TIME::TIME, (CURRENT_TIME::TIME + INTERVAL '1 HOUR')::TIME);
    ASSERT (free_rooms = 1), 'Test 15 Failure';
    RAISE NOTICE 'Test 15 Success: Found 1 available room with capacity of at least 8 currently'; 
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc16() AS $$
BEGIN
    RAISE NOTICE 'Test 16 - book_room routine:';
    CALL book_room(1, 1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 48); -- Senior Dept 1
    CALL book_room(1, 1, CURRENT_DATE + 2, TIME '12:00', TIME '14:00', 48); -- Senior Dept 1
    CALL book_room(1, 1, CURRENT_DATE + 3, TIME '12:00', TIME '14:00', 48); -- Senior Dept 1
    CALL book_room(2, 1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 75); -- Senior Dept 2
    CALL book_room(2, 1, CURRENT_DATE + 1, TIME '16:00', TIME '18:00', 75); -- Senior Dept 2
    CALL book_room(3, 1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 48); -- Senior Dept 3
    CALL book_room(3, 1, CURRENT_DATE + 2, TIME '12:00', TIME '14:00', 36); -- Senior Dept 3
    CALL book_room(10, 1, CURRENT_DATE + 3, TIME '14:00', TIME '16:00', 79); -- Manager Dept 10
    CALL book_room(10, 1, CURRENT_DATE + 4, TIME '14:00', TIME '16:00', 79); -- Manager Dept 10
    CALL book_room(10, 1, CURRENT_DATE + 5, TIME '14:00', TIME '16:00', 79); -- Manager Dept 10
    CALL book_room(7, 1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 82); -- Senior Dept 7 (To be deleted)
    -- booking a past meeting
    ALTER TABLE Meetings DISABLE TRIGGER booking_only_future;
    ALTER TABLE Joins DISABLE TRIGGER only_join_future_meetings;
    CALL book_room(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 38); -- Senior dept 5
    ALTER TABLE Meetings ENABLE TRIGGER booking_only_future;
    ALTER TABLE Joins ENABLE TRIGGER only_join_future_meetings;
    -- booked a past meeting
    ASSERT ((SELECT COUNT(*) FROM Meetings) = 22), format('Test 16 Failure: There are %s instead of 21 meetings booked', (SELECT COUNT (*) FROM Meetings));
    RAISE NOTICE 'Test 16 Success: Database populated with 22 (10 x 2 hours + 2 x 1 hour) meetings'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc17() AS $$
DECLARE
    is_in_meeting BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 17 - Constraint 18 Employee booking the room immediately joins the meeting:';
    SELECT j.eid IS NOT NULL INTO is_in_meeting
    FROM Joins j
    WHERE j.room = 1
    AND j.floor_no = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.start_time = '12:00'
    AND j.eid = 48;
    ASSERT (is_in_meeting IS TRUE), 'Test 17 Failure: Employee booking the room did not join the meeting';
    RAISE NOTICE 'Test 17 Success: Employee ID 48 who booked Room 1-1 immediately joined meeting'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc18() AS $$
BEGIN
    RAISE NOTICE 'Test 18 - Constraint 13 Junior cannot book a room';
    CALL book_room(1, 1, CURRENT_DATE + 4, TIME '12:00', TIME '14:00', 32); -- Junior Dept 1
    RAISE NOTICE 'Test 18 Failed: Junior could book a room.';
    EXCEPTION  
        WHEN sqlstate '23503' THEN
        RAISE NOTICE 'Test 18 Success: Junior with employee ID 32 is unable to book a room in department 1'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc19() AS $$
DECLARE 
    booker_id INTEGER;
BEGIN
    RAISE NOTICE 'Test 19 - Constraint 15 Meeting room can only booked by one group for a given date and time';
    CALL book_room(1, 1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 91); -- Senior Dept 1
    SELECT m.booker_eid INTO booker_id
    FROM Meetings m
    WHERE m.room = 1
    AND m.floor_no = 1
    AND m.start_time = TIME '12:00'
    AND m.meeting_date = CURRENT_DATE + 1;
    ASSERT (booker_id = 48), 'Test 19 Failure: Booker ID should not have changed from 48';
    EXCEPTION 
        WHEN sqlstate '23505' THEN
        RAISE NOTICE 'Test 19 Success: Room 1-1 cannot be booked by employee 91 as it has already been booked by employee 48';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc_20() AS $$
BEGIN
    RAISE NOTICE 'Test 20 - Constraint 26 Employees can only join future meetings'; 
    CALL book_room(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 38); -- Senior dept 5
    EXCEPTION
        WHEN sqlstate 'OBFMT' THEN 
            RAISE NOTICE 'Test 20 Success: Employee 38 could not book Meeting Room 5-1 from 12:00 to 13:00 on the previous day'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc21() AS $$
DECLARE
    free_rooms INTEGER;
BEGIN
    RAISE NOTICE 'Test 21 - search_room routine AFTER book_room:';
    SELECT COUNT(*) INTO free_rooms
    FROM search_room(5, CURRENT_DATE + 1, TIME '12:00', TIME '13:00');
    ASSERT (free_rooms = 9), 'Test 21 Failure: There should be 9 available rooms (Room 1-1, 2-1, 3-1, 7-1 are booked)';
    RAISE NOTICE 'Test 21 Success: Found 10 available rooms with capacity of at least 5 tomorrow from 12:00 to 13:00'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc22() AS $$
DECLARE
    is_unbooked BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 22 - unbook_room routine:';
    CALL unbook_room(7, 1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 82); -- Senior dept 7
    is_unbooked := (1, 7, CURRENT_DATE + 1, TIME '14:00') NOT IN (SELECT m.room, m.floor_no, m.meeting_date, m.start_time FROM Meetings m);
    ASSERT (is_unbooked IS TRUE), 'Test 22 Failure';
    RAISE NOTICE 'Test 22 Success: Room 7-1 unbooked'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc23() AS $$
DECLARE
    meeting_exists BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 23 - unbook_room routine - No sabotage rule:';
    CALL unbook_room(10, 1, CURRENT_DATE + 5, TIME '14:00', TIME '16:00', 23); -- 23 is a senior from dept 10 but is NOT the booker
    SELECT m.booker_eid IS NOT NULL INTO meeting_exists
    FROM Meetings m
    WHERE m.room = 1
    AND m.floor_no = 10
    AND m.start_time = TIME '14:00'
    AND m.meeting_date = CURRENT_DATE + 5;
    ASSERT (meeting_exists IS FALSE), 'Test 23 Failure: The meeting was unbooked by an employee that did not book the meeting';
    EXCEPTION 
        WHEN sqlstate 'NOSBT' THEN
        RAISE NOTICE 'Test 23 Success: Employee 23 was unable to unbook a meeting that Employee 79 booked';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc24() AS $$
DECLARE
    free_rooms INTEGER;
BEGIN
    RAISE NOTICE 'Test 24 - search_room routine AFTER unbook_room:';
    SELECT COUNT(*) INTO free_rooms
    FROM search_room(5, CURRENT_DATE + 1, TIME '12:00', TIME '13:00');
    ASSERT (free_rooms = 10), 'Test 24 Failure: There should be 10 available rooms (As Room 7-1 was unbooked)';
    RAISE NOTICE 'Test 24 Success: Found 10 available rooms with capacity of at least 5 tomorrow from 12:00 to 13:00 after unbooking Room 7-1';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc25() AS $$
DECLARE
    half_meeting INTEGER;
    full_meeting INTEGER;
BEGIN
    RAISE NOTICE 'Test 25 - join_meeting routine';
    CALL join_meeting(2,1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 51);
    CALL join_meeting(2,1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 52);
    CALL join_meeting(2,1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 53);
    CALL join_meeting(2,1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 54);

    SELECT COUNT(*) INTO half_meeting -- There should be 5 entries from 12:00 to 13:00
    FROM Joins j
    WHERE j.floor_no = 2
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.start_time = TIME '12:00';

    SELECT COUNT(*) INTO full_meeting -- There should be 8 entries from 12:00 to 14:00
    FROM Joins j
    WHERE j.floor_no = 2
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.start_time >= TIME '12:00'
    AND j.start_time < TIME '14:00';

    ASSERT (half_meeting = 5 AND full_meeting = 8), 'Test 25 Failure: The number of people joining the meeting is wrong';
    RAISE NOTICE 'Test 25 Success: Employee 51 and 52 are joining Meeting Room 2-1 from 12:00 to 14:00 and Employee 53 and 53 are joining Meeting Room from 2-1 12:00 to 13:00'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc26() AS $$
DECLARE
    is_present INTEGER;
BEGIN
    RAISE NOTICE 'Test 26 - Constraint 36 Employee cannot join a meeting that is already at full capacity';
    CALL join_meeting(2, 1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 55);

    SELECT j.eid INTO is_present
    FROM Joins j
    WHERE j.floor_no = 2
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.start_time = TIME '12:00';

    ASSERT (is_present IS NULL), 'Test 26 Failure: Employee 55 was able to join a meeting room that is full';
    EXCEPTION 
        WHEN sqlstate 'FULLR' THEN
            RAISE NOTICE 'Test 26 Success: Employee 55 not able to join Meeting Room 2-1 from 12:00 to 13:00 because it is already at full capacity';
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc27() AS $$
DECLARE num_present INTEGER;
BEGIN
    RAISE NOTICE 'Test 27 - Constraint 37 Employee cannot join a meeting that they have already joined';
    CALL join_meeting(1, 1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 48);
    
    SELECT COUNT(*) INTO num_present
    FROM Joins J
    WHERE j.floor = 1
    AND j.room_no = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.eid = 48
    AND (j.start_time = TIME '12:00' OR j.start_time = TIME '13:00');
    ASSERT (num_present = 2), 'Test 27 Failure: Employee 48 joined Meeting Room 2-1 from 12:00 to 14:00 twice';
    EXCEPTION 
        WHEN sqlstate '23505' THEN 
            RAISE NOTICE 'Test 27 Success: Employee 48 not able to join Meeting Room 2-1 from 12:00 to 14:00 again as he had already joined the meeting';     
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc28() AS $$
DECLARE 
    num_joined INTEGER;
BEGIN
    RAISE NOTICE 'Test 28 - Constraint 26 Employees can only join future meetings';
    CALL join_meeting(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 74); -- Senior dept 5
    SELECT COUNT(eid) INTO num_joined
    FROM Joins j
    WHERE j.floor = 5
    AND j.room_no = 1
    AND j.meeting_date = CURRENT_DATE -1
    and j.start_time = TIME '12:00';
    ASSERT (num_joined = 1), 'Test case 28 Failure: Employee 74 able to join a past meeting';
    EXCEPTION
        WHEN sqlstate 'OJFMT' THEN 
            RAISE NOTICE 'Test 28 Success: Employee 74 could not join Meeting Room 5-1 from 12:00 to 13:00 as it is already over'; 
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc29() AS $$
DECLARE
    present INTEGER;
BEGIN
    RAISE NOTICE 'Test 29 - leave_meeting routine'; 
    CALL leave_meeting(2,1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 54);

    SELECT COUNT(*) INTO present
    FROM Joins j
    WHERE j.floor_no = 2
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.start_time >= TIME '12:00'
    AND j.start_time < TIME '13:00'
    AND j.eid = 54;

    ASSERT (present = 0), 'Test 29 Failure: Employee 54 should have left meeting 2-1';
    RAISE NOTICE 'Test 29 Success: Employee 54 successfully left Meeting 2-1 from 12:00 to 13:00'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc30() AS $$
DECLARE
approver_id_first_hour INTEGER;
approver_id_second_hour INTEGER;
BEGIN
    RAISE NOTICE 'Test 30 - approve_meeting routine:';
    CALL approve_meeting(2,1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 24); -- ID 24 is a Mananger in Department 2

    SELECT m.approver_eid INTO approver_id_first_hour
    FROM Meetings m
    WHERE m.floor_no = 2
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 1
    AND m.start_time = TIME '12:00';

    SELECT m.approver_eid INTO approver_id_second_hour
    FROM Meetings m
    WHERE m.floor_no = 2
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 1
    AND m.start_time = TIME '13:00';

    ASSERT
    (approver_id_first_hour IS NOT NULL AND approver_id_first_hour = 24 AND
    approver_id_second_hour IS NOT NULL AND approver_id_second_hour = 24),
    'Test 30 Failure: Meeting was not approved';
    RAISE NOTICE 'Test 30 Success: Employee 24 successfully approveed Meeting 2-1 from 12:00 to 14:00'; 
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc31() AS $$
DECLARE
num_approved INTEGER;
BEGIN
    RAISE NOTICE 'Test 31 - Constraint 20 Only managers can approve a booking:';
    
    CALL approve_meeting(3, 1, CURRENT_DATE + 2, TIME '12:00', TIME '14:00', 46); -- 46 is Junior in Dept 3
    
    SELECT COUNT(*) INTO num_approved
    FROM Meetings m
    WHERE m.floor_no = 3
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 1
    AND m.start_time >= TIME '12:00'
    AND m.start_time < TIME '14:00'
    AND m.approver_eid IS NOT NULL; 

    ASSERT (num_approved = 0), 'Test 31 Failure: Employee 46 approved meeting 3-1 12:00 to 14:00 despite being a junior';
    EXCEPTION
        WHEN sqlstate 'NOMGR' THEN 
            RAISE NOTICE 'Test 31 Success: Employee 46 could not approve a meeting as they are not a Manager'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc32() AS $$
DECLARE num_approved INTEGER;
BEGIN
    RAISE NOTICE 'Test 32 - Constraint 21 Only managers in the same department as the meeting room can approve the meeting';
    CALL approve_meeting(3, 1, CURRENT_DATE + 2, TIME '12:00', TIME '14:00', 27); -- Manager dept 2
    SELECT COUNT(*) INTO num_approved
    FROM Meetings m
    WHERE m.floor = 3
    AND m.room_no = 1
    AND m.meeting_date = CURRENT_DATE + 2
    AND approver_eid IS NOT NULL
    AND (m.start_time = TIME '12:00' OR m.start_time = TIME '13:00');
    ASSERT (num_approved = 0), 'Test 32 Failure: Manager 27 from department 2 was able to approve a meeting in Meeting Room 3-1 from department 3';
    EXCEPTION 
        WHEN sqlstate 'DIFFD' THEN
        RAISE NOTICE 'Test 32 Success: Employee 27 could not approve a meeting as they are not in the same department'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc33() AS $$
DECLARE
    approve_id INTEGER;
BEGIN
    RAISE NOTICE 'Test 33 - Constraint 22 A booked meeting is approved at most once:';
    CALL approve_meeting(2,1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 27); -- ID 27 is a Manager in Department 2
    SELECT m.approver_eid INTO approve_id
    FROM Meetings m
    WHERE m.floor_no = 2
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 1
    AND m.start_time = TIME '12:00';

    ASSERT (approve_id = 27), 'Test 33 Failure: Employee 27 was able to approve a meeting that was already approved';
    EXCEPTION 
        WHEN sqlstate '2APPR' THEN
        RAISE NOTICE 'Test 33 Success: Employee 27 was unable to approve Meeting 2-1 from 12:00 to 14:00 as it is already approved'; 
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc34() AS $$
DECLARE 
    is_approved BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 34 - Constraint 27 Manager can only approve future booking';
    CALL approve_meeting(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 15); -- Manager dept 5
    
    SELECT m.approver_eid IS NOT NULL INTO is_approved
    FROM Meetings m
    WHERE m.floor = 5
    AND m.room_no = 1
    AND m.meeting_date = CURRENT_DATE - 1
    AND m.start_time = TIME '12:00';
    ASSERT (is_approved IS FALSE), 'Test 34 Failure: Manager 15 was able to approve a past meeting';
    
    EXCEPTION 
        WHEN sqlstate 'OAFMT' THEN
            RAISE NOTICE 'Test 34 Success: Manager 15 was not able to approve a past meeting';  
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc35() AS $$
DECLARE
    meeting_exists INTEGER;
    participant_exists INTEGER;
BEGIN
    RAISE NOTICE 'Test 35 - A rejected meeting should be immediately deleted:';
    CALL join_meeting(10, 1, CURRENT_DATE + 5, TIME '14:00', TIME '16:00', 99); -- 99 is joining just to test the deletion
    CALL reject_meeting(10, 1, CURRENT_DATE + 5, TIME '14:00', TIME '16:00', 60); -- 60 is a manager in department 10

    SELECT COUNT(*) INTO meeting_exists
    FROM Meetings m 
    WHERE m.floor_no = 10
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 5
    AND m.start_time >= TIME '14:00'
    AND m.start_time < TIME '16:00';

    SELECT COUNT(*) INTO participant_exists
    FROM Joins j
    WHERE j.floor_no = 10
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 5
    AND j.start_time >= TIME '14:00' 
    AND j.start_time < TIME '16:00';


    -- Positive testing
    ASSERT (meeting_exists = 0 AND participant_exists = 0), 'Test 35 Failure: The meeting was not deleted OR the participant is still in the meeting';
    RAISE NOTICE 'Test 35 Success: Employee 60 rejected Meeting at 10-1, causing it and all its participants to be deleted'; 
    
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc_1() AS $$
BEGIN
    RAISE NOTICE 'Test 1 - :';
    -- Positive testing
    ASSERT <statement>, 'Test 1 Failure';
    RAISE NOTICE 'Test 1 Success: Description'; 
    -- Negative testing
    ASSERT (num_approved = 0), 'Test 1 Failed:'
    EXCEPTION 
        WHEN sqlstate 'CODE' THEN
        RAISE NOTICE 'Test 1 Success: Description';  
END
$$ LANGUAGE plpgsql;

-- 25 join
-- 26 join max capacity
-- 27 join cannot join twice
-- 28 join cannot join past meeting
-- 29 leave
-- 30 approve
-- 31 approve must be manager constraint 20
-- 32 approve must be same department constraint 21
-- 33 approve at most once constraint 22
-- 34 approve must be future booking constraint 27
-- 35 reject meeting is immediately deleted

-- 36 unbook after approve
-- 37 join after approve
-- 38 leave after approve no fever no resign
-- 39 leave can leave after approval if resigned
-- 



-- TESTS TO TEST
-- employees in a meeting that was unbooked are removed
-- if a meeting that was approved is unbook, remove the approval
-- 






-- REMOVE EMPLOYEE
-- CALL remove_employee(100, CURRENT_DATE);

-- ADD PHONE NUMBER
-- (Employee_ID, Number, Type)
--Success
CALL add_phone_number(1, 91234567 , 'Mobile');
CALL add_phone_number(1, 61234567 , 'Home');
-- --Fail (Ensure only one phone number of each type)
-- CALL add_phone_number(1, 61234567 , 'Home')

-- INSERT ROOMS
-- Success
-- (Room, Floor, Name, Capacity, Department ID, Manager ID)
CALL add_room(1, 1, 'Room 1-1', 5, 1, 2);
CALL add_room(1, 2, 'Room 1-2', 5, 1, 10);
CALL add_room(2, 1, 'Room 2-1', 5, 2, 75);
CALL add_room(3, 1, 'Room 3-1', 5, 3, 66);
CALL add_room(4, 1, 'Room 4-1', 5, 4, 71);
CALL add_room(5, 1, 'Room 5-1', 5, 5, 43);
CALL add_room(6, 1, 'Room 6-1', 5, 6, 58);
CALL add_room(7, 1, 'Room 7-1', 5, 7, 82);
CALL add_room(8, 1, 'Room 8-1', 5, 8, 39);
CALL add_room(9, 1, 'Room 9-1', 5, 9, 78);
CALL add_room(10, 1, 'Room 10-1', 5, 10, 79);
CALL add_room(10, 2, 'Room 10-2', 5, 10, 87);
CALL add_room(11, 1, 'Room 11-1', 6, 10, 87);
-- -- Fail (Non Manager)
-- CALL add_room(6, 2, 'Room 6-2', 5, 6, 100); --junior
-- CALL add_room(7, 2, 'Room 7-2', 5, 7, 99); --senior
-- CALL add_room(4, 2, 'Room 4-2', 5, 4, 98); --junior
-- -- Fail (Diff Dept)
-- CALL add_room(3, 1, 'Room 3-1', 5, 3, 2); --dept 1
-- CALL add_room(4, 2, 'Room 4-2', 5, 4, 10); --dept 1
-- CALL add_room(5, 1, 'Room 5-1', 5, 5, 75); --dept 2

-- BOOK ROOM
-- (Floor, Room, Date, Start Time, End Time, EID)
CALL book_room(1, 1, CURRENT_DATE, TIME '14:00', TIME '16:00', 48); -- Senior Dept 1
CALL book_room(1, 2, CURRENT_DATE, TIME '18:00', TIME '20:00', 79);

-- Invalid start/end time
--CALL book_room(1, 1, CURRENT_DATE, TIME '16:00', TIME '14:00', 48); -- Senior Dept 1

-- UPDATE CAPACITY
-- (Floor, Room, Date, Capacity, EID)
-- Success
CALL change_capacity(1, 1, CURRENT_DATE, 8, 2);
-- -- Fail (Not Manager)
-- CALL change_capacity(1, 1, CURRENT_DATE, 8, 3);
-- -- Fail (Wrong Department)
-- CALL change_capacity(1, 1, CURRENT_DATE, 8, 39);

-- DECLARE HEALTH
-- FIRST TEST (TESTING REMOVED FROM MEETINGS, )
CALL book_room(1, 2, CURRENT_DATE,  '18:00',  '20:00', 1);
CALL join_meeting(1, 2, CURRENT_DATE, '18:00', '20:00', 2);
CALL join_meeting(1, 2, CURRENT_DATE, '18:00', '20:00', 3);
CALL join_meeting(1, 2, CURRENT_DATE, '18:00', '20:00', 4);
CALL join_meeting(1, 2, CURRENT_DATE, '18:00', '20:00', 5);
CALL declare_health(2, CURRENT_DATE, 37.6); -- ONLY FEVER PERSON SHOULD BE REMOVED
CALL declare_health(1, CURRENT_DATE, 37.6); -- ENTIRE MEETING SHOULD BE CANCELLED
DELETE FROM Health_Declaration;

-- SECOND TEST (TESTING REMOVE CLOSE CONTACT FROM MEETINGS FOR NEXT 7 DAYS)
DELETE FROM Health_Declaration;
DELETE FROM Meetings;
CALL book_room(1, 2, CURRENT_DATE, '14:00',  '16:00', 3); -- Meeting 1
CALL join_meeting(1, 2, CURRENT_DATE,  '14:00',  '16:00', 1);
CALL join_meeting(1, 2, CURRENT_DATE,  '14:00',  '16:00', 2);
CALL join_meeting(1, 2, CURRENT_DATE,  '14:00',  '16:00', 4);
CALL join_meeting(1, 2, CURRENT_DATE,  '14:00',  '16:00', 5);
CALL approve_meeting(1, 2, CURRENT_DATE,  '14:00',  '16:00', 2); -- 2 is MANAGER of Dept 1
CALL book_room(2, 1, CURRENT_DATE + 3,  '12:00',  '14:00', 6); -- Meeting 2
CALL join_meeting(2, 1, CURRENT_DATE + 3,  '12:00',  '14:00', 2);
CALL join_meeting(2, 1, CURRENT_DATE + 3,  '12:00',  '14:00', 7); 
CALL join_meeting(2, 1, CURRENT_DATE + 3,  '12:00',  '14:00', 8);
CALL approve_meeting(2, 1, CURRENT_DATE + 3,  '12:00',  '14:00', 27); -- 27 is MANAGER of Dept 2
CALL declare_health(1, CURRENT_DATE, 37.6);
-- EID 2, 3, 4, 5 should be close contact
-- Meeting in Room 2-1 should NOT change as it in the past
-- EID 2 Should be removed from Meeting in Room 1-2

-- SEARCH ROOM
-- (capacity, date, start_time, end_time)
-- Success
SELECT * FROM search_room(5, CURRENT_DATE, CURRENT_TIME::TIME, CURRENT_TIME::TIME + interval '1 hour');
SELECT * FROM search_room(6, CURRENT_DATE, TIME '14:00', TIME '14:00' + interval '2 hours');

-- UNBOOK ROOM
-- (Floor, Room, Date, Start Time, End Time, EID)
-- Success
CALL unbook_room(1, 1, CURRENT_DATE, TIME '14:00', TIME '16:00', 48); -- Senior Dept 1
CALL unbook_room(1, 2, CURRENT_DATE, TIME '18:00', TIME '20:00', 79);

-- LEAVE MEETING
-- (Floor, Room, Date, Start Time, End Time, EID)
-- Success
CALL leave_meeting(1, 1, CURRENT_DATE, TIME '14:00', TIME '15:00', 55);

-- APPROVE MEETING
-- (floor no, room no, meeting date, start time, end time, approver_eid)
-- Success
CALL approve_meeting(1, 1, CURRENT_DATE, TIME '18:00', TIME '20:00', 2);
-- Fail (No Second Approval)
CALL approve_meeting(1, 1, CURRENT_DATE, TIME '18:00', TIME '20:00', 2);
-- Fail (Different Department)
CALL approve_meeting(1, 1, CURRENT_DATE, TIME '18:00', TIME '20:00', 71);
-- Fail (Not A Manager)
CALL approve_meeting(1, 1, CURRENT_DATE, TIME '18:00', TIME '20:00', 80);

-- REJECT MEETING
-- (floor no, room no, meeting_date, start_time, end_time, approver_eid)
-- CALL reject_meeting(1, 1, CURRENT_DATE, TIME '18:00', TIME '20:00', 48);

-- DECLARE HEALTH
-- Success
CALL declare_health(1, CURRENT_DATE, 37.1);
-- Trigger contact tracing
CALL declare_health(2, CURRENT_DATE, 39.9);

-- NON COMPLIANCE
CALL non_compliance(CURRENT_DATE, CURRENT_DATE + 1);


-- MANAGER LIST
-- EID DID
-- 2	1
-- 10	1
-- 17	1
-- 27	2
-- 75	2
-- 24	2
-- 44	3
-- 55	3
-- 28	3
-- 37	3
-- 66	3
-- 71	4
-- 43	5
-- 15	5
-- 58	6
-- 82	7
-- 25	8
-- 39	8
-- 78	9
-- 87	10
-- 60	10
-- 23	10
-- 79	10

-- SENIOR LIST
-- EID DID
-- 80	1
-- 86	1
-- 48	1
-- 95	1
-- 91	1
-- 41	2
-- 36	3
-- 3	4
-- 76	4
-- 33	4
-- 74	5
-- 38	5
-- 77	5
-- 30	6
-- 51	6
-- 52	6
-- 6	6
-- 72	6
-- 19	6
-- 99	7
-- 64	7
-- 65	8
-- 12	8
-- 81	9
-- 68	9
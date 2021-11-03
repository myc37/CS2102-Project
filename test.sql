-- BASIC FUNCTIONALITY TEST CASES

CREATE OR REPLACE PROCEDURE test_all() AS $$
BEGIN
    ALTER TABLE Updates DISABLE TRIGGER no_empty_updates;
    CALL reset_db();
    ALTER TABLE Updates ENABLE TRIGGER no_empty_updates;
    CALL basic_func();
    CALL core_func();
    CALL health_func();
    CALL admin_func();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE reset_db() AS $$
BEGIN
    ALTER TABLE Joins DISABLE TRIGGER valid_leave_meeting; 
    CALL delete_all();
    CALL clear_serial();
    ALTER TABLE Joins ENABLE TRIGGER valid_leave_meeting;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE basic_func() AS $$
BEGIN
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
    CALL add_employee('To be deleted', 12345678, 'Home', 'manager', 1);
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
        RAISE NOTICE 'Test 8 Success: Employee 101 has resigned';
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
        WHEN sqlstate '23503' THEN
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
    CALL tc36();
    CALL tc37();
    CALL tc38();
    CALL tc39();
    CALL tc40();
    CALL tc41();
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
    CALL tc16_1();
    CALL tc16_2();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc16_1() AS $$
BEGIN
    CALL declare_health(48, CURRENT_DATE, 36);
    CALL declare_health(75, CURRENT_DATE, 36);
    CALL declare_health(36, CURRENT_DATE, 36);
    CALL declare_health(79, CURRENT_DATE, 36);
    CALL declare_health(6, CURRENT_DATE, 36);
    CALL declare_health(82, CURRENT_DATE, 36);
    RAISE NOTICE 'Test 16.1 - book_room routine:';
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
    CALL book_room(6, 1, CURRENT_DATE + 6, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
    CALL book_room(6, 1, CURRENT_DATE + 14, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
    CALL book_room(7, 1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 82); -- Senior Dept 7 (To be deleted)
    -- booking a past meeting
    ALTER TABLE Meetings DISABLE TRIGGER booking_only_future;
    ALTER TABLE Joins DISABLE TRIGGER only_join_future_meetings;
    ALTER TABLE Meetings DISABLE TRIGGER no_declare_cannot_book;
    ALTER TABLE Joins DISABLE TRIGGER no_declare_cannot_join;
    CALL book_room(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 38); -- Senior dept 5
    CALL join_meeting(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 30);
    ALTER TABLE Joins ENABLE TRIGGER no_declare_cannot_join;
    ALTER TABLE Meetings ENABLE TRIGGER no_declare_cannot_book;
    ALTER TABLE Meetings ENABLE TRIGGER booking_only_future;
    ALTER TABLE Joins ENABLE TRIGGER only_join_future_meetings;
    -- booked a past meeting
    ASSERT ((SELECT COUNT(*) FROM Meetings) = 24), format('Test 16.1 Failure: There are %s instead of 24 meetings booked', (SELECT COUNT (*) FROM Meetings));
    RAISE NOTICE 'Test 16.1 Success: Database populated with 24 (10 x 2 hours + 4 x 1 hour) meetings'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc16_2() AS $$
BEGIN
    RAISE NOTICE 'Test 16.2 - book_room routine integrity checks (start_date must be before end_date)';
    CALL book_room(1, 1, CURRENT_DATE + 20, TIME '14:00', TIME '12:00', 48);
    RAISE NOTICE 'Test 16.2 Failure: Room was booked despite start_time being after end_time';
    EXCEPTION
        WHEN sqlstate 'SHAEH' THEN
        RAISE NOTICE 'Test 16.2 Success: Room was not booked as start_time was after end_time';

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
    CALL declare_health(32, CURRENT_DATE, 36);
    RAISE NOTICE 'Test 18 - Constraint 13 Junior cannot book a room';
    CALL book_room(1, 1, CURRENT_DATE + 4, TIME '12:00', TIME '14:00', 32); -- Junior Dept 1
    RAISE NOTICE 'Test 18 Failed: Junior could book a room.';
    EXCEPTION  
        WHEN sqlstate '23503' THEN
        RAISE NOTICE 'Test 18 Success: Junior with employee ID 32 is unable to book a room in department 1'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc19() AS $$
begin
    -- Initialization
    CALL book_room(1, 1, CURRENT_DATE + 1, TIME '14:00', TIME '15:00', 48); 
    CALL tc19_1();
    CALL tc19_2();
    CALL tc19_3();
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc19_1() AS $$
DECLARE 
    booker_id INTEGER;
BEGIN 
    RAISE NOTICE 'Test 19.1 - Constraint 15 Meeting room can only booked by one group for a given date and time';
    CALL declare_health(91, CURRENT_DATE, 36);
    CALL book_room(1, 1, CURRENT_DATE + 1, TIME '12:00', TIME '13:00', 91); -- Senior Dept 1
    SELECT m.booker_eid INTO booker_id
    FROM Meetings m
    WHERE m.room = 1
    AND m.floor_no = 1
    AND m.start_time = TIME '12:00'
    AND m.meeting_date = CURRENT_DATE + 1;
    ASSERT (booker_id = 48), 'Test 19.1 Failure: Booker ID should not have changed from 48';
    EXCEPTION 
        WHEN sqlstate 'INVMT' THEN
        RAISE NOTICE 'Test 19.1 Success: Room 1-1 cannot be booked by employee 91 as it has already been booked by employee 48';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc19_2() AS $$
DECLARE 
    meeting_exists BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 19.2 - Constraint 15 Checking if meeting can be booked in the middle of another meeting:';
    CALL book_room(1, 1, CURRENT_DATE + 1, TIME '12:01', TIME '14:01', 48); 
    SELECT EXISTS INTO meeting_exists (SELECT 1 FROM Meetings WHERE room = 1 AND floor_no = 1 AND meeting_date = CURRENT_DATE + 1 AND start_time = TIME '12:01' AND booker_eid = 48);
    ASSERT (meeting_exists IS FALSE), 'Test 19.2 Failure: Meeting should not have been booked in the middle of another meeting';
    EXCEPTION 
        WHEN sqlstate 'INVMT' THEN
        RAISE NOTICE 'Test 19.2 Success: Room 1-1 cannot be booked as it already has a meeting ongoing during that time';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc19_3() AS $$
DECLARE 
    meeting_exists BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 19.3 - Constraint 15 Checking if meeting can be booked in the middle of another meeting:';
    CALL book_room(1, 1, CURRENT_DATE + 1, TIME '10:00', TIME '12:00', 48); 
    SELECT EXISTS INTO meeting_exists (SELECT 1 FROM Meetings WHERE room = 1 AND floor_no = 1 AND meeting_date = CURRENT_DATE + 1 AND start_time = TIME '10:00' AND booker_eid = 48);
    ASSERT (meeting_exists IS TRUE), 'Test 19.3 Success: Meeting was booked as there are no clashes';
    EXCEPTION 
        WHEN sqlstate 'INVMT' THEN
        RAISE NOTICE 'Test 19.3 Failure: Meeting could not be booked despite having no clashes';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc20() AS $$
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
    CALL declare_health(51, CURRENT_DATE, 36);
    CALL declare_health(52, CURRENT_DATE, 36);
    CALL declare_health(53, CURRENT_DATE, 36);
    CALL declare_health(54, CURRENT_DATE, 36);
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
    RAISE NOTICE 'Test 26 - Constraint 35 Employee cannot join a meeting that is already at full capacity';
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
    RAISE NOTICE 'Test 27 - Constraint 36 Employee cannot join a meeting that they have already joined';
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
    CALL declare_health(74, CURRENT_DATE, 36);
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
    RAISE NOTICE 'Test 30 Success: Employee 24 successfully approved Meeting 2-1 from 12:00 to 14:00'; 
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
    CALL declare_health(99, CURRENT_DATE, 36);
    CALL declare_health(60, CURRENT_DATE, 36);
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

create or replace procedure tc36() as $$
begin
    RAISE NOTICE 'Test 36 - Constraint 23 Employee cannot join meeting after it is approved:';
    CALL join_meeting(2, 1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 64);
    RAISE NOTICE 'Test 36 Failure: Employee could join approved meeting';
    EXCEPTION 
        WHEN sqlstate 'JNAPR' THEN
        RAISE NOTICE 'Test 36 Success: Employee not allowed to join approved meeting';  
END
$$ LANGUAGE plpgsql;


CREATE OR replace procedure tc37() AS $$
DECLARE
    num_approved INTEGER;
BEGIN
    raise notice 'Test 37 - Constraint 34 Resigned employee cannot approve room';
    CALL approve_meeting(1, 1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 101);
    
    SELECT COUNT(*) INTO num_approved
    FROM Meetings m
    WHERE m.floor_no = 1
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 1
    AND m.approver_eid IS NOT NULL
    AND (m.start_time = TIME '12:00' OR m.start_time = TIME '13:00');
    
    ASSERT (num_approved = 0), 'Test 37 failure: Resigned Manager 101 is able to approve a meeting';
    EXCEPTION 
        WHEN sqlstate 'APPNR' THEN
        RAISE NOTICE 'Test 37 Success: Manager 101 has resigned and so is not able to approve meeting';  
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc38() AS $$
DECLARE
    join_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 38 - Resigning automatically removes the employee from future meetings:';

    CALL remove_employee(52, CURRENT_DATE); -- 52 is in an approved meeting 2-1

    SELECT COUNT(*) INTO join_count
    FROM Joins j
    WHERE j.floor_no = 2
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.start_time >= '12:00'
    AND j.start_time < '14:00'
    AND j.eid = 52;

    ASSERT (join_count = 0), 'Test 38 Failure: Employee 52 did not automatically leave the meeting after resigning';
    RAISE NOTICE 'Test 38 Success: Employee 52 automatically left approved future meeting 2-1 after resigning'; 
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc39() AS $$
DECLARE
    join_count INTEGER; 
BEGIN
    RAISE NOTICE 'Test 39 - Constraint 23 Employees should not be able to leave a meeting after it has been approved:';

    CALL leave_meeting(2, 1, CURRENT_DATE + 1, TIME '12:00', TIME '14:00', 51); -- 51 is in an approved meeting 2-1

    SELECT COUNT(*) INTO join_count
    FROM Joins j
    WHERE j.floor_no = 2
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 1
    AND j.start_time >= TIME '12:00'
    AND j.start_time < TIME '14:00'
    AND j.eid = 51;

    -- negative testing
    ASSERT (join_count = 2), 'Test 39 Failed: Employee 23 was able to leave an approved meeting with no valid reason';
    EXCEPTION
        WHEN sqlstate 'CNLVM' THEN
        RAISE NOTICE 'Test 39 Success: Employee 23 was unable to leave an approved meeting 2-1 as he has no valid reason';  
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc40() AS $$
DECLARE 
    join_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 40 - Employees cannot leave a past meeting';
    CALL leave_meeting(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 38);

    SELECT COUNT(*) INTO join_count
    FROM Joins
    WHERE j.floor_no = 5
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE - 1
    AND j.start_time = TIME '12:00'
    AND j.eid = 38;

    ASSERT (join_count = 1), 'Test 40 Failure: Employee 38 was able to leave a past meeting at Meeting Room 5-1 on the previous day';
    EXCEPTION
        WHEN sqlstate 'CNLVM' THEN
            RAISE NOTICE 'Test 40 Success: Employee 38 was unable to leave a past meeting at Meeting Room 5-1 on the previous day';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc41() AS $$
DECLARE 
    did_book BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 41 - Constraint 34 A resigned employee should not be able to book a room';
    
    CALL book_room(1, 1, CURRENT_DATE + 7, TIME '08:00', TIME '09:00', 101);

    SELECT (COUNT(*) > 0) INTO did_book
    FROM Meetings m
    WHERE m.floor_no = 1
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 7
    AND m.start_time = TIME '08:00'
    AND m.eid = 101;

    ASSERT (did_book IS FALSE), 'Test 41 Failed: Employee 101 has resigned but is still able to book a meeting at Meeting Room 1-1 one week later';
    EXCEPTION
        WHEN sqlstate 'BNFNR' THEN
            RAISE NOTICE 'Test 41 Success: Employee 101 has resigned and so is not able to book a meeting at Meeting Room 1-1 one week later
            ';
END
$$ LANGUAGE plpgsql;

-- Health

CREATE OR REPLACE PROCEDURE health_func() AS $$
BEGIN
    RAISE NOTICE 'HEALTH FUNCTIONALITY TESTS
    ';
    CALL tc42();
    CALL tc43();
    CALL tc44();
    CALL tc45();
    CALL tc46();
    CALL tc47();
    CALL tc48();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc42() AS $$
DECLARE
    has_fever_1 BOOLEAN;
    has_fever_23 BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 42 - declare_health routine:';

    CALL declare_health(1, CURRENT_DATE, 37.3); -- Employee 1 has no fever today
    CALL declare_health(23, CURRENT_DATE, 37.6); -- Employee 23 has a fever today

    SELECT (hd.temp > 37.5) INTO has_fever_1
    FROM Health_Declaration hd
    WHERE hd.eid = 1
    AND hd.hd_date = CURRENT_DATE;

    SELECT (hd.temp > 37.5) INTO has_fever_23
    FROM Health_Declaration hd
    WHERE hd.eid = 23
    AND hd.hd_date = CURRENT_DATE;

    ASSERT (has_fever_1 IS NOT NULL AND has_fever_23 IS NOT NULL), 'Test 42 Failure: Employees 1 and 23 were unable to declare their temperatures';
    RAISE NOTICE 'Test 42 Success: Employee 1 declared 37.3 degrees today and Employee 23 declared 37.6 degrees (fever) today'; 
    END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc43() AS $$ 
DECLARE 
    declaration_count INTEGER;
BEGIN
        RAISE NOTICE 'Test 43 - Can only declare health once a day';
        CALL declare_health(1, CURRENT_DATE, 37.3);
        
        SELECT COUNT(*) INTO declaration_count
        FROM Health_Declaration
        WHERE eid = 1
        AND hd_date = CURRENT_DATE;

        ASSERT declaration_count = 1, 'Test 43 Failure: Employee 1 was able to declare twice in a day';
        EXCEPTION
            WHEN sqlstate '23505' THEN
            RAISE NOTICE 'Test 43 Success: Employee 1 was not able to declare their temperature more than once';
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc44() AS $$
DECLARE 
    did_book BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 44 - Constraint 16 Employee having a fever cannot book room';
    CALL book_room(10, 1, CURRENT_DATE, TIME '08:00', TIME '09:00', 23); -- Manager dept 10
    
    SELECT (COUNT(*) > 0) INTO did_book
    FROM Meetings m
    WHERE m.floor_no = 10
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE
    AND m.start_time = TIME '08:00'
    AND m.eid = 23;

    ASSERT (did_book IS FALSE), 'Test 44 Failed: Employee 23 is having a fever but is still able to book a meeting at Meeting Room 10-1';
    EXCEPTION
        WHEN sqlstate 'BNFNR' THEN
            RAISE NOTICE 'Test 44 Success: Employee 23 is having a fever and so is not able to book a meeting at Meeting Room 10-1';  
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc45() AS $$
DECLARE
    join_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 45 - Constraint 19 Employee having a fever cannot join a booked meeting:';

    CALL join_meeting(10, 1, CURRENT_DATE + 3, TIME '14:00', TIME '16:00', 23); -- Employee 23 has a fever

    SELECT COUNT(*) INTO join_count
    FROM Joins j
    WHERE j.floor_no = 10
    AND j.room = 1
    AND j.meeting_date = CURRENT_DATE + 3
    AND j.start_time >= TIME '14:00'
    AND j.start_time < TIME '16:00'
    AND j.eid = 23;

    ASSERT (join_count = 0), 'Test 45 Failed: Employee 23 had a fever but could still join Meeting 10-1 on CURRENT_DATE + 3';
    EXCEPTION
        WHEN sqlstate 'FVRNJ' THEN
        RAISE NOTICE 'Test 45 Success: Employee 23 with a fever is unable to join Meeting 10-1';  
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc46() AS $$
DECLARE 
    employee1_hasFever BOOLEAN;
    employee23_hasFever BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 46 - Constraint 31 A health declaration with temperature greater than 37.5 is considered a fever:';

    SELECT hd.temp > 37.5 INTO employee1_hasFever
    FROM Health_Declaration hd
    WHERE hd.eid = 1
    AND hd.hd_date = CURRENT_DATE;

    SELECT hd.temp > 37.5 INTO employee23_hasFever
    FROM Health_Declaration hd
    WHERE hd.eid = 23
    AND hd.hd_date = CURRENT_DATE;

    ASSERT (employee1_hasFever IS FALSE AND employee23_hasFever IS TRUE
    ), 'Test 46 Failure: Employee 1 or employee 23 has wrong fever status';
    RAISE NOTICE 'Test 46 Success: Employee 1 declared 37.3 degrees today, thus has no fever. Employee 23 declared 37.6 degrees, thus has fever'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc47() AS $$
BEGIN
    CALL tc47_1();
    CALL tc47_2();
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE tc47_1() AS $$
DECLARE
    declare_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 47.1 - Constraint 32 Declare Temperature must be between 34 and 43 degrees (Below 34):';

    CALL declare_health(69, CURRENT_DATE, 33.9);

    SELECT COUNT(*) INTO declare_count
    FROM Health_Declaration hd
    WHERE hd.hd_date = CURRENT_DATE
    AND hd.eid = 69; 

    ASSERT (declare_count = 0), 'Test 47.1 Failed: Employee 69 was able to declare a temperature of 33.9';
    EXCEPTION
        WHEN sqlstate '23514' THEN
        RAISE NOTICE 'Test 47.1 Success: Employee 69 was unable to declare a temperature of 33.9 (Hypothermia)';  
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc47_2() AS $$
DECLARE
    declare_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 47.2 - Constraint 32 Declare Temperature must be between 34 and 43 degrees (Above 43):';

    CALL declare_health(69, CURRENT_DATE, 43.1);

    SELECT COUNT(*) INTO declare_count
    FROM Health_Declaration hd
    WHERE hd.hd_date = CURRENT_DATE
    AND hd.eid = 69; 

    ASSERT (declare_count = 0), 'Test 47.2 Failed: Employee 69 was able to declare a temperature of 43.1';
    EXCEPTION
        WHEN sqlstate '23514' THEN
        RAISE NOTICE 'Test 47.2 Success: Employee 69 was unable to declare a temperature of 43.1 (Hyperthermia)';  
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc48() AS $$
BEGIN
    CALL tc48_0();
    CALL tc48_1();
    CALL tc48_2();
    CALL tc48_3();
    CALL tc48_4();
    CALL tc48_5();
    CALL tc48_6();
    CALL tc48_7();
    CALL tc48_8();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc48_0() AS $$
DECLARE
    scenario_0_0 BOOLEAN;
    scenario_0_1 BOOLEAN;
    scenario_1 BOOLEAN;
    scenario_2 BOOLEAN;
    scenario_3 BOOLEAN;
    scenario_4 BOOLEAN;
    scenario_5 BOOLEAN;
    scenario_6 BOOLEAN;
    scenario_7 BOOLEAN;
    scenario_8 BOOLEAN;
BEGIN
    RAISE NOTICE 'Setup 48.0 - Creating scenarios for testing all the cases of contact tracing:';
    CALL declare_health(30, CURRENT_DATE, 36);
    ALTER TABLE Joins DISABLE TRIGGER no_declare_cannot_join;
    ALTER TABLE Meetings DISABLE TRIGGER no_declare_cannot_book;
    -- 0.0 is that employee 38 is in Past Meeting 5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00'
    SELECT j.eid IS NOT NULL INTO scenario_0_0
    FROM Joins j WHERE j.floor_no = 5 AND j.room = 1 AND j.meeting_date = CURRENT_DATE - 1 AND j.start_time = '12:00' AND j.eid = 38;

    -- 0.1 is that employee 30 is in Past Meeting 5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00' 
    SELECT j.eid IS NOT NULL INTO scenario_0_1
    FROM Joins j WHERE j.floor_no = 5 AND j.room = 1 AND j.meeting_date = CURRENT_DATE - 1 AND j.start_time = '12:00' AND j.eid = 30;

    -- 1. add employee 38 to future meeting more than +7 days BY CALL book_room(6, 1, CURRENT_DATE + 14, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
    CALL join_meeting(6, 1, CURRENT_DATE + 14, TIME '14:00', TIME '15:00', 38);
    SELECT j.eid IS NOT NULL INTO scenario_1
    FROM Joins j WHERE j.floor_no = 6 AND j.room = 1 AND j.meeting_date = CURRENT_DATE + 14 AND j.start_time = '14:00' AND j.eid = 38;

    -- 2. add employee 38 to future meeting less than +7 days BY CALL book_room(6, 1, CURRENT_DATE + 6, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
    CALL join_meeting(6, 1, CURRENT_DATE + 6, TIME '14:00', TIME '15:00', 38);
    SELECT j.eid IS NOT NULL INTO scenario_2
    FROM Joins j WHERE j.floor_no = 6 AND j.room = 1 AND j.meeting_date = CURRENT_DATE + 6 AND j.start_time = '14:00' AND j.eid = 38;

    -- 3. make employee 38 book a room in the future
    CALL book_room(5, 1, CURRENT_DATE + 20, TIME '14:00', TIME '15:00', 38);
    SELECT m.booker_eid IS NOT NULL AND m.booker_eid = 38 INTO scenario_3
    FROM Meetings m WHERE m.floor_no = 5 AND m.room = 1 AND m.meeting_date = CURRENT_DATE + 20 AND m.start_time = '14:00';

    -- 4. add employee 30 to future meeting more than +7 days BY CALL book_room(6, 1, CURRENT_DATE + 14, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6 
    CALL join_meeting(6, 1, CURRENT_DATE + 14, TIME '14:00', TIME '15:00', 30);
    SELECT j.eid IS NOT NULL INTO scenario_4
    FROM Joins j WHERE j.floor_no = 6 AND j.room = 1 AND j.meeting_date = CURRENT_DATE + 14 AND j.start_time = '14:00' AND j.eid = 30;

    -- 5. add employee 30 to future meeting less than +7 days BY CALL book_room(6, 1, CURRENT_DATE + 6, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
    CALL join_meeting(6, 1, CURRENT_DATE + 6, TIME '14:00', TIME '15:00', 30);
    SELECT j.eid IS NOT NULL INTO scenario_5
    FROM Joins j WHERE j.floor_no = 6 AND j.room = 1 AND j.meeting_date = CURRENT_DATE + 6 AND j.start_time = '14:00' AND j.eid = 30;

    -- 6. make employee 30 book a room less than +7 days
    CALL book_room(6, 1, CURRENT_DATE + 5, TIME '14:00', TIME '15:00', 30);
    SELECT m.booker_eid IS NOT NULL AND m.booker_eid = 30 INTO scenario_6
    FROM Meetings m WHERE m.floor_no = 6 AND m.room = 1 AND m.meeting_date = CURRENT_DATE + 5 AND m.start_time = '14:00';

    -- 7. make employee 30 book a room more than +7 days
    CALL book_room(6, 1, CURRENT_DATE + 8, TIME '14:00', TIME '15:00', 30);
    SELECT m.booker_eid IS NOT NULL AND m.booker_eid = 30 INTO scenario_7
    FROM Meetings m WHERE m.floor_no = 6 AND m.room = 1 AND m.meeting_date = CURRENT_DATE + 8 AND m.start_time = '14:00';

    -- 8. approve past meeting 
    ALTER TABLE Meetings DISABLE TRIGGER only_approve_future_meetings;
    CALL approve_meeting(5, 1, CURRENT_DATE - 1, TIME '12:00', TIME '13:00', 15); -- 15 is Manager from Department 5
    ALTER TABLE Meetings ENABLE TRIGGER only_approve_future_meetings;

    SELECT approver_eid IS NOT NULL INTO scenario_8
    FROM Meetings m WHERE m.floor_no = 5 AND m.room = 1 AND m.meeting_date = CURRENT_DATE - 1 AND m.start_time = '12:00';

    ASSERT (scenario_0_0 IS TRUE), 'Setup 48.0.0.0 Failed: Employee 38 is NOT in Past Meeting 5-1, Current_Date - 1';
    ASSERT (scenario_0_1 IS TRUE), 'Setup 48.0.0.1 Failed: Employee 30 iS NOT in Past Meeting 5-1, Current_Date - 1';
    ASSERT (scenario_1 IS TRUE), 'Setup 48.0.1 Failed: Employee 38 is NOT in Future Meeting 6-1, Current_Date + 14';
    ASSERT (scenario_2 IS TRUE), 'Setup 48.0.2 Failed: Employee 38 is NOT in Future Meeting 6-1, Current_Date + 6';
    ASSERT (scenario_3 IS TRUE), 'Setup 48.0.3 Failed: Employee 38 did NOT book a Future Meeting 5-1, Current_Date + 20';
    ASSERT (scenario_4 IS TRUE), 'Setup 48.0.4 Failed: Employee 30 is NOT in Future Meeting 6-1, Current_Date + 14';
    ASSERT (scenario_5 IS TRUE), 'Setup 48.0.5 Failed: Employee 30 is NOT in Future Meeting 6-1, Current_date + 6';
    ASSERT (scenario_6 IS TRUE), 'Setup 48.0.6 Failed: Employee 30 did NOT book a Future Meeting 6-1, Current_Date + 6';
    ASSERT (scenario_7 IS TRUE), 'Setup 48.0.7 Failed: Employee 30 did NOT book a Future Meeting 6-1, Current_Date + 8'; 
    ASSERT (scenario_8 IS TRUE), 'Setup 48.0.8 Failed: Past meeting has not been approved'; 
    RAISE NOTICE 'Setup 48.0 Success: Scenarios successfully set up to test contact tracing';

    ALTER TABLE Joins ENABLE TRIGGER no_declare_cannot_join;
    ALTER TABLE Meetings ENABLE TRIGGER no_declare_cannot_book;

END;
$$ LANGUAGE plpgsql;

--syntax ok
CREATE OR REPLACE PROCEDURE tc48_1() AS $$
DECLARE 
    num_contacts INTEGER;
    is_contact_30 BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 48.1 - Declaring fever for Employee 38';
    CALL declare_health(38, CURRENT_DATE, 38.1);

    SELECT COUNT(*) INTO num_contacts
    FROM (SELECT * FROM contact_tracing(38)) a;
    
    is_contact_30 := (30 IN (SELECT close_contact_eid FROM contact_tracing(38)));
    
    ASSERT (num_contacts = 1), 'Test 48.1 Failure, Employee 30 is not the only close contact of Employee 38';
    ASSERT (is_contact_30 IS TRUE), 'Test 48.1 Failure, Employee 30 is not a close contact of Employee 38';
    RAISE NOTICE 'Test 48.1 Success, Employee 30 is the only close contact of Employee 38';
END
$$ LANGUAGE plpgsql;

--syntax ok
CREATE OR REPLACE PROCEDURE tc48_2() AS $$
DECLARE 
    person_count INTEGER; 
BEGIN
    RAISE NOTICE 'Test 48.2 Employee 38 and 30 should still be in past meeting';
    
    SELECT COUNT(*) INTO person_count
    FROM Joins
    WHERE meeting_date = CURRENT_DATE - 1
    AND start_time = (TIME '12:00')
    AND floor_no = 5
    AND room = 1
    AND (eid = 30 OR eid = 38);    

    ASSERT (person_count = 2), 'Test Failure: Employee 38 and 30 should still be in past meeting after contact tracing';
    RAISE NOTICE 'Test 48.2 Success: Both employee 38 and 30 are still in past meeting after contact tracing';
END
$$ LANGUAGE plpgsql;

--syntax ok
CREATE OR REPLACE PROCEDURE tc48_3() AS $$
DECLARE future_meeting_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 48.3 - Constraint 37 Employee with fever should leave all future meetings:';
    SELECT COUNT(*) INTO future_meeting_count FROM Joins 
    WHERE ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE)) 
    AND eid = 38;
    ASSERT (future_meeting_count = 0), 'Test 48.3 Failure: Employee is still present in future meetings';
    RAISE NOTICE 'Test 48.3 Success: Employee 38 has left all future meetings due to a fever'; 
END
$$ LANGUAGE plpgsql;

-- fever should unbook future meetings, regardless if approved or not
--syntax ok
CREATE OR REPLACE PROCEDURE tc48_4() AS $$
DECLARE future_booked_rooms INTEGER;
BEGIN
    RAISE NOTICE 'Test 48.4 - Constraint 38 Employee with a fever should have all their future meetings unbooked:';
    SELECT COUNT(*) INTO future_booked_rooms FROM Meetings 
    WHERE booker_eid = 38 AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE)); 
    ASSERT (future_booked_rooms = 0), 'Test 48.4 Failure: There are still future meetings booked by an employee with fever';
    RAISE NOTICE 'Test 48.4 Success: Employee 38 has had all their future meetings unbooked due to a fever'; 
END
$$ LANGUAGE plpgsql;

-- 48.5 employee 30 should leave future meeting less than +7 days
--syntax ok
CREATE OR REPLACE PROCEDURE tc48_5() AS $$
DECLARE next_seven_days_meetings INTEGER;
BEGIN
    RAISE NOTICE 'Test 48.5 - Close Contacts should leave meeting in the next 7 days:';
    SELECT COUNT(*) INTO next_seven_days_meetings FROM Joins 
    WHERE eid = 30
    AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR meeting_date > CURRENT_DATE)
    AND meeting_date <= CURRENT_DATE + 7;
    ASSERT (next_seven_days_meetings = 0), 'Test 48.5 Failure: Employee is still in a meeting in the next 7 days despite being a close contact';
    RAISE NOTICE 'Test 48.5 Success: Employee 30 has been removed from meetings for the next 7 days'; 
END
$$ LANGUAGE plpgsql;

-- 48.6 employee 30 should NOT leave future meeting more than +7 days
--syntax ok
CREATE OR REPLACE PROCEDURE tc48_6() AS $$
DECLARE joined_meetings_after_seven_days INTEGER;
BEGIN
    RAISE NOTICE 'Test 48.6 - Close Contacts should not leave meetings happening more than 7 days away';
    SELECT COUNT(*) INTO joined_meetings_after_seven_days FROM Joins
    WHERE eid = 30
    AND room = 1
    AND floor_no = 6
    AND meeting_date = CURRENT_DATE + 14
    AND start_time = TIME '14:00';
    ASSERT (joined_meetings_after_seven_days = 1), format('Test 48.6 Failure: Employee 30 left meetings happening more than 7 days away. %s',joined_meetings_after_seven_days );
    RAISE NOTICE 'Test 48.6 Success: Employee 30 has not left meeting happening more than 7 days away'; 
END
$$ LANGUAGE plpgsql;

--syntax ok
CREATE OR REPLACE PROCEDURE tc48_7() AS $$
DECLARE meetings_in_seven_days INTEGER;
BEGIN
    RAISE NOTICE 'Test 48.7 - Meetings booked by close contacts in the next 7 days should be removed';
    SELECT COUNT(*) INTO meetings_in_seven_days FROM Meetings 
    WHERE booker_eid = 30
    AND ((meeting_date = CURRENT_DATE AND start_time > CURRENT_TIME) OR (meeting_date > CURRENT_DATE))
    AND (meeting_date <= CURRENT_DATE + 7);
    ASSERT (meetings_in_seven_days = 0), 'Test 48.7 Failure: Close Contact Employee 30 still has meetings booked in the next 7 days';
    RAISE NOTICE 'Test 48.7 Success: Employee 30 has had all their meetings unbooked for the next 7 days due to close contact'; 
END
$$ LANGUAGE plpgsql;

--syntax ok
CREATE OR REPLACE PROCEDURE tc48_8() AS $$
DECLARE 
    e30_meetings_after_seven_days INTEGER;
BEGIN
 
    RAISE NOTICE 'Test 48.8 - Employee 30 should not have their future bookings after 7 days deleted';

    SELECT COUNT(*) INTO e30_meetings_after_seven_days 
    FROM Meetings
    WHERE booker_eid = 30
    AND meeting_date > CURRENT_DATE + 7;
    
    ASSERT (e30_meetings_after_seven_days != 0), 'Test 48.8 Failure: Employee 30 had their meetings after seven days unbooked';
    RAISE NOTICE 'Test 48.8 Success: Employee 30 did not have their meetings unbooked after 7 days
    '; 
END
$$ LANGUAGE plpgsql;

-- Admin
CREATE OR REPLACE PROCEDURE admin_func() AS $$
BEGIN
    RAISE NOTICE 'ADMIN FUNCTIONALITY TESTS
    ';
    CALL tc49();
    CALL tc50();
    CALL tc51();
    CALL tc52();
    CALL tc53();
    CALL tc54();
    CALL tc55();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc49() AS $$
BEGIN
    CALL tc49_1();
    CALL tc49_2();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc49_1() AS $$
DECLARE non_compliance_count INTEGER;
BEGIN
    -- Currently on 1, 23, 38 has declared temperature on CURRENT_DATE, 2 is resigned
    -- Should have 96 entries in non_compliance for CURRENT_DATE
    RAISE NOTICE 'Test 49.1 - Non Compliance Functionality for Current Date:';
    -- positive testing
    SELECT COUNT(*) INTO non_compliance_count FROM non_compliance(CURRENT_DATE, CURRENT_DATE);
    ASSERT (non_compliance_count = 96), format('Test 49.1 Failure: Only %s employees were flagged for non-compliance on current date when it should have been 96', non_compliance_count);
    RAISE NOTICE 'Test 49.1 Success: One Day Non Compliance Successful and 96 employees were flagged for non-compliance'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc49_2() AS $$

DECLARE e23_compliance_count INTEGER;

DECLARE e91_compliance_count INTEGER;
BEGIN
    -- Set-up for Non Compliance Testing
    ALTER TABLE Health_Declaration DISABLE TRIGGER no_future_hd;
    CALL declare_health(1, CURRENT_DATE + 1, 35.2);
    CALL declare_health(1, CURRENT_DATE + 2, 36.6);
    CALL declare_health(1, CURRENT_DATE + 3, 35.6);
    CALL declare_health(23, CURRENT_DATE + 1, 35.6);
    CALL declare_health(23, CURRENT_DATE + 2, 35.6);
    ALTER TABLE Health_Declaration ENABLE TRIGGER no_future_hd;
    RAISE NOTICE 'Test 49.2 - Non Compliance Functionality for Multiple Dates';   
    SELECT number_of_days INTO e23_compliance_count FROM non_compliance(CURRENT_DATE, CURRENT_DATE + 3) WHERE employee_id = 23;
    SELECT number_of_days INTO e91_compliance_count FROM non_compliance(CURRENT_DATE, CURRENT_DATE + 3) WHERE employee_id = 91;
    ASSERT ('1' NOT IN (SELECT employee_id FROM non_compliance(CURRENT_DATE, CURRENT_DATE + 3))), 'Test 49.2 Failure: Employee 1 has an entry in table when it should not';
    ASSERT (e23_compliance_count = 1), format('Test 49.2 Failure: Non Compliance Count for Employee %s should have been %s but it is %s', 23, 1, e23_compliance_count);
    ASSERT (e91_compliance_count =  3), format('Test 49.2 Failure: Non Compliance Count for Employee %s should have been %s but it is %s', 91, 3, e91_compliance_count);
    RAISE NOTICE 'Test 49.2 Success: Non Compliance Successful and all employees have correct non compliance count'; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc50() AS $$
DECLARE
    e48_current_count INTEGER;
    e48_future_count INTEGER;
    e38_past_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 50 - View booking report functionality';
    SELECT COUNT(*) INTO e48_current_count
    FROM view_booking_report(CURRENT_DATE, 48);
    SELECT COUNT(*) INTO e48_future_count
    FROM view_booking_report(CURRENT_DATE + 2, 48);
    SELECT COUNT(*) INTO e38_past_count 
    FROM view_booking_report(CURRENT_DATE, 38);
    ASSERT (e48_current_count = 11), format('Test 50 Failure: Number of booked meetings from CURRENT_DATE for Employee %s should have been %s but it is %s', 48, 11, e48_current_count);
    ASSERT (e48_future_count = 4), format('Test 50 Failure: Number of booked meetings from CURRENT_DATE + 2 for Employee %s should have been %s but it is %s', 48, 4, e48_future_count);
    ASSERT (e38_past_count = 0), format('Test 50 Failure: Number of booked meetings from CURRENT_DATE for Employee %s should have been %s but it is %s', 38, 0, e38_past_count);
    RAISE NOTICE 'Test 50 Success: View booking report successfully shows all booked meetings of Employee from given start date';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc51() AS $$
DECLARE
    e75_current_count INTEGER;
    e75_future_count INTEGER;
    e38_past_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 51 - View future meeting functionality';
    SELECT COUNT(*) INTO e75_current_count
    FROM view_future_meeting(CURRENT_DATE, 75);
    SELECT COUNT(*) INTO e75_future_count
    FROM view_future_meeting(CURRENT_DATE + 2, 75);
    SELECT COUNT(*) INTO e38_past_count 
    FROM view_future_meeting(CURRENT_DATE, 38);
    ASSERT (e75_current_count = 2), format('Test 51 Failure: Number of approved future meetings from CURRENT_DATE for Employee %s should have been %s but it is %s', 75, 2, e48_current_count);
    ASSERT (e75_future_count = 0), format('Test 51 Failure: Number of approved future meetings from CURRENT_DATE + 2 for Employee %s should have been %s but it is %s', 75, 0, e48_future_count);
    ASSERT (e38_past_count = 0), format('Test 51 Failure: Number of approved future meetings from CURRENT_DATE for Employee %s should have been %s but it is %s', 38, 0, e38_past_count);
    RAISE NOTICE 'Test 51 Success: View future meeting successfully shows all approved future meetings of Employee from given start date';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc52() AS $$
BEGIN
    CALL tc52_1();
    CALL tc52_2();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc52_1() AS $$
DECLARE
    e2_current_count INTEGER;
    e2_future_count INTEGER;
    e43_past_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 52.1 - View manager report functionality';
    SELECT COUNT(*) INTO e2_current_count
    FROM view_manager_report(CURRENT_DATE, 2); -- manager dept 1;
    SELECT COUNT(*) INTO e2_future_count
    FROM view_manager_report(CURRENT_DATE + 2, 2); -- manager dept 1;
    SELECT COUNT(*) INTO e43_past_count
    FROM view_manager_report(CURRENT_DATE, 43); -- manager dept 5
    ASSERT (e2_current_count = 9), format('Test 52.1 Failure: Number of meetings to approve from CURRENT DATE for Manager %s should be %s but is %s', 2, 9, e2_current_count);
    ASSERT (e2_future_count = 4), format('Test 52.1 Failure: Number of meetings to approve from CURRENT DATE + 2 for Manager %s should be %s but is %s', 2, 6, e2_future_count);
    ASSERT (e43_past_count = 0), format('Test 52.1 Failure: Number of meetings to approve from CURRENT DATE for Manager %s should be %s but is %s', 43, 0, e43_past_count);
    RAISE NOTICE 'Test 52.1 Success: View manager report successfully shows all meetings to approve for a Manager from CURRENT_DATE onwards';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc52_2() AS $$
DECLARE
    appr_count INTEGER;
BEGIN
    RAISE NOTICE 'Test 52.2 - Constraint 40 Only a Manager can view manager report';
    SELECT COUNT(*) INTO appr_count
    FROM view_manager_report(CURRENT_DATE, 80); -- senior dept 1
    ASSERT (appr_count = 0), format('Test 52.2 Failure: Number of meetings to approve from CURRENT DATE for Non-managers should be 0 but is %s', appr_count);
    EXCEPTION 
        WHEN sqlstate 'NOMGR' THEN
            RAISE NOTICE 'Test 52.2 Success: Non-manager Employee 80 not able to view manager report';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc53() AS $$
DECLARE
num_meetings INTEGER;
BEGIN
    RAISE NOTICE 'Test 53 - Constraint 41 When a meeting room has its capacity changed, any room booking after the change date with more participants will automatically be removed.';
    CALL change_capacity(2, 1, CURRENT_DATE, 2, 27);

    SELECT COUNT(*) INTO num_meetings
    FROM Meetings m
    WHERE m.floor_no = 2
    AND m.room = 1
    AND m.meeting_date = CURRENT_DATE + 1
    AND m.start_time = TIME '12:00';

    ASSERT (num_meetings = 0), format('Test 53 Failure: Meeting in Room 2-1 should have been cancelled as the participants (3) is greater than the new capacity (2). Meet count %s',num_meetings);
    RAISE NOTICE 'Test 53 Success: After Room 2-1 capacity was reduced from 5 to 2, the meeting was cancelled as it had 3 participants';
END
$$ LANGUAGE plpgsql;

-- Additional Triggers
CREATE OR REPLACE PROCEDURE health_func() AS $$
BEGIN
    RAISE NOTICE 'HEALTH FUNCTIONALITY TESTS
    ';
    CALL tc42();
    CALL tc43();
    CALL tc44();
    CALL tc45();
    CALL tc46();
    CALL tc47();
    CALL tc48();
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc54() AS $$
DECLARE 
    joined_meeting BOOLEAN;
BEGIN
    RAISE NOTICE 'Test 54 - no_declare_cannot_join If an employee has not declared health today, they cannot join a meeting';
    CALL join_meeting(1, 1, CURRENT_DATE + 1, TIME '12:00', '14:00', 19);
    SELECT INTO joined_meeting EXISTS (SELECT * FROM Joins j WHERE j.room = 1 AND j.floor_no = 1 AND meeting_date = CURRENT_DATE + 1 and start_time = TIME '12:00' AND eid = 19);
    ASSERT(joined_meeting IS FALSE), 'Test 54 Failure: Employee was able to join meeting despite not having declared health today';
    EXCEPTION
        WHEN sqlstate 'NHDNJ' THEN
            RAISE NOTICE 'Test 54 Success: Employee could not join meeting as they did not declare health';
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE tc55() AS $$
DECLARE
    booked_meeting BOOLEAN;
BEGIN
    CALL join_meeting(1, 1, CURRENT_DATE + 1, TIME '12:00', '14:00', 19);
    SELECT INTO booked_meeting EXISTS (SELECT * FROM Meetings m WHERE m.room = 1 AND j.floor_no = 1 AND meeting_date = CURRENT_DATE + 9 and start_time = TIME '12:00' AND eid = 19);
    ASSERT (booked_meeting IS FALSE), 'Test 55 Failure: Employee 38 was able to book a meeting in Meeting Room 1-1 on CURRENT_DATE + 1 despite not declaring health';
    EXCEPTION 
        WHEN sqlstate 'NHDNB' THEN
            RAISE NOTICE 'Test 55 Success: Employee 38 could not book a meeting in Meeting Room 1-1 on CURRENT_DATE + 1 as they did not declare health';
END
$$ LANGUAGE plpgsql

-- Past Meeting: 5-1 Current_Date - 1 '12:00' - '13:00'
-- Book Room: 38 Senior Dept 5
-- Join Meeting: 30 Senior Dept 6

-- 48.0 setup:

-- 1. add employee 38 to future meeting more than +7 days  CALL book_room(6, 1, CURRENT_DATE + 14, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
-- 2. add employee 38 to future meeting less than +7 days  CALL book_room(6, 1, CURRENT_DATE + 6, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
-- 3. make employee 38 book a room in the future
-- 4. add employee 30 to future meeting more than +7 days  CALL book_room(6, 1, CURRENT_DATE + 14, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6 
-- 5. add employee 30 to future meeting less than +7 days  CALL book_room(6, 1, CURRENT_DATE + 6, TIME '14:00', TIME '15:00', 6); -- Senior Dept 6
-- 6. make employee 30 book a room less than +7 days
-- 7. make employee 30 book a room more than +7 days

-- 48.1 declare fever on employee 38. contact_tracing is called on 38 and should return Employee 30
-- 48.2 employee 38 and 30 should still be in past meeting
-- 48.3 employee 38 should leave BOTH future meetings
-- 48.4 employee 38's future booking should be gone
-- 48.5 employee 30 should leave future meeting less than +7 days
-- 48.6 employee 30 should NOT leave future meeting more than +7 days
-- 48.7 employee 30's future booking less than +7 days should be gone
-- 48.8 employee 30's future booking more than +7 days should still remain



-- CREATE OR REPLACE PROCEDURE tc1() AS $$
-- BEGIN
--     RAISE NOTICE 'Test 1 -:';
--     -- positive testing
--     ASSERT <statement>, 'Test 1 Failure';
--     RAISE NOTICE 'Test 1 Success: description'; 
--     -- negative testing
--     ASSERT (num_approved = 0), 'Test 1 Failed:'
--     EXCEPTION
--         WHEN sqlstate 'code' THEN
--         RAISE NOTICE 'Test 1 Success: Description';  
-- END
-- $$ LANGUAGE plpgsql;



-- TESTS TO TEST
-- employees in a meeting that was unbooked are removed
-- if a meeting that was approved is unbook, remove the approval
-- 








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
-- 68	n
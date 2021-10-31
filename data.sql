CALL delete_all();
CALL clear_serial();

-- INSERT 10 DEPARTMENTS
-- (Department ID, Department Name)
--Success
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
-- --Fail (PK DID)
-- CALL add_department(1, 'Marketing'); 

-- REMOVE DEPARTMENTS
CALL remove_department(11);

-- INSERT 100 EMPLOYEES
-- (Employee name, Phone number, Phoen type, Kind, Department ID)
CALL add_employee('Adel Stannislawski', 44898478, 'Office', 'junior', 2);
CALL add_employee('Kleon Delve', 46379749, 'Mobile', 'manager', 1);
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
CALL add_employee('Lea Church', 54850716, 'Home', 'senior', 4);
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

-- REMOVE EMPLOYEE
CALL remove_employee(100, CURRENT_DATE);

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

-- Update Capacity
-- (Floor, Room, Date, Capacity, EID)
-- Success
CALL change_capacity(1, 1, CURRENT_DATE, 8, 2);
-- -- Fail (Not Manager)
-- CALL change_capacity(1, 1, CURRENT_DATE, 8, 3);
-- -- Fail (Wrong Department)
-- CALL change_capacity(1, 1, CURRENT_DATE, 8, 39);


-- Declare Health


-- Search Room
-- capacity, date, start_time, end_time
SELECT * FROM search_room(5, CURRENT_DATE, CURRENT_TIME::TIME, CURRENT_TIME::TIME + interval '1 hour');

SELECT *
FROM search_room(6, CURRENT_DATE, TIME '14:00', TIME '14:00' + interval '2 hours');







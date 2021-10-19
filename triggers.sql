--- Enforces the ISA No Overlap Constraint between Junior and Booker

CREATE FUNCTION junior_not_booker() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN 
	SELECT COUNT(eid) INTO count FROM Booker WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN 
        RAISE NOTICE 'Error: Employee is already a Booker, cannot be a Junior'; 
		RETURN NULL;
	ELSE 
		RETURN NEW;
	ENDIF
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER junior_ISA
BEFORE INSERT OR UPDATE ON Junior
FOR EACH ROW EXECUTE FUNCTION junior_not_booker();

--- Enforces the ISA No Overlap Constraint between Junior and Booker

CREATE FUNCTION booker_not_junior() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN
	SELECT COUNT(eid) INTO count FROM Junior WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN
        RAISE NOTICE 'Error: Employee is already a Junior, cannot be a Booker'
		RETURN NULL;
	ELSE
		RETURN NEW;
	ENDIF
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER booker_ISA
BEFORE INSERT ON Booker
FOR EACH ROW EXECUTE FUNCTION booker_not_junior();

---

CREATE FUNCTION senior_not_manager() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN
	SELECT COUNT(eid) INTO count FROM Manager WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN
        RAISE NOTICE 'Error: Employee is already a Manager, cannot be a Senior'
		RETURN NULL;
	ELSE
		RETURN NEW;
	ENDIF
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER senior_ISA
BEFORE INSERT ON Senior 
FOR EACH ROW EXECUTE FUNCTION senior_not_manager();

---

CREATE FUNCTION manager_not_senior() RETURNS TRIGGER AS $$
DECLARE
	count INTEGER;
BEGIN
	SELECT COUNT(eid) INTO count FROM Senior WHERE eid = NEW.eid;
	IF (COUNT > 0) THEN
        RAISE NOTICE 'Error: Employee is already a Senior, cannot be a Manager'
		RETURN NULL;
	ELSE
		RETURN NEW;
	ENDIF
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER manager_ISA
BEFORE INSERT ON Manager
FOR EACH ROW EXECUTE FUNCTION manager_not_senior();

---
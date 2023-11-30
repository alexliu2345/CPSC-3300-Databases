/*
	Airline System
    
*/

-- Use my database
use km_aliu1;

/*
  Drop Tables so the database starts fresh
*/

	-- Drop existence dependent tables
	DROP TABLE IF EXISTS CHANGES;
    DROP TABLE IF EXISTS MANIFEST;
	DROP TABLE IF EXISTS FLIGHT;

	-- Drop remaining entities
    DROP TABLE IF EXISTS MODIFICATION;
	DROP TABLE IF EXISTS PASSENGER;
	DROP TABLE IF EXISTS DESTINATION;
	DROP TABLE IF EXISTS PLANE;

/* 
	Create Tables
*/

	-- Create PLANE table
	CREATE TABLE IF NOT EXISTS PLANE(
		PLANE_ID INT AUTO_INCREMENT PRIMARY KEY,
		PLANE_NAME VARCHAR(25) NOT NULL UNIQUE,
		PLANE_MODEL VARCHAR(25) NOT NULL,
		PLANE_ROWS INT,
		PLANE_COLUMNS INT
	);

	-- Create PASSENGER table
	CREATE TABLE IF NOT EXISTS PASSENGER(
		PASSENGER_ID INT AUTO_INCREMENT PRIMARY KEY,
		PASSENGER_NAME_FIRST VARCHAR(25) NOT NULL,
		PASSENGER_NAME_LAST VARCHAR(25) NOT NULL
	);

	-- Create DESTINATION table
	CREATE TABLE IF NOT EXISTS DESTINATION(
		DESTINATION_ID INT AUTO_INCREMENT PRIMARY KEY,
		DESTINATION_CODE CHAR(3) NOT NULL UNIQUE,
		DESTINATION_NAME VARCHAR(25) NOT NULL
	);

	-- Create FLIGHT table
	CREATE TABLE IF NOT EXISTS FLIGHT(
		FLIGHT_ID INT AUTO_INCREMENT PRIMARY KEY,
		PLANE_ID INT,
		DESTINATION_ID INT,
		FLIGHT_DATE date,
		FOREIGN KEY (PLANE_ID) REFERENCES PLANE(PLANE_ID),
		FOREIGN KEY (DESTINATION_ID) REFERENCES DESTINATION(DESTINATION_ID)
	);

	-- Create MODIFICATION table
    CREATE TABLE IF NOT EXISTS MODIFICATION(
		MODIFICATION_ID INT AUTO_INCREMENT PRIMARY KEY,
        MODIFICATION_NAME VARCHAR(25) NOT NULL UNIQUE
    );
    
	-- Create MANIFEST table
	CREATE TABLE IF NOT EXISTS MANIFEST(
		PASSENGER_ID INT,
		FLIGHT_ID INT,
		MANIFEST_ROW INT,
		MANIFEST_COLUMN INT,
		FOREIGN KEY (PASSENGER_ID) REFERENCES PASSENGER(PASSENGER_ID),
		FOREIGN KEY (FLIGHT_ID) REFERENCES FLIGHT(FLIGHT_ID),
		PRIMARY KEY (PASSENGER_ID, FLIGHT_ID)
	);

	-- Create the CHANGES table
    CREATE TABLE IF NOT EXISTS CHANGES(
		CHANGES_ID INT AUTO_INCREMENT,
        FLIGHT_ID INT,
        PASSENGER_ID INT,
        MODIFICATION_ID INT,
        CHANGES_DATE DATE,
        MANIFEST_ROW INT,
        MANIFEST_COLUMN INT,
        FOREIGN KEY (FLIGHT_ID) REFERENCES MANIFEST(FLIGHT_ID),
		FOREIGN KEY (PASSENGER_ID) REFERENCES MANIFEST(PASSENGER_ID),        
        FOREIGN KEY (MODIFICATION_ID) REFERENCES MODIFICATION(MODIFICATION_ID),
        PRIMARY KEY (CHANGES_ID, FLIGHT_ID, PASSENGER_ID, MODIFICATION_ID, CHANGES_DATE)
        );
/*
	Create Views
*/
	-- Create a View that returns the Flight ID, Date, Destination Code, Plane Model, Full Name, SeatRow, SeatColumn of all passengers
	CREATE OR REPLACE VIEW VIEW_PASSENGERS_ALL AS
		SELECT 
			MANIFEST.FLIGHT_ID, FLIGHT.FLIGHT_DATE, DESTINATION.DESTINATION_CODE, PLANE.PLANE_MODEL, CONCAT(PASSENGER_NAME_LAST,',',PASSENGER_NAME_FIRST) as 'FULLNAME', MANIFEST_ROW AS SEATROW, MANIFEST_COLUMN AS SEATCOLUMN
		FROM 
			MANIFEST 
			INNER JOIN PASSENGER ON MANIFEST.PASSENGER_ID = PASSENGER.PASSENGER_ID
			INNER JOIN FLIGHT ON MANIFEST.FLIGHT_ID = FLIGHT.FLIGHT_ID
			INNER JOIN PLANE ON PLANE.PLANE_ID = FLIGHT.PLANE_ID
			INNER JOIN DESTINATION ON FLIGHT.DESTINATION_ID = DESTINATION.DESTINATION_ID;

	-- Create/Replace a view called VIEW_PASSENGERS_ASSIGNED.  SELECT FROM the passenger View that shows only the seat assigned passengers on the Flight ID, City Code, Date, PASSENGER Name, Seat Row, Column.
	CREATE OR REPLACE VIEW VIEW_PASSENGERS_ASSIGNED AS
		SELECT 
			FLIGHT_ID, FLIGHT_DATE, DESTINATION_CODE, FULLNAME, SEATROW, SEATCOLUMN
		FROM
			VIEW_PASSENGERS_ALL
		WHERE 
			SEATROW IS NOT NULL AND 
			SEATCOLUMN IS NOT NULL;

	-- Create/Replace a view for VIEW_PASSENGERS_UNASSIGNED, similar to Assigned
	CREATE OR REPLACE VIEW VIEW_PASSENGERS_UNASSIGNED AS
		SELECT 
			FLIGHT_ID, FLIGHT_DATE, DESTINATION_CODE, FULLNAME
		FROM
			VIEW_PASSENGERS_ALL
		WHERE 
			SEATROW IS NULL AND 
			SEATCOLUMN IS NULL;

	-- Create/Replace a view for VIEW_FLIGHT_ALL
	CREATE OR REPLACE VIEW VIEW_FLIGHT_ALL AS
		SELECT 
			FLIGHT_ID, FLIGHT_DATE, DESTINATION_CODE, DESTINATION_NAME
		FROM
			FLIGHT
            INNER JOIN DESTINATION ON DESTINATION.DESTINATION_ID = FLIGHT.DESTINATION_ID;

	CREATE OR REPLACE VIEW VIEW_CHANGES AS
		SELECT 
			MANIFEST.FLIGHT_ID, FLIGHT.FLIGHT_DATE, 
            DESTINATION.DESTINATION_CODE, 
            PLANE.PLANE_MODEL, 
            CONCAT(PASSENGER_NAME_LAST,',',PASSENGER_NAME_FIRST) as 'FULLNAME', 
            CHANGES.MANIFEST_ROW AS SEATROW, CHANGES.MANIFEST_COLUMN AS SEATCOLUMN, 
            MODIFICATION_NAME, CHANGES_DATE
		FROM 
			CHANGES
            INNER JOIN MODIFICATION ON MODIFICATION.MODIFICATION_ID = CHANGES.MODIFICATION_ID
            INNER JOIN MANIFEST ON MANIFEST.PASSENGER_ID = CHANGES.PASSENGER_ID AND MANIFEST.FLIGHT_ID = CHANGES.FLIGHT_ID
			INNER JOIN PASSENGER ON MANIFEST.PASSENGER_ID = PASSENGER.PASSENGER_ID
			INNER JOIN FLIGHT ON MANIFEST.FLIGHT_ID = FLIGHT.FLIGHT_ID
			INNER JOIN PLANE ON PLANE.PLANE_ID = FLIGHT.PLANE_ID
			INNER JOIN DESTINATION ON FLIGHT.DESTINATION_ID = DESTINATION.DESTINATION_ID;

/*
	Stored Procedures
*/
DELIMITER $$

-- Create/Replace a Proceudure called SP_PLANE_ADD that adds a destination if it does not exist
DROP PROCEDURE IF EXISTS SP_PLANE_ADD$$
CREATE PROCEDURE SP_PLANE_ADD (IN P_NAME VARCHAR(25), IN P_MODEL CHAR(25),IN P_ROWS INT, IN P_COLUMNS INT) 
BEGIN
	INSERT INTO PLANE(PLANE_NAME, PLANE_MODEL, PLANE_ROWS, PLANE_COLUMNS)
	SELECT P_NAME, P_MODEL, P_ROWS, P_COLUMNS
	WHERE 
		NOT EXISTS (SELECT PLANE_ID FROM PLANE WHERE PLANE_MODEL = P_MODEL AND PLANE_NAME = P_NAME);
END$$

-- Create/Replace a Proceudure called SP_DESTINATION_ADD that adds a destination if it does not exist
DROP PROCEDURE IF EXISTS SP_DESTINATION_ADD$$
CREATE PROCEDURE SP_DESTINATION_ADD (IN D_CODE CHAR(3),IN D_NAME VARCHAR(25)) 
BEGIN
	INSERT INTO DESTINATION(DESTINATION_CODE,DESTINATION_NAME)
	SELECT D_CODE, D_NAME
	WHERE 
		NOT EXISTS (SELECT DESTINATION_ID FROM DESTINATION WHERE DESTINATION_CODE = D_CODE);
END$$

-- Create/Replace a Proceudure called SP_PASSENGER_ADD that takes a PASSENGER Name and adds them to the PASSENGER table
DROP PROCEDURE IF EXISTS SP_PASSENGER_ADD$$
CREATE PROCEDURE SP_PASSENGER_ADD (IN P_NAME_FIRST VARCHAR(25),IN P_NAME_LAST VARCHAR(25)) 
	BEGIN
	INSERT INTO PASSENGER(PASSENGER_NAME_FIRST,PASSENGER_NAME_LAST)
	SELECT P_NAME_FIRST, P_NAME_LAST
	WHERE 
		NOT EXISTS (SELECT PASSENGER_ID FROM PASSENGER WHERE PASSENGER_NAME_FIRST = P_NAME_FIRST AND PASSENGER_NAME_LAST = P_NAME_LAST);
END$$

-- Create/Replace procedure SP_FLIGHT_ADD that takes a destination code of char 3, and a plane ID, and adds the flight if the flight is not in the system, and the destination is valid
DROP PROCEDURE IF EXISTS SP_FLIGHT_ADD$$
CREATE PROCEDURE SP_FLIGHT_ADD (IN D_CODE CHAR(3), IN P_MODEL VARCHAR(25))
BEGIN
	INSERT INTO FLIGHT(DESTINATION_ID, FLIGHT_DATE, PLANE_ID)
	SELECT 
		DESTINATION.DESTINATION_ID, 
        CURDATE(), 
        PLANE.PLANE_ID 
	FROM DESTINATION
		INNER JOIN PLANE ON PLANE.PLANE_ID = (SELECT PLANE_ID FROM PLANE WHERE PLANE_MODEL = P_MODEL)
		LEFT OUTER JOIN FLIGHT ON FLIGHT.DESTINATION_ID = DESTINATION.DESTINATION_ID
	WHERE 
		DESTINATION.DESTINATION_CODE = D_CODE
		AND (FLIGHT.DESTINATION_ID IS NULL OR FLIGHT.DESTINATION_ID <> DESTINATION.DESTINATION_ID);
END$$

-- Create/Replace a Proceudure called SP_ASSIGN SEAT that takes a Flight ID, PASSENGER Name, Seat Row AND Column AND Updates the PASSENGER seat row AND number
DROP PROCEDURE IF EXISTS SP_MANIFEST_ASSIGN_SEAT$$
CREATE PROCEDURE SP_MANIFEST_ASSIGN_SEAT (IN F_ID INT, IN D_CODE CHAR(3), IN P_LAST VARCHAR(25), IN P_FIRST VARCHAR(25), IN M_ROW INT, IN M_COLUMN INT) 
BEGIN
IF NOT EXISTS (
	SELECT MANIFEST_ROW 
	FROM MANIFEST
    WHERE 
		MANIFEST_ROW = M_ROW AND 
        MANIFEST_COLUMN =M_COLUMN
    )THEN

	UPDATE MANIFEST 
		INNER JOIN PASSENGER 
		ON MANIFEST.PASSENGER_ID = PASSENGER.PASSENGER_ID
        INNER JOIN FLIGHT
        ON MANIFEST.FLIGHT_ID = FLIGHT.FLIGHT_ID
        INNER JOIN DESTINATION
        ON FLIGHT.DESTINATION_ID = DESTINATION.DESTINATION_ID
        INNER JOIN PLANE
        ON FLIGHT.PLANE_ID = PLANE.PLANE_ID
	SET 
		MANIFEST_ROW = M_ROW, 
		MANIFEST_COLUMN = M_COLUMN
	WHERE 
		MANIFEST.FLIGHT_ID = F_ID AND
        DESTINATION_CODE = D_CODE AND
        PASSENGER_NAME_LAST = P_LAST AND
		PASSENGER_NAME_FIRST = P_FIRST AND
        PLANE_ROWS >= M_ROW AND
        PLANE_COLUMNS >= M_COLUMN;
	END IF;
        
END$$

-- Create/Replace a procedure called SP_ADD_PASSENGER_TO_FLIGHT that takes a Flight ID and a PASSENGER Name and adds them to the flight with no Assigned seat.  It should not add someone who is already on the flight
DROP PROCEDURE IF EXISTS SP_MANIFEST_PASSENGER_ADD$$
CREATE PROCEDURE SP_MANIFEST_PASSENGER_ADD (IN D_CODE VARCHAR(3), IN P_LAST VARCHAR(25), IN P_FIRST VARCHAR(25))
BEGIN
	SET @F_ID = 0;
    
	SELECT FLIGHT_ID INTO @F_ID	
	FROM
		FLIGHT
        INNER JOIN DESTINATION ON FLIGHT.DESTINATION_ID = DESTINATION.DESTINATION_ID
	WHERE
		DESTINATION.DESTINATION_CODE = D_CODE;
    
	INSERT INTO MANIFEST(FLIGHT_ID, PASSENGER_ID) 
	SELECT @F_ID, PASSENGER.PASSENGER_ID 
    FROM
		PASSENGER
		LEFT OUTER JOIN MANIFEST ON PASSENGER.PASSENGER_ID = MANIFEST.PASSENGER_ID
	WHERE 
		PASSENGER_NAME_FIRST = P_FIRST AND
        PASSENGER_NAME_LAST = P_LAST AND
		MANIFEST.MANIFEST_ROW IS NULL AND
        MANIFEST.MANIFEST_COLUMN IS NULL AND
		(MANIFEST.FLIGHT_ID IS NULL OR MANIFEST.FLIGHT_ID <> @F_ID);
END$$
DELIMITER ;

/*
	Triggers
*/

DELIMITER $$

DROP TRIGGER IF EXISTS TRIGGER_MANIFEST_CHANGES_ADD$$
CREATE TRIGGER TRIGGER_MANIFEST_CHANGES_ADD
	AFTER INSERT 
    ON 
		MANIFEST 
	FOR
		EACH ROW
	BEGIN
		INSERT INTO CHANGES(CHANGES_DATE, PASSENGER_ID, FLIGHT_ID, MANIFEST_ROW, MANIFEST_COLUMN, MODIFICATION_ID)
		SELECT CURDATE(), PASSENGER_ID, FLIGHT_ID, MANIFEST_ROW, MANIFEST_COLUMN, MODIFICATION_ID
		FROM 
			MANIFEST, MODIFICATION
		WHERE 
			MODIFICATION_NAME ='Created';
	END$$

-- Create/Drop a Trigger called MANIFEST_CHANGES_CHANGE that inserts into the CHANGES Table the Manifest changed data 
DROP TRIGGER IF EXISTS TRIGGER_MANIFEST_CHANGES_CHANGE$$
-- GRADE: Needs to say AFTER UPDATE, and use Update in the where
CREATE TRIGGER TRIGGER_MANIFEST_CHANGES_CHANGE
	AFTER UPDATE
    ON MANIFEST 
    FOR 
		EACH ROW
	BEGIN
			INSERT INTO CHANGES(CHANGES_DATE, PASSENGER_ID, FLIGHT_ID, MANIFEST_ROW, MANIFEST_COLUMN, MODIFICATION_ID)
			SELECT CURDATE(), PASSENGER_ID, FLIGHT_ID, MANIFEST_ROW, MANIFEST_COLUMN, MODIFICATION_ID
			FROM 
				MANIFEST, MODIFICATION
			WHERE MODIFICATION_NAME ='Updated';
	END $$
DELIMITER ;

/*
	Import Data from Mike's Database
*/
	-- Only import the regular entities
	INSERT INTO PASSENGER (PASSENGER_NAME_LAST, PASSENGER_NAME_FIRST) SELECT PASSENGER_NAME_LAST, PASSENGER_NAME_FIRST FROM km_airline2021.PASSENGER;
	INSERT INTO PLANE (PLANE_NAME, PLANE_MODEL, PLANE_ROWS, PLANE_COLUMNS) SELECT PLANE_NAME, PLANE_MODEL, PLANE_ROWS, PLANE_COLUMNS FROM km_airline2021.PLANE;
	INSERT INTO DESTINATION (DESTINATION_CODE, DESTINATION_NAME) SELECT DESTINATION_CODE, DESTINATION_NAME FROM km_airline2021.DESTINATION;

/*
	Add Data to MODIFICATION
*/

	INSERT INTO MODIFICATION (MODIFICATION_NAME)
    VALUES ('Created'), ('Updated');

/*
	Add Data using Stored Procedures
*/

-- Add Planes P1 787 and P2 777
CALL SP_PLANE_ADD('P1','787',40,8);
CALL SP_PLANE_ADD('P2','777',30,6);
CALL SP_PLANE_ADD('P3','747',50,9);

-- Add Seattle (SEA), Narita (NTR) airports, and Los Angeles (LAX)
CALL SP_DESTINATION_ADD('SEA', 'Seattle');
CALL SP_DESTINATION_ADD('NTR', 'Narita');
CALL SP_DESTINATION_ADD('LAX', 'Los Angeles');
CALL SP_DESTINATION_ADD('LHR', 'London');

-- Add a flight on the 787 to SEA from NTR
CALL SP_FLIGHT_ADD('SEA','787');
CALL SP_FLIGHT_ADD('LAX','777');
CALL SP_FLIGHT_ADD('LHR','747');

-- Add Passengers Mike and Masami Koenig
CALL SP_PASSENGER_ADD('Mike','Koenig');
CALL SP_PASSENGER_ADD('Masami','Nakata');
CALL SP_PASSENGER_ADD('Asumi','Taga');
CALL SP_PASSENGER_ADD('Jake','Dennis');
CALL SP_PASSENGER_ADD('Honami','Dennis');

CALL SP_MANIFEST_PASSENGER_ADD ('SEA', 'Koenig', 'Mike');
CALL SP_MANIFEST_PASSENGER_ADD ('SEA', 'Nakata', 'Masami');
CALL SP_MANIFEST_PASSENGER_ADD ('SEA', 'Taga', 'Asumi');
CALL SP_MANIFEST_PASSENGER_ADD ('LHR', 'Dennis', 'Jake');

-- Try to insert Mike into the database twice, should not insert
CALL SP_MANIFEST_PASSENGER_ADD ('SEA', 'Koenig', 'Mike');
CALL SP_MANIFEST_PASSENGER_ADD ('LHR', 'Koenig', 'Mike');

-- Assign Seats to Mike and Masami
CALL SP_MANIFEST_ASSIGN_SEAT (1,'SEA', 'Koenig','Mike', 1, 2);
CALL SP_MANIFEST_ASSIGN_SEAT (1,'SEA', 'Nakata','Masami', 1, 1);

-- Try to change Masami to the same seat as Mike, should not change the seat
CALL SP_MANIFEST_ASSIGN_SEAT (1,'SEA', 'Nakata','Masami', 1, 2);

-- Try to change Masami to the last row and last colum, should change to it
CALL SP_MANIFEST_ASSIGN_SEAT (1,'SEA', 'Nakata','Masami', 40, 8);


/*

Transactions

*/

/*

1. New Stored Procedure SP_BOOK_PASSENGER_FLIGHT
Make a new Stored Procedure that takes in a passenger first and last name and a flight code
If the passenger does not exist, it adds them to the database
Then it adds the passenger to the manifest for that flight
Wrap the procedure in a Transaction, so the data is committed only if both operations complete successfully

Test you procedure by
2. Calling with a passenger that exists, and a flight that exists
3. Calling with a passenger that does not exist, so they are added, and a flight that does exist
4. Calling with a passenger that exists, and a flight that does not exists
5. Calling with a passenger that does not exist, so they are added, and a flight that does not exist

6. Show in your output the passengers added to the flight view (only the passengers from test A, and B should be there)

*/

DELIMITER $$
DROP PROCEDURE IF EXISTS SP_BOOK_PASSENGER_FLIGHT$$
CREATE PROCEDURE SP_BOOK_PASSENGER_FLIGHT (IN D_CODE VARCHAR(3), IN P_NAME_LAST VARCHAR(25), IN P_NAME_FIRST VARCHAR(25))
BEGIN
IF NOT EXISTS(
	SELECT PASSENGER_ID
    FROM PASSENGER
    WHERE PASSENGER_NAME_FIRST = P_NAME_FIRST AND PASSENGER_NAME_LAST = P_NAME_LAST
    )THEN
-- Start the transaction

	-- Grab the code to insert a passenger who does not exist into passenger
	CALL SP_PASSENGER_ADD(P_NAME_FIRST, P_NAME_LAST);
    
	-- Grab the code to get the flight id and put it into @F_ID for the destination
    SET @F_ID = 0;
    SELECT FLIGHT_ID INTO @F_ID
    FROM DESTINATION
    INNER JOIN FLIGHT ON FLIGHT.DESTINATION_ID = DESTINATION.DESTINATION_ID
    WHERE DESTINATION_CODE = D_CODE;
    -- Check if the @F_ID is zero, if it is, rollback, else insert into the flight
    IF (@F_ID = 0)
	THEN
    ROLLBACK;
	ELSE
   --  CALL MANIFEST_PASSENGER_ASSIGN_SEAT(D_CODE, P_NAME_LAST, P_NAME_FIRST);
    -- Grab the code from inserting a passenger onto a flight
    CALL SP_MANIFEST_PASSENGER_ADD(D_CODE, P_NAME_LAST, P_NAME_FIRST);
    END IF;
    END IF;

-- Commit the transaction
COMMIT;
END$$
DELIMITER ;

-- 2. Calling with a passenger that exists, and a flight that exists
CALL SP_BOOK_PASSENGER_FLIGHT ('SEA','APPLE','MIKE');

-- 3. Calling with a passenger that does not exist, so they are added, and a flight that does exist
CALL SP_BOOK_PASSENGER_FLIGHT('SEA','APPLE','JOE');

-- 4. Calling with a passenger that exists, and a flight that does not exists
CALL SP_BOOK_PASSENGER_FLIGHT('ABC','APPLE','MIKE');

-- 5. Calling with a passenger that does not exist, so they are added, and a flight that does not exist
CALL SP_BOOK_PASSENGER_FLIGHT('ABC','APPLE','ALEX');

-- 6. Show in your output the passengers added to the flight view (only the passengers from test A, and B should be there)
SELECT * FROM VIEW_PASSENGERS_ALL;


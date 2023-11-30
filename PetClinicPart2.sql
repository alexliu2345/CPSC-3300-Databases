/*
	PET SQL Lab Part 2
    Alexander Liu
*/
-- Use my database
USE km_aliu1;

/*
 Drop Tables so the database starts fresh
 */

-- Drop the Staff Table
DROP TABLE IF EXISTS STAFF;

-- Drop the Doctor Table
DROP TABLE IF EXISTS DOCTOR;

-- Drop the Clinic Table
DROP TABLE IF EXISTS CLINIC;

-- Drop the PetCustomer table
DROP TABLE IF EXISTS PETCUSTOMER;

-- Drop the Customer table
DROP TABLE IF EXISTS CUSTOMER;

 -- Drop the Pet Table
 DROP TABLE IF EXISTS PET;
 
-- Drop the Category Table
DROP TABLE IF EXISTS CATEGORY;

/* 
	Create Tables
*/

-- Create the Category Table
CREATE TABLE IF NOT EXISTS CATEGORY(CATEGORY_ID VARCHAR(10) PRIMARY KEY,
CATEGORY_TITLE VARCHAR(50));

-- Create the Pet Table
CREATE TABLE IF NOT EXISTS PET (
PET_ID VARCHAR(10) PRIMARY KEY,
PET_NAME VARCHAR(50) NOT NULL,
PET_BIRTH_DATE DATE NOT NULL,
CATEGORY_ID VARCHAR(10),
FOREIGN KEY (CATEGORY_ID) REFERENCES CATEGORY(CATEGORY_ID));

-- Create the Customer Table
CREATE TABLE IF NOT EXISTS CUSTOMER(
CUSTOMER_ID VARCHAR(50) PRIMARY KEY,
CUSTOMER_NAME_FIRST VARCHAR(50) NOT NULL,
CUSTOMER_NAME_LAST VARCHAR(50) NOT NULL);

-- Create the PetCustomer Table
CREATE TABLE IF NOT EXISTS PETCUSTOMER(
	CUSTOMER_ID VARCHAR(50),
    PET_ID VARCHAR(50),
	FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER(CUSTOMER_ID),
    FOREIGN KEY (PET_ID) REFERENCES PET(PET_ID),
	PRIMARY KEY (CUSTOMER_ID, PET_ID));

-- Create the Clinic Table
CREATE TABLE IF NOT EXISTS CLINIC(
	CLINIC_ID VARCHAR(50) PRIMARY KEY,
    CLINIC_CITY VARCHAR(50) NOT NULL);
    
 -- Create the Doctor Table   
CREATE TABLE IF NOT EXISTS DOCTOR(
	DOCTOR_ID VARCHAR(50) PRIMARY KEY,
    DOCTOR_NAME_FIRST VARCHAR(50) NOT NULL,
    DOCTOR_NAME_LAST VARCHAR(50) NOT NULL);

-- Create the Staff Table
CREATE TABLE IF NOT EXISTS STAFF(
	CLINIC_ID VARCHAR(50),
    DOCTOR_ID VARCHAR(50),
	FOREIGN KEY (CLINIC_ID) REFERENCES CLINIC(CLINIC_ID),
	FOREIGN KEY (DOCTOR_ID) REFERENCES DOCTOR(DOCTOR_ID),
    PRIMARY KEY(CLINIC_ID, DOCTOR_ID));
    
/*
	Add Data to the Tables
*/

-- Add data to the Category Table

INSERT INTO CATEGORY 
	(CATEGORY_ID, CATEGORY_TITLE)
VALUES
    ('CAT1','Dog'),
    ('CAT2', 'Cat'),
    ('CAT3','Hamster');
    
-- Add data to the Pet Table

INSERT INTO PET
	(PET_ID, PET_NAME, PET_BIRTH_DATE, CATEGORY_ID)
VALUES
	('123','Hucky', DATE('2001-1-1'),'CAT1'),
    ('456', 'Peanut', DATE('2002-2-2'), 'CAT1'),
    ('789', 'Sumi', DATE('2003-3-3'), 'CAT1'),
    ('333', 'Sumi', DATE('2004-4-4'), 'CAT3');
    
-- Add data to the Customer Table
	INSERT INTO CUSTOMER
		(CUSTOMER_ID, CUSTOMER_NAME_FIRST, CUSTOMER_NAME_LAST)
	VALUES
		('001', 'Mike', 'Koenig'),
        ('002', 'Sue', 'Koenig'),
        ('003', 'Jea', 'Koenig');
        
    
-- Add data to the PetCustomer Table
INSERT INTO PETCUSTOMER
	(CUSTOMER_ID, PET_ID)
VALUES
	('001', '123'),
    ('001', '456'),
    ('001', '789'),
    ('002', '123'),
    ('003', '333');
    
-- Add data to the Clinic table
INSERT INTO CLINIC
	(CLINIC_ID, CLINIC_CITY)
VALUES
	('C1', 'Bellevue'),
    ('C2', 'Seattle'),
    ('C3', 'Tacoma');

-- Add data to the Doctor Table
INSERT INTO DOCTOR
	(DOCTOR_ID, DOCTOR_NAME_FIRST, DOCTOR_NAME_LAST)
VALUES
	('001', 'Dani' , 'Taga'),
    ('002', 'Megan', 'Nakata'),
    ('003', 'Jacob', 'Dennis');

-- Add data to the Staff Table
INSERT INTO STAFF
	(CLINIC_ID, DOCTOR_ID)
VALUES
	('C1', '001'),
    ('C1', '002'),
    ('C2', '001'),
    ('C2', '003'),
    ('C3', '003');

/*
	Confirm Insert Data worked properly
*/

-- Get everything from Category
SELECT * FROM CATEGORY;

-- Get everything from Pet
SELECT * FROM PET;

-- Get everything from CUSTOMER
SELECT * FROM CUSTOMER;

-- Get everything from PETCUSTOMER
SELECT * FROM PETCUSTOMER;

-- Get everything from STAFF
SELECT * FROM STAFF;

-- Get everything from DOCTOR
SELECT * FROM DOCTOR;

-- Get everything from CLINIC
SELECT* FROM CLINIC;

-- 1. Get the Pet Names for the Dogs
SELECT 
	PET_NAME
FROM
	PET
INNER JOIN CATEGORY
	ON CATEGORY.CATEGORY_ID = PET.CATEGORY_ID
WHERE
	CATEGORY_TITLE = 'Dog';
-- 2. Left Outer Join Pet on Category
SELECT
	*
FROM 
	PET
LEFT OUTER JOIN CATEGORY
	ON PET.CATEGORY_ID = CATEGORY.CATEGORY_ID;
    
-- 3. Right outer join Pet on Category
SELECT
	*
FROM 
	PET
RIGHT OUTER JOIN CATEGORY
	ON PET.CATEGORY_ID = CATEGORY.CATEGORY_ID;

-- 4. Get the animal category not found at the clinic
SELECT
	CATEGORY_TITLE
FROM 
	CATEGORY
LEFT OUTER JOIN PET
	ON CATEGORY.CATEGORY_ID = PET.CATEGORY_ID
WHERE 
	PET.CATEGORY_ID IS NULL;

/* 
	Part 2 QUERIES
*/

-- 1. Return all CUSTOMERs by full name
SELECT 
	CUSTOMER_NAME_FIRST, CUSTOMER_NAME_LAST
FROM
	CUSTOMER;

-- 2. Return the FUll names of the CUSTOMERs of pet 123
	SELECT
		CUSTOMER_NAME_FIRST, CUSTOMER_NAME_LAST
	FROM 
		CUSTOMER
	INNER JOIN PETCUSTOMER
	WHERE
		PET_ID = '123' AND PETCUSTOMER.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID ;        
		
-- 3. Return all City Names for Clinics
SELECT
	CLINIC_CITY
FROM
	CLINIC;
    
-- 4. Return the full names of the doctors who work in the clinic C1
SELECT
	DOCTOR_NAME_FIRST, DOCTOR_NAME_LAST
FROM 
	DOCTOR
INNER JOIN STAFF
	ON DOCTOR.DOCTOR_ID = STAFF.DOCTOR_ID
WHERE
	STAFF.CLINIC_ID = 'C1';
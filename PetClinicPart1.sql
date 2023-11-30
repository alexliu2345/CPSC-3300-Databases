/*
	PET SQL Lab Part 1
    Alexander Liu
*/
-- Use my database
USE km_aliu1;

/*
 Drop Tables so the database starts fresh
 */
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
    
/*
	Confirm Insert Data worked properly
*/

-- Get everything from Category
SELECT * FROM CATEGORY;

-- Get everything from Pet
SELECT * FROM PET;

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



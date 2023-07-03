/*
CSY2038
Group 8

Joel Harsent - 20413335
Stefan-Felician Baloiu – 20410488
Louise Anderson – 20422051
Danielle Fox – 20422917
*/ 

SET SERVEROUTPUT ON

-- DROPS --

DROP PROCEDURE proc_review_deletion;
DROP FUNCTION func_ambassador_username;
DROP PROCEDURE proc_ambassador_username;

DROP PACKAGE funcs_procs;

DROP PROCEDURE proc_cur_guests_tickets;

DROP TRIGGER trig_age_category;
DROP TRIGGER trig_invalid_date;

DROP TABLE programmes;
DROP TYPE ambassadors_varray_type;
DROP TYPE ambassadors_type;
DROP TYPE practices_type;
DROP TABLE guests;
DROP TABLE retreat_accommodations;
DROP TABLE accommodations;
DROP TABLE addresses;
DROP TYPE address_type;
DROP TABLE retreat_settings;
DROP TYPE reviews_table_type;
DROP TYPE reviews_type;

PURGE RECYCLEBIN;

-- CREATES --

CREATE TYPE reviews_type AS OBJECT(
title VARCHAR2(25),
rating NUMBER(2) );
/

CREATE TYPE reviews_table_type AS TABLE OF reviews_type;
/

CREATE TABLE retreat_settings(
retreat_setting_id NUMBER(6) NOT NULL,
retreat_category VARCHAR2(25),
setting VARCHAR2(25),
reviews reviews_table_type)
NESTED TABLE reviews STORE AS reviews_table; 

CREATE TYPE address_type AS OBJECT(
country VARCHAR2(25),
city VARCHAR2(25),
street VARCHAR2(25),
house_number VARCHAR2(5),
postcode VARCHAR2(10) );
/

CREATE TABLE addresses OF address_type;

CREATE TABLE accommodations(
accommodation_id NUMBER(6) NOT NULL,
accommodation_style VARCHAR2(25),
number_of_rooms VARCHAR2(2),
price_per_night NUMBER(6,2),
address REF address_type SCOPE IS addresses );

CREATE TABLE retreat_accommodations(
retreat_accommodation_id NUMBER(6) NOT NULL,
retreat_setting_id NUMBER(6) NOT NULL,
accommodation_id NUMBER(6) NOT NULL );

CREATE TABLE guests(
guest_id NUMBER(6) NOT NULL,
guest_firstname VARCHAR2(25),
guest_surname VARCHAR2(25),
date_of_birth DATE,
phone_number VARCHAR2(25),
email VARCHAR2(50),
ticket CHAR,
address address_type );

CREATE TYPE practices_type AS OBJECT(
practice_id NUMBER(6),
practice_name VARCHAR2(25) );
/

CREATE TYPE ambassadors_type AS OBJECT(
ambassador_id NUMBER(6),
ambassador_firstname VARCHAR2(25),
ambassador_surname VARCHAR2(25),
date_of_birth DATE,
email VARCHAR2(50),
salary NUMBER(8,2),
practice practices_type );
/

CREATE TYPE ambassadors_varray_type AS VARRAY(40) OF ambassadors_type;
/

CREATE TABLE programmes(
programme_id NUMBER(6) NOT NULL,
cost NUMBER(6,2) DEFAULT '110.50',
duration VARCHAR2(15) DEFAULT '1.5 HOURS',
retreat_accommodation_id NUMBER(6),
guest_id NUMBER(6),
ambassadors ambassadors_varray_type );


-- ALTERS --

-- PKs 
ALTER TABLE retreat_settings
ADD CONSTRAINT pk_retreat_settings
PRIMARY KEY (retreat_setting_id);

ALTER TABLE accommodations
ADD CONSTRAINT pk_accommodations
PRIMARY KEY (accommodation_id);

ALTER TABLE retreat_accommodations
ADD CONSTRAINT pk_retreat_accommodations
PRIMARY KEY (retreat_accommodation_id);

ALTER TABLE programmes
ADD CONSTRAINT pk_programmes
PRIMARY KEY (programme_id);

ALTER TABLE guests
ADD CONSTRAINT pk_guests
PRIMARY KEY (guest_id);

-- FKs

ALTER TABLE retreat_accommodations
ADD CONSTRAINT fk_ra_retreat_settings
FOREIGN KEY (retreat_setting_id)
REFERENCES retreat_settings(retreat_setting_id);

ALTER TABLE retreat_accommodations
ADD CONSTRAINT fk_ra_accommodations
FOREIGN KEY (accommodation_id)
REFERENCES accommodations(accommodation_id);

ALTER TABLE programmes
ADD CONSTRAINT fk_p_retreat_accommodations
FOREIGN KEY (retreat_accommodation_id)
REFERENCES retreat_accommodations(retreat_accommodation_id);

ALTER TABLE programmes
ADD CONSTRAINT fk_p_guests
FOREIGN KEY (guest_id)
REFERENCES guests(guest_id);

-- CHECKs

ALTER TABLE guests
ADD CONSTRAINT ck_guest_firstname
CHECK (guest_firstname = upper(guest_firstname));

ALTER TABLE guests
ADD CONSTRAINT ck_guest_surname
CHECK (guest_surname = upper(guest_surname));

-- UNIQUEs

ALTER TABLE guests
ADD CONSTRAINT uk_email
UNIQUE (email);

ALTER TABLE guests
ADD CONSTRAINT uk_phone_number
UNIQUE (phone_number);


-- INSERTS --

INSERT INTO retreat_settings(retreat_setting_id, retreat_category, setting, reviews)
VALUES (100, 'REST AND RELAXATION', 'COASTAL', 
reviews_table_type(
				reviews_type('INCREDIBLE', 9),
				reviews_type('SUPER RELAXING', 8),
				reviews_type('HAPPY', 8))
		);

INSERT INTO retreat_settings(retreat_setting_id, retreat_category, setting, reviews)
VALUES (101, 'ENERGISING', 'PLANETARY LEY LINES',
reviews_table_type(
				reviews_type('AWESOME', 8),
				reviews_type('SPLENDID', 9),
				reviews_type('KINDA BAD', 5))
		);
		
INSERT INTO retreat_settings(retreat_setting_id, retreat_category, setting, reviews)
VALUES (102, 'WEIGHT LOSS', 'WOODLAND',
reviews_table_type(
				reviews_type('THE VERY BEST', 10),
				reviews_type('MEDIOCRE', 6),
				reviews_type('BAD', 1))
		);

INSERT INTO retreat_settings(retreat_setting_id, retreat_category, setting, reviews)
VALUES (103, 'ANXIETY RELIEF', 'COZY LODGE', 
reviews_table_type(
				reviews_type('NEVER FELT SO RELAXED', 9),
				reviews_type('AMAZING ATMOSPHERE', 9),
				reviews_type('WAS OKAY', 5))
		);

INSERT INTO retreat_settings(retreat_setting_id, retreat_category, setting, reviews)
VALUES (104, 'RELATIONSHIP COUNSELLING', 'TROPICAL', 
reviews_table_type(
				reviews_type('DONE WONDERS', 10),
				reviews_type('BROKE UP', 6),
				reviews_type('AWFUL', 2))
		);


INSERT INTO addresses(country, city, street, house_number, postcode)
VALUES ('FRANCE', 'PARIS', 'JEANNE DARC ST', '55', '75000');

INSERT INTO addresses(country, city, street, house_number, postcode)
VALUES ('FRANCE', 'PARIS', 'LOUIS XII ST', '43', '75008');

INSERT INTO addresses(country, city, street, house_number, postcode)
VALUES ('UK', 'LONDON', 'GREENWICH ST', '10', 'EZ6N 7CD');

INSERT INTO addresses(country, city, street, house_number, postcode)
VALUES ('GERMANY', 'HAMBURG', 'JAGER ST', '21', 'GR5 155');

INSERT INTO addresses(country, city, street, house_number, postcode)
VALUES ('JAPAN', 'TOKYO', 'SENPAI ROAD', '33', 'TK3 51U');


INSERT INTO accommodations(accommodation_id, accommodation_style, number_of_rooms, price_per_night)
VALUES (200, 'CABIN', '4', 222.50);

UPDATE accommodations SET address =
(SELECT REF(a) FROM addresses a
WHERE a.street = 'JEANNE DARC ST')
WHERE accommodation_id = 200;

INSERT INTO accommodations(accommodation_id, accommodation_style, number_of_rooms, price_per_night)
VALUES (201, 'LUXURY', '10', 999.99);

UPDATE accommodations SET address =
(SELECT REF(a) FROM addresses a
WHERE a.street = 'LOUIS XII ST')
WHERE accommodation_id = 201;

INSERT INTO accommodations(accommodation_id, accommodation_style, number_of_rooms, price_per_night)
VALUES (202, 'LUXURY', '2', 400.00);

UPDATE accommodations SET address =
(SELECT REF(a) FROM addresses a
WHERE a.street = 'GREENWICH ST')
WHERE accommodation_id = 202;

INSERT INTO accommodations(accommodation_id, accommodation_style, number_of_rooms, price_per_night)
VALUES (203, 'LODGE', '6', 360.00);

UPDATE accommodations SET address =
(SELECT REF(a) FROM addresses a
WHERE a.street = 'JAGER ST')
WHERE accommodation_id = 203;

INSERT INTO accommodations(accommodation_id, accommodation_style, number_of_rooms, price_per_night)
VALUES (204, 'HUT', '5', 450.50);

UPDATE accommodations SET address =
(SELECT REF(a) FROM addresses a
WHERE a.street = 'SENPAI ROAD')
WHERE accommodation_id = 204;


INSERT INTO retreat_accommodations(retreat_accommodation_id, retreat_setting_id, accommodation_id)
VALUES (300, 100, 202);

INSERT INTO retreat_accommodations(retreat_accommodation_id, retreat_setting_id, accommodation_id)
VALUES (301, 104, 202);

INSERT INTO retreat_accommodations(retreat_accommodation_id, retreat_setting_id, accommodation_id)
VALUES (302, 101, 200);

INSERT INTO retreat_accommodations(retreat_accommodation_id, retreat_setting_id, accommodation_id)
VALUES (303, 103, 203);

INSERT INTO retreat_accommodations(retreat_accommodation_id, retreat_setting_id, accommodation_id)
VALUES (304, 104, 204);


INSERT INTO guests(guest_id, guest_firstname, guest_surname, date_of_birth, phone_number, email, ticket, address)
VALUES (1000, 'JOHN', 'DOE', '25-DEC-1979', '+447712345834', 'JOHNDOE@EXAMPLE.COM', 'Y', address_type('UK', 'LIVERPOOL', 'LIUER ST', '10', 'LV1 6LY'));

INSERT INTO guests(guest_id, guest_firstname, guest_surname, date_of_birth, phone_number, email, ticket, address)
VALUES (1001, 'MARY', 'SMITH', '15-MAR-1987', '+447756744567', 'MARYSMITH@EXAMPLE.COM', 'Y', address_type('UK', 'GLASGOW', 'SHINY ST', '77', 'GG6 9HF'));

INSERT INTO guests(guest_id, guest_firstname, guest_surname, date_of_birth, phone_number, email, ticket, address)
VALUES (1002, 'NIA', 'VAUGHAN', '11-NOV-1991', '+447756355532', 'NIAVAUGHAN@EXAMPLE.COM', 'N', address_type('UK', 'CARDIFF', 'SWANSEA ST', '2', 'CF22 5QT'));

INSERT INTO guests(guest_id, guest_firstname, guest_surname, date_of_birth, phone_number, email, ticket, address)
VALUES (1003, 'MARTIN', 'BATES', '06-OCT-2001', '+44777593764', 'MARTINBATES@EXAMPLE.COM', 'Y', address_type('SINOH', 'PALLET CITY', 'GHASTLY ST', '3', 'GH1 311'));

INSERT INTO guests(guest_id, guest_firstname, guest_surname, date_of_birth, phone_number, email, ticket, address)
VALUES (1004, 'CHELSEA', 'JONES', '02-JUN-2005', '+447713068475', 'CHELSEAJONES@EXAMPLE.COM', 'N', address_type('USA', 'WISCONSIN', 'BULL RD', '32', 'NY72 D11'));


INSERT INTO programmes(programme_id, retreat_accommodation_id, guest_id, ambassadors)
VALUES (400, 300, 1000,
ambassadors_varray_type(
				ambassadors_type(500, 'CHRIS', 'TYLER', '22-FEB-1994', 'CHRISTYLER@EXAMPLE.COM', 22400.50, practices_type(600, 'HIIT')),
				ambassadors_type(501, 'ADAM', 'DAVIDSON', '07-DEC-1995', 'ADAMDAVIDSON@EXAMPLE.COM', 20986.50, practices_type(601, 'MINDFULNESS')),
				ambassadors_type(502, 'SARAH', 'EVANS', '17-OCT-1998', 'SARAHEVANS@EXAMPLE.COM', 25400.00, practices_type(602, 'CRYSTALS'))
						)
		);
		
INSERT INTO programmes(programme_id, cost, duration, retreat_accommodation_id, guest_id, ambassadors)
VALUES (401, 160.00, '2 HOURS', 301, 1002,
ambassadors_varray_type(
				ambassadors_type(503, 'JENNY', 'TYLER', '05-AUG-1989', 'JENNYTYLER@EXAMPLE.COM', 32500.00, practices_type(603, 'YOGA')),
				ambassadors_type(504, 'LILY', 'WHITE', '11-SEP-1986', 'LILYWHITE@EXAMPLE.COM', 30000.00, practices_type(604, 'TIBETAN SINGING BOWLS')),
				ambassadors_type(505, 'VIOLET', 'BLACK', '14-JUN-1980', 'VIOLETBLACK@EXAMPLE.COM', 29672.50, practices_type(605, 'CLEANSING'))
						)
		);
		
INSERT INTO programmes(programme_id, cost, duration, retreat_accommodation_id, guest_id, ambassadors)
VALUES (402, 175.00, '2.5 HOURS', 300, 1000,
ambassadors_varray_type(
				ambassadors_type(506, 'DEBORAH', 'ADDISON', '20-JAN-1992', 'DEBORAHADDISSON@EXAMPLE.COM', 22500.00, practices_type(600, 'HIIT')),
				ambassadors_type(507, 'KATSUROU', 'YAMASHITA', '14-APR-1990', 'KATSUROUYAMASHITA@EXAMPLE.COM', 36000.00, practices_type(602, 'CRYSTALS')),
				ambassadors_type(508, 'OLGA-MARIE', 'ANIMUSPHERE', '06-MAY-1993', 'MARIEANIMUSPHERE@EXAMPLE.COM', 24500.50, practices_type(603, 'YOGA'))
						)
		);

INSERT INTO programmes(programme_id, cost, duration, retreat_accommodation_id, guest_id, ambassadors)
VALUES (403, 200.00, '4 HOURS', 303, 1003,
ambassadors_varray_type(
				ambassadors_type(509, 'DANNI', 'JONES', '24-JAN-1973', 'DANNIJONES@EXAMPLE.COM', 28972.80, practices_type(606, 'MEDIATION')),
				ambassadors_type(510, 'BEN', 'SHAW', '14-NOV-1999', 'BENSHAW@EXAMPLE.COM', 34270.10, practices_type(607, 'BREATHING TECHNIQUES')),
				ambassadors_type(511, 'MARY', 'LINK', '23-FEB-1993', 'MARYLINK@EXAMPLE.COM', 29200.00, practices_type(608, 'EXCERCISE'))
						)
		);	
INSERT INTO programmes(programme_id, cost, duration, retreat_accommodation_id, guest_id, ambassadors)
VALUES (404, 500.00, '6 HOURS', 304, 1004,
ambassadors_varray_type(
				ambassadors_type(512, 'CAMMY', 'BURNS', '18-MAY-1990', 'CAMMYBURNS@EXAMPLE.COM', 52536.25, practices_type(609, 'COMMUNICATION')),
				ambassadors_type(513, 'KATIE', 'LOWE', '25-APR-1983', 'KATIELOWE@EXAMPLE.COM', 38720.50, practices_type(610, 'TRUST EXCERCISES')),
				ambassadors_type(514, 'KYLE', 'SANDERS', '02-OCT-2000', 'KYLESANDERS@EXAMPLE.COM', 39300.00, practices_type(611, 'SOLVING ISSUES'))
						)
		);


-- QUERIES --

-- Query to show programme id where cost is under 200
SELECT programme_id "Programme ID"
FROM programmes
WHERE cost < 200;

-- Query to show guests contact information where guests live in the UK DESC
SELECT guest_id "Guest ID", guest_firstname "First name", guest_surname "Surname", email "Email", phone_number "Phone number", g.address.house_number "House number", g.address.postcode "Postcode", g.address.country "Country"
FROM guests g
WHERE g.address.country = 'UK'
ORDER BY guest_id DESC;

-- DEREF query to show accommodation id with address ref
SELECT accommodation_id "Accommodation ID", DEREF(address) "Reference of Address"
FROM accommodations
WHERE accommodation_id IN (
		SELECT accommodation_id
		FROM accommodations
		WHERE accommodation_id = '203'
);

-- Query to show accommodation style and id of style strating with 'L'
SELECT accommodation_id "Accommodation ID", accommodation_style "Accommodation style"
FROM accommodations 
WHERE accommodation_style LIKE 'L%';

-- OUTER JOIN that shows guests and their accommodation and which programme they're taking part in
SELECT r.retreat_accommodation_id "Retreat accommodation ID", g.guest_id "Guest ID", p.programme_id "Programme ID", p.cost "Cost"
FROM retreat_accommodations r
FULL OUTER JOIN programmes p
ON r.retreat_accommodation_id = p.retreat_accommodation_id
FULL OUTER JOIN guests g
ON g.guest_id = p.guest_id;

-- INNER JOIN that shows only the accommodation_ids and retreat_setting_ids used in the creation of retreat_accommodations
SELECT ra.retreat_accommodation_id "Retreat accommodation ID", a.accommodation_id "Accommodation ID", rs.retreat_setting_id "Retreat setting ID"
FROM retreat_settings rs 
JOIN retreat_accommodations ra
ON ra.retreat_setting_id = rs.retreat_setting_id
JOIN accommodations a
ON ra.accommodation_id = a.accommodation_id;

-- Query to show the ambassadors born after a certain date
SELECT programme_id "Programme ID", a.ambassador_id "Ambassador ID", a.ambassador_firstname "First name", date_of_birth "DOB"
FROM programmes p, TABLE(p.ambassadors) a
WHERE date_of_birth > '01-JAN-1990'
ORDER BY a.ambassador_id;

-- QUERY that displays the number of salaries of ambassadors over a threshold for every programme
SELECT programme_id "Programme ID", COUNT(a.salary) "Number of salaries"
FROM programmes p, TABLE(p.ambassadors) a
WHERE a.salary > 30000
GROUP BY programme_id;


-- FUNCTIONS and PROCEDURES --

-- Procedure to delete reviews under a certain value
CREATE OR REPLACE PROCEDURE proc_review_deletion(in_retreat_id retreat_settings.retreat_setting_id%TYPE, in_rating NUMBER) IS
vn_retreat_id NUMBER(6);
vn_id_value NUMBER(6);
BEGIN
	SELECT MAX(retreat_setting_id)
	INTO vn_retreat_id
	FROM retreat_settings;
	
	vn_id_value := in_retreat_id;
	
	WHILE vn_id_value <= vn_retreat_id LOOP
		DELETE TABLE(
			SELECT rs.reviews
			FROM retreat_settings rs
			WHERE retreat_setting_id = vn_id_value) r
		WHERE r.rating < in_rating;
	
		vn_id_value := vn_id_value +1;
	END LOOP;

	IF SQL%FOUND THEN
	DBMS_OUTPUT.PUT_LINE('The reviews under the specified value have been deleted.');
	ELSE 
	DBMS_OUTPUT.PUT_LINE('There are no reviews with a rating lower than the selected value.');
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE(SQLERRM);
END proc_review_deletion;
/

-- Function to create a username for an ambassador 
CREATE OR REPLACE FUNCTION func_ambassador_username(in_ambassador_id NUMBER) RETURN VARCHAR2 IS
vc_username VARCHAR2(25);
vc_firstname VARCHAR2(25);
vc_surname VARCHAR2(25);
BEGIN
	SELECT a.ambassador_firstname, a.ambassador_surname
	INTO vc_firstname, vc_surname
	FROM programmes p, TABLE(p.ambassadors) a
	WHERE a.ambassador_id = in_ambassador_id;
	
	vc_username := INITCAP(SUBSTR(vc_firstname, 1,2)) || INITCAP(SUBSTR(vc_surname, 1, 5));
	
	RETURN vc_username;
END func_ambassador_username;
/

-- Procedure using func_ambassador_username
CREATE OR REPLACE PROCEDURE proc_ambassador_username(in_ambassador_id NUMBER) IS
vc_username VARCHAR(25);
BEGIN
	vc_username := func_ambassador_username(in_ambassador_id);
	
	DBMS_OUTPUT.PUT_LINE('Your login username is ' || vc_username || '.');
END proc_ambassador_username;
/


-- PACKAGE --

-- Creating a package with the titles of small functions and the procedures that call them
CREATE OR REPLACE PACKAGE funcs_procs IS
	FUNCTION func_salary_sum RETURN NUMBER; -- Creating a function that returns the sum of the salaries paid to ambassadors
	PROCEDURE proc_salary_func; -- The procedure that calls the function and displays a message
	FUNCTION func_ticket_ct RETURN NUMBER; -- Creating a function that returns the number of guests that have tickets
	PROCEDURE proc_ticket_func; -- The procedure that calls the function and displays a message
	FUNCTION func_rating_avg RETURN NUMBER; -- Creating a function that returns the average of a retreats ratings
	PROCEDURE proc_rating_func; -- The procedure that calls the function and displays a message
END funcs_procs;
/

-- The package body containing the functions and procedures
CREATE OR REPLACE PACKAGE BODY funcs_procs IS
	FUNCTION func_salary_sum RETURN NUMBER IS
	vn_salary_sum NUMBER(9,2);
	BEGIN
		SELECT CEIL(SUM(a.salary))
		INTO vn_salary_sum
		FROM programmes p, TABLE(p.ambassadors) a;
		RETURN vn_salary_sum;
	END func_salary_sum;
	PROCEDURE proc_salary_func IS
	vn_sum_salary NUMBER(9,2);
	BEGIN
		vn_sum_salary := func_salary_sum;
		DBMS_OUTPUT.PUT_LINE('The total sum of salary paid to ambassadors is ' || vn_sum_salary || '.');
	END proc_salary_func;
	
	FUNCTION func_ticket_ct RETURN NUMBER IS
	vn_counter_ct NUMBER(3);
	BEGIN
		SELECT COUNT(guest_id)
		INTO vn_counter_ct
		FROM guests
		WHERE ticket = 'Y';
		RETURN vn_counter_ct;
	END func_ticket_ct;
	PROCEDURE proc_ticket_func IS
	vn_no_of_tickets NUMBER(3);
	BEGIN
		vn_no_of_tickets := func_ticket_ct;
		DBMS_OUTPUT.PUT_LINE('There are ' || vn_no_of_tickets || ' guests who have tickets.');
	END proc_ticket_func;
	
	FUNCTION func_rating_avg RETURN NUMBER IS
	vn_rating_avg NUMBER(2);
	BEGIN
		SELECT AVG(r.rating)
		INTO vn_rating_avg
		FROM retreat_settings rs, TABLE(rs.reviews) r;
		RETURN vn_rating_avg;
	END func_rating_avg;
	PROCEDURE proc_rating_func IS
	vn_avg_rating NUMBER(2);
	BEGIN
		vn_avg_rating := func_rating_avg;
		DBMS_OUTPUT.PUT_LINE('The average accommodation rating is ' || vn_avg_rating);
	END proc_rating_func;
END;
/


-- TRIGGERS --

-- Trigger that displays whether a guest is an adult or a minor
CREATE OR REPLACE TRIGGER trig_age_category
AFTER INSERT OR UPDATE OF date_of_birth 
ON guests 
FOR EACH ROW
WHEN (NEW.date_of_birth IS NOT NULL)
DECLARE
vn_age NUMBER(5,2);
BEGIN 
	vn_age := MONTHS_BETWEEN(SYSDATE, :NEW.date_of_birth)/12;
	IF vn_age < 18 THEN 
		DBMS_OUTPUT.PUT_LINE('The person is a minor aged ' || vn_age || '.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('The person is an adult aged ' ||vn_age || '.');
	END IF;
	EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE(SQLERRM);
END trig_age_category;
/

-- Trigger that displays an error message in case of an invalid birth date
CREATE OR REPLACE TRIGGER trig_invalid_date
AFTER INSERT OR UPDATE OF date_of_birth
ON guests
FOR EACH ROW
WHEN(NEW.date_of_birth>SYSDATE)
BEGIN
	RAISE_APPLICATION_ERROR(-20000, 'Invalid date of birth');
END;
/


-- CURSORS --

-- Cursor that modifies the cost of the programme a guest is attending to 0 if that customer has a ticket for it
CREATE OR REPLACE PROCEDURE proc_cur_guests_tickets IS
	CURSOR cur_guests IS
	SELECT guest_id, guest_firstname, guest_surname, email, phone_number, ticket
	FROM guests;
BEGIN
	FOR rec_cur_guests IN cur_guests LOOP
		IF rec_cur_guests.ticket = 'Y' THEN
		UPDATE programmes SET cost = 0 WHERE guest_id = rec_cur_guests.guest_id;
			IF SQL%FOUND THEN
			DBMS_OUTPUT.PUT_LINE(INITCAP(rec_cur_guests.guest_firstname) || ' ' || INITCAP(rec_cur_guests.guest_surname) || ' has a ticket so they don''t have to pay for their programme.');
			ELSE
			DBMS_OUTPUT.PUT_LINE(INITCAP(rec_cur_guests.guest_firstname) || ' ' || INITCAP(rec_cur_guests.guest_surname) || ' has a ticket but they''re not participating in any programmes.');
			END IF;
		END IF;
	END LOOP;
	EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE(SQLERRM);
END proc_cur_guests_tickets;
/


-- Video commands to run --

/*
COLUMN object_name FORMAT A30
COLUMN object_type FORMAT A12

SELECT TNAME FROM TAB;
SELECT object_name, object_type FROM user_objects;

SELECT retreat_setting_id, r.title, r.rating
FROM retreat_settings rs, TABLE(rs.reviews) r;

exec proc_review_deletion(100, 6)

SELECT retreat_setting_id, r.title, r.rating
FROM retreat_settings rs, TABLE(rs.reviews) r;


SELECT a.ambassador_id, a.ambassador_firstname, a.ambassador_surname
FROM programmes p, TABLE(p.ambassadors) a;

exec proc_ambassador_username(508)


SELECT a.ambassador_id, a.salary
FROM programmes p, TABLE(p.ambassadors) a;

exec funcs_procs.proc_salary_func


SELECT guest_id, ticket
FROM guests;

exec funcs_procs.proc_ticket_func


SELECT retreat_setting_id, r.rating
FROM retreat_settings rs, TABLE(rs.reviews) r;

exec funcs_procs.proc_rating_func

INSERT INTO guests(guest_id, guest_firstname, date_of_birth)
VALUES (1010, 'STEFAN', '06-OCT-2001');

INSERT INTO guests(guest_id, guest_firstname, date_of_birth)
VALUES (1011, 'IRRELEVANT', '10-JUL-2025');


SELECT g.guest_id, g.guest_firstname, g.guest_surname, g.ticket, p.programme_id, p.cost
FROM guests g
JOIN programmes p
ON g.guest_id = p.guest_id;

COLUMN guest_firstname FORMAT A15
COLUMN guest_surname FORMAT A15

exec proc_cur_guests_tickets



DROP PROCEDURE proc_review_deletion;
DROP FUNCTION func_ambassador_username;
DROP PROCEDURE proc_ambassador_username;

DROP PACKAGE funcs_procs;

DROP PROCEDURE proc_cur_guests_tickets;

DROP TRIGGER trig_age_category;
DROP TRIGGER trig_invalid_date;

DROP TABLE programmes;
DROP TYPE ambassadors_varray_type;
DROP TYPE ambassadors_type;
DROP TYPE practices_type;
DROP TABLE guests;
DROP TABLE retreat_accommodations;
DROP TABLE accommodations;
DROP TABLE addresses;
DROP TYPE address_type;
DROP TABLE retreat_settings;
DROP TYPE reviews_table_type;
DROP TYPE reviews_type;

PURGE RECYCLEBIN;


SELECT TNAME FROM TAB;
SELECT object_name, object_type FROM user_objects;
*/

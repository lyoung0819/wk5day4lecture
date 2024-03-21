-- STORED FUNCTIONS 

--Take DQL or DML statements and write them into a stored function so you can call for the function

-- Example: 
-- We are often asked to get the count of actors who have a last name starting with _

-- How many actors are there whose last name starts with a?
SELECT count(*)
FROM actor a 
WHERE last_name LIKE 'A%'; -- 7

-- What about b? 
SELECT count(*)
FROM actor a 
WHERE last_name LIKE 'B%'; -- 22 

-- What about c?
SELECT count(*)
FROM actor a 
WHERE last_name LIKE 'C%'; -- 15

-- Create a stored function that will return the count of actors 
-- with a last name starting with the given letter 

-- SYNTAX: CREATE FUNCTION name_of_function(arguments DATATYPE(num)) 
-- RETURNS DATATYPE
-- LANGUAGE plpssql
-- AS $$ 
	-- DECLARE variable_name DATATYPE;
--BEGIN
	-- QUERY DEFINITION < >with CONCAT(letter, '&');
--END;

--$$;

CREATE OR REPLACE FUNCTION get_actor_count(num INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
	DECLARE actor_count INTEGER;
BEGIN
	SELECT count(*)
	INTO actor_count
	FROM actor a 
	WHERE last_name ILIKE CONCAT(letter, '%');
	RETURN actor_count;
END;
$$;


-- Execute the function: use SELECT
SELECT get_actor_count('A');
SELECT get_actor_count('B');
SELECT get_actor_count('Z');
SELECT get_actor_count('a');

-- To DELETE a stored function, use the DROP clause 
-- DROP FUNCTION IF EXISTS function_name *if function_name is unique
-- DOP FUNCTION IF EXSISTS function_name(argtype) *if function_name NOT unique

DROP FUNCTION IF EXISTS get_actor_count(int4);

-- Stored Functions can return a table 
-- must outline what the table looks like
-- Example: We are often asked to provide a table of all customers that live in *country*
-- We want the first name, last name, address, city and district, and country

SELECT first_name, last_name, address, city, district, country 
FROM customer c 
JOIN address a
ON c.address_id = a.address_id 
JOIN city ci
ON a.city_id = ci.city_id 
JOIN country co
ON ci.country_id = co.country_id
WHERE country = 'China';


-- Write above query into function
CREATE OR REPLACE FUNCTION customers_in_country(country_name VARCHAR)
RETURNS TABLE ( -- define what the TABLE looks like
	first_name VARCHAR,
	last_name VARCHAR,
	address VARCHAR,
	city VARCHAR,
	district VARCHAR,
	country VARCHAR 
) 
LANGUAGE plpgsql
AS $$
BEGIN 
	RETURN QUERY -- we want this to run this query, this IS ALL one command, so ONLY one semi colon
	SELECT c.first_name, c.last_name, a.address, ci.city, a.district, co.country 
	FROM customer c 
	JOIN address a
	ON c.address_id = a.address_id 
	JOIN city ci
	ON a.city_id = ci.city_id 
	JOIN country co
	ON ci.country_id = co.country_id
	WHERE co.country = country_name;
END;
$$;

-- To executed a function that returns a table - use SELECT ... FROM function_name
SELECT * FROM customers_in_country('United States');

SELECT * FROM customers_in_country('Mexico');

SELECT * FROM customers_in_country('Canada')
WHERE district = 'Ontario';

-- This is a procedure that is not giving us a return back
UPDATE customer 
SET first_name = 'Patty'
WHERE customer_id = 2; 


-- FUNCTIONS v PROCEDURES
-- https://www.enterprisedb.com/postgres-tutorials/everything-you-need-know-about-postgres-stored-procedures-and-functions

-- STORED PROCEDURES

-- To CREATE a PROCEDURE, very similar to Fucntion but leaving out a RETURNS

-- Example: Reset all of the loyalty_member = False (in customer)
UPDATE customer
SET loyalty_member = FALSE;

SELECT * FROM customer c 
WHERE loyalty_member = FALSE;

-- Create a Procedure that will make any customer who has spent > $100 a loyalty member
-- Step1. Subquery! Will first need to find customers who've spent >= $100 
SELECT customer_id
FROM payment p
GROUP BY customer_id 
HAVING SUM(amount) >= '100';

-- Step2. Write an update statement to set the above customers as loyalty members
UPDATE customer 
SET loyalty_member = TRUE 
WHERE customer_id IN (
	SELECT customer_id
	FROM payment p
	GROUP BY customer_id 
	HAVING SUM(amount) >= '100'
);

SELECT * FROM customer c
WHERE loyalty_member = FALSE;

-- Step3. Take Step2 and put it into a stored procedure
CREATE OR REPLACE PROCEDURE update_loyalty_status()
LANGUAGE plpgsql
AS $$
BEGIN 
	UPDATE customer 
	SET loyalty_member = TRUE 
	WHERE customer_id IN (
		SELECT customer_id
		FROM payment p
		GROUP BY customer_id 
		HAVING SUM(amount) >= '100'
);
END;
$$;

SELECT * FROM customer;

-- To Execute a Prodcedure - use CALL
CALL update_loyalty_status(); 
SELECT * FROM customer
WHERE loyalty_member = TRUE;

-- Let's pretend that a user close to the threshold makes a new payment 
SELECT customer_id, SUM(amount)
FROM payment p 
GROUP BY customer_id 
HAVING SUM(amount) BETWEEN 95 AND 100;

-- Make a new payment
INSERT INTO payment(customer_id, staff_id, rental_id, amount, payment_date)
VALUES (175, 1, 1, 4.99, '2024-03-21 12:02:30');

-- Call the procedure again
CALL update_loyalty_status();

-- Check 
SELECT * FROM customer c 
WHERE customer_id = 175;

-- Creating a procedure for instering data

SELECT * FROM actor a;

SELECT NOW(); -- lil f(x) TO give us CURRENT time 

-- Manual process below: 
INSERT INTO actor(first_name, last_name, last_update)
VALUES (
	'Cillian', 'Murphy', NOW()
);

INSERT INTO actor(first_name, last_name, last_update)
VALUES (
	'Emma', 'Stone', NOW()
);

CREATE OR REPLACE PROCEDURE add_actor(first_name VARCHAR, last_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN 
	INSERT INTO actor(first_name, last_name, last_update)
	VALUES (first_name, last_name, NOW());
END;
$$;

CALL add_actor('Lexie', 'Young');

SELECT * FROM actor a 
WHERE first_name LIKE 'L%';
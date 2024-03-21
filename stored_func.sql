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

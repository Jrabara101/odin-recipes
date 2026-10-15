-- ==============================================================================
-- SQLZoo Tutorial 0: SELECT basics
-- Table Schema: world(name, continent, area, population, gdp)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Show population of Germany
-- The example uses a WHERE clause to show the population of 'France'.
-- Modify it to show the population of 'Germany'.
-- ------------------------------------------------------------------------------
SELECT population 
FROM world
WHERE name = 'Germany';

-- ------------------------------------------------------------------------------
-- 2. Scandinavia (IN keyword)
-- Checking a list: The word IN allows us to check if an item is in a list.
-- Show the name and the population for 'Sweden', 'Norway' and 'Denmark'.
-- ------------------------------------------------------------------------------
SELECT name, population 
FROM world
WHERE name IN ('Sweden', 'Norway', 'Denmark');

-- ------------------------------------------------------------------------------
-- 3. Just the right size (BETWEEN keyword)
-- Which countries are not too small and not too big? 
-- BETWEEN allows range checking (range specified is inclusive of boundary values).
-- Modify the query to show the country and the area for countries with an area
-- between 200,000 and 250,000 sq km.
-- ------------------------------------------------------------------------------
SELECT name, area 
FROM world
WHERE area BETWEEN 200000 AND 250000;


-- ==============================================================================
-- SELECT Quiz (Basics) Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the code which produces this table:
--   Bahrain   | 1234571
--   Swaziland | 1249365
--   Timor-Leste | 1066409
-- Answer:
--   SELECT name, population
--   FROM world
--   WHERE population BETWEEN 1000000 AND 1250000;
--
-- Question 2: Select the code that shows the value of population for 'China'
-- Answer:
--   SELECT population
--   FROM world
--   WHERE name = 'China';
--
-- Question 3: Select the code which shows the countries that end in A or L
-- Answer:
--   SELECT name FROM world
--   WHERE name LIKE '%a' OR name LIKE '%l';
--
-- Question 4: Pick the result from the query:
--   SELECT name, length(name) FROM world WHERE length(name)=5 and region='Europe'
-- Answer:
--   Table showing 5-letter European country names (e.g., Italy 5, Malta 5, Spain 5).
--
-- Question 5: Pick the result from the query:
--   SELECT name, area*2 FROM world WHERE population = 64000
-- Answer:
--   Table showing Andorra with area*2 = 936.
--
-- Question 6: Select the code which shows the countries with an area larger than 50000
--             and a population smaller than 10000000
-- Answer:
--   SELECT name, area, population
--   FROM world
--   WHERE area > 50000 AND population < 10000000;
--
-- Question 7: Select the code that shows the population density of China, Nigeria, France, Australia
-- Answer:
--   SELECT name, population/area
--   FROM world
--   WHERE name IN ('China', 'Nigeria', 'France', 'Australia');

-- ==============================================================================
-- SQLZoo Tutorial 5: SUM and COUNT
-- Table Schema: world(name, continent, area, population, gdp)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Total world population
-- Show the total population of the world.
-- ------------------------------------------------------------------------------
SELECT SUM(population) 
FROM world;

-- ------------------------------------------------------------------------------
-- 2. List of continents
-- List all the continents - just once each.
-- ------------------------------------------------------------------------------
SELECT DISTINCT continent 
FROM world;

-- ------------------------------------------------------------------------------
-- 3. GDP of Africa
-- Give the total GDP of Africa.
-- ------------------------------------------------------------------------------
SELECT SUM(gdp) 
FROM world
WHERE continent = 'Africa';

-- ------------------------------------------------------------------------------
-- 4. Count the big countries
-- How many countries have an area of at least 1,000,000 sq km?
-- ------------------------------------------------------------------------------
SELECT COUNT(name) 
FROM world
WHERE area >= 1000000;

-- ------------------------------------------------------------------------------
-- 5. Baltic states population
-- What is the total population of ('Estonia', 'Latvia', 'Lithuania')?
-- ------------------------------------------------------------------------------
SELECT SUM(population) 
FROM world
WHERE name IN ('Estonia', 'Latvia', 'Lithuania');

-- ------------------------------------------------------------------------------
-- 6. Counting the countries of each continent
-- For each continent show the continent and number of countries.
-- ------------------------------------------------------------------------------
SELECT continent, COUNT(name) AS country_count
FROM world
GROUP BY continent;

-- ------------------------------------------------------------------------------
-- 7. Counting big countries in each continent
-- For each continent show the continent and number of countries with
-- populations of at least 10 million.
-- ------------------------------------------------------------------------------
SELECT continent, COUNT(name) AS big_country_count
FROM world
WHERE population >= 10000000
GROUP BY continent;

-- ------------------------------------------------------------------------------
-- 8. Counting big continents
-- List the continents that have a total population of at least 100 million.
-- ------------------------------------------------------------------------------
SELECT continent 
FROM world
GROUP BY continent
HAVING SUM(population) >= 100000000;


-- ==============================================================================
-- SUM and COUNT Quiz Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the statement that shows the sum of population of all
--             countries in 'Europe'.
-- Answer:
--   SELECT SUM(population) FROM bbc WHERE region = 'Europe';
--
-- Question 2: Select the statement that shows the number of countries with
--             population smaller than 150000.
-- Answer:
--   SELECT COUNT(name) FROM bbc WHERE population < 150000;
--
-- Question 3: Select the list of core SQL aggregate functions.
-- Answer:
--   AVG(), COUNT(), MAX(), MIN(), SUM()
--
-- Question 4: Select the result that would be obtained from:
--             SELECT region, SUM(area) FROM bbc WHERE SUM(area) > 15000000 GROUP BY region
-- Answer:
--   No result due to invalid use of the WHERE function.
--   (Explanation: Aggregate functions like SUM() cannot be used in a WHERE clause;
--    they must be filtered using a HAVING clause).
--
-- Question 5: Select the statement that shows the average population of
--             'Poland', 'Germany' and 'Denmark'.
-- Answer:
--   SELECT AVG(population) FROM bbc WHERE name IN ('Poland', 'Germany', 'Denmark');
--
-- Question 6: Select the statement that shows a group and the density of the region.
-- Answer:
--   SELECT region, SUM(population)/SUM(area) AS density FROM bbc GROUP BY region;
--
-- Question 7: Select the statement that shows the name and density of the country
--             with the largest population in the database.
-- Answer:
--   SELECT name, population/area AS density FROM bbc WHERE population = (SELECT MAX(population) FROM bbc);

-- ==============================================================================
-- SQLZoo Tutorial 2: SELECT from World
-- Table Schema: world(name, continent, area, population, gdp, capital)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Introduction
-- Observe the result of running this SQL command to show the name, continent
-- and population of all countries.
-- ------------------------------------------------------------------------------
SELECT name, continent, population 
FROM world;

-- ------------------------------------------------------------------------------
-- 2. Large Countries
-- Show the name for the countries that have a population of at least 200 million.
-- (200 million is 200000000, there are eight zeros).
-- ------------------------------------------------------------------------------
SELECT name 
FROM world
WHERE population >= 200000000;

-- ------------------------------------------------------------------------------
-- 3. Per capita GDP
-- Give the name and the per capita GDP for those countries with a population
-- of at least 200 million.
-- ------------------------------------------------------------------------------
SELECT name, gdp / population AS per_capita_gdp
FROM world
WHERE population >= 200000000;

-- ------------------------------------------------------------------------------
-- 4. South America In millions
-- Show the name and population in millions for the countries of the continent
-- 'South America'. Divide the population by 1000000 to get population in millions.
-- ------------------------------------------------------------------------------
SELECT name, population / 1000000 AS population_millions
FROM world
WHERE continent = 'South America';

-- ------------------------------------------------------------------------------
-- 5. France, Germany, Italy
-- Show the name and population for France, Germany, Italy.
-- ------------------------------------------------------------------------------
SELECT name, population 
FROM world
WHERE name IN ('France', 'Germany', 'Italy');

-- ------------------------------------------------------------------------------
-- 6. United
-- Show the countries which have a name that includes the word 'United'.
-- ------------------------------------------------------------------------------
SELECT name 
FROM world
WHERE name LIKE '%United%';

-- ------------------------------------------------------------------------------
-- 7. Two ways to be big
-- Two ways to be big: A country is big if it has an area of more than 3 million
-- sq km or it has a population of more than 250 million.
-- Show the countries that are big by area or big by population. Show name, population and area.
-- ------------------------------------------------------------------------------
SELECT name, population, area 
FROM world
WHERE area > 3000000 OR population > 250000000;

-- ------------------------------------------------------------------------------
-- 8. One or the other (Exclusive OR)
-- Exclusive OR (XOR). Show the countries that are big by area (> 3 million sq km)
-- or big by population (> 250 million) but not both. Show name, population and area.
-- ------------------------------------------------------------------------------
SELECT name, population, area 
FROM world
WHERE area > 3000000 XOR population > 250000000;
-- Standard SQL alternative without XOR keyword:
-- WHERE (area > 3000000 AND population <= 250000000)
--    OR (area <= 3000000 AND population > 250000000);

-- ------------------------------------------------------------------------------
-- 9. Rounding
-- Show the name and population in millions and the GDP in billions for the
-- countries of the continent 'South America'. Use the ROUND function to show
-- the values to two decimal places.
-- ------------------------------------------------------------------------------
SELECT name, 
       ROUND(population / 1000000, 2) AS population_millions, 
       ROUND(gdp / 1000000000, 2) AS gdp_billions
FROM world
WHERE continent = 'South America';

-- ------------------------------------------------------------------------------
-- 10. Trillion dollar economies
-- Show the name and per-capita GDP for those countries with a GDP of at least
-- one trillion (1000000000000; that is 12 zeros). Round this value to the nearest 1000.
-- ------------------------------------------------------------------------------
SELECT name, ROUND(gdp / population, -3) AS per_capita_gdp
FROM world
WHERE gdp >= 1000000000000;

-- ------------------------------------------------------------------------------
-- 11. Name and capital have the same length
-- Greece has capital Athens. Each has 6 characters.
-- Show the name and capital where the name and the capital have the same number of characters.
-- ------------------------------------------------------------------------------
SELECT name, capital 
FROM world
WHERE LENGTH(name) = LENGTH(capital);

-- ------------------------------------------------------------------------------
-- 12. Matching start letters
-- The capital of Sweden is Stockholm. Both start with the letter 'S'.
-- Show the name and the capital where the first letters of each match.
-- Don't include countries where the name and the capital are the same word.
-- ------------------------------------------------------------------------------
SELECT name, capital 
FROM world
WHERE LEFT(name, 1) = LEFT(capital, 1) AND name <> capital;

-- ------------------------------------------------------------------------------
-- 13. All the vowels
-- Equatorial Guinea and Dominican Republic have all of the vowels (a e i o u).
-- Find the country that has all the vowels and no spaces in its name.
-- ------------------------------------------------------------------------------
SELECT name 
FROM world
WHERE name LIKE '%a%'
  AND name LIKE '%e%'
  AND name LIKE '%i%'
  AND name LIKE '%o%'
  AND name LIKE '%u%'
  AND name NOT LIKE '% %';


-- ==============================================================================
-- BBC / World Quiz Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the code which gives the name of countries beginning with U
-- Answer:
--   SELECT name FROM world WHERE name LIKE 'U%';
--
-- Question 2: Select the code which shows the population of the United Kingdom
-- Answer:
--   SELECT population FROM world WHERE name = 'United Kingdom';
--
-- Question 3: 'name' should be name (syntax error identification)
-- Answer:
--   The query fails because column names cannot be in quotes when referenced as identifier.
--
-- Question 4: Select the result that would be obtained from:
--             SELECT name, population/10 FROM world WHERE population < 10000
-- Answer:
--   Nauru | 990
--
-- Question 5: Select the code which shows the countries and population of Europe and Asia
-- Answer:
--   SELECT name, population FROM world WHERE continent IN ('Europe', 'Asia');
--
-- Question 6: Select the code which gives two rows: Cuba, Togo
-- Answer:
--   SELECT name FROM world WHERE name IN ('Cuba', 'Togo');
--
-- Question 7: Select the result that would be obtained from:
--             SELECT name FROM world WHERE continent = 'South America' AND population > 40000000
-- Answer:
--   Brazil
--   Colombia

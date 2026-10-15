-- ==============================================================================
-- SQLZoo Tutorial 4: SELECT within SELECT (Subqueries)
-- Table Schema: world(name, continent, area, population, gdp)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Bigger than Russia
-- List each country name where the population is larger than that of 'Russia'.
-- ------------------------------------------------------------------------------
SELECT name 
FROM world
WHERE population > (
    SELECT population 
    FROM world
    WHERE name = 'Russia'
);

-- ------------------------------------------------------------------------------
-- 2. Richer than UK
-- Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.
-- ------------------------------------------------------------------------------
SELECT name 
FROM world
WHERE continent = 'Europe'
  AND (gdp / population) > (
      SELECT gdp / population 
      FROM world
      WHERE name = 'United Kingdom'
  );

-- ------------------------------------------------------------------------------
-- 3. Neighbours of Argentina and Australia
-- List the name and continent of countries in the continents containing either
-- Argentina or Australia. Order by name of the country.
-- ------------------------------------------------------------------------------
SELECT name, continent 
FROM world
WHERE continent IN (
    SELECT continent 
    FROM world
    WHERE name IN ('Argentina', 'Australia')
)
ORDER BY name;

-- ------------------------------------------------------------------------------
-- 4. Between Canada and Poland (or United Kingdom and Germany)
-- Which country has a population that is more than United Kingdom but less
-- than Germany? Show the name and the population.
-- ------------------------------------------------------------------------------
SELECT name, population 
FROM world
WHERE population > (
    SELECT population 
    FROM world 
    WHERE name = 'United Kingdom'
)
  AND population < (
    SELECT population 
    FROM world 
    WHERE name = 'Germany'
);

-- ------------------------------------------------------------------------------
-- 5. Percentages of Germany
-- Germany (population 80 million) has the largest population of the countries
-- in Europe. Austria (population 8.5 million) has 11% of the population of Germany.
-- Show the name and the population of each country in Europe.
-- Show the population as a percentage of the population of Germany.
-- Format: name, percentage (e.g. 11% using CONCAT and ROUND).
-- ------------------------------------------------------------------------------
SELECT name, 
       CONCAT(ROUND((population / (SELECT population FROM world WHERE name = 'Germany')) * 100), '%') AS percentage
FROM world
WHERE continent = 'Europe';

-- ------------------------------------------------------------------------------
-- 6. Bigger than every country in Europe
-- Which countries have a GDP greater than every country in Europe?
-- [Give the name only.] (Some countries may have NULL gdp values).
-- The keyword ALL ensures the condition holds for every element in the subquery.
-- ------------------------------------------------------------------------------
SELECT name 
FROM world
WHERE gdp > ALL (
    SELECT gdp 
    FROM world
    WHERE continent = 'Europe' 
      AND gdp > 0
);

-- ------------------------------------------------------------------------------
-- 7. Largest in each continent
-- Find the largest country (by area) in each continent, show the continent,
-- the name and the area.
-- Correlated Subquery: the inner query references the outer query row (x.continent).
-- ------------------------------------------------------------------------------
SELECT continent, name, area 
FROM world x
WHERE area >= ALL (
    SELECT area 
    FROM world y
    WHERE y.continent = x.continent
      AND area > 0
);

-- ------------------------------------------------------------------------------
-- 8. First country of each continent (alphabetically)
-- List each continent and the name of the country that comes first alphabetically.
-- ------------------------------------------------------------------------------
SELECT continent, name 
FROM world x
WHERE name <= ALL (
    SELECT name 
    FROM world y
    WHERE y.continent = x.continent
);

-- ------------------------------------------------------------------------------
-- 9. Difficult Questions That Utilize Techniques Not Covered In Prior Sections
-- Find the continents where all countries have a population <= 25000000.
-- Then find the names of the countries associated with these continents.
-- Show name, continent and population.
-- ------------------------------------------------------------------------------
SELECT name, continent, population 
FROM world x
WHERE 25000000 >= ALL (
    SELECT population 
    FROM world y
    WHERE y.continent = x.continent
);

-- ------------------------------------------------------------------------------
-- 10. Three times bigger
-- Some countries have populations more than three times that of all of their
-- neighbours (in the same continent). Give the countries and continents.
-- ------------------------------------------------------------------------------
SELECT name, continent 
FROM world x
WHERE population > ALL (
    SELECT population * 3 
    FROM world y
    WHERE y.continent = x.continent 
      AND y.name <> x.name
);


-- ==============================================================================
-- Nested SELECT Quiz Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the code that shows the name, region and population of the
--             smallest country in each region.
-- Answer:
--   SELECT region, name, population 
--   FROM bbc x 
--   WHERE population <= ALL (SELECT population 
--                            FROM bbc y 
--                            WHERE y.region = x.region AND population > 0);
--
-- Question 2: Select the code that shows the countries belonging to regions with all
--             populations over 50000.
-- Answer:
--   SELECT name, region, population 
--   FROM bbc x 
--   WHERE 50000 < ALL (SELECT population 
--                       FROM bbc y 
--                       WHERE y.region = x.region AND population > 0);
--
-- Question 3: Select the code that shows the countries the population of which
--             is larger than the population of all countries in Europe.
-- Answer:
--   SELECT name 
--   FROM bbc 
--   WHERE population > ALL (SELECT population 
--                           FROM bbc 
--                           WHERE region = 'Europe');
--
-- Question 4: Select the code that shows the countries that have a population greater
--             than the population of chairman countries in South America.
-- Answer:
--   SELECT name 
--   FROM bbc 
--   WHERE population > (SELECT MAX(population) 
--                       FROM bbc 
--                       WHERE region = 'South America');
--
-- Question 5: Select the code that would show the countries with a greater GDP than
--             any country in Africa (some countries may have NULL gdp values).
-- Answer:
--   SELECT name 
--   FROM bbc 
--   WHERE gdp > (SELECT MAX(gdp) 
--                FROM bbc 
--                WHERE region = 'Africa');
--   (Note: Using MAX(gdp) handles NULLs properly, unlike a bare > ALL that fails when NULLs exist).

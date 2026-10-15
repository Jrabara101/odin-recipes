-- ==============================================================================
-- SQLZoo Tutorial 9+: Window LAG (COVID-19 Pandemic Dataset)
-- Tables:
--   covid(name, whn, confirmed, deaths, recovered)
--   world(name, continent, area, population, gdp)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Introducing the covid table
-- The example uses a WHERE clause to show the cases in 'Italy' in March.
-- Modify the query to show data from Spain.
-- ------------------------------------------------------------------------------
SELECT name, DAY(whn) AS day_of_month, confirmed, deaths, recovered
FROM covid
WHERE name = 'Spain' 
  AND MONTH(whn) = 3
ORDER BY whn;

-- ------------------------------------------------------------------------------
-- 2. Introducing the LAG function
-- The LAG function shows data from the preceding row of the table.
-- Modify the query to show confirmed for the day before.
-- ------------------------------------------------------------------------------
SELECT name, DAY(whn) AS day_of_month, confirmed,
       LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS confirmed_yesterday
FROM covid
WHERE name = 'Italy' 
  AND MONTH(whn) = 3
ORDER BY whn;

-- ------------------------------------------------------------------------------
-- 3. Number of new cases
-- The number of confirmed cases is cumulative - but we can use LAG to recover
-- the number of new cases reported for each day.
-- Show the number of new cases for each day, for Italy, for March.
-- ------------------------------------------------------------------------------
SELECT name, DAY(whn) AS day_of_month,
       confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new_cases
FROM covid
WHERE name = 'Italy' 
  AND MONTH(whn) = 3
ORDER BY whn;

-- ------------------------------------------------------------------------------
-- 4. Weekly changes
-- Show the number of new cases in Italy for each week - show Monday only.
-- In MySQL, WEEKDAY(whn) returns 0 for Monday.
-- ------------------------------------------------------------------------------
SELECT name, 
       DATE_FORMAT(whn, '%Y-%m-%d') AS date_recorded,
       confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS weekly_new_cases
FROM covid
WHERE name = 'Italy' 
  AND WEEKDAY(whn) = 0
ORDER BY whn;

-- ------------------------------------------------------------------------------
-- 5. LAG using a JOIN
-- You can also join a table to itself using date arithmetic.
-- Show the number of new cases in Italy for each week using a JOIN.
-- ------------------------------------------------------------------------------
SELECT tw.name, 
       DATE_FORMAT(tw.whn, '%Y-%m-%d') AS date_recorded, 
       (tw.confirmed - lw.confirmed) AS weekly_new_cases
FROM covid tw
LEFT JOIN covid lw ON (DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn AND tw.name = lw.name)
WHERE tw.name = 'Italy' 
  AND WEEKDAY(tw.whn) = 0
ORDER BY tw.whn;

-- ------------------------------------------------------------------------------
-- 6. Ranking (Deaths & Confirmed)
-- Include the ranking for the number of deaths in the table.
-- Only include rows for '2020-04-20'.
-- ------------------------------------------------------------------------------
SELECT name, 
       confirmed, 
       RANK() OVER (ORDER BY confirmed DESC) AS rnk_confirmed, 
       deaths, 
       RANK() OVER (ORDER BY deaths DESC) AS rnk_deaths
FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC;

-- ------------------------------------------------------------------------------
-- 7. Infection rate ranking
-- Show the infection rate ranking for each country.
-- Only include countries with a population of at least 10 million.
-- Infection rate is measured per 100,000 population.
-- ------------------------------------------------------------------------------
SELECT world.name,
       ROUND(100000 * confirmed / population, 0) AS rate_per_100k,
       RANK() OVER (ORDER BY (100000 * confirmed / population) DESC) AS infection_rank
FROM covid
JOIN world ON (covid.name = world.name)
WHERE whn = '2020-04-20' 
  AND population > 10000000
ORDER BY population DESC;

-- ------------------------------------------------------------------------------
-- 8. Turning the corner (Peak daily new cases)
-- For each country that has had at least 1000 new cases in a single day,
-- show the date of the peak number of new cases.
-- ------------------------------------------------------------------------------
WITH daily_new_cases AS (
    SELECT name, 
           whn, 
           confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS day_count
    FROM covid
),
ranked_peaks AS (
    SELECT name, 
           whn, 
           day_count,
           RANK() OVER (PARTITION BY name ORDER BY day_count DESC) AS peak_rank
    FROM daily_new_cases
    WHERE day_count >= 1000
)
SELECT name, 
       DATE_FORMAT(whn, '%Y-%m-%d') AS peak_date, 
       day_count AS peak_count
FROM ranked_peaks
WHERE peak_rank = 1
ORDER BY peak_date ASC;

-- ==============================================================================
-- SQLZoo Tutorial 3: SELECT from Nobel
-- Table Schema: nobel(yr, subject, winner)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Winners from 1950
-- Change the query shown so that it displays Nobel prizes for 1950.
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE yr = 1950;

-- ------------------------------------------------------------------------------
-- 2. 1962 Literature
-- Show who won the 1962 prize for literature.
-- ------------------------------------------------------------------------------
SELECT winner 
FROM nobel
WHERE yr = 1962 
  AND subject = 'literature';

-- ------------------------------------------------------------------------------
-- 3. Albert Einstein
-- Show the year and subject that won 'Albert Einstein' his prize.
-- ------------------------------------------------------------------------------
SELECT yr, subject 
FROM nobel
WHERE winner = 'Albert Einstein';

-- ------------------------------------------------------------------------------
-- 4. Recent Peace Prizes
-- Give the name of the 'peace' winners since the year 2000, including 2000.
-- ------------------------------------------------------------------------------
SELECT winner 
FROM nobel
WHERE subject = 'peace' 
  AND yr >= 2000;

-- ------------------------------------------------------------------------------
-- 5. Literature in the 1980's
-- Show all details (yr, subject, winner) of the literature prize winners
-- for 1980 to 1989 inclusive.
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE subject = 'literature' 
  AND yr BETWEEN 1980 AND 1989;

-- ------------------------------------------------------------------------------
-- 6. Only Presidents
-- Show all details of the presidential winners:
-- Theodore Roosevelt, Thomas Woodrow Wilson, Jimmy Carter, Barack Obama.
-- (Note: in database, Woodrow Wilson is listed as 'Woodrow Wilson').
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE winner IN ('Theodore Roosevelt', 'Woodrow Wilson', 'Jimmy Carter', 'Barack Obama');

-- ------------------------------------------------------------------------------
-- 7. John
-- Show the winners with first name John.
-- ------------------------------------------------------------------------------
SELECT winner 
FROM nobel
WHERE winner LIKE 'John %';

-- ------------------------------------------------------------------------------
-- 8. Chemistry and Physics
-- Show the year, subject, and name of physics winners for 1980 together with
-- the chemistry winners for 1984.
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE (subject = 'physics' AND yr = 1980) 
   OR (subject = 'chemistry' AND yr = 1984);

-- ------------------------------------------------------------------------------
-- 9. Exclude Chemists and Medics
-- Show the year, subject, and name of winners for 1980 excluding chemistry and medicine.
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE yr = 1980 
  AND subject NOT IN ('chemistry', 'medicine');

-- ------------------------------------------------------------------------------
-- 10. Early Medicine, Late Literature
-- Show year, subject, and name of people who won a Medicine prize in an early
-- year (before 1910, not including 1910) together with winners of a Literature
-- prize in a later year (after 2004, including 2004).
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE (subject = 'medicine' AND yr < 1910) 
   OR (subject = 'literature' AND yr >= 2004);

-- ------------------------------------------------------------------------------
-- 11. Umlaut: Peter Grünberg
-- Find all details of the prize won by PETER GRÜNBERG.
-- The character ü can be typed as &uuml; or using an underscore wildcard.
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE winner = 'Peter Grünberg';
-- Wildcard alternative:
-- WHERE winner LIKE 'Peter Gr_nberg';

-- ------------------------------------------------------------------------------
-- 12. Apostrophe: Eugene O'Neill
-- Find all details of the prize won by EUGENE O'NEILL.
-- In SQL, an apostrophe is escaped by doubling it ('').
-- ------------------------------------------------------------------------------
SELECT yr, subject, winner 
FROM nobel
WHERE winner = 'Eugene O''Neill';

-- ------------------------------------------------------------------------------
-- 13. Knights of the Realm
-- List the winners, year and subject where the winner starts with Sir.
-- Show the most recent first, then by name order.
-- ------------------------------------------------------------------------------
SELECT winner, yr, subject 
FROM nobel
WHERE winner LIKE 'Sir %'
ORDER BY yr DESC, winner ASC;

-- ------------------------------------------------------------------------------
-- 14. Chemistry and Physics Last
-- The expression subject IN ('chemistry','physics') can be used as a value (0 or 1).
-- Show the 1984 winners and subject ordered by subject and winner name;
-- but list chemistry and physics last.
-- ------------------------------------------------------------------------------
SELECT winner, subject 
FROM nobel
WHERE yr = 1984
ORDER BY subject IN ('chemistry', 'physics'), subject, winner;


-- ==============================================================================
-- Nobel Quiz Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the code which shows the name of winner's names beginning with C and ending in n
-- Answer:
--   SELECT winner FROM nobel WHERE winner LIKE 'C%' AND winner LIKE '%n';
--
-- Question 2: Select the code that shows how many Chemistry awards were given between 1950 and 1960
-- Answer:
--   SELECT COUNT(subject) FROM nobel WHERE subject = 'Chemistry' AND yr BETWEEN 1950 and 1960;
--
-- Question 3: Pick the code that shows the amount of years where no Medicine awards were given
-- Answer:
--   SELECT COUNT(DISTINCT yr) FROM nobel WHERE yr NOT IN (SELECT DISTINCT yr FROM nobel WHERE subject = 'Medicine');
--
-- Question 4: Select the result that would be obtained from:
--             SELECT subject, winner FROM nobel WHERE winner LIKE '%Sir%' AND yr LIKE '196%'
-- Answer:
--   Medicine | Sir John Eccles
--   Medicine | Sir Frank Macfarlane Burnet
--
-- Question 5: Select the code which would show the year when neither a Physics nor a Chemistry award was given
-- Answer:
--   SELECT yr FROM nobel WHERE yr NOT IN (SELECT yr FROM nobel WHERE subject IN ('Chemistry','Physics'));
--
-- Question 6: Select the code which shows the years when a Medicine award was given but no Peace or Literature award was
-- Answer:
--   SELECT DISTINCT yr FROM nobel WHERE subject='Medicine' 
--   AND yr NOT IN(SELECT yr FROM nobel WHERE subject='Literature')
--   AND yr NOT IN (SELECT yr FROM nobel WHERE subject='Peace');
--
-- Question 7: Pick the result that would be obtained from the following code:
--             SELECT subject, COUNT(subject) FROM nobel WHERE yr ='1960' GROUP BY subject
-- Answer:
--   Chemistry 1, Literature 1, Medicine 2, Peace 1, Physics 1

-- ==============================================================================
-- SQLZoo Tutorial 9: Self JOIN (Edinburgh Buses Network)
-- Tables:
--   stops(id, name)
--   route(num, company, pos, stop)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Total stops
-- How many stops are in the database?
-- ------------------------------------------------------------------------------
SELECT COUNT(*) AS total_stops
FROM stops;

-- ------------------------------------------------------------------------------
-- 2. Stop ID for Craiglockhart
-- Find the id value for the stop 'Craiglockhart'.
-- ------------------------------------------------------------------------------
SELECT id 
FROM stops
WHERE name = 'Craiglockhart';

-- ------------------------------------------------------------------------------
-- 3. Stops on service '4' 'LRT'
-- Give the id and the name for the stops on the '4' 'LRT' service.
-- ------------------------------------------------------------------------------
SELECT stops.id, stops.name 
FROM stops 
JOIN route ON (stops.id = route.stop)
WHERE route.num = '4' 
  AND route.company = 'LRT'
ORDER BY route.pos;

-- ------------------------------------------------------------------------------
-- 4. Routes and Joints (HAVING count = 2)
-- The query gives the number of routes that visit either London Road (149)
-- or Craiglockhart (53). Add a HAVING clause to restrict the output to the
-- two services that link both of these stops.
-- ------------------------------------------------------------------------------
SELECT company, num, COUNT(*) AS link_count
FROM route 
WHERE stop = 149 OR stop = 53
GROUP BY company, num
HAVING COUNT(*) = 2;

-- ------------------------------------------------------------------------------
-- 5. Craiglockhart to London Road (Stop IDs)
-- Self join route table to find direct bus routes between Craiglockhart (53)
-- and London Road (149).
-- ------------------------------------------------------------------------------
SELECT a.company, a.num, a.stop, b.stop
FROM route a 
JOIN route b ON (a.company = b.company AND a.num = b.num)
WHERE a.stop = 53 
  AND b.stop = 149;

-- ------------------------------------------------------------------------------
-- 6. Craiglockhart to London Road (Stop Names)
-- Join stops table to refer to stops by name rather than stop IDs.
-- ------------------------------------------------------------------------------
SELECT a.company, a.num, stopa.name, stopb.name
FROM route a 
JOIN route b ON (a.company = b.company AND a.num = b.num)
JOIN stops stopa ON (a.stop = stopa.id)
JOIN stops stopb ON (b.stop = stopb.id)
WHERE stopa.name = 'Craiglockhart' 
  AND stopb.name = 'London Road';

-- ------------------------------------------------------------------------------
-- 7. Haymarket and Leith
-- Give a list of all the services which connect stops 115 and 137
-- ('Haymarket' and 'Leith').
-- ------------------------------------------------------------------------------
SELECT DISTINCT a.company, a.num
FROM route a 
JOIN route b ON (a.company = b.company AND a.num = b.num)
WHERE a.stop = 115 
  AND b.stop = 137;

-- ------------------------------------------------------------------------------
-- 8. Craiglockhart and Tollcross
-- Give a list of the services which connect the stops 'Craiglockhart' and 'Tollcross'.
-- ------------------------------------------------------------------------------
SELECT a.company, a.num
FROM route a 
JOIN route b ON (a.company = b.company AND a.num = b.num)
JOIN stops stopa ON (a.stop = stopa.id)
JOIN stops stopb ON (b.stop = stopb.id)
WHERE stopa.name = 'Craiglockhart' 
  AND stopb.name = 'Tollcross';

-- ------------------------------------------------------------------------------
-- 9. Direct stops from Craiglockhart (LRT only)
-- Give a distinct list of the stops which may be reached from 'Craiglockhart'
-- by taking one bus, including 'Craiglockhart' itself, offered by the LRT company.
-- Include the company and bus no. of the relevant services.
-- ------------------------------------------------------------------------------
SELECT stopb.name, a.company, a.num
FROM route a 
JOIN route b ON (a.company = b.company AND a.num = b.num)
JOIN stops stopa ON (a.stop = stopa.id)
JOIN stops stopb ON (b.stop = stopb.id)
WHERE stopa.name = 'Craiglockhart' 
  AND a.company = 'LRT';

-- ------------------------------------------------------------------------------
-- 10. Two buses from Craiglockhart to Lochend
-- Find the routes involving two buses that can go from Craiglockhart to Lochend.
-- Show the bus no. and company for the first bus, the name of the stop for
-- the transfer, and the bus no. and company for the second bus.
-- ------------------------------------------------------------------------------
SELECT DISTINCT 
       a.num AS first_bus, 
       a.company AS first_company, 
       stopb.name AS transfer_stop, 
       d.num AS second_bus, 
       d.company AS second_company
FROM route a
-- Leg 1: From Craiglockhart to transfer stop
JOIN route b ON (a.company = b.company AND a.num = b.num)
JOIN stops stopa ON (a.stop = stopa.id)
JOIN stops stopb ON (b.stop = stopb.id)
-- Leg 2: From transfer stop to Lochend
JOIN route c ON (b.stop = c.stop)
JOIN route d ON (c.company = d.company AND c.num = d.num)
JOIN stops stopd ON (d.stop = stopd.id)
WHERE stopa.name = 'Craiglockhart' 
  AND stopd.name = 'Lochend'
ORDER BY a.num, stopb.name, d.num;


-- ==============================================================================
-- Self Join Quiz Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the code that would show it is possible to get from
--             Craiglockhart to Haymarket:
-- Answer:
--   SELECT DISTINCT a.name, b.name 
--   FROM stops a 
--   JOIN route z ON a.id = z.stop 
--   JOIN route y ON y.num = z.num AND y.company = z.company 
--   JOIN stops b ON y.stop = b.id 
--   WHERE a.name = 'Craiglockhart' AND b.name = 'Haymarket';
--
-- Question 2: Select the code that shows the stops that are on route.num '2A'
--             which can be reached with one bus from Haymarket:
-- Answer:
--   SELECT S2.id, S2.name, R2.company, R2.num 
--   FROM stops S1, stops S2, route R1, route R2 
--   WHERE S1.name = 'Haymarket' 
--     AND S1.id = R1.stop 
--     AND R1.company = R2.company 
--     AND R1.num = R2.num 
--     AND R2.stop = S2.id 
--     AND R1.num = '2A';
--
-- Question 3: Select the code that shows a sensible join for the route table:
-- Answer:
--   SELECT a.company, a.num, stopa.name, stopb.name 
--   FROM route a 
--   JOIN route b ON (a.company = b.company AND a.num = b.num) 
--   JOIN stops stopa ON (a.stop = stopa.id) 
--   JOIN stops stopb ON (b.stop = stopb.id);

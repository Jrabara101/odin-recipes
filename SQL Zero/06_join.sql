-- ==============================================================================
-- SQLZoo Tutorial 6: The JOIN Operation (Euro 2012 Football Database)
-- Tables:
--   game(id, mdate, stadium, team1, team2)
--   goal(matchid, teamid, player, gtime)
--   eteam(id, teamname, coach)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. German goals
-- Show the matchid and player name for all goals scored by Germany.
-- To identify German players, check for: teamid = 'GER'
-- ------------------------------------------------------------------------------
SELECT matchid, player 
FROM goal 
WHERE teamid = 'GER';

-- ------------------------------------------------------------------------------
-- 2. Match 1012
-- Show id, stadium, team1, team2 for just game 1012.
-- ------------------------------------------------------------------------------
SELECT id, stadium, team1, team2 
FROM game
WHERE id = 1012;

-- ------------------------------------------------------------------------------
-- 3. Details of German goals
-- Modify the query to show the player, teamid, stadium and mdate for every
-- German goal.
-- ------------------------------------------------------------------------------
SELECT goal.player, goal.teamid, game.stadium, game.mdate
FROM game 
JOIN goal ON (game.id = goal.matchid)
WHERE goal.teamid = 'GER';

-- ------------------------------------------------------------------------------
-- 4. Mario goals
-- Show the team1, team2 and player for every goal scored by a player called Mario.
-- ------------------------------------------------------------------------------
SELECT game.team1, game.team2, goal.player
FROM game 
JOIN goal ON (game.id = goal.matchid)
WHERE goal.player LIKE 'Mario%';

-- ------------------------------------------------------------------------------
-- 5. Early goals (first 10 minutes)
-- Show player, teamid, coach, gtime for all goals scored in the first 10 minutes
-- (gtime <= 10).
-- ------------------------------------------------------------------------------
SELECT goal.player, goal.teamid, eteam.coach, goal.gtime
FROM goal 
JOIN eteam ON (goal.teamid = eteam.id)
WHERE goal.gtime <= 10;

-- ------------------------------------------------------------------------------
-- 6. Fernando Santos as coach
-- List the dates of the matches and the name of the team in which 'Fernando Santos'
-- was the team1 coach.
-- ------------------------------------------------------------------------------
SELECT game.mdate, eteam.teamname
FROM game 
JOIN eteam ON (game.team1 = eteam.id)
WHERE eteam.coach = 'Fernando Santos';

-- ------------------------------------------------------------------------------
-- 7. National Stadium, Warsaw goals
-- List the player for every goal scored in a game where the stadium was
-- 'National Stadium, Warsaw'.
-- ------------------------------------------------------------------------------
SELECT goal.player
FROM goal 
JOIN game ON (goal.matchid = game.id)
WHERE game.stadium = 'National Stadium, Warsaw';

-- ------------------------------------------------------------------------------
-- 8. Goals scored against Germany
-- The example query shows all goals scored in the Germany-Greece quarterfinal.
-- Instead, show the name of all players who scored a goal against Germany.
-- ------------------------------------------------------------------------------
SELECT DISTINCT goal.player
FROM game 
JOIN goal ON (game.id = goal.matchid)
WHERE (game.team1 = 'GER' OR game.team2 = 'GER')
  AND goal.teamid <> 'GER';

-- ------------------------------------------------------------------------------
-- 9. Total goals per team
-- Show teamname and the total number of goals scored.
-- ------------------------------------------------------------------------------
SELECT eteam.teamname, COUNT(goal.player) AS total_goals
FROM eteam 
JOIN goal ON (eteam.id = goal.teamid)
GROUP BY eteam.teamname;

-- ------------------------------------------------------------------------------
-- 10. Goals per stadium
-- Show the stadium and the number of goals scored in each stadium.
-- ------------------------------------------------------------------------------
SELECT game.stadium, COUNT(goal.player) AS total_goals
FROM game 
JOIN goal ON (game.id = goal.matchid)
GROUP BY game.stadium;

-- ------------------------------------------------------------------------------
-- 11. Matches involving Poland
-- For every match involving 'POL', show the matchid, date and the number of goals scored.
-- ------------------------------------------------------------------------------
SELECT game.id, game.mdate, COUNT(goal.player) AS total_goals
FROM game 
JOIN goal ON (game.id = goal.matchid)
WHERE game.team1 = 'POL' OR game.team2 = 'POL'
GROUP BY game.id, game.mdate;

-- ------------------------------------------------------------------------------
-- 12. Matches where Germany scored
-- For every match where 'GER' scored, show matchid, match date and the number
-- of goals scored by 'GER'.
-- ------------------------------------------------------------------------------
SELECT goal.matchid, game.mdate, COUNT(goal.player) AS german_goals
FROM goal 
JOIN game ON (goal.matchid = game.id)
WHERE goal.teamid = 'GER'
GROUP BY goal.matchid, game.mdate;

-- ------------------------------------------------------------------------------
-- 13. Every match with scores (CASE statement matrix)
-- Notice in the query given every goal is listed. If it was a team1 goal then
-- a 1 appears in score1, otherwise there is a 0. You could SUM this column to
-- get a count of the goals scored by team1. Sort your result by mdate, matchid,
-- team1 and team2. Use LEFT JOIN so games with 0-0 score are also included.
-- ------------------------------------------------------------------------------
SELECT game.mdate,
       game.team1,
       SUM(CASE WHEN goal.teamid = game.team1 THEN 1 ELSE 0 END) AS score1,
       game.team2,
       SUM(CASE WHEN goal.teamid = game.team2 THEN 1 ELSE 0 END) AS score2
FROM game 
LEFT JOIN goal ON (game.id = goal.matchid)
GROUP BY game.mdate, game.id, game.team1, game.team2
ORDER BY game.mdate, game.id, game.team1, game.team2;


-- ==============================================================================
-- JOIN Quiz Answer Key & Explanations
-- ==============================================================================
-- Question 1: You want to find the stadium where player 'Dimitris Salpingidis'
--             scored. Select the JOIN condition to use:
-- Answer:
--   game JOIN goal ON (id=matchid)
--
-- Question 2: You JOIN the tables goal and eteam in an SQL statement.
--             Indicate the list of column names that may be used in the SELECT line:
-- Answer:
--   matchid, teamid, player, gtime, id, teamname, coach
--
-- Question 3: Select the code which shows players, their team and the amount of
--             goals they scored against Greece(GRE):
-- Answer:
--   SELECT player, teamid, COUNT(*)
--   FROM game JOIN goal ON matchid = id
--   WHERE (team1 = "GRE" OR team2 = "GRE")
--     AND teamid != 'GRE'
--   GROUP BY player, teamid;
--
-- Question 4: Select the result that would be obtained from this code:
--             SELECT DISTINCT teamid, mdate
--             FROM goal JOIN game ON (matchid = id)
--             WHERE mdate = '9 June 2012';
-- Answer:
--   DEN 9 June 2012
--   GER 9 June 2012
--   POR 9 June 2012
--
-- Question 5: Select the code which would show the player and their team for those
--             who have scored against Poland (POL) in National Stadium, Warsaw:
-- Answer:
--   SELECT DISTINCT player, teamid
--   FROM game JOIN goal ON matchid = id
--   WHERE stadium = 'National Stadium, Warsaw'
--     AND (team1 = 'POL' OR team2 = 'POL')
--     AND teamid != 'POL';
--
-- Question 6: Select the code which shows the player, their team and the time
--             they scored, for players who have played in Stadion Miejski (Wroclaw)
--             but not against Italy (ITA):
-- Answer:
--   SELECT DISTINCT player, teamid, gtime
--   FROM game JOIN goal ON matchid = id
--   WHERE stadium = 'Stadion Miejski (Wroclaw)'
--     AND ((team1 = teamid AND team2 != 'ITA') 
--       OR (team2 = teamid AND team1 != 'ITA'));
--
-- Question 7: Select the result that would be obtained from this code:
--             SELECT teamname, COUNT(*)
--             FROM eteam JOIN goal ON teamid = id
--             GROUP BY teamname
--             HAVING COUNT(*) < 3;
-- Answer:
--   Netherlands 2
--   Poland 2
--   Republic of Ireland 1
--   Ukraine 2

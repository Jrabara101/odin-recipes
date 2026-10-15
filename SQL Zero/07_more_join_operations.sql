-- ==============================================================================
-- SQLZoo Tutorial 7: More JOIN Operations (Movie Database)
-- Tables:
--   movie(id, title, yr, director, budget, gross)
--   actor(id, name)
--   casting(movieid, actorid, ord)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. 1962 movies
-- List the films where the yr is 1962 [Show id, title].
-- ------------------------------------------------------------------------------
SELECT id, title 
FROM movie
WHERE yr = 1962;

-- ------------------------------------------------------------------------------
-- 2. When was Citizen Kane released?
-- Give year of 'Citizen Kane'.
-- ------------------------------------------------------------------------------
SELECT yr 
FROM movie
WHERE title = 'Citizen Kane';

-- ------------------------------------------------------------------------------
-- 3. Star Trek movies
-- List all of the Star Trek movies, include the id, title and yr
-- (all of these movies include the words 'Star Trek' in their title).
-- Order results by year.
-- ------------------------------------------------------------------------------
SELECT id, title, yr 
FROM movie
WHERE title LIKE '%Star Trek%'
ORDER BY yr;

-- ------------------------------------------------------------------------------
-- 4. Glenn Close id
-- What id number does the actor 'Glenn Close' have?
-- ------------------------------------------------------------------------------
SELECT id 
FROM actor
WHERE name = 'Glenn Close';

-- ------------------------------------------------------------------------------
-- 5. Casablanca id
-- What is the id of the film 'Casablanca'?
-- ------------------------------------------------------------------------------
SELECT id 
FROM movie
WHERE title = 'Casablanca';

-- ------------------------------------------------------------------------------
-- 6. Cast list for Casablanca
-- Obtain the cast list for 'Casablanca'.
-- Use movieid = 11768, or use a subquery to look up the id dynamically.
-- ------------------------------------------------------------------------------
SELECT actor.name 
FROM actor
JOIN casting ON (actor.id = casting.actorid)
WHERE casting.movieid = (
    SELECT id 
    FROM movie 
    WHERE title = 'Casablanca'
);

-- ------------------------------------------------------------------------------
-- 7. Alien cast list
-- Obtain the cast list for the film 'Alien'.
-- ------------------------------------------------------------------------------
SELECT actor.name 
FROM actor
JOIN casting ON (actor.id = casting.actorid)
JOIN movie ON (movie.id = casting.movieid)
WHERE movie.title = 'Alien';

-- ------------------------------------------------------------------------------
-- 8. Harrison Ford movies
-- List the films in which 'Harrison Ford' has appeared.
-- ------------------------------------------------------------------------------
SELECT movie.title 
FROM movie
JOIN casting ON (movie.id = casting.movieid)
JOIN actor ON (actor.id = casting.actorid)
WHERE actor.name = 'Harrison Ford';

-- ------------------------------------------------------------------------------
-- 9. Harrison Ford as a supporting actor
-- List the films where 'Harrison Ford' has appeared - but not in the starring role.
-- [Note: the ord field of casting gives the position of the actor. If ord=1 then
-- this actor is in the starring role].
-- ------------------------------------------------------------------------------
SELECT movie.title 
FROM movie
JOIN casting ON (movie.id = casting.movieid)
JOIN actor ON (actor.id = casting.actorid)
WHERE actor.name = 'Harrison Ford'
  AND casting.ord <> 1;

-- ------------------------------------------------------------------------------
-- 10. Lead actors in 1962 films
-- List the films together with the leading star for all 1962 films.
-- ------------------------------------------------------------------------------
SELECT movie.title, actor.name 
FROM movie
JOIN casting ON (movie.id = casting.movieid)
JOIN actor ON (actor.id = casting.actorid)
WHERE movie.yr = 1962 
  AND casting.ord = 1;

-- ------------------------------------------------------------------------------
-- 11. Busy years for Rock Hudson
-- Which were the busiest years for 'Rock Hudson'? Show the year and the number
-- of movies he made each year for any year in which he made more than 2 movies.
-- ------------------------------------------------------------------------------
SELECT movie.yr, COUNT(movie.title) AS movie_count
FROM movie
JOIN casting ON (movie.id = casting.movieid)
JOIN actor ON (actor.id = casting.actorid)
WHERE actor.name = 'Rock Hudson'
GROUP BY movie.yr
HAVING COUNT(movie.title) > 2;

-- ------------------------------------------------------------------------------
-- 12. Lead actor in Julie Andrews movies
-- List the film title and the leading actor for all of the films 'Julie Andrews'
-- played in.
-- ------------------------------------------------------------------------------
SELECT movie.title, actor.name 
FROM movie
JOIN casting ON (movie.id = casting.movieid AND casting.ord = 1)
JOIN actor ON (actor.id = casting.actorid)
WHERE movie.id IN (
    SELECT casting.movieid 
    FROM casting
    JOIN actor ON (actor.id = casting.actorid)
    WHERE actor.name = 'Julie Andrews'
);

-- ------------------------------------------------------------------------------
-- 13. Actors with 15 leading roles
-- Obtain a list, in alphabetical order, of actors who've had at least 15 starring roles.
-- ------------------------------------------------------------------------------
SELECT actor.name 
FROM actor
JOIN casting ON (actor.id = casting.actorid AND casting.ord = 1)
GROUP BY actor.name
HAVING COUNT(casting.ord) >= 15
ORDER BY actor.name ASC;

-- ------------------------------------------------------------------------------
-- 14. 1978 films by cast size
-- List the films released in the year 1978 ordered by the number of actors
-- in the cast, then by title.
-- ------------------------------------------------------------------------------
SELECT movie.title, COUNT(casting.actorid) AS cast_size
FROM movie
JOIN casting ON (movie.id = casting.movieid)
WHERE movie.yr = 1978
GROUP BY movie.title
ORDER BY cast_size DESC, movie.title ASC;

-- ------------------------------------------------------------------------------
-- 15. Colleagues of Art Garfunkel
-- List all the people who have worked with 'Art Garfunkel'.
-- ------------------------------------------------------------------------------
SELECT DISTINCT actor.name 
FROM actor
JOIN casting ON (actor.id = casting.actorid)
WHERE casting.movieid IN (
    SELECT casting.movieid 
    FROM casting
    JOIN actor ON (actor.id = casting.actorid)
    WHERE actor.name = 'Art Garfunkel'
)
  AND actor.name <> 'Art Garfunkel';


-- ==============================================================================
-- More JOIN Operations Quiz (JOIN Quiz 2) Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the statement which lists the unfortunate directors of the
--             movies which have caused financial losses (gross < budget):
-- Answer:
--   SELECT name FROM actor INNER JOIN movie ON actor.id = director WHERE gross < budget;
--
-- Question 2: Select the correct example of JOINing three tables:
-- Answer:
--   SELECT * FROM actor JOIN casting ON actor.id = actorid JOIN movie ON movie.id = movieid;
--
-- Question 3: Select the statement that shows the list of actors called 'John'
--             by order of number of movies in which they acted:
-- Answer:
--   SELECT name, COUNT(movieid) 
--   FROM casting JOIN actor ON actorid=actor.id 
--   WHERE name LIKE 'John %' 
--   GROUP BY name 
--   ORDER BY 2 DESC;
--
-- Question 4: Select the result that would be obtained from:
--             SELECT title FROM movie JOIN casting ON (movieid = movie.id)
--             JOIN actor ON (actorid = actor.id)
--             WHERE name = 'Alan Rickman' AND ord = 1
-- Answer:
--   Table containing movie titles where Alan Rickman had the starring role (ord = 1).
--
-- Question 5: Select the list which gives the actor names and the total number
--             of movies in which they have starred:
-- Answer:
--   SELECT name, COUNT(movieid) 
--   FROM casting JOIN actor ON actorid = actor.id 
--   WHERE ord = 1 
--   GROUP BY name;

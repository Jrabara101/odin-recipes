# SQLZoo Quizzes Master Reference & Solutions Guide

This guide contains solutions and rationale for all end-of-tutorial quizzes in the SQLZoo curriculum as assigned by **The Odin Project**.

---

## 1. SELECT Basics Quiz

### Q1: Select the code which produces this table:
```text
Bahrain     | 1234571
Swaziland   | 1249365
Timor-Leste | 1066409
```
* **Correct Query:**
  ```sql
  SELECT name, population
  FROM world
  WHERE population BETWEEN 1000000 AND 1250000;
  ```
* **Why:** `BETWEEN` tests inclusive numeric intervals. The three populations listed all fall strictly inside `[1,000,000, 1,250,000]`.

### Q2: Select the code that shows the value of population for 'China'
* **Correct Query:**
  ```sql
  SELECT population
  FROM world
  WHERE name = 'China';
  ```
* **Why:** Single-column selection (`population`) filtered precisely with `WHERE name = 'China'`.

### Q3: Select the code which shows the countries that end in A or L
* **Correct Query:**
  ```sql
  SELECT name FROM world
  WHERE name LIKE '%a' OR name LIKE '%l';
  ```
* **Why:** The `%` character matches zero or more preceding characters, so `%a` targets names ending in `a`.

### Q4: Pick the result from the query:
```sql
SELECT name, length(name) FROM world WHERE length(name)=5 and region='Europe';
```
* **Correct Choice:** Table displaying 5-character European country names:
  * `Italy 5`
  * `Malta 5`
  * `Spain 5`

### Q5: Pick the result from the query:
```sql
SELECT name, area*2 FROM world WHERE population = 64000;
```
* **Correct Choice:** Table row showing `Andorra | 936` (Andorra area 468 multiplied by 2).

### Q6: Select the code which shows the countries with an area larger than 50000 and a population smaller than 10000000
* **Correct Query:**
  ```sql
  SELECT name, area, population
  FROM world
  WHERE area > 50000 AND population < 10000000;
  ```

### Q7: Select the code that shows the population density of China, Nigeria, France, Australia
* **Correct Query:**
  ```sql
  SELECT name, population/area
  FROM world
  WHERE name IN ('China', 'Nigeria', 'France', 'Australia');
  ```

---

## 2. BBC / World Quiz

### Q1: Select the code which gives the name of countries beginning with U
* **Correct Query:**
  ```sql
  SELECT name FROM world WHERE name LIKE 'U%';
  ```

### Q2: Select the code which shows the population of the United Kingdom
* **Correct Query:**
  ```sql
  SELECT population FROM world WHERE name = 'United Kingdom';
  ```

### Q3: Error analysis: 'name' should be name
* **Explanation:** In standard SQL syntax, column identifiers cannot be enclosed in single quotes `'name'` because single quotes denote string literals, not column references.

### Q4: Select the result that would be obtained from:
```sql
SELECT name, population/10 FROM world WHERE population < 10000;
```
* **Correct Choice:** `Nauru | 990`

### Q5: Select the code which shows the countries and population of Europe and Asia
* **Correct Query:**
  ```sql
  SELECT name, population FROM world WHERE continent IN ('Europe', 'Asia');
  ```

### Q6: Select the code which gives two rows: Cuba, Togo
* **Correct Query:**
  ```sql
  SELECT name FROM world WHERE name IN ('Cuba', 'Togo');
  ```

### Q7: Select the result from:
```sql
SELECT name FROM world WHERE continent = 'South America' AND population > 40000000;
```
* **Correct Choice:**
  * `Brazil`
  * `Colombia`

---

## 3. Nobel Prize Quiz

### Q1: Select the code which shows winner names beginning with C and ending in n
* **Correct Query:**
  ```sql
  SELECT winner FROM nobel WHERE winner LIKE 'C%' AND winner LIKE '%n';
  ```

### Q2: Select the code that shows how many Chemistry awards were given between 1950 and 1960
* **Correct Query:**
  ```sql
  SELECT COUNT(subject) FROM nobel WHERE subject = 'Chemistry' AND yr BETWEEN 1950 and 1960;
  ```

### Q3: Pick the code that shows the amount of years where no Medicine awards were given
* **Correct Query:**
  ```sql
  SELECT COUNT(DISTINCT yr) FROM nobel 
  WHERE yr NOT IN (SELECT DISTINCT yr FROM nobel WHERE subject = 'Medicine');
  ```

### Q4: Select the result that would be obtained from:
```sql
SELECT subject, winner FROM nobel WHERE winner LIKE '%Sir%' AND yr LIKE '196%';
```
* **Correct Choice:**
  * `Medicine | Sir John Eccles`
  * `Medicine | Sir Frank Macfarlane Burnet`

### Q5: Select the code which would show the year when neither a Physics nor a Chemistry award was given
* **Correct Query:**
  ```sql
  SELECT yr FROM nobel WHERE yr NOT IN (SELECT yr FROM nobel WHERE subject IN ('Chemistry','Physics'));
  ```

### Q6: Select the code which shows the years when a Medicine award was given but no Peace or Literature award was
* **Correct Query:**
  ```sql
  SELECT DISTINCT yr FROM nobel 
  WHERE subject='Medicine' 
    AND yr NOT IN (SELECT yr FROM nobel WHERE subject='Literature')
    AND yr NOT IN (SELECT yr FROM nobel WHERE subject='Peace');
  ```

### Q7: Pick the result that would be obtained from:
```sql
SELECT subject, COUNT(subject) FROM nobel WHERE yr ='1960' GROUP BY subject;
```
* **Correct Choice:**
  * `Chemistry 1, Literature 1, Medicine 2, Peace 1, Physics 1`

---

## 4. Nested SELECT Quiz

### Q1: Select the code that shows the name, region and population of the smallest country in each region
* **Correct Query:**
  ```sql
  SELECT region, name, population 
  FROM bbc x 
  WHERE population <= ALL (
      SELECT population 
      FROM bbc y 
      WHERE y.region = x.region AND population > 0
  );
  ```

### Q2: Select the code that shows the countries belonging to regions with all populations over 50000
* **Correct Query:**
  ```sql
  SELECT name, region, population 
  FROM bbc x 
  WHERE 50000 < ALL (
      SELECT population 
      FROM bbc y 
      WHERE y.region = x.region AND population > 0
  );
  ```

### Q3: Select the code that shows countries whose population is larger than all countries in Europe
* **Correct Query:**
  ```sql
  SELECT name 
  FROM bbc 
  WHERE population > ALL (SELECT population FROM bbc WHERE region = 'Europe');
  ```

### Q4: Select the code that shows countries with a population greater than the largest South American country
* **Correct Query:**
  ```sql
  SELECT name 
  FROM bbc 
  WHERE population > (SELECT MAX(population) FROM bbc WHERE region = 'South America');
  ```

### Q5: Select the code that would show countries with greater GDP than any country in Africa (with NULL handling)
* **Correct Query:**
  ```sql
  SELECT name 
  FROM bbc 
  WHERE gdp > (SELECT MAX(gdp) FROM bbc WHERE region = 'Africa');
  ```
* **Why:** Using `MAX(gdp)` safely ignores `NULL` entries, whereas `> ALL(...)` returns false or null if any row evaluated in the subquery is null.

---

## 5. SUM and COUNT Quiz

### Q1: Select the statement that shows the sum of population of all countries in 'Europe'
* **Correct Query:**
  ```sql
  SELECT SUM(population) FROM bbc WHERE region = 'Europe';
  ```

### Q2: Select the statement that shows the number of countries with population smaller than 150000
* **Correct Query:**
  ```sql
  SELECT COUNT(name) FROM bbc WHERE population < 150000;
  ```

### Q3: Select the list of core SQL aggregate functions
* **Correct Choice:** `AVG(), COUNT(), MAX(), MIN(), SUM()`

### Q4: Select the result from:
```sql
SELECT region, SUM(area) FROM bbc WHERE SUM(area) > 15000000 GROUP BY region;
```
* **Correct Choice:** `No result due to invalid use of the WHERE function` (Aggregates must be in `HAVING`).

### Q5: Average population of Poland, Germany, and Denmark
* **Correct Query:**
  ```sql
  SELECT AVG(population) FROM bbc WHERE name IN ('Poland', 'Germany', 'Denmark');
  ```

### Q6: Region population density
* **Correct Query:**
  ```sql
  SELECT region, SUM(population)/SUM(area) AS density FROM bbc GROUP BY region;
  ```

### Q7: Largest country density
* **Correct Query:**
  ```sql
  SELECT name, population/area AS density FROM bbc WHERE population = (SELECT MAX(population) FROM bbc);
  ```

---

## 6. JOIN Quiz

### Q1: Find stadium where 'Dimitris Salpingidis' scored
* **Correct Join:** `game JOIN goal ON (id=matchid)`

### Q2: Available columns when joining goal and eteam
* **Columns:** `matchid, teamid, player, gtime, id, teamname, coach`

### Q3: Goals scored against Greece (GRE)
* **Correct Query:**
  ```sql
  SELECT player, teamid, COUNT(*)
  FROM game JOIN goal ON matchid = id
  WHERE (team1 = "GRE" OR team2 = "GRE")
    AND teamid != 'GRE'
  GROUP BY player, teamid;
  ```

### Q4: Result of goals on '9 June 2012'
* **Correct Result:** Lists teams playing and scoring on 9 June 2012 (`DEN`, `GER`, `POR`).

### Q5: Scored against Poland in National Stadium, Warsaw
* **Correct Query:**
  ```sql
  SELECT DISTINCT player, teamid
  FROM game JOIN goal ON matchid = id
  WHERE stadium = 'National Stadium, Warsaw'
    AND (team1 = 'POL' OR team2 = 'POL')
    AND teamid != 'POL';
  ```

### Q6: Wroclaw matches excluding Italy
* **Correct Query:** Matches `stadium = 'Stadion Miejski (Wroclaw)'` and ensures `team1 != 'ITA'` and `team2 != 'ITA'`.

### Q7: Teams with fewer than 3 goals
* **Correct Result:**
  * `Netherlands 2`
  * `Poland 2`
  * `Republic of Ireland 1`
  * `Ukraine 2`

---

## 7. More JOIN Operations Quiz (JOIN Quiz 2)

### Q1: Directors whose movies made losses (gross < budget)
* **Correct Query:**
  ```sql
  SELECT name FROM actor INNER JOIN movie ON actor.id = director WHERE gross < budget;
  ```

### Q2: Joining three tables correctly
* **Correct Query:**
  ```sql
  SELECT * FROM actor JOIN casting ON actor.id = actorid JOIN movie ON movie.id = movieid;
  ```

### Q3: Actors named 'John' by movie count
* **Correct Query:**
  ```sql
  SELECT name, COUNT(movieid) 
  FROM casting JOIN actor ON actorid=actor.id 
  WHERE name LIKE 'John %' 
  GROUP BY name 
  ORDER BY 2 DESC;
  ```

### Q4: Result of query filtering `name = 'Alan Rickman' AND ord = 1`
* **Correct Choice:** Films where Alan Rickman had the starring / lead role (`ord = 1`).

### Q5: Actors and total starring roles
* **Correct Query:**
  ```sql
  SELECT name, COUNT(movieid) FROM casting JOIN actor ON actorid = actor.id WHERE ord = 1 GROUP BY name;
  ```

---

## 8. Using Null Quiz

### Q1: Correct outer join syntax
* **Correct Query:**
  ```sql
  SELECT teacher.name, dept.name FROM teacher LEFT OUTER JOIN dept ON (teacher.dept = dept.id);
  ```

### Q2: Department employing Cutflower
* **Correct Query:**
  ```sql
  SELECT dept.name FROM teacher JOIN dept ON (dept.id = teacher.dept) WHERE teacher.name = 'Cutflower';
  ```

### Q3: All departments with teacher counts (including empty ones)
* **Correct Query:**
  ```sql
  SELECT dept.name, COUNT(teacher.name) FROM teacher RIGHT JOIN dept ON dept.id = teacher.dept GROUP BY dept.name;
  ```

### Q4: Output of `COALESCE(dept, 0)`
* **Correct Choice:** Displays `0` in the result column for all teachers without a department.

### Q5: Phone digits CASE statement
* **Correct Choice:** Shows `'three'` for Shrivell (phone 2753), `'four'` for Throd (phone 2754), and `NULL` for others.

### Q6: Department category CASE
* **Correct Choice:** Teachers in Dept 1 show `'Computing'`, while all others (or NULL) show `'Other'`.

---

## 9. Self Join Quiz

### Q1: Routes from Craiglockhart to Haymarket
* **Correct Query:**
  ```sql
  SELECT DISTINCT a.name, b.name 
  FROM stops a 
  JOIN route z ON a.id = z.stop 
  JOIN route y ON y.num = z.num AND y.company = z.company 
  JOIN stops b ON y.stop = b.id 
  WHERE a.name = 'Craiglockhart' AND b.name = 'Haymarket';
  ```

### Q2: Stops on route '2A' reached from Haymarket
* **Correct Query:**
  ```sql
  SELECT S2.id, S2.name, R2.company, R2.num 
  FROM stops S1, stops S2, route R1, route R2 
  WHERE S1.name = 'Haymarket' 
    AND S1.id = R1.stop 
    AND R1.company = R2.company 
    AND R1.num = R2.num 
    AND R2.stop = S2.id 
    AND R1.num = '2A';
  ```

### Q3: Standard route self join template
* **Correct Query:**
  ```sql
  SELECT a.company, a.num, stopa.name, stopb.name 
  FROM route a 
  JOIN route b ON (a.company = b.company AND a.num = b.num) 
  JOIN stops stopa ON (a.stop = stopa.id) 
  JOIN stops stopb ON (b.stop = stopb.id);
  ```

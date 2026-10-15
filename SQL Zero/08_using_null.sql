-- ==============================================================================
-- SQLZoo Tutorial 8: Using Null (Teachers and Departments)
-- Tables:
--   teacher(id, dept, name, phone, mobile)
--   dept(id, name)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. NULL departments
-- List the teachers who have NULL for their department.
-- ------------------------------------------------------------------------------
SELECT name 
FROM teacher
WHERE dept IS NULL;

-- ------------------------------------------------------------------------------
-- 2. INNER JOIN misses records with NULL
-- Note the INNER JOIN misses the teachers with no department and the departments
-- with no teacher.
-- ------------------------------------------------------------------------------
SELECT teacher.name, dept.name
FROM teacher 
INNER JOIN dept ON (teacher.dept = dept.id);

-- ------------------------------------------------------------------------------
-- 3. LEFT JOIN (All teachers)
-- Use a different JOIN so that all teachers are listed.
-- ------------------------------------------------------------------------------
SELECT teacher.name, dept.name
FROM teacher 
LEFT JOIN dept ON (teacher.dept = dept.id);

-- ------------------------------------------------------------------------------
-- 4. RIGHT JOIN (All departments)
-- Use a different JOIN so that all departments are listed.
-- ------------------------------------------------------------------------------
SELECT teacher.name, dept.name
FROM teacher 
RIGHT JOIN dept ON (teacher.dept = dept.id);

-- ------------------------------------------------------------------------------
-- 5. COALESCE for mobile numbers
-- Use COALESCE to print the mobile number. Use the number '07986 444 2266'
-- if there is no number given. Show teacher name and mobile number.
-- ------------------------------------------------------------------------------
SELECT name, COALESCE(mobile, '07986 444 2266') AS mobile_contact
FROM teacher;

-- ------------------------------------------------------------------------------
-- 6. COALESCE with LEFT JOIN
-- Use the COALESCE function and a LEFT JOIN to print the teacher name and
-- department name. Use the string 'None' where there is no department.
-- ------------------------------------------------------------------------------
SELECT teacher.name, COALESCE(dept.name, 'None') AS dept_name
FROM teacher 
LEFT JOIN dept ON (teacher.dept = dept.id);

-- ------------------------------------------------------------------------------
-- 7. COUNT behavior with NULL
-- Use COUNT to show the number of teachers and the number of mobile phones.
-- (Note: COUNT(column) ignores NULL entries while COUNT(*) counts all rows).
-- ------------------------------------------------------------------------------
SELECT COUNT(name) AS teacher_count, COUNT(mobile) AS mobile_count
FROM teacher;

-- ------------------------------------------------------------------------------
-- 8. Department staff count
-- Use COUNT and GROUP BY dept.name to show each department and the number
-- of staff. Use a RIGHT JOIN to ensure that the Engineering department is listed.
-- ------------------------------------------------------------------------------
SELECT dept.name, COUNT(teacher.name) AS staff_count
FROM teacher 
RIGHT JOIN dept ON (teacher.dept = dept.id)
GROUP BY dept.name;

-- ------------------------------------------------------------------------------
-- 9. CASE: Sci vs Art
-- Use CASE to show the name of each teacher followed by 'Sci' if the teacher
-- is in dept 1 or 2 and 'Art' otherwise.
-- ------------------------------------------------------------------------------
SELECT name,
       CASE 
           WHEN dept IN (1, 2) THEN 'Sci' 
           ELSE 'Art' 
       END AS faculty
FROM teacher;

-- ------------------------------------------------------------------------------
-- 10. CASE: Sci, Art, None
-- Use CASE to show the name of each teacher followed by 'Sci' if the teacher
-- is in dept 1 or 2, show 'Art' if the teacher is in dept 3 and 'None' otherwise.
-- ------------------------------------------------------------------------------
SELECT name,
       CASE 
           WHEN dept IN (1, 2) THEN 'Sci'
           WHEN dept = 3 THEN 'Art'
           ELSE 'None'
       END AS faculty
FROM teacher;


-- ==============================================================================
-- Using Null Quiz Answer Key & Explanations
-- ==============================================================================
-- Question 1: Select the code which uses an outer join correctly:
-- Answer:
--   SELECT teacher.name, dept.name 
--   FROM teacher LEFT OUTER JOIN dept ON (teacher.dept = dept.id);
--
-- Question 2: Select the correct statement that shows the name of department
--             which employs Cutflower:
-- Answer:
--   SELECT dept.name 
--   FROM teacher JOIN dept ON (dept.id = teacher.dept) 
--   WHERE teacher.name = 'Cutflower';
--
-- Question 3: Select out of following the code which uses a JOIN to show a list
--             of all the departments and number of employed teachers:
-- Answer:
--   SELECT dept.name, COUNT(teacher.name) 
--   FROM teacher RIGHT JOIN dept ON dept.id = teacher.dept 
--   GROUP BY dept.name;
--
-- Question 4: Using SELECT name, dept, COALESCE(dept, 0) AS result FROM teacher on teacher table will:
-- Answer:
--   display 0 in result column for all teachers without department.
--
-- Question 5: Select the result table obtained by mapping phone numbers to words:
--   CASE WHEN phone = 2752 THEN 'two' WHEN phone = 2753 THEN 'three' ...
-- Answer:
--   Table showing Shrivell as 'three', Throd as 'four', and teachers with null or other phones as NULL.
--
-- Question 6: Select the result that would be obtained from:
--             SELECT name, CASE WHEN dept IN (1) THEN 'Computing' ELSE 'Other' END FROM teacher
-- Answer:
--   Table with Shrivell, Throd, Splint as 'Computing' and Spiregrain, Cutflower, Deadyawn as 'Other'.

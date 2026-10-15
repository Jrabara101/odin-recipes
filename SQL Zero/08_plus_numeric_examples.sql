-- ==============================================================================
-- SQLZoo Tutorial 8+: Numeric Examples (NSS - National Student Survey)
-- Table:
--   nss(ukprn, institution, subject, question, 
--       A_STRONGLY_DISAGREE, A_DISAGREE, A_NEUTRAL, A_AGREE, A_STRONGLY_AGREE, 
--       score, response, sample)
-- Engine: MySQL
-- The Odin Project: Databases - Project: SQL Zoo
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Check out one row
-- The example shows the number who responded for: question 1; at
-- 'Edinburgh Napier University'; studying '(8) Computer Science'.
-- Show the percentage who STRONGLY AGREE.
-- ------------------------------------------------------------------------------
SELECT A_STRONGLY_AGREE 
FROM nss
WHERE question = 'Q01'
  AND institution = 'Edinburgh Napier University'
  AND subject = '(8) Computer Science';

-- ------------------------------------------------------------------------------
-- 2. Calculate how many agree or strongly agree
-- Show the institution and subject where the score is 100 for question 'Q15'.
-- ------------------------------------------------------------------------------
SELECT institution, subject 
FROM nss
WHERE question = 'Q15'
  AND score = 100;

-- ------------------------------------------------------------------------------
-- 3. Unhappy Computer Students
-- Show the institution and score where the subject is '(8) Computer Science'
-- and the score for question 'Q15' is less than 50.
-- ------------------------------------------------------------------------------
SELECT institution, score 
FROM nss
WHERE question = 'Q15'
  AND subject = '(8) Computer Science'
  AND score < 50;

-- ------------------------------------------------------------------------------
-- 4. More Computing or Creative Students?
-- Show the subject and total number of students who responded to question 22
-- for each of the subjects '(8) Computer Science' and '(H) Creative Arts and Design'.
-- ------------------------------------------------------------------------------
SELECT subject, SUM(response) AS total_responses
FROM nss
WHERE question = 'Q22'
  AND subject IN ('(8) Computer Science', '(H) Creative Arts and Design')
GROUP BY subject;

-- ------------------------------------------------------------------------------
-- 5. Strongly Agree Numbers
-- Show the subject and total number of students who A_STRONGLY_AGREE to
-- question 22 for each of the subjects '(8) Computer Science' and
-- '(H) Creative Arts and Design'.
-- (A_STRONGLY_AGREE is stored as a percentage, so calculate count = response * pct / 100).
-- ------------------------------------------------------------------------------
SELECT subject, SUM(A_STRONGLY_AGREE * response / 100) AS strongly_agree_count
FROM nss
WHERE question = 'Q22'
  AND subject IN ('(8) Computer Science', '(H) Creative Arts and Design')
GROUP BY subject;

-- ------------------------------------------------------------------------------
-- 6. Strongly Agree, Percentage
-- Show the percentage of students who A_STRONGLY_AGREE to question 22 for the
-- subject '(8) Computer Science' and '(H) Creative Arts and Design'.
-- Round to whole number.
-- ------------------------------------------------------------------------------
SELECT subject, 
       ROUND(SUM(A_STRONGLY_AGREE * response / 100) * 100 / SUM(response)) AS pct_strongly_agree
FROM nss
WHERE question = 'Q22'
  AND subject IN ('(8) Computer Science', '(H) Creative Arts and Design')
GROUP BY subject;

-- ------------------------------------------------------------------------------
-- 7. Scores for Institutions in Manchester
-- Show the average scores for question 'Q22' for each institution that
-- includes 'Manchester' in the name.
-- Note: Must compute the weighted average score across subjects.
-- ------------------------------------------------------------------------------
SELECT institution, 
       ROUND(SUM(score * response) / SUM(response)) AS avg_score
FROM nss
WHERE question = 'Q22'
  AND institution LIKE '%Manchester%'
GROUP BY institution;

-- ------------------------------------------------------------------------------
-- 8. Number of Computing Students in Manchester
-- Show the institution, total sample size, and the number of computing students
-- for institutions in Manchester for 'Q01'.
-- ------------------------------------------------------------------------------
SELECT institution, 
       SUM(sample) AS total_sample, 
       SUM(CASE WHEN subject = '(8) Computer Science' THEN sample ELSE 0 END) AS comp_sci_sample
FROM nss
WHERE question = 'Q01'
  AND institution LIKE '%Manchester%'
GROUP BY institution;

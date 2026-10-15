# The Odin Project — Project: SQL Zoo Solutions & Notes

Complete, verified solutions and study notes for **The Odin Project (Databases Course): Project SQL Zoo**.

- **Course:** The Odin Project - Databases
- **Assignment:** [Project: SQL Zoo](https://www.theodinproject.com/lessons/databases-sql-zoo)
- **Target Engine:** MySQL (default on SQLZoo)

---

## 📚 Curriculum Index & File Map

| Tutorial # | Topic | File | Quizzes Covered |
|:---|:---|:---|:---|
| **0** | SELECT basics | [`00_select_basics.sql`](00_select_basics.sql) | SELECT Quiz (Basics) |
| **1** | SELECT names (Pattern Matching) | [`01_select_names.sql`](01_select_names.sql) | Pattern Matching Strings |
| **2** | SELECT from World | [`02_select_from_world.sql`](02_select_from_world.sql) | BBC / World Quiz |
| **3** | SELECT from Nobel | [`03_select_from_nobel.sql`](03_select_from_nobel.sql) | Nobel Quiz |
| **4** | SELECT within SELECT (Subqueries) | [`04_select_within_select.sql`](04_select_within_select.sql) | Nested SELECT Quiz |
| **5** | SUM and COUNT (Aggregates) | [`05_sum_and_count.sql`](05_sum_and_count.sql) | SUM and COUNT Quiz |
| **6** | The JOIN Operation | [`06_join.sql`](06_join.sql) | JOIN Quiz |
| **7** | More JOIN Operations | [`07_more_join_operations.sql`](07_more_join_operations.sql) | More JOIN Quiz (JOIN Quiz 2) |
| **8** | Using Null | [`08_using_null.sql`](08_using_null.sql) | Using Null Quiz |
| **8+** | Numeric Examples (NSS Survey) | [`08_plus_numeric_examples.sql`](08_plus_numeric_examples.sql) | Weighted Metrics & CASE |
| **9-** | Window Functions (Elections) | [`09_minus_window_functions.sql`](09_minus_window_functions.sql) | `RANK()`, `PARTITION BY` |
| **9** | Self JOIN (Bus Network) | [`09_self_join.sql`](09_self_join.sql) | Self Join Quiz |
| **9+** | Window LAG (COVID-19 Data) | [`09_plus_covid19.sql`](09_plus_covid19.sql) | `LAG()`, Time-Series, CTEs |
| **Quizzes** | All Quiz Answers & Rationale | [`quizzes_reference.md`](quizzes_reference.md) | Comprehensive Quiz Guide |

---

## 🔑 Key Concepts & Techniques Mastered

### 1. Pattern Matching & String Manipulation (`01_select_names.sql`)
- Wildcards: `%` (multi-character) and `_` (single character).
- String functions: `CONCAT()`, `REPLACE()`, `SUBSTRING()`, `LENGTH()`, `LEFT()`.

### 2. Relational Filtering & Conditionals (`02_select_from_world.sql`, `03_select_from_nobel.sql`)
- Set checks: `IN (...)`, `BETWEEN ... AND ...`.
- Bitwise / Exclusive logic: `XOR` or composite `AND`/`OR`.
- Escaping special characters and string quotes: `''`.
- Boolean expressions in sorting (`ORDER BY subject IN ('chemistry', 'physics'), subject`).

### 3. Subqueries & Set Quantifiers (`04_select_within_select.sql`)
- Scalar subqueries vs list subqueries (`IN`, `NOT IN`).
- Quantified comparisons: `> ALL (...)`, `>= ALL (...)`.
- Correlated subqueries where the inner query binds to the outer query row alias (`x.continent = y.continent`).

### 4. Aggregations & Grouping (`05_sum_and_count.sql`)
- Aggregate functions: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`.
- Filtering groups using `HAVING` rather than `WHERE` (which cannot evaluate aggregates directly).

### 5. Multi-Table Joins & Cardinality (`06_join.sql`, `07_more_join_operations.sql`)
- Combining records with `INNER JOIN ... ON (...)`.
- Using `LEFT JOIN` to preserve zero-count or unmatched parent rows.
- Pivot-style aggregations with `SUM(CASE WHEN ... THEN 1 ELSE 0 END)`.
- 3-table entity-relationship joins (Movies $\leftrightarrow$ Casting $\leftrightarrow$ Actors).

### 6. NULL Handling & Outer Joins (`08_using_null.sql`)
- Testing for null values using `IS NULL` and `IS NOT NULL`.
- `COALESCE(val, fallback)` to gracefully substitute default values.
- Multi-branch conditional classifications using `CASE WHEN ... THEN ... ELSE ... END`.

### 7. Window Functions & Time Series Analysis (`09_minus_window_functions.sql`, `09_plus_covid19.sql`)
- `RANK() OVER (PARTITION BY ... ORDER BY ...)` for segmented leaderboards.
- `LAG(col, n) OVER (PARTITION BY ... ORDER BY ...)` for calculating daily / weekly diffs in cumulative time-series data.
- Common Table Expressions (`WITH ... AS (...)`) for structuring multi-tier analytics queries.

### 8. Self Joins & Graph Traversal (`09_self_join.sql`)
- Joining a table to itself (`route a JOIN route b ON a.num = b.num AND a.company = b.company`) to compute transit edges between two stops.
- 4-way joins to resolve 2-bus transfer routes between arbitrary network nodes.

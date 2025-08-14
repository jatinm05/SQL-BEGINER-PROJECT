/* ----------------------------------------------------------------
   DATABASE: kickstarter
   PURPOSE: Full MySQL analysis of Kickstarter projects dataset
   WORKFLOW: 
      1. Basic exploration
      2. Data cleaning
      3. Key aggregations
      4. Creating reusable views
      5. KPI summary table
      6. Stored procedures for dynamic queries
      7. Detect anomalies
      8. Advanced SQL examples (RANK, CTE)
   ---------------------------------------------------------------- */

-- Create database (run only if not exists)
CREATE DATABASE IF NOT EXISTS kickstarter;
USE kickstarter;

-- Quick preview of table data
SELECT * FROM projects LIMIT 10;

-- Show table structure
SHOW COLUMNS FROM projects;

-- Count total rows
SELECT COUNT(*) AS total_rows FROM projects;

-- Count total columns
SELECT COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'kickstarter'
  AND table_name = 'projects';

-- Distinct project states
SELECT DISTINCT state FROM projects;

-- Projects per country
SELECT country, COUNT(*) AS num_projects
FROM projects
GROUP BY country
ORDER BY num_projects DESC;

-- NULL check for important columns
SELECT 
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS null_name,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category
FROM projects;

-- =================
-- 2. DATA CLEANING
-- =================
-- Remove rows with missing essential fields
DELETE FROM projects
WHERE name IS NULL OR goal IS NULL;

-- Remove rows with non-positive goals
DELETE FROM projects
WHERE goal <= 0;

-- Standardize currency codes to uppercase
UPDATE projects
SET currency = UPPER(currency);

-- ======================
-- 3. KEY AGGREGATIONS
-- ======================
-- Most popular main categories
SELECT main_category, COUNT(*) AS total_projects
FROM projects
GROUP BY main_category
ORDER BY total_projects DESC;

-- Average pledged per category
SELECT main_category, ROUND(AVG(pledged), 2) AS avg_pledged
FROM projects
GROUP BY main_category
ORDER BY avg_pledged DESC;

-- Success rate per category
SELECT main_category,
       SUM(state = 'successful') * 100.0 / COUNT(*) AS success_rate
FROM projects
GROUP BY main_category
ORDER BY success_rate DESC;

-- Top 10 most-funded projects
SELECT name, main_category, pledged, currency
FROM projects
ORDER BY pledged DESC
LIMIT 10;

-- Success rate by country
SELECT country,
       SUM(state = 'successful') / COUNT(*) * 100 AS success_rate
FROM projects
GROUP BY country
ORDER BY success_rate DESC;

-- High funding but low success categories (<50% success rate)
SELECT main_category,
       AVG(pledged) AS avg_pledged,
       SUM(state = 'successful') / COUNT(*) * 100 AS success_rate
FROM projects
GROUP BY main_category
HAVING success_rate < 50
ORDER BY avg_pledged DESC;

-- Cross tab: category & country success rate
SELECT country, main_category,
       SUM(state = 'successful') / COUNT(*) * 100 AS success_rate
FROM projects
GROUP BY country, main_category
ORDER BY country, success_rate DESC;

-- =====================
-- 4. REUSABLE VIEWS
-- =====================
-- View: all successful projects
DROP VIEW IF EXISTS successful_projects;
CREATE VIEW successful_projects AS
SELECT * 
FROM projects
WHERE state = 'successful';

-- View: country success rate & total projects
CREATE OR REPLACE VIEW country_success_rate AS
SELECT country,
       ROUND(SUM(state='successful') / COUNT(*) * 100, 2) AS success_rate,
       COUNT(*) AS total_projects
FROM projects
GROUP BY country
ORDER BY success_rate DESC;

-- View: high-value successful projects
CREATE OR REPLACE VIEW high_value_success AS
SELECT name, main_category, pledged, backers
FROM projects
WHERE state = 'successful' AND pledged > 50000;

-- ================================
-- 5. KPI SUMMARY TABLE
-- ================================
CREATE TABLE IF NOT EXISTS project_kpis AS
SELECT 
    COUNT(*) AS total_projects,
    ROUND(SUM(state = 'successful') / COUNT(*) * 100, 2) AS overall_success_rate,
    ROUND(AVG(pledged), 2) AS avg_pledged_amount,
    ROUND(AVG(goal), 2) AS avg_goal_amount
FROM projects;

-- ======================
-- 6. STORED PROCEDURES
-- ======================
DELIMITER $$

-- Procedure: top N projects by category
CREATE PROCEDURE IF NOT EXISTS top_projects(IN cat_name VARCHAR(100), IN limit_num INT)
BEGIN
  SELECT name, pledged
  FROM projects
  WHERE main_category = cat_name
  ORDER BY pledged DESC
  LIMIT limit_num;
END $$

-- NOTE: Removed `top_projects_by_year_cat` since launch_year is gone

DELIMITER ;

-- ======================
-- 7. ANOMALY DETECTION
-- ======================
CREATE TABLE IF NOT EXISTS anomalies AS
SELECT * 
FROM projects
WHERE goal > 1000000 OR pledged > 2000000;

-- ======================
-- 8. ADVANCED SQL
-- ======================
-- Ranking projects within category by pledged amount
SELECT name, main_category,
       RANK() OVER (PARTITION BY main_category ORDER BY pledged DESC) AS rank_in_category
FROM projects;

-- Using CTE: category success rate
WITH category_success AS (
  SELECT main_category, COUNT(*) AS total,
         SUM(state='successful') AS success_count
  FROM projects
  GROUP BY main_category
)
SELECT main_category, success_count * 100 / total AS success_rate
FROM category_success;

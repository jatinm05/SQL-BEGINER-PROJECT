# Kickstarter Data Analysis in MySQL

## Overview
This project contains SQL scripts to perform a complete exploratory data analysis (EDA) and KPI extraction on a Kickstarter projects dataset using MySQL.  
The code demonstrates a full workflow from data exploration, cleaning, aggregation, and creation of reusable database objects to advanced SQL techniques such as window functions and common table expressions (CTEs).

The dataset contains details of Kickstarter campaigns including project name, category, country, funding goals, pledged amounts, state (success/failure), and other attributes.

---

## Project Structure
- **Basic Exploration:** Initial checks of dataset structure, row/column counts, distinct values, and NULL value counts.
- **Data Cleaning:** Removing invalid or incomplete records and standardizing formats.
- **Key Aggregations:** Querying for category popularity, funding statistics, success rates, and top-funded projects.
- **Views:** Creating reusable database views for common analytical queries.
- **KPI Summary Table:** Generating a pre-aggregated summary of overall metrics.
- **Stored Procedures:** Implementing parameterized procedures for dynamic retrieval of top projects.
- **Anomaly Detection:** Identifying projects with anomalously high goals or pledges.
- **Advanced SQL:** Using ranking and CTEs for deeper analysis.

---

## Steps Implemented in the Script

### 1. Database and Table Inspection
- Create and select the `kickstarter` database.
- Preview data with `SELECT * ... LIMIT 10`.
- Display table structure with `SHOW COLUMNS`.
- Count rows and columns in the `projects` table.
- Identify distinct project states.
- Compute counts of projects by country.
- Check for NULL values in key columns (`id`, `name`, `category`).

### 2. Data Cleaning
- Remove rows with missing essential values (`name` or `goal`).
- Remove rows with zero or negative goals.
- Standardize currency codes to uppercase.

### 3. Key Aggregations
- Calculate the number of projects per main category.
- Calculate the average pledged amount per main category.
- Calculate success rate by main category.
- Retrieve top 10 projects by pledged amount.
- Calculate success rate by country.
- Identify categories with high funding but low success (<50% success rate).
- Generate category–country interaction success rate table.

### 4. Views
- `successful_projects`: All projects with `state = 'successful'`.
- `country_success_rate`: Success rate and total projects by country.
- `high_value_success`: Successful projects with pledged amounts greater than 50,000.

### 5. KPI Summary Table
- `project_kpis`: One-row table containing:
  - Total projects
  - Overall success rate
  - Average pledged amount
  - Average goal amount

### 6. Stored Procedures
- `top_projects`: Returns top N pledged projects for a given main category.

### 7. Data Quality Checks
- `anomalies` table: Projects flagged for extremely high goals or pledged amounts.

### 8. Advanced SQL
- Ranking: Use of `RANK()` window function to rank projects within a category by pledged amount.
- CTE (`category_success`): Calculates success rate by category using an intermediate result set.

---

## How to Use
1. Import the Kickstarter dataset into a MySQL database.
2. Run the provided SQL script sequentially.
3. Use the views and stored procedures for further interactive analysis.
4. Export query outputs for visualization in tools such as Python (Pandas, Matplotlib, Plotly), Excel, or Tableau.

---

## Potential Visualizations
The following queries are strong candidates for charting:
- Most popular main categories by number of projects.
- Average pledged amount by main category.
- Success rate by main category.
- Success rate by country.
- Categories with high funding but low success.
- Ranked projects within each category.

---

## Technologies Used
- MySQL 8.0
- SQL features: `GROUP BY`, aggregations, `CASE`, window functions, CTEs, views, stored procedures.

---

## Dataset Considerations
- Ensure data includes essential fields (`id`, `name`, `category`, `country`, `goal`, `pledged`, `state`).
- Date-based trends dependent on launch dates were excluded from this version as the original `launched` column was removed.

---

## Author
This analysis was developed as part of a technical data analytics project illustrating SQL proficiency in cleaning, exploring, and analyzing real-world datasets.

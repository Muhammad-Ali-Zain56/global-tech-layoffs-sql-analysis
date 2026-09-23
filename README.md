# Global Tech Layoffs — SQL Data Cleaning & Exploratory Analysis

## Overview
This project cleans and analyzes a real-world dataset of global tech layoffs (2020–2023, sourced from Kaggle) using **MySQL**. It covers the full pipeline from raw, messy data to analysis-ready tables and business insights — a common first step in any data analyst workflow.

- **Raw data:** `layoffs.csv` — 2,361 rows across 51 countries
- **After cleaning:** 1,995 analysis-ready records
- **Tools:** MySQL Workbench, SQL (CTEs, window functions, subqueries)

## Files
| File | Purpose |
|---|---|
| `layoffs.csv` | Raw, unprocessed dataset |
| `data_cleaning.sql` | Removes duplicates, standardizes fields, handles NULL/blank values, drops unusable rows |
| `global_layoffs_analysis.sql` | Exploratory analysis — rankings, trends over time, rolling totals, top companies per year |

Run `data_cleaning.sql` first to produce the cleaned table (`layoffs_staging2`), then run `global_layoffs_analysis.sql` against it.

## Data Cleaning Steps
1. **Removed duplicates** using `ROW_NUMBER()` partitioned across all columns
2. **Standardized data** — trimmed whitespace, merged inconsistent category names (e.g. "Crypto Currency" → "Crypto"), fixed inconsistent country names, converted text dates to proper `DATE` type
3. **Handled NULLs/blanks** — converted placeholder text to real NULLs, backfilled missing `industry` values from other rows of the same company
4. **Dropped unusable rows** — records with no layoff count and no percentage (nothing to analyze)

## Key Findings
- **Amazon, Google, and Meta** had the highest total layoffs among all companies in the dataset
- **Consumer** and **Retail** were the hardest-hit industries by total layoffs
- Layoffs were heavily concentrated in the **US**, with clear spikes tied to major economic downturn periods
- Several companies laid off **100% of staff** — most were well-funded startups, suggesting funding alone didn't guarantee survival

## Skills Demonstrated
- Data cleaning: deduplication, standardization, null handling
- Window functions: `ROW_NUMBER()`, `DENSE_RANK()`, rolling `SUM() OVER()`
- CTEs and correlated subqueries for layered analysis
- Aggregation and trend analysis (`GROUP BY`, `YEAR()`, time-series rollups)

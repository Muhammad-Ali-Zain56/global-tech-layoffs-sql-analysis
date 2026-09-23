-- =====================================================
-- Global Tech Layoffs: Exploratory Data Analysis (MySQL)
-- Run data_cleaning.sql first. Uses table layoffs_staging2.
-- =====================================================
USE world_layoffs;

-- Overview
SELECT MAX(total_laid_off) AS max_laid_off,
       MAX(percentage_laid_off) AS max_pct
FROM layoffs_staging2;

-- Companies that laid off 100% of staff, biggest funding first
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Top companies by total layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Layoffs by company stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Layoffs by year
SELECT YEAR(`date`) AS yr, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY yr
ORDER BY yr;

-- Rolling total of layoffs by month (CTE + window function)
WITH monthly AS (
  SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  WHERE `date` IS NOT NULL
  GROUP BY `month`
)
SELECT `month`, total_laid_off,
       SUM(total_laid_off) OVER (ORDER BY `month`) AS rolling_total
FROM monthly
ORDER BY `month`;

-- Top 5 companies per year (two CTEs + DENSE_RANK)
WITH company_year AS (
  SELECT company, YEAR(`date`) AS yr, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  WHERE `date` IS NOT NULL
  GROUP BY company, YEAR(`date`)
),
ranked AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY yr ORDER BY total_laid_off DESC) AS ranking
  FROM company_year
  WHERE total_laid_off IS NOT NULL
)
SELECT * FROM ranked WHERE ranking <= 5;

-- Subquery: industries whose total layoffs exceed the average industry total
SELECT industry, total_laid_off
FROM (
  SELECT industry, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY industry
) AS t
WHERE total_laid_off > (
  SELECT AVG(s.total_laid_off)
  FROM (SELECT SUM(total_laid_off) AS total_laid_off
        FROM layoffs_staging2 GROUP BY industry) AS s
);
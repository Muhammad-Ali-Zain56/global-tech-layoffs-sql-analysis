-- =====================================================
-- Global Tech Layoffs: Data Cleaning (MySQL)
-- Steps: 1) remove duplicates 2) standardize data
--        3) handle NULL/blank values 4) drop unusable rows
-- Import layoffs.csv first (Table Data Import Wizard) into
-- schema `world_layoffs` as table `layoffs`.
-- =====================================================

CREATE DATABASE IF NOT EXISTS world_layoffs;
USE world_layoffs;

-- MySQL Workbench blocks UPDATE/DELETE without a key column by default (Error 1175)
SET SQL_SAFE_UPDATES = 0;

-- Work on a copy so the raw table stays untouched
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;

-- The CSV stores missing values as the text 'NULL' or blanks; convert to real NULLs
UPDATE layoffs_staging SET industry = NULL WHERE industry IN ('', 'NULL');
UPDATE layoffs_staging SET total_laid_off = NULL WHERE total_laid_off IN ('', 'NULL');
UPDATE layoffs_staging SET percentage_laid_off = NULL WHERE percentage_laid_off IN ('', 'NULL');
UPDATE layoffs_staging SET funds_raised_millions = NULL WHERE funds_raised_millions IN ('', 'NULL');
UPDATE layoffs_staging SET stage = NULL WHERE stage IN ('', 'NULL');
UPDATE layoffs_staging SET `date` = NULL WHERE `date` IN ('', 'NULL');

-- -----------------------------------------------------
-- 1. REMOVE DUPLICATES
-- -----------------------------------------------------
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off TEXT,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions TEXT,
  row_num INT
);

INSERT INTO layoffs_staging2
SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num
FROM layoffs_staging;

-- Check duplicates before deleting
SELECT * FROM layoffs_staging2 WHERE row_num > 1;

DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- -----------------------------------------------------
-- 2. STANDARDIZE DATA
-- -----------------------------------------------------
-- Trim extra spaces in company names
UPDATE layoffs_staging2 SET company = TRIM(company);

-- Merge Crypto variants: 'Crypto Currency', 'CryptoCurrency' -> 'Crypto'
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- Fix 'United States.' -> 'United States'
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country);

-- Convert date text (e.g. 3/6/2023) to a real DATE column
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;

-- Convert numeric columns from text to proper types
ALTER TABLE layoffs_staging2 MODIFY COLUMN total_laid_off INT;
ALTER TABLE layoffs_staging2 MODIFY COLUMN percentage_laid_off DECIMAL(5,2);
ALTER TABLE layoffs_staging2 MODIFY COLUMN funds_raised_millions INT;

-- -----------------------------------------------------
-- 3. NULL / BLANK VALUES
-- -----------------------------------------------------
-- Fill missing industry from other rows of the same company
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- -----------------------------------------------------
-- 4. DROP UNUSABLE ROWS AND HELPER COLUMN
-- -----------------------------------------------------
-- Rows with no layoff count and no percentage cannot be analysed
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;

      SELECT COUNT(*) FROM layoffs_staging2;
   
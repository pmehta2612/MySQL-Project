-- Data Cleaning Project
-- Steps to be taken to clean data
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Remove null or blank values
-- 4. Remove any unnecessary column

-- creating the layoffs duplicate table to perform data cleaning
create table layoffs_staging
like layoffs;

insert layoffs_staging
select * 
from layoffs;

select *
from layoffs_staging;

-- 1. Removing Duplicates
-- step 1 - View the data by adding row number 
select *,
row_number() over 
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions) as 'Row_Num'
from layoffs_staging;

-- step 2 - Created CTE to view the duplicates in dataset
with layoffs_duplicate as 
(
select *,
row_number() over 
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions) as 'Row_Num'
from layoffs_staging
)
select *
from layoffs_duplicate 
where Row_Num > 1;

-- Step 3 - Created a duplicate table of layoffs_staging and inserted all the records
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over 
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions) as 'Row_Num'
from layoffs_staging;

-- Step 4 - Deleted the duplicates 
delete
from layoffs_staging2
where Row_Num > 1;

select * 
from layoffs_staging2
where Row_Num > 1;

-- 2. Standardizing the Data
-- Remove the spaces in company column
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

-- Updating the industry name which has similar name
select distinct industry
from layoffs_staging2
order by 1;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- updating the country name issue
select distinct country
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

-- Updating the date format
select `date` 
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- Convert into Date type
alter table layoffs_staging2
modify column `date` date;

-- Filling the null values in industry column
-- View the data which contains null/blank values
select *
from layoffs_staging2
where industry is null
or industry = '';
-- View the data of specific company
select * 
from layoffs_staging2
where company like 'Bally%';
-- Performed the self join 
select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;
-- updated all the blank values to null
update layoffs_staging2
set industry = null
where industry = '';
-- updated the dataset and set the values which were having null
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- 3. Removing null values
delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- 4. Removing unwanted column
alter table layoffs_staging2
drop column Row_Num;

select * 
from layoffs_staging2;


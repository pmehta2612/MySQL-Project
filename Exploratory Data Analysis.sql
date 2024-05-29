-- Exploratory Data Analysis
-- Viewing entire dataset
select *
from layoffs_staging2;
-- viewing the maximum employees laid off and the maximum percentage of laid off
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;
-- Viewing the percentage laid off order by funds raised
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;
-- Viewing the total employees laid off by different companies
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;
-- Viewing the industry which laid off the employees
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;
-- Viewing the country which has maximum layoffs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;
-- Viewing the layoffs on yearly basis
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;
-- Viewing layoffs by stage
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;
-- Calculating Monthly Rolling Total 
select substring(`date`,1,7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by 1 asc;

with Rolling_Total1 As
(
select substring(`date`,1,7) as `Month`, sum(total_laid_off) as 'Total_Off'
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by 1 asc
)
select `Month`, Total_Off, 
sum(Total_off) over(order by `Month`) as 'rolling_total'
from Rolling_total1;

-- Analyzing company's maximum layoffs on yearly basis
select company, year(`date`) as 'Year', sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

with Company_Year (Company,Years,Total_laid_off) as 
(
select company, year(`date`) as 'Year', sum(total_laid_off) 
from layoffs_staging2
group by company, year(`date`)
), 
Company_Year_Ranking as
(
select *, dense_rank() over(partition by Years order by Total_laid_off desc) as Ranking
from Company_Year
where years is not null
)
select *
from Company_Year_Ranking
where Ranking <=5;

-- Analyzing which industry had maximum layoffs on yearly basis
select industry, year(`date`) as 'Year', sum(total_laid_off)
from layoffs_staging2
group by industry, year(`date`)
order by 3 desc;

with Industry_Year (Industry,Years,Total_laid_off) as 
(
select industry, year(`date`) as 'Year', sum(total_laid_off) 
from layoffs_staging2
group by industry, year(`date`)
), 
Industry_Year_Ranking as
(
select *, dense_rank() over(partition by Years order by Total_laid_off desc) as Ranking
from Industry_Year
where years is not null
)
select *
from Industry_Year_Ranking
where Ranking <=5;

-- Total funds raised by each company
select company, sum(funds_raised_millions) as 'Total_Funds'
from layoffs_staging2
group by company
order by 2 desc;

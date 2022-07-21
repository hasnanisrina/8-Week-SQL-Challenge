/*Case Study 5: Data Mart
Tools: PostgreSQL
Skills: Windows Function, CAST, CASE WHEN
Author: Hasna Nisrina*/

SET search_path = data_mart

--Case Study Question
--A. Data Cleansing Steps
DROP TABLE IF EXISTS clean_weekly_sales

SELECT CAST(week_date AS date) AS week_date,
		DATE_PART('WEEK', CAST(week_date AS date)) AS week_number,
		DATE_PART('MONTH', CAST(week_date AS date)) AS month_number,
		DATE_PART('YEAR', CAST(week_date AS date)) AS calendar_year,
		region,
		platform,
		segment,
		CASE WHEN RIGHT(segment,1)= '1' THEN 'Young Adults'
		WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
		WHEN RIGHT(segment, 1) = '3' OR RIGHT(segment, 1) = '4' THEN'Retirees'
		ELSE 'unknown' END AS age_band,
		CASE WHEN LEFT(segment,1)='F' THEN 'Families'
		WHEN LEFT(segment,1)='C' THEN 'Couples'
		ELSE 'unknown' END AS demographics,
		customer_type,
		CAST(transactions AS float) AS transactions,
		CAST(sales AS float) AS sales,
		ROUND(sales/transactions, 2) avg_transaction
INTO clean_weekly_sales
FROM weekly_sales

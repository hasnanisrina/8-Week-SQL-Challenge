/*Case Study 7: Balanced Tree Clothing Co.
Tools: PostgreSQL
Skills: Aggregation
Author: Hasna Nisrina*/

SET search_path = balanced_tree;

--Case Study Question--
--B. Transaction Analysis
--1. How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales

--2. What is the average unique products purchased in each transaction?
WITH unique_prod AS(
	SELECT txn_id, COUNT(distinct prod_id) AS unique_product
	FROM sales
	GROUP BY txn_id)
SELECT AVG(unique_product) AS avg_unique_product
FROM unique_prod

--3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH revenue AS(
	SELECT txn_id,
	ROUND(SUM((1-discount::NUMERIC/100)*price*qty),2) AS total_revenue
	FROM sales
	GROUP BY txn_id)
SELECT
	percentile_disc(.25) WITHIN GROUP(ORDER BY total_revenue),
	percentile_disc(.5) WITHIN GROUP(ORDER BY total_revenue),
	percentile_disc(.75) WITHIN GROUP(ORDER BY total_revenue)
FROM revenue

--4. What is the average discount value per transaction?
WITH discounts AS(
	SELECT txn_id,
	ROUND(SUM((discount::NUMERIC/100)*price*qty),2) AS total_discount
	FROM sales
	GROUP BY txn_id)
SELECT ROUND(AVG(total_discount),2) AS avg_discount
FROM discounts

--5. What is the percentage split of all transactions for members vs non-members?
SELECT member,
	COUNT(DISTINCT txn_id) AS frequency,
	ROUND(100 *(COUNT(DISTINCT txn_id) / SUM(COUNT(DISTINCT txn_id)) OVER()),2) AS percentage
FROM sales
GROUP BY member

--6. What is the average revenue for member transactions and non-member transactions?
WITH revenue AS(
	SELECT txn_id, member,
	SUM((1-discount::NUMERIC/100)*price*qty) AS total_revenue
	FROM sales
	GROUP BY txn_id, member)
SELECT member,
	ROUND(AVG(total_revenue),2) AS avg_revenue
FROM revenue
GROUP BY member


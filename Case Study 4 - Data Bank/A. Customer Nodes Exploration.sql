/*Case Study 4: Data Bank
Tools: PostgreSQL
Skills: Join, Aggregate, CTE, Windows Function
Author: Hasna Nisrina*/

SET search_path = data_bank

--Case Study Question
--A. Customer Nodes Exploration
--1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes

--2. What is the number of nodes per region?
SELECT r.region_id, r.region_name, COUNT(node_id) AS number_nodes
FROM customer_nodes AS c
INNER JOIN regions AS r
ON c.region_id = r.region_id
GROUP BY r.region_id, r.region_name

--3. How many customers are allocated to each region?
SELECT r.region_id, r.region_name, COUNT(DISTINCT customer_id) AS number_customer 
FROM customer_nodes AS c
INNER JOIN regions AS r
ON c.region_id = r.region_id
GROUP BY r.region_id, r.region_name

--4. How many days on average are customers reallocated to a different node?
SELECT AVG(DATE_PART('day', end_date::timestamp - start_date::timestamp))
FROM customer_nodes
WHERE end_date != '9999-12-31'

--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH diff_data AS (
					SELECT c.customer_id, c.region_id, r.region_name,
					DATE_PART('day', end_date::timestamp - start_date::timestamp) AS diff
					FROM customer_nodes AS c 
					INNER JOIN regions AS r
					ON c.region_id = r.region_id
					WHERE end_date != '9999-12-31')
SELECT region_id, region_name,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff) AS median,
	PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY diff) AS percentile_80,
	PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY diff) AS percentile_95
FROM diff_data
GROUP BY region_id, region_name



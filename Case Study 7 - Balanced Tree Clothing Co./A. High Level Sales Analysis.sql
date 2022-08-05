/*Case Study 7: Balanced Tree Clothing Co.
Tools: PostgreSQL
Skills: Aggregation
Author: Hasna Nisrina*/

SET search_path = balanced_tree;

--Case Study Question--
--A. High Level Sales Analysis
--1. What was the total quantity sold for all products?
SELECT SUM(qty) AS total_sold
FROM sales

--2. What is the total generated revenue for all products before discounts?
SELECT SUM(qty * price) AS total_revenue
FROM sales

--3. What was the total discount amount for all products?
SELECT ROUND(SUM(qty * price * discount::NUMERIC/100),2) AS total_discount
FROM sales


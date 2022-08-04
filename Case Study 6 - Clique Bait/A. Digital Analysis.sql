/*Case Study 6: Clique Bait
Tools: PostgreSQL
Skills: Aggregation, JOIN, Windows Function, CASE WHEN
Author: Hasna Nisrina*/

SET search_path = clique_bait;

--Case Study Question--
--A. Digital Analysis
--1. How many users are there?
SELECT COUNT(DISTINCT user_id) AS total_users
FROM users;

--2. How many cookies does each user have on average?
WITH cookie AS(
	SELECT user_id, COUNT(DISTINCT cookie_id) AS cookies
	FROM users
	GROUP BY user_id)
SELECT ROUND(AVG(cookies),0) AS avg_cookies
FROM cookie;

--3. What is the unique number of visits by all users per month?
SELECT DATE_PART('MONTH', event_time) AS month,
	COUNT(DISTINCT visit_id) AS unique_visit
FROM events
GROUP BY month;

--4. What is the number of events for each event type?
SELECT event_type, COUNT(event_type) AS number_of_events
FROM events
GROUP BY event_type
ORDER BY event_type;

--5. What is the percentage of visits which have a purchase event?
SELECT ROUND(100*COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT visit_id)
					FROM events),2) AS percentage_visit
FROM events AS e
INNER JOIN event_identifier AS ei
ON e.event_type = ei.event_type
WHERE event_name = 'Purchase';

--6. What is the percentage of visits which view the checkout page but do not have a purchase event?
SELECT ROUND(100*COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT visit_id)
					FROM events),2) AS percentage_visit
FROM events AS e
INNER JOIN event_identifier AS ei
ON e.event_type = ei.event_type
INNER JOIN page_hierarchy AS ph
ON e.page_id = ph.page_id
WHERE page_name = 'Checkout' AND event_name != 'Purchase';

--7. What are the top 3 pages by number of views?
SELECT p.page_name, COUNT(p.page_name) AS number_views
FROM page_hierarchy AS p
INNER JOIN events AS e
ON p.page_id = e.page_id
WHERE e.event_type = 1 --Page View
GROUP BY p.page_name
ORDER BY number_views DESC
LIMIT 3

--8. What is the number of views and cart adds for each product category?
SELECT p.product_category,
	SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
	SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM page_hierarchy AS p
INNER JOIN events AS e
ON p.page_id = e.page_id
WHERE p.product_category IS NOT NULL
GROUP BY p.product_category

/*Case Study 2: Pizza Runner
Tools: PostgreSQL
Skills: Aggregate, Join, CTE, Windows Function
Author: Hasna Nisrina*/

--Case Study Question--
--A. Pizza Metrics
--1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS pizza_ordered
FROM customer_orders

--2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM customer_orders

--3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE distance != ''
GROUP BY runner_id

--4. How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(r.order_id) AS successful_delivered
FROM runner_orders AS r
INNER JOIN customer_orders AS c
ON r.order_id = c.order_id
INNER JOIN pizza_names AS p
ON c.pizza_id = p.pizza_id
WHERE distance != ''
GROUP BY p.pizza_name

--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, COUNT(c.order_id) AS pizza_ordered
FROM customer_orders AS c
INNER JOIN pizza_names AS p
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id

--6. What was the maximum number of pizzas delivered in a single order?
WITH orders AS(
	SELECT c.order_id, COUNT(*) AS pizza_delivered
	FROM runner_orders AS r
	INNER JOIN customer_orders AS c
	ON r.order_id = c.order_id
	WHERE distance != ''
	GROUP BY c.order_id)
SELECT MAX(pizza_delivered)
FROM orders

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
	SUM(CASE WHEN exclusions != '' OR extras != '' THEN 1
	   ELSE 0
	   END) AS at_least_1_change,
	SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1
	   ELSE 0
	   END) AS no_changes
FROM customer_orders AS c
INNER JOIN runner_orders AS r
ON r.order_id = c.order_id
WHERE distance != ''
GROUP BY customer_id
ORDER BY customer_id

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1
	   ELSE 0
	   END) AS at_least_1_change
FROM customer_orders AS c
INNER JOIN runner_orders AS r
ON r.order_id = c.order_id
WHERE distance != ''

--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATE_PART('HOUR', order_time) AS hour_of_the_day,
		COUNT(order_id) AS total_pizza
FROM customer_orders
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day

--10. What was the volume of orders for each day of the week?
SELECT EXTRACT(dow from order_time) AS day,
		COUNT(order_id) AS total_pizza
FROM customer_orders
GROUP BY day
ORDER BY day
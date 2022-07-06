/*Case Study 2: Pizza Runner
Tools: PostgreSQL
Skills: Aggregate, Join, CTE, Windows Function
Author: Hasna Nisrina*/

--Case Study Question--
--B. Runner and Customer Experience
--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATE_PART('week', registration_date) AS week_period,
		COUNT(*) AS runner_signup
FROM runners
GROUP BY week_period

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH pickup_times AS(
SELECT r.runner_id, 
	c.order_id,
	DATEDIFF('MINUTE', c.order_time, r.pickup_time) AS pickup_minutes
FROM customer_orders AS c
INNER JOIN runner_orders AS r
ON r.order_id = c.order_id
WHERE distance != ''
GROUP BY r.runnerid)
SELECT runner_id, AVG(pickup_minutes) AS avg_pickup_minutes
FROM pickup_times
GROUP BY runner_id

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_times AS(
SELECT c.order_id, 
	COUNT(c.order_id) AS number_pizza,
	DATEDIFF('MINUTE', c.order_time, r.pickup_time) AS prep_minutes
FROM customer_orders AS c
INNER JOIN runner_orders AS r
ON r.order_id = c.order_id
WHERE distance != ''
GROUP BY c.order_id)
SELECT number_pizza, AVG(prep_minutes) AS avg_prep_minutes
FROM prep_times
GROUP BY number_pizza

--4. What was the average distance travelled for each customer?
SELECT c.customer_id, AVG(r.distance::Float) AS avg_distance
FROM customer_orders AS c
INNER JOIN runner_orders AS r
ON r.order_id = c.order_id
WHERE distance != ''
GROUP BY c.customer_id
ORDER BY c.customer_id

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration::Numeric) - MIN(duration::Numeric) AS delivery_times_difference
FROM  runner_orders
WHERE duration != ''

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT r.runner_id, c.order_id, ROUND((r.distance/r.duration * 60), 2) AS avg_speed
FROM customer_orders AS c
INNER JOIN runner_orders AS r
ON r.order_id = c.order_id
WHERE distance != ''
GROUP BY r.runner_id, c.order_id
ORDER BY r.runner_id, c.order_id

--7. What is the successful delivery percentage for each runner?
SELECT runner_id, 
		ROUND(100*SUM(CASE WHEN distance = '' THEN 0
							   	ELSE 1
							   END)/COUNT(*), 0) AS successful_percentage
FROM runner_orders 
GROUP BY runner_id
ORDER BY runner_id
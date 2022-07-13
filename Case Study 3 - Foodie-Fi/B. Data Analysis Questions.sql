/*Case Study 3: Foodie- Fi
Tools: PostgreSQL
Skills: Join, Aggregate, CTE, Subquery, Windows Function
Author: Hasna Nisrina*/

SET search_path = foodie_fi

--Case Study Question
--B. Data Analysis Questions
--1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customer
FROM subscriptions

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT DATE_PART('MONTH', s.start_date) AS month,
		COUNT(s.start_date)
FROM subscriptions AS s
LEFT JOIN plans AS p
ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY month
ORDER BY month

--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
WITH plans_2020 AS(SELECT plan_id, COUNT(*) AS event_2020
				  FROM subscriptions
				  WHERE DATE_PART('YEAR', start_date)= 2020
				  GROUP BY plan_id),
plans_2021 AS (SELECT plan_id, COUNT(*) AS event_2021
				FROM subscriptions
				WHERE DATE_PART('YEAR', start_date)= 2021
				GROUP BY plan_id)
SELECT p.plan_name, a.event_2020, b.event_2021
FROM plans_2020 AS a
INNER JOIN plans_2021 AS b
ON a.plan_id = b.plan_id
INNER JOIN plans AS p
ON p.plan_id = b.plan_id

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(DISTINCT s.customer_id) AS total_churn,
		ROUND(100*COUNT(DISTINCT s.customer_id)::numeric/
			 (SELECT COUNT(DISTINCT customer_id)
			 FROM subscriptions),1) AS percentage_churn
FROM subscriptions AS s
LEFT JOIN plans AS p
ON s.plan_id = p.plan_id
WHERE p.plan_name = 'churn'

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH ranks AS(SELECT *,
			 RANK() OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) AS rank
			FROM subscriptions)
SELECT COUNT(DISTINCT r.customer_id) AS total_churn,
		ROUND(100*COUNT(DISTINCT r.customer_id)::numeric/
			 (SELECT COUNT(DISTINCT customer_id)
			 FROM subscriptions),1) AS percentage_churn
FROM ranks AS r
LEFT JOIN plans AS p
ON r.plan_id = p.plan_id
WHERE p.plan_name = 'churn' AND rank=2

--6. What is the number and percentage of customer plans after their initial free trial?
WITH next AS (
			SELECT customer_id, plan_id,
					LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
			FROM subscriptions)
SELECT next_plan,
		COUNT(next_plan) AS number_plan,
		ROUND(100*COUNT(next_plan)::numeric/
			 	(SELECT COUNT(DISTINCT customer_id)
				FROM subscriptions),1) AS percentage_plan
FROM next
WHERE next_plan IS NOT NULL AND plan_id=0
GROUP BY next_plan
ORDER BY next_plan

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH next AS (
			SELECT customer_id, plan_id, start_date,
					LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_date
			FROM subscriptions
			WHERE start_date <= '2020-12-31'),
customer_breakdown AS(
			SELECT plan_id, COUNT(DISTINCT customer_id) AS customers
			FROM next
			WHERE (next_date IS NULL AND start_date <= '2020-12-31')
			OR (next_date IS NOT NULL AND (start_date <= '2020-12-31' AND next_date >'2020-12-31'))
			GROUP BY plan_id)
SELECT plan_id, customers,
		ROUND(100*customers::numeric/
			 (SELECT COUNT(DISTINCT customer_id)
				FROM subscriptions),1) AS percentage
FROM customer_breakdown
GROUP BY plan_id, customers
ORDER BY plan_id

--8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id)
FROM subscriptions
WHERE plan_id = 3
AND DATE_PART('YEAR', start_date) = 2020

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_plans AS(
					SELECT customer_id, start_date AS trial_date
					FROM subscriptions
					WHERE plan_id = 0),
annual_plans AS(
					SELECT customer_id, start_date AS annual_date
					FROM subscriptions
					WHERE plan_id = 3),
day AS (SELECT a.customer_id, (annual_date - trial_date) AS days
FROM trial_plans AS t
JOIN annual_plans AS a
ON t.customer_id = a.customer_id)
SELECT AVG(days) 
FROM day
					
--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial_plans AS(
					SELECT customer_id, start_date AS trial_date
					FROM subscriptions
					WHERE plan_id = 0),
annual_plans AS(
					SELECT customer_id, start_date AS annual_date
					FROM subscriptions
					WHERE plan_id = 3),
bins AS(
		SELECT WIDTH_BUCKET(a.annual_date - t.trial_date,0,360,12) AS avg_days
		FROM trial_plans AS t
		JOIN annual_plans AS a
		ON t.customer_id = a.customer_id)
SELECT (avg_days-1)	*30 || '-' || (avg_days*30) || 'days' AS brekdown,
		COUNT(*) AS customers
FROM bins
GROUP BY avg_days
ORDER BY avg_days

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH next AS (
			SELECT customer_id, plan_id, start_date,
					LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
			FROM subscriptions)
SELECT COUNT(*) AS downgraded
FROM next
WHERE DATE_PART('YEAR', start_date) = 2020
AND plan_id = 2
AND next_plan =1

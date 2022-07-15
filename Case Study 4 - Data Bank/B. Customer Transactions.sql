/*Case Study 4: Data Bank
Tools: PostgreSQL
Skills: Join, Aggregate, CTE, Windows Function
Author: Hasna Nisrina*/

SET search_path = data_bank

--Case Study Question
--B. Customer Transactions
--1. What is the unique count and total amount for each transaction type?
SELECT txn_type, COUNT(txn_type) AS unique_count, SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type

--2. What is the average total historical deposit counts and amounts for all customers?
WITH historical AS(
					SELECT customer_id, txn_type, 
					COUNT(txn_type) AS unique_count, AVG(txn_amount) AS total_amount
					FROM customer_transactions
					GROUP BY customer_id, txn_type)
SELECT AVG(unique_count), AVG(total_amount)
FROM historical
WHERE txn_type = 'deposit'

--3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH monthly_transactions AS (
  		SELECT customer_id, 
    	DATE_PART('month', txn_date) AS month,
    	SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
    	SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
    	SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  		FROM customer_transactions
  		GROUP BY customer_id, month)
SELECT month, COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_transactions
WHERE deposit_count > 1 
  AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY month
ORDER BY month

--4. What is the closing balance for each customer at the end of the month?
-- CTE 1 - To identify transaction amount as an inflow (+) or outflow (-)
WITH monthly_balances AS (
  SELECT 
    customer_id, 
    (DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month, 
    txn_type, 
    txn_amount,
    SUM(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN (-txn_amount)
      ELSE txn_amount END) AS transaction_balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_date, txn_type, txn_amount
),

-- CTE 2 - To generate txn_date as a series of last day of month for each customer
last_day AS (
  SELECT
    DISTINCT customer_id,
    ('2020-01-31'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS ending_month
  FROM data_bank.customer_transactions
),

-- CTE 3 - Create closing balance for each month using Window function SUM() to add changes during the month
solution_t1 AS (
  SELECT 
    ld.customer_id, 
    ld.ending_month,
    COALESCE(mb.transaction_balance, 0) AS monthly_change,
    SUM(mb.transaction_balance) OVER 
      (PARTITION BY ld.customer_id ORDER BY ld.ending_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
  FROM last_day ld
  LEFT JOIN monthly_balances mb
    ON ld.ending_month = mb.closing_month
      AND ld.customer_id = mb.customer_id
),

-- CTE 4 - Use Window function ROW_NUMBER() to rank transactions within each month
solution_t2 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance,
    ROW_NUMBER() OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS record_no
  FROM solution_t1
),

-- CTE 5 - Use Window function LEAD() to query value in next row and retrieve NULL for last row
solution_t3 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance, 
    record_no,
    LEAD(record_no) OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS lead_no
  FROM solution_t2
)

SELECT 
  customer_id, ending_month, 
  monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL;

--5. What is the percentage of customers who increase their closing balance by more than 5%?
WITH 
	first_month 
		AS
	(
		SELECT 
			customer_id,
			CAST('20200131' as date) closing_date,
			MIN(DATEPART(M, txn_date)) min_month, 
			MAX(DATEPART(M, txn_date)) max_month
		from customer_transactions
		group by customer_id
	),
	months  --recursive function (for closing_date)
		AS
	(
		SELECT 
			customer_id,
			closing_date,
			DATEPART(M, closing_date) month_id,
			DATENAME(M, closing_date) month_name
			, min_month, max_month
		FROM first_month

			UNION ALL 
    
		SELECT 
			customer_id,
			DATEADD(M, 1, closing_date) closing_date,
			DATEPART(M, DATEADD(M, 1, closing_date)) closing_id,
			DATENAME(M, DATEADD(M, 1, closing_date)) closing_name
			, min_month, max_month
		FROM months b
		WHERE closing_date <= CAST('20200401' as date)
	),
	balance --count data each type transactions
AS
	(
		select
			customer_id,
			DATEPART(M, txn_date) month_id,
			DATENAME(M, txn_date) month_name,
			sum(case when txn_type in ('purchase','withdrawal') then -txn_amount
				else txn_amount end) txn_amount
		from customer_transactions
		group by customer_id, DATEPART(M, txn_date), DATENAME(M, txn_date)
	),
	closing_balances --first and closing balances
AS
	(
		select
			m.customer_id,
			m.month_id,
			m.month_name,
			SUM(txn_amount) OVER(PARTITION BY m.customer_id ORDER BY m.month_id
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) closing_balance
		from months m
		left join balance b on b.customer_id = m.customer_id and b.month_id = m.month_id
		where m.month_id between min_month and max_month
	),
	balances --first balances
AS
	(
		select
			customer_id,
			month_id,
			month_name,
			coalesce(LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY month_id),0) opening_balance,
			closing_balance
		from closing_balances
	),
	cases --closing - opening balance
AS
	(
		select
			customer_id,
			month_id,
			month_name,
			opening_balance,
			closing_balance,
			case when opening_balance is null then cast((closing_balance - 0) as float)
				else cast((closing_balance - opening_balance) as float) end diff
		from balances
	),
	percents --percentage increase
AS
	(
		select *, 
			case when opening_balance = 0 then round(cast(diff/1*100 as float), 2)
				else round(cast(diff/opening_balance*100 as float), 2) end percentage
		from cases
	),
	minimum --when balance null then 0
AS
	(
		select *,
			MIN(percentage) OVER(PARTITION BY customer_id) mins
		from percents
	)
select ROUND(100 * CAST(COUNT(customer_id) as float) / 
			(select count(*) from customer_transactions), 2) percentage_of_customers
from minimum
where mins > 5;

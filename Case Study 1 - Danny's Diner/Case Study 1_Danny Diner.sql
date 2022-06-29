/*Case Study 1: Danny's Diner
Tools: PostgreSQL
Skills: Aggregate, Join, Subquery, CTE, Windows Function
Author: Hasna Nisrina
*/

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER);
  
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER);
  
INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE);
  
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
--Case Study Question--
--1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, 
		sum(m.price) AS total_amount
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id

--2. How many days has each customer visited the restaurant?
SELECT customer_id,
		COUNT(DISTINCT order_date) as Days
FROM sales
GROUP BY customer_id
ORDER BY customer_id

--3. What was the first item from the menu purchased by each customer?
SELECT customer_id,
		product_name
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
WHERE order_date = (SELECT min(order_date)
				   FROM sales)
ORDER BY customer_id

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, 
		COUNT(s.product_id) AS total_purchased
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name
LIMIT 1

--5. Which item was the most popular for each customer?
WITH popular_menu AS(
		SELECT s.customer_id, 
				m.product_name,
				COUNT(s.product_id) AS total_order,
				DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank
		FROM sales AS s
		INNER JOIN menu AS m
		ON s.product_id = m.product_id
		GROUP BY s.customer_id, m.product_name)
SELECT customer_id,
		product_name,
		total_order
FROM popular_menu
WHERE rank = 1
ORDER BY customer_id

--6. Which item was purchased first by the customer after they became a member?
WITH member_cte AS(
		SELECT s.customer_id,
				m.join_date,
				s.order_Date,
				s.product_id,
				DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
		FROM sales AS s
		INNER JOIN members AS m
		ON s.customer_id = m.customer_id
		WHERE m.join_date <= s.order_Date
		)
SELECT mc.customer_id,
		m.product_name
FROM member_cte AS mc
INNER JOIN menu as m
ON mc.product_id = m.product_id
WHERE rank = 1
ORDER BY mc.customer_id

--7. Which item was purchased just before the customer became a member?
WITH member_cte AS(
		SELECT s.customer_id,
				m.join_date,
				s.order_Date,
				s.product_id,
				DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank
		FROM sales AS s
		INNER JOIN members AS m
		ON s.customer_id = m.customer_id
		WHERE m.join_date > s.order_Date
		)
SELECT mc.customer_id,
		m.product_name
FROM member_cte AS mc
INNER JOIN menu as m
ON mc.product_id = m.product_id
WHERE rank = 1
ORDER BY mc.customer_id

--8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
		COUNT(s.product_id) AS total_items,
		SUM(me.price) AS total_amount
FROM sales AS s
INNER JOIN members AS m
ON s.customer_id = m.customer_id
INNER JOIN menu as me
ON s.product_id = me.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points AS(
		SELECT *,
			CASE WHEN product_id =1 THEN price*20
			ELSE price*10
			END AS point
		FROM menu)
SELECT s.customer_id,
		sum(p.point) AS total_point
FROM sales AS s
INNER JOIN points AS p
ON s.product_id = p.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates AS(
		SELECT *,
			join_date + INTERVAL '6 day' AS valid_date,
			'2021-01-31' :: DATE AS last_date
		FROM members),
points AS(
		SELECT s.customer_id,
		s.order_date,
		d.join_date,
		d.valid_date,
		d.last_date,
		m.product_name,
		m.price,
		SUM(CASE WHEN m.product_name ='sushi' THEN m.price*20
		   WHEN s.order_date BETWEEN d.join_date AND d.valid_Date THEN m.price*20
		   ELSE m.price*10
		   END) AS point
FROM dates AS d
INNER JOIN sales AS s
ON d.customer_id = s.customer_id
INNER JOIN menu AS m
ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY s.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price)
SELECT customer_id, 
		SUM(point) AS total_point
FROM points
GROUP BY customer_id

--Bonus Question
--Recreate the table with: customer_id, order_date, product_name, price, member(Y/N)
SELECT s.customer_id,
		s.order_date,
		m.product_name,
		m.price,
		CASE WHEN me.join_date > s.order_date THEN 'N'
		WHEN me.join_date <= s.order_date THEN 'Y'
		ELSE 'N'
		END AS member
FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
LEFT JOIN members AS me
ON s.customer_id = me.customer_id

--Ranking of customer for member
WITH summary AS(
	SELECT s.customer_id,
			s.order_date,
			m.product_name,
			m.price,
			CASE WHEN me.join_date > s.order_date THEN 'N'
			WHEN me.join_date <= s.order_date THEN 'Y'
			ELSE 'N'
			END AS member
	FROM sales AS s
	LEFT JOIN menu AS m
	ON s.product_id = m.product_id
	LEFT JOIN members AS me
	ON s.customer_id = me.customer_id)
SELECT *,
		CASE WHEN member= 'N' THEN NULL
		ELSE RANK() OVER(PARTITION BY customer_id, member 
						 ORDER BY order_date)
		END AS ranking
FROM summary

--Finished--
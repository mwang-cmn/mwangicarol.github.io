USE dannys_diner;

--View the menu table
SELECT *
 from menu;
 
 --View the menu table
SELECT *
  FROM sales;

--View the menu table
SELECT *
  FROM members;
--SOLUTIONS
-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) as total_spent
  FROM sales s
LEFT JOIN  menu m
ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT	s.customer_id, COUNT(DISTINCT order_date) as days_visited
  FROM sales s
LEFT JOIN  menu m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

with Product_by_customer AS
(SELECT s.customer_id, s.order_date, m.product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS order_rank
	FROM sales s
	LEFT JOIN menu m
	ON s.product_id = m.product_id)
	SELECT customer_id, order_date, product_name AS first_order
	  FROM Product_by_customer 
	  WHERE order_rank = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1 m.product_name, COUNT(s.product_id)
  FROM sales s
  LEFT JOIN menu m
  ON s.product_id = m.product_id
  GROUP BY m.product_name
  ORDER BY COUNT(s.product_id) DESC;

-- 5. Which item was the most popular for each customer?
WITH popular_items AS (
SELECT s.customer_id, m.product_name,COUNT(s.product_id) as count_item ,DENSE_RANK() OVER( PARTITION BY s.customer_id order by COUNT(s.product_id) DESC) AS rank
  from menu m
  join sales s
  on s.product_id = m.product_id
  group by s.customer_id,m.product_name, s.product_id)
  SELECT customer_id, product_name, count_item
    from popular_items
	WHERE rank=1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH Rank AS(SELECT s.customer_id, m.product_name,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ranking
  FROM sales s
  JOIN menu m
  ON s.product_id = m.product_id
  JOIN members
  ON members.customer_id =s.customer_id
  WHERE s.order_date >= members.join_date)
  SELECT *
    FROM Rank
	WHERE ranking=1;



-- 7. Which item was purchased just before the customer became a member?
WITH Rank AS(
SELECT s.customer_id, m.product_name,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ranking
  FROM sales s
  JOIN menu m
  ON s.product_id = m.product_id
  JOIN members
  ON members.customer_id =s.customer_id
  WHERE s.order_date < members.join_date)
  SELECT *
    FROM Rank
	WHERE ranking=1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id) as total_items, SUM(m.price) AS total_sales
  FROM sales s
  JOIN menu m
  ON s.product_id = m.product_id
  JOIN members
  ON members.customer_id = s.customer_id
  WHERE s.order_date < members.join_date
  GROUP BY s.customer_id;
  
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points as(
SELECT *, 
 CASE WHEN product_id =1 THEN price*20
	ELSE price*10 END AS Points
  FROM menu
)
SELECT s.customer_id, SUM(p.points) as Points
  FROM sales s
  join points p
  on s.product_id=p.product_id
  GROUP BY s.customer_id;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT s.customer_id
	,SUM(CASE WHEN (DATEDIFF(DAY, members.join_date, s.order_date) BETWEEN 0 AND 7) OR (m.product_ID = 1) THEN m.price * 20
              ELSE m.price * 10 END) AS Points
 FROM members
 INNER JOIN sales s
 ON s.customer_id=members.customer_id
 INNER JOIN menu m
 ON s.product_id= m.product_id
 WHERE s.order_date >= members.join_date AND s.order_date <= CAST('2021-01-31' AS DATE)
 GROUP BY s.customer_id;

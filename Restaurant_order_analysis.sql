USE restaurant_db;
--View the menu_items table
SELECT *
  FROM menu_items;
  --View the order_details table
SELECT *
  FROM order_details;

--Analysis
--View the menu_items table and write a query to find the number of items on the menu
SELECT COUNT(DISTINCT item_name) AS no_of_items
  FROM menu_items;
--What are the least and most expensive items on the menu?
SELECT TOP 1 item_name, price AS cheapest_price
  FROM menu_items
 ORDER BY price ;

 SELECT TOP 1 item_name, price AS most_expensive
  FROM menu_items
 ORDER BY price DESC;

--How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT COUNT(menu_item_id) as no_of_Italian_items
  FROM menu_items
  WHERE category='Italian';

SELECT TOP 1 item_name, price
  FROM menu_items
  WHERE category='Italian'
  ORDER BY price;

SELECT TOP 1 item_name, price
  FROM menu_items
  WHERE category='Italian'
  ORDER BY price DESC;

--How many dishes are in each category? What is the average dish price within each category?
SELECT category, COUNT(menu_item_id) AS items_per_category, ROUND(AVG(price),2) AS average_cost_category
  FROM menu_items
  GROUP BY category;

--View the order_details table. What is the date range of the table?
SELECT MAX(order_date) as latest_order, MIN(order_date) AS first_order
  FROM order_details;
--How many orders were made within this date range? How many items were ordered within this date range?
SELECT COUNT(DISTINCT order_id) as count_of_orders
  FROM order_details;
--Which orders had the most number of items?
SELECT order_id, COUNT(order_id) as items_per_order
  FROM order_details
  GROUP BY order_id
  ORDER BY items_per_order DESC;
--How many orders had more than 12 items?
SELECT COUNT(*) AS orders_more_than_12
  FROM
(SELECT order_id, COUNT(order_id) as items_per_order
  FROM order_details
  GROUP BY order_id
  HAVING COUNT(order_id) > 12) AS subquery ;
--Combine the menu_items and order_details tables into a single table
SELECT *
  FROM order_details o
  JOIN menu_items m
  ON o.item_id = m.menu_item_id
--What were the least and most ordered items? What categories were they in?
SELECT TOP 1 m.item_name,m.category, COUNT(o.order_id) AS count
  FROM order_details o
  JOIN menu_items m
  ON o.item_id = m.menu_item_id
  GROUP BY  item_name, category
  ORDER BY count;

  SELECT TOP 1 m.item_name,m.category, COUNT(o.order_id) AS count
  FROM order_details o
  JOIN menu_items m
  ON o.item_id = m.menu_item_id
  GROUP BY  item_name, category
  ORDER BY count DESC;
--What were the top 5 orders that spent the most money?
  SELECT TOP 5 o.order_id, SUM(m.price) AS total_spent_per_order
    FROM order_details o
    JOIN menu_items m
      ON o.item_id = m.menu_item_id
   GROUP BY o.order_id
   ORDER BY total_spent_per_order DESC;
--View the details of the highest spend order. Which specific items were purchased?
  SELECT o.order_id, m.item_name, m.category, m.price
    FROM order_details o
    JOIN menu_items m
      ON o.item_id = m.menu_item_id
   WHERE order_id=440;
--View the details of the top 5 highest spend orders
  SELECT o.order_id, m.item_name, m.category, m.price
    FROM order_details o
    JOIN menu_items m
      ON o.item_id = m.menu_item_id
   WHERE order_id IN (440, 2075, 1957,330,2675)
   ORDER BY m.item_name, m.category;
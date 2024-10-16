/* 
#8weekslchallange Case study #2 - Pizza Runner
Solution by Vaibhav Chavan on youtube @iThinkData
Subscribe to @ iThinkData For more SQL Challange Series
*/

-- Let's get Started with Part - A  .....

-- A. Pizza Metrics

-- A1. How many pizzas were ordered?

SELECT 
	COUNT(*) AS 'Total Pizza Orders'
FROM customer_orders;

-- A2. How many unique customer orders were made?

SELECT 
	COUNT(DISTINCT(order_id)) AS 'Unique Customer Orders'
FROM customer_orders;

-- A3. How many successful orders were delivered by each runner?

SELECT 
	runner_id,
	COUNT(order_id) AS 'Total Successful Orders Delivered'
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;

-- A4. How many of each type of pizza was delivered?

SELECT 
	pizza_names.pizza_id AS 'Pizza ID',  
	pizza_names.pizza_name AS 'Pizza Name', 
	COUNT(customer_orders_temp.order_id) AS 'Total Successful Pizzas\' Delivered'
FROM runner_orders_temp 
	INNER JOIN customer_orders_temp 
		ON runner_orders_temp.order_id=customer_orders_temp.order_id
	INNER JOIN pizza_names 
		ON customer_orders_temp.pizza_id=pizza_names.pizza_id
WHERE runner_orders_temp.cancellation IS NULL
GROUP BY 
	pizza_names.pizza_id, 
	pizza_names.pizza_name; 

-- A5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	pizza_names.pizza_name,
	customer_orders_temp.customer_id,
	COUNT(customer_orders_temp.order_id)
FROM customer_orders_temp 
	INNER JOIN pizza_names 
		ON customer_orders_temp.pizza_id=pizza_names.pizza_id
GROUP BY 
	pizza_names.pizza_name,
	customer_orders_temp.customer_id
ORDER BY 
	pizza_names.pizza_name,
	customer_orders_temp.customer_id;

-- A6. What was the maximum number of pizzas delivered in a single order?

SELECT
	cot.customer_id,
    cot.order_id,
    COUNT(cot.pizza_id) AS 'Pizza Count'
FROM customer_orders_temp AS cot 
	INNER JOIN runner_orders_temp AS rot 
		ON cot.order_id=rot.order_id
WHERE 
	rot.cancellation IS NULL
GROUP BY 
	cot.order_id,
	cot.customer_id
ORDER BY 
	COUNT(cot.pizza_id) DESC 
    LIMIT 1;

-- A7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
	cot.customer_id,
	SUM(CASE
			WHEN cot.exclusions IS NOT NULL OR cot.extras IS NOT NULL THEN 1
			ELSE 0
		END) AS 'Pizza has atleast 1 Change',
	SUM(CASE
			WHEN cot.exclusions IS NULL AND cot.extras IS NULL THEN 1
			ELSE 0
		END) AS 'Pizza NOT Changed'      
FROM customer_orders_temp As cot 
	INNER JOIN runner_orders_temp AS rot ON cot.order_id=rot.order_id
WHERE cancellation IS NULL
GROUP BY cot.customer_id
ORDER BY cot.customer_id;

-- A8. How many pizzas were delivered that had both exclusions and extras?
SELECT  
	cot.customer_id,
	SUM(CASE
			WHEN cot.exclusions IS NOT NULL AND cot.extras IS NOT NULL THEN 1
			ELSE 0
			END) AS 'Count of Pizzas\' with both Changes'
FROM customer_orders_temp As cot 
	INNER JOIN runner_orders_temp AS rot ON cot.order_id=rot.order_id
WHERE cancellation IS NULL
GROUP BY cot.customer_id
ORDER BY cot.customer_id;

-- A9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
	HOUR(order_time) AS Hour_of_Day,
	COUNT(order_id) AS Volume_of_Pizza_ordered
FROM customer_orders_temp
GROUP BY Hour_of_Day
ORDER BY Hour_of_Day ;

-- A10. What was the volume of orders for each day of the week?

SELECT 
	DAYNAME(order_time) AS Day_of_week,
	COUNT(order_id) AS Volume_of_Pizza_ordered
FROM customer_orders_temp
GROUP BY Day_of_week
ORDER BY Volume_of_Pizza_ordered DESC ;


-- #8weekslchallange Case study #2 - Pizza Runner
-- Solution by Vaibhav Chavan on youtube @iThinkData
-- Subscribe to @ iThinkData For more SQL Challange Series

-- Let's get Started with Part B.....

-- B. Runner and Customer Experience

-- B1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT  registration_date - ((registration_date - DATE('2021-01-01')) % 7) AS 'Week Start Date',
		week(registration_date - ((registration_date - DATE('2021-01-01')) % 7)) + 1 as 'Week Number',   -- +1 bcz week number starts from zero
		COUNT(runner_id) AS 'Runners signed up'
FROM runners
GROUP BY 1,2 ;


-- B2.What was the average time in minutes it took for each runner to 
--    arrive at the Pizza Runner HQ to pickup the order?

SELECT  rot.runner_id AS 'Runner ID',
		ROUND(AVG(TIMESTAMPDIFF(MINUTE, cot.order_time, rot.pickup_time)) ,2) AS 'Avg pickup time in Minutes'
FROM customer_orders_temp AS cot 
INNER JOIN runner_orders_temp AS rot ON cot.order_id=rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY rot.runner_id;

-- B3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH cte_pizza AS (
	SELECT
		cot.order_id,
		COUNT(cot.order_id) AS Count_of_Pizza,
        cot.order_time,
        rot.pickup_time,
        TIMEDIFF(rot.pickup_time, cot.order_time) AS preperation_time
	FROM runner_orders_temp AS rot
    JOIN customer_orders_temp AS cot ON cot.order_id = rot.order_id
	WHERE rot.cancellation IS NULL
    GROUP BY cot.order_id)
SELECT
	Count_of_Pizza,
    CONCAT(minute(preperation_time),' Min') AS 'Avg Preperation Time'
FROM cte_pizza
GROUP BY Count_of_Pizza;

-- B4. What was the average distance travelled for each customer?

SELECT  cot.customer_id ,
		CONCAT(ROUND(AVG(rot.distance),2),' Km') AS 'Average Distance'
FROM customer_orders_temp AS cot 
INNER JOIN runner_orders_temp AS rot ON cot.order_id=rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY cot.customer_id;

-- B5. What was the difference between the longest and shortest delivery times for all orders?

SELECT CONCAT(MAX(duration)-MIN(duration),' Min') AS Delivery_time_difference
FROM runner_orders_temp
WHERE cancellation IS NULL;

-- B6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT
	runner_id,
    distance AS distance_in_km,
    ROUND(duration/60,2) AS duration_in_hour,
    ROUND(distance*60/duration, 2) AS average_speed_in_kmph
FROM runner_orders_temp
WHERE cancellation IS NULL
ORDER BY runner_id;


-- B7. What is the successful delivery percentage for each runner?

SELECT 
	runner_id,
    CONCAT(ROUND(COUNT(pickup_time)/COUNT(*)*100),' %') AS Successful_delivary_percentage
FROM runner_orders_temp
GROUP BY runner_id
ORDER BY runner_id;


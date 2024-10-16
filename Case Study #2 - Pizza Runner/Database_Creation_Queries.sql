-- #8weekslchallange Case study #2 - Pizza Runner
-- Solution by Vaibhav Chavan on youtube @iThinkData
-- Subscribe to @ iThinkData For more SQL Challange Series

-- Let's get Started.....

DROP DATABASE IF EXISTS pizza_runner;

CREATE database pizza_runner;

USE pizza_runner;

DROP TABLE IF EXISTS runners;

CREATE TABLE runners (
  runner_id INTEGER PRIMARY KEY,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;

CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(10),
  extras VARCHAR(10),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;

CREATE TABLE runner_orders (
  order_id INTEGER PRIMARY KEY,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS pizza_names;

CREATE TABLE pizza_names (
  pizza_id INTEGER PRIMARY KEY,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  ('1', 'Meatlovers'),
  ('2', 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER PRIMARY KEY,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  ('1', '1, 2, 3, 4, 5, 6, 8, 10'),
  ('2', '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
 -- Let's create relationship between tables.
 
ALTER TABLE runner_orders                                
ADD FOREIGN KEY (runner_id) REFERENCES runners(runner_id);   
	
ALTER TABLE customer_orders
ADD FOREIGN KEY (order_id) REFERENCES runner_orders(order_id);

ALTER TABLE customer_orders
ADD FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id);

ALTER TABLE customer_orders
ADD FOREIGN KEY (pizza_id) REFERENCES pizza_recipes(pizza_id);
  
-- Since there is some mismatch in some data and hence let's do data cleaning 
-- firstly will clear customer_orders table

DROP TABLE IF EXISTS customer_orders_temp;

CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id,
       customer_id,
       pizza_id,
       CASE
           WHEN exclusions = '' THEN NULL
           WHEN exclusions = 'null' THEN NULL
           ELSE exclusions
       END AS exclusions,
       CASE
           WHEN extras = '' THEN NULL
           WHEN extras = 'null' THEN NULL
           ELSE extras
       END AS extras,
       CAST(order_time AS DATETIME)  AS order_time
FROM customer_orders;

-- now let's do data cleaning in runner_orders table

DROP TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp AS
	SELECT order_id,
		   runner_id,
		   CASE
			   WHEN pickup_time LIKE 'null' OR pickup_time IS NULL THEN NULL
			   ELSE CAST(STR_TO_DATE(pickup_time, '%Y-%m-%d %H:%i:%s') AS DATETIME )
		   END AS pickup_time,
		   CASE
			   WHEN distance LIKE 'null' THEN NULL	
			   ELSE CAST(regexp_replace(distance, '[a-z]+', '') AS FLOAT)
		   END AS distance,
		   CASE
			   WHEN duration LIKE 'null' THEN NULL
			   ELSE CAST(regexp_replace(duration, '[a-z]+', '') AS FLOAT)
		   END AS duration,
		   CASE
			   WHEN cancellation LIKE '' THEN NULL
			   WHEN cancellation LIKE 'null' THEN NULL
			   ELSE cancellation
		   END AS cancellation
	FROM runner_orders;


-- now our data is ready for analysis..

 
-- #8weekslchallange Case study #1 - Danny's Diner
-- Solution by Vaibhav Chavan on youtube @iThinkData
-- Subscribe to @ iThinkData For more SQL Challange Series

-- CASE STUDY Questions and Answers

-- Let's get Started.....

-- Q1. What is the total amount each customer spent at the restaurant?

SELECT 
	sales.customer_id,
    SUM(menu.price) AS 'Total Spending in $'
FROM sales
INNER JOIN menu ON sales.product_id=menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;


-- Q2. How many days has each customer visited the restaurant?

SELECT
	customer_id,
    COUNT(DISTINCT(order_date)) AS days_visited
FROM sales
GROUP BY customer_id;


-- Q3. What was the first item from the menu purchased by each customer?

SELECT 
		customer_id,
        product_name AS first_purchased_product
FROM
    (SELECT 
		sales.customer_id,
		menu.product_name,
		DENSE_RANK() OVER( PARTITION BY sales.customer_id ORDER BY sales.order_date) As rnk
	FROM sales
	INNER JOIN menu ON sales.product_id=menu.product_id) AS sales_rank
WHERE rnk = 1
GROUP BY customer_id,product_name;


-- Q4. What is the most purchased item on the menu and 
--     how many times was it purchased by all customers?

-- Part 1

SELECT 
	menu.product_name AS 'Most purchased Product',
    COUNT(sales.product_id) AS 'Purchase Count'
FROM sales 
INNER JOIN menu 
	ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY COUNT(sales.product_id) DESC
LIMIT 1;                                           -- this gives the most purchased item on menu


-- Part 2

SELECT 
	sales.customer_id,
    COUNT(sales.product_id) AS purchase_count
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
WHERE sales.product_id = (SELECT product_id FROM sales
							GROUP BY product_id
                            ORdER BY count(product_id)
                            DESC LIMIT 1)
GROUP BY sales.customer_id
ORDER BY purchase_count DESC;                    -- this gives the list of customers who have purchased highest purchased item


-- Q5. Which item was the most popular for each customer?


WITH cte_popular_products as ( 
	SELECT 
		sales.customer_id,
		menu.product_name,
		COUNT(*) as purchase_count,
		DENSE_RANK() OVER( PARTITION BY sales.customer_id 
						ORDER BY COUNT(*) DESC) AS rnk
	FROM sales
	INNER JOIN menu ON sales.product_id = menu.product_id
	GROUP BY sales.customer_id, menu.product_name )
SELECT 
	customer_id,
    product_name,
    purchase_count
FROM cte_popular_products
WHERE rnk=1;


-- Q6. Which item was purchased first by the customer after they became a member?

WITH cte_after_membership AS (
  SELECT
    members.customer_id, 
    sales.product_id,
    DENSE_RANK() OVER (
      PARTITION BY members.customer_id
      ORDER BY sales.order_date) AS densrank
  FROM members
  INNER JOIN sales
    ON members.customer_id = sales.customer_id
    AND sales.order_date > members.join_date
)
SELECT 
  cte_after_membership.customer_id, 
  menu.product_name 
FROM cte_after_membership
INNER JOIN menu
  ON cte_after_membership.product_id = menu.product_id
WHERE densrank = 1
ORDER BY cte_after_membership.customer_id ASC;


-- Q7. Which item was purchased just before the customer became a member?


WITH cte_after_membership AS (
  SELECT
    members.customer_id, 
    sales.product_id,
    DENSE_RANK() OVER (
      PARTITION BY members.customer_id
      ORDER BY sales.order_date) AS densrank
  FROM members
  INNER JOIN sales
    ON members.customer_id = sales.customer_id
    AND sales.order_date < members.join_date
)
SELECT 
  cte_after_membership.customer_id, 
  menu.product_name 
FROM cte_after_membership
INNER JOIN menu
  ON cte_after_membership.product_id = menu.product_id
WHERE densrank = 1
ORDER BY cte_after_membership.customer_id ASC;


-- Q8. What is the total items and amount spent for each member before they became a member?

SELECT
	sales.customer_id,
    COUNT(sales.product_id) AS total_items,
    SUM(menu.price) AS total_amt_spent
FROM sales
JOIN members ON sales.customer_id = members.customer_id
JOIN menu ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
group by sales.customer_id
ORDER BY sales.customer_id;


-- Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
--     how many points would each customer have?

SELECT 
    sales.customer_id,
    SUM(menu.price) AS total_price,
    SUM(CASE
        WHEN menu.product_name = 'sushi' THEN menu.price * 20
        ELSE menu.price * 10
    END) AS total_points
FROM sales
	JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;


-- Q10. In the first week after a customer joins the program (including their join date)
--     they earn 2x points on all items, not just sushi - 
--     how many points do customer A and B have at the end of January?


SELECT 
	sales.customer_id,
    SUM(menu.price) AS total_price,
    SUM(CASE 
			WHEN sales.order_date BETWEEN members.join_date AND DATE_ADD(members.join_date, INTERVAL 6 DAY) THEN menu.price*20
			ELSE 
				CASE WHEN menu.product_name = 'sushi' THEN menu.price * 20
				ELSE menu.price * 10
				END
			END) AS points
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE sales.order_date <= '2021-01-31'
AND sales.customer_id IN ('A','B')
GROUP BY sales.customer_id
ORDER BY sales.customer_id;


-- ------------------------------------------------------------------------------------------------------------------------------------
 /*
Bonus Questions

Q1. Join All The Things

Recreate the table with: customer_id, order_date, product_name, price, member_status (Y/N) 

 */ 
 
SELECT 
  sales.customer_id, 
  sales.order_date,  
  menu.product_name, 
  menu.price,
  CASE
    WHEN sales.order_date >= members.join_date THEN 'Y'
    ELSE 'N' END AS member_status
FROM sales
LEFT JOIN members
  ON sales.customer_id = members.customer_id
INNER JOIN menu
  ON sales.product_id = menu.product_id
ORDER BY members.customer_id;
 
 

 /*   
Q2. Rank All The Things

Danny also requires further information about the ranking of customer products, 
but he purposely does not need the ranking for non-member purchases so he expects null ranking values 
for the records when customers are not yet part of the loyalty program.    
*/  
 
  WITH cte_all_joined AS (
    SELECT
        s.customer_id,
        s.order_date AS order_date,
        m.product_name,
        m.price,
        CASE
            WHEN s.customer_id IS NOT NULL
                 AND s.order_date >= mm.join_date THEN 'Y'
            ELSE 'N'
        END AS member_status
    FROM sales s
    INNER JOIN menu m ON s.product_id = m.product_id
    LEFT JOIN members mm ON s.customer_id = mm.customer_id
)
SELECT
    *,
    CASE
        WHEN member_status = 'Y' THEN
            DENSE_RANK() OVER (
				PARTITION BY customer_id 
                ORDER BY order_date)
        ELSE
            NULL
    END AS ranking
FROM
    cte_all_joined
ORDER BY
    customer_id,
    order_date,
    product_name;
 
 
 
  /*  
   
For more such SQL Challenges and Data Analysis related stuff, 
Subscribe my youtube channel www.youtube.com/@iThinkData

Github: www.github.com/vaibhavchavan20
LinkedIn: www.linkedin.com/in/vaibhav-chavan
WhatsApp: www.bit.ly/WhatsAppiThinkData 
   
*/
 
 
-------------------------------------------------------------------------------------------------------------------------------------------
--PART 3: Customer Analysis
-------------------------------------------------------------------------------------------------------------------------------------------
--Using the database
USE Brazilian_Ecommerce
GO

-- 1. What's the Repurchase rate?

/*
Repurchase Rate Formula:
(Number of customers with ≥ 2 purchases) /
(Total number of purchasing customers)
*/

WITH customer_order_counts AS (
	SELECT
	cus.customer_unique_id AS customer_id,
  COUNT(DISTINCT order_id) AS num_orders
  FROM olist_orders_dataset  o
  JOIN olist_customers_dataset cus ON o.customer_id = cus.customer_id
  WHERE order_status = 'delivered' -- opcional, solo compras completadas
  GROUP BY cus.customer_unique_id
	)
 SELECT
  CAST(SUM(CASE WHEN num_orders >= 2 THEN 1 ELSE 0 END) AS FLOAT)
    / COUNT(*) AS repurchase_rate
	FROM customer_order_counts;

-- In this dataset, `customer_id` does not uniquely identify a customer.
-- Therefore, `customer_unique_id` is used to calculate the repurchase rate.

/*
Only about 3% of Olist customers place a second order or more.
This indicates low customer loyalty, which is expected since Olist
operates as a marketplace offering products from many different brands.

The low repurchase rate reflects typical marketplace behavior, where
customers are more likely to switch sellers rather than remain loyal
to a single platform or brand.
*/


-- 2. New vs. returning customers: total spend by each group

WITH type_customers AS (
SELECT 
     YEAR(o.order_approved_at) AS year,
	cus.customer_unique_id AS customer_id,
  COUNT(DISTINCT o.order_id) AS num_orders,
  CASE WHEN COUNT(DISTINCT o.order_id) > 1  THEN 'returning_customer' ELSE 'new_customer' END AS type_customer,
 ROUND(SUM(orders.freight_value), 2) AS freight_value_total
  FROM olist_orders_dataset  o
  JOIN olist_customers_dataset cus ON o.customer_id = cus.customer_id
  JOIN olist_order_items_dataset orders  ON orders.order_id = o.order_id
  WHERE order_status = 'delivered' -- only for delivered orders
  GROUP BY YEAR(o.order_approved_at),cus.customer_unique_id
  )

  SELECT 
  year,
  type_customer,
  COUNT (DISTINCT customer_id) AS num_customers,
  ROUND(SUM(freight_value_total),2) AS total_spent
  FROM type_customers
  GROUP BY year,type_customer
  ORDER BY year, type_customer;


  -- 3. Cities with the highest number of customer orders


WITH orders_city AS (
    SELECT
        YEAR(rev.review_creation_date) AS year_review,
        cus.customer_city AS city,
        COUNT(DISTINCT ordat.order_id) AS num_orders
    FROM olist_customers_dataset cus
    JOIN olist_orders_dataset ordat ON cus.customer_id = ordat.customer_id
    JOIN olist_order_items_dataset oi ON oi.order_id = ordat.order_id
    JOIN olist_order_reviews_dataset rev 
        ON rev.order_id = ordat.order_id
    WHERE rev.review_creation_date IS NOT NULL
    GROUP BY   
        YEAR(rev.review_creation_date),
        cus.customer_city
),
ranks AS (
    SELECT
        year_review,
        city,
        num_orders,
        ROW_NUMBER() OVER (PARTITION BY year_review ORDER BY num_orders DESC) AS city_rank_orders
    FROM orders_city
)
SELECT
    year_review,
    city,
    num_orders
FROM ranks
WHERE city_rank_orders <= 5
ORDER BY year_review, city_rank_orders;
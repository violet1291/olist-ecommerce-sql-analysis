
-------------------------------------------------------------------------------------------------------------------------------------------
--PART 2: Sales Analysis
-------------------------------------------------------------------------------------------------------------------------------------------
--Using the database
USE Brazilian_Ecommerce
GO

-- 1. What's the average ticket?

		--Total value by year 

		SELECT YEAR(ordat.order_approved_at) AS order_year,
		ROUND(SUM(orders.price),2) AS price_total
		FROM olist_order_items_dataset orders
		JOIN olist_orders_dataset ordat ON orders.order_id = ordat.order_id
		WHERE YEAR(ordat.order_approved_at)  IS NOT NULL
		GROUP BY YEAR(ordat.order_approved_at)
		ORDER BY YEAR(ordat.order_approved_at)

		--Total value by year and month
				SELECT YEAR(ordat.order_approved_at) AS order_year,
		MONTH(ordat.order_approved_at) AS order_MONTH,
		ROUND(SUM(orders.price),2) AS price_total
		FROM olist_order_items_dataset orders
		JOIN olist_orders_dataset ordat ON orders.order_id = ordat.order_id
		WHERE YEAR(ordat.order_approved_at)  IS NOT NULL
		GROUP BY YEAR(ordat.order_approved_at),MONTH(ordat.order_approved_at)
		ORDER BY YEAR(ordat.order_approved_at), MONTH(ordat.order_approved_at)

		--Average ticket by year and product category name

		SELECT YEAR(ordat.order_approved_at) AS order_year,
		trans.column2 AS product_category_name,
		ROUND(SUM(orders.price),2) AS total_value,
		ROUND(AVG(orders.freight_value),2) AS freight_value_avg
		FROM olist_order_items_dataset orders
		JOIN olist_orders_dataset ordat ON orders.order_id = ordat.order_id
		JOIN olist_products_dataset products ON  orders.product_id = products.product_id
		JOIN product_category_name_translation trans ON trans.column1 = products.product_category_name
		WHERE YEAR(ordat.order_approved_at)  IS NOT NULL
		GROUP BY YEAR(ordat.order_approved_at), trans.column2
		ORDER BY YEAR(ordat.order_approved_at), trans.column2, ROUND(SUM(orders.price),2)   DESC


-- 2. Year-over-Year (YoY) comparison by month for orders and freight value

WITH cif_month AS (
    SELECT
        YEAR(ordat.order_approved_at) AS order_year,
        MONTH(ordat.order_approved_at) AS order_month_num,  -- for ordering months
        ROUND(SUM(orders.price), 2) AS total_value
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat
        ON orders.order_id = ordat.order_id
		WHERE YEAR(ordat.order_approved_at)  IS NOT NULL
    GROUP BY
        YEAR(ordat.order_approved_at),
        MONTH(ordat.order_approved_at)
)
SELECT
    c.order_year,
    DATENAME(MONTH, DATEFROMPARTS(c.order_year, c.order_month_num, 1)) AS order_month_name,
    c.total_value,
	p.total_value AS freight_value_last_year
FROM cif_month c
LEFT JOIN cif_month p ON c.order_month_num = p.order_month_num
   AND c.order_year = p.order_year + 1
ORDER BY c.order_year, c.order_month_num;

--Notice there is no data from November 2016


--3. Top-selling products by total value (overall)

WITH top_selling_products AS (
   SELECT 
        trans.column2 AS product_category_name,
        products.product_id,
        ROUND(AVG(orders.price), 2) AS price_avg,
	ROUND(SUM(orders.price), 2) AS total_value, 
		ROW_NUMBER() OVER(ORDER BY SUM(orders.freight_value) DESC) AS row_number
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat 
        ON orders.order_id = ordat.order_id
    JOIN olist_products_dataset products 
        ON orders.product_id = products.product_id
    JOIN product_category_name_translation trans 
        ON trans.column1 = products.product_category_name
	WHERE ordat.order_approved_at IS NOT NULL
    GROUP BY 
        products.product_id,
        trans.column2)
	SELECT 
	product_category_name,
	product_id,
	total_value,
	price_avg
	FROM top_selling_products
	WHERE row_number <= 5;


--4. Top 5 highest-revenue products per year
		
	WITH sales_by_product AS (
    SELECT 
        YEAR(ordat.order_approved_at) AS order_year,
        trans.column2 AS product_category_name,
        products.product_id,
        ROUND(AVG(orders.price), 2) AS price_avg,
		ROUND(SUM(orders.freight_value), 2) AS total_value  
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat 
        ON orders.order_id = ordat.order_id
    JOIN olist_products_dataset products 
        ON orders.product_id = products.product_id
    JOIN product_category_name_translation trans 
        ON trans.column1 = products.product_category_name
		WHERE ordat.order_approved_at IS NOT NULL
    GROUP BY 
        YEAR(ordat.order_approved_at),
        products.product_id,
        trans.column2
)
SELECT *
FROM (
    SELECT
        order_year,
        product_category_name,
		product_id,
        total_value,
		price_avg,
        ROW_NUMBER() OVER (PARTITION BY order_year ORDER BY total_value DESC) AS product_rank
    FROM sales_by_product
) ranked
WHERE product_rank <= 5
ORDER BY order_year, product_rank;


-- 5. Create product categories based on sales
  
  WITH sales AS (
    SELECT 
        YEAR(ordat.order_approved_at) AS order_year,
        trans.column2 AS product_category_name,
        products.product_id,
        ROUND(AVG(orders.price), 2) AS price_avg,
        ROUND(SUM(orders.price), 2) AS total_value
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat 
        ON orders.order_id = ordat.order_id
    JOIN olist_products_dataset products 
        ON orders.product_id = products.product_id
    JOIN product_category_name_translation trans 
        ON trans.column1 = products.product_category_name
		WHERE ordat.order_approved_at IS NOT NULL
    GROUP BY 
        YEAR(ordat.order_approved_at),
        products.product_id,
        trans.column2
)
SELECT *,
    CASE 
        WHEN total_value BETWEEN 0 AND 15 THEN 'low_sales'
        WHEN total_value BETWEEN 16 AND 50 THEN 'medium_sales'
        ELSE 'high_sales'
    END AS category_sales
FROM sales;




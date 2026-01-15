
-------------------------------------------------------------------------------------------------------------------------------------------
--PART 2: Sales Analysis
-------------------------------------------------------------------------------------------------------------------------------------------
--Using the database
USE Brazilian_Ecommerce
GO

-- 1. What's the average ticket?

		--Total freight value by year 

		SELECT YEAR(ordat.order_approved_at) AS order_year,
		ROUND(SUM(orders.freight_value),2) AS freight_value_total
		FROM olist_order_items_dataset orders
		JOIN olist_orders_dataset ordat ON orders.order_id = ordat.order_id
		WHERE YEAR(ordat.order_approved_at)  IS NOT NULL
		GROUP BY YEAR(ordat.order_approved_at)
		ORDER BY YEAR(ordat.order_approved_at)

		--Total freight value by year and month
				SELECT YEAR(ordat.order_approved_at) AS order_year,
		MONTH(ordat.order_approved_at) AS order_MONTH,
		ROUND(SUM(orders.freight_value),2) AS freight_value_total
		FROM olist_order_items_dataset orders
		JOIN olist_orders_dataset ordat ON orders.order_id = ordat.order_id
		WHERE YEAR(ordat.order_approved_at)  IS NOT NULL
		GROUP BY YEAR(ordat.order_approved_at),MONTH(ordat.order_approved_at)
		ORDER BY YEAR(ordat.order_approved_at), MONTH(ordat.order_approved_at)

				--Average ticket by year and product category name

		SELECT YEAR(ordat.order_approved_at) AS order_year,
		trans.column2 AS product_category_name,
		ROUND(AVG(orders.price),2) AS avg_price
		FROM olist_order_items_dataset orders
		JOIN olist_orders_dataset ordat ON orders.order_id = ordat.order_id
		JOIN olist_products_dataset products ON  orders.product_id = products.product_id
		JOIN product_category_name_translation trans ON trans.column1 = products.product_category_name
		WHERE YEAR(ordat.order_approved_at)  IS NOT NULL
		GROUP BY YEAR(ordat.order_approved_at), trans.column2
		ORDER BY YEAR(ordat.order_approved_at), trans.column2

		
-- 2. What's the Monthly revenue growth (MoM)?

WITH cif_month AS (
    SELECT
        YEAR(ordat.order_approved_at) AS order_year,
        MONTH(ordat.order_approved_at) AS order_month_num,  -- for ordering months
        ROUND(SUM(orders.freight_value), 2) AS freight_value_total
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat
        ON orders.order_id = ordat.order_id
    GROUP BY
        YEAR(ordat.order_approved_at),
        MONTH(ordat.order_approved_at)
)
SELECT
    order_year,
    DATENAME(MONTH, DATEFROMPARTS(order_year, order_month_num, 1)) AS order_month_name,
    freight_value_total
FROM cif_month
ORDER BY order_year, order_month_num;

-- 3. Year-over-Year (YoY) comparison by month for orders and freight value

WITH cif_month AS (
    SELECT
        YEAR(ordat.order_approved_at) AS order_year,
        MONTH(ordat.order_approved_at) AS order_month_num,  -- for ordering months
        ROUND(SUM(orders.freight_value), 2) AS freight_value_total
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat
        ON orders.order_id = ordat.order_id
    GROUP BY
        YEAR(ordat.order_approved_at),
        MONTH(ordat.order_approved_at)
)
SELECT
    c.order_year,
    DATENAME(MONTH, DATEFROMPARTS(c.order_year, c.order_month_num, 1)) AS order_month_name,
    c.freight_value_total,
	p.freight_value_total AS freight_value_last_year
FROM cif_month c
LEFT JOIN cif_month p ON c.order_month_num = p.order_month_num
   AND c.order_year = p.order_year + 1
ORDER BY c.order_year, c.order_month_num;


--- 4. Month-over-Month (MoM) comparison

WITH cif_MoM AS (
    SELECT
        YEAR(ordat.order_approved_at) AS order_year,
        MONTH(ordat.order_approved_at) AS order_month_num,  -- for ordering months
        ROUND(SUM(orders.freight_value), 2) AS freight_value_total
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat
        ON orders.order_id = ordat.order_id
    GROUP BY
        YEAR(ordat.order_approved_at),
        MONTH(ordat.order_approved_at)
)
SELECT
    c.order_year,
    DATENAME(MONTH, DATEFROMPARTS(c.order_year, c.order_month_num, 1)) AS order_month_name,
    c.freight_value_total,
	p.freight_value_total AS freight_value_last_month
FROM cif_MoM c
LEFT JOIN cif_MoM p 
ON (
        -- same year, last month
        c.order_year = p.order_year
        AND c.order_month_num = p.order_month_num + 1
    )
    OR (
        -- for jan, dec of last year
        c.order_month_num = 1
        AND p.order_month_num = 12
        AND c.order_year = p.order_year + 1
    )
ORDER BY c.order_year, c.order_month_num;

-- There is no data for november in the dataset, that's why freight_value_last_month is NULL for december 2016


--5. Top-selling products by total revenue (overall)

WITH top_selling_products AS (
   SELECT 
        trans.column2 AS product_category_name,
        products.product_id,
        ROUND(AVG(orders.price), 2) AS price_avg,
	ROUND(SUM(orders.freight_value), 2) AS total_sales, 
		ROW_NUMBER() OVER(ORDER BY SUM(orders.freight_value) DESC) AS row_number
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat 
        ON orders.order_id = ordat.order_id
    JOIN olist_products_dataset products 
        ON orders.product_id = products.product_id
    JOIN product_category_name_translation trans 
        ON trans.column1 = products.product_category_name
    GROUP BY 
        products.product_id,
        trans.column2)
	SELECT 
	product_category_name,
	product_id,
	total_sales,
	price_avg
	FROM top_selling_products
	WHERE row_number <= 5;


--6. Top 5 highest-revenue products per year
		
	WITH sales_by_product AS (
    SELECT 
        YEAR(ordat.order_approved_at) AS order_year,
        trans.column2 AS product_category_name,
        products.product_id,
        ROUND(AVG(orders.price), 2) AS price_avg,
		ROUND(SUM(orders.freight_value), 2) AS total_sales  --Also called CIF
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat 
        ON orders.order_id = ordat.order_id
    JOIN olist_products_dataset products 
        ON orders.product_id = products.product_id
    JOIN product_category_name_translation trans 
        ON trans.column1 = products.product_category_name
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
        total_sales,
		price_avg,
        ROW_NUMBER() OVER (PARTITION BY order_year ORDER BY total_sales DESC) AS product_rank
    FROM sales_by_product
) ranked
WHERE product_rank <= 5
ORDER BY order_year, product_rank;

/*
Some dates are missing because the `order_approved_at` column is used as the reference date.
Orders that had not yet been approved at the time of data extraction have a NULL value
in this field.
*/

-- 7. Create product categories based on sales

  
  WITH sales AS (
    SELECT 
        YEAR(ordat.order_approved_at) AS order_year,
        trans.column2 AS product_category_name,
        products.product_id,
        ROUND(AVG(orders.price), 2) AS price_avg,
        ROUND(SUM(orders.freight_value), 2) AS total_sales
    FROM olist_order_items_dataset orders
    JOIN olist_orders_dataset ordat 
        ON orders.order_id = ordat.order_id
    JOIN olist_products_dataset products 
        ON orders.product_id = products.product_id
    JOIN product_category_name_translation trans 
        ON trans.column1 = products.product_category_name
    GROUP BY 
        YEAR(ordat.order_approved_at),
        products.product_id,
        trans.column2
)
SELECT *,
    CASE 
        WHEN total_sales BETWEEN 0 AND 15 THEN 'low_sales'
        WHEN total_sales BETWEEN 16 AND 50 THEN 'medium_sales'
        ELSE 'high_sales'
    END AS category_sales
FROM sales;




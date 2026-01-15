-------------------------------------------------------------------------------------------------------------------------------------------
--PART 4: Customer satisfaction
-------------------------------------------------------------------------------------------------------------------------------------------
--Using the database
USE Brazilian_Ecommerce
GO



--1. Top 10 products with worst ratings

   WITH avg_rating_sellers AS (
    SELECT
        YEAR(rev.review_creation_date) AS year_review,
        pro.product_category_name AS category_name,
        pro.product_id,
        AVG(rev.review_score) AS avg_review_score
    FROM olist_products_dataset pro 
    JOIN olist_order_items_dataset orders 
        ON orders.product_id = pro.product_id
    JOIN olist_order_reviews_dataset rev 
        ON rev.order_id = orders.order_id
    GROUP BY   
        YEAR(rev.review_creation_date),
       pro.product_category_name,
         pro.product_id
		 ),

worst_ranks AS (
    SELECT
        year_review,
        category_name,
        product_id,
        avg_review_score,
        ROW_NUMBER() OVER (
            PARTITION BY year_review 
            ORDER BY avg_review_score ASC
        ) AS product_rank
    FROM avg_rating_sellers
)
SELECT
    year_review,
    category_name,
    product_id,
    avg_review_score
FROM worst_ranks
WHERE product_rank <= 10
ORDER BY year_review, category_name;





-- 2. Top 5 lowest-rated sellers by city

  WITH avg_rating_sellers AS (
    SELECT
        YEAR(rev.review_creation_date) AS year_review,
        sellers.seller_city AS city,
        sellers.seller_id,
        AVG(rev.review_score) AS avg_review_score
    FROM olist_sellers_dataset sellers
    JOIN olist_order_items_dataset orders 
        ON orders.seller_id = sellers.seller_id
    JOIN olist_order_reviews_dataset rev 
        ON rev.order_id = orders.order_id
    GROUP BY   
        YEAR(rev.review_creation_date),
        sellers.seller_city,
        sellers.seller_id
),
worst_ranks AS (
    SELECT
        year_review,
        city,
        seller_id,
        avg_review_score,
        ROW_NUMBER() OVER (
            PARTITION BY year_review 
            ORDER BY avg_review_score ASC
        ) AS seller_rank
    FROM avg_rating_sellers
)
SELECT
    year_review,
    city,
    seller_id,
    avg_review_score
FROM worst_ranks
WHERE seller_rank <= 5
ORDER BY year_review, city;



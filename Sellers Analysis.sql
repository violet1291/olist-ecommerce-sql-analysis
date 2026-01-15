-------------------------------------------------------------------------------------------------------------------------------------------
--PART 5: Sellers Analysis
-------------------------------------------------------------------------------------------------------------------------------------------
--Using the database
USE Brazilian_Ecommerce
GO

-- 1. Frequency of orders by seller and year

  SELECT
  YEAR(rev.review_creation_date) AS year_review,
  sellers.seller_city AS city,
  sellers.seller_id,
 COUNT(DISTINCT orders.order_id) AS orders
  FROM olist_sellers_dataset sellers
  JOIN olist_order_items_dataset orders ON orders.seller_id = sellers.seller_id
  LEFT JOIN olist_order_reviews_dataset rev ON rev.order_id = orders.order_id
  WHERE YEAR(rev.review_creation_date) IS NOT NULL   --Null values of year are not taked into account for this query
  GROUP BY   YEAR(rev.review_creation_date), sellers.seller_city, sellers.seller_id
  ORDER BY YEAR(rev.review_creation_date), COUNT(DISTINCT orders.order_id) DESC;



  --2.Ratings by seller

  SELECT
  YEAR(rev.review_creation_date) AS year_review,
  sellers.seller_city AS city,
  sellers.seller_id,
  AVG(rev.review_score) AS avg_review_score
  FROM olist_sellers_dataset sellers
  JOIN olist_order_items_dataset orders ON orders.seller_id = sellers.seller_id
  LEFT JOIN olist_order_reviews_dataset rev ON rev.order_id = orders.order_id
  WHERE YEAR(rev.review_creation_date) IS NOT NULL   --Null values of year are not taked into account for this query
  GROUP BY   YEAR(rev.review_creation_date), sellers.seller_city, sellers.seller_id
  ORDER BY YEAR(rev.review_creation_date), AVG(rev.review_score) DESC;



-- 3.Top sellers by rating and city

 WITH avg_rating_sellers AS (
   SELECT
  YEAR(rev.review_creation_date) AS year_review,
  sellers.seller_city AS city,
  sellers.seller_id AS seller_id,
  AVG(rev.review_score) AS avg_review_score
  FROM olist_sellers_dataset sellers
  JOIN olist_order_items_dataset orders ON orders.seller_id = sellers.seller_id
  LEFT JOIN olist_order_reviews_dataset rev ON rev.order_id = orders.order_id
  WHERE YEAR(rev.review_creation_date) IS NOT NULL
  GROUP BY   YEAR(rev.review_creation_date), sellers.seller_city, sellers.seller_id
)
SELECT *
FROM (
    SELECT
        year_review,
        city,
		seller_id,
        avg_review_score,
        ROW_NUMBER() OVER (PARTITION BY year_review ORDER BY avg_review_score DESC) AS seller_rank
    FROM avg_rating_sellers
) ranked
WHERE seller_rank <= 5
ORDER BY year_review,city, seller_rank;

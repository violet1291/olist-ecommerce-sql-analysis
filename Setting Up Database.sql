
-------------------------------------------------------------------------------------------------------------------------------------------
--PART 1: Creating and Setting Up the database
-------------------------------------------------------------------------------------------------------------------------------------------

--Creating a database for the project
CREATE DATABASE Brazilian_Ecommerce

USE Brazilian_Ecommerce
GO

--Now, insert the tables in the dataset using Task > Import Flat File...
--Once all tables are in the database it's time to create the connections between tables:

--Connection between: olist_orders_dataset and olist_order_items_dataset

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT FK_Order_Items
FOREIGN KEY (order_id)
REFERENCES olist_orders_dataset(order_id);

--Connection between: olist_orders_dataset and olist_customer_dataset

ALTER TABLE olist_orders_dataset
ADD CONSTRAINT FK_customer_order
FOREIGN KEY (customer_id)
REFERENCES olist_customers_dataset(customer_id);

--Connection between: olist_orders_dataset and olist_order_reviews_dataset

ALTER TABLE olist_order_reviews_dataset
ADD CONSTRAINT FK_order_and_review
FOREIGN KEY (order_id)
REFERENCES olist_orders_dataset(order_id)

--Connection between: olist_orders_dataset and olist_order_payments_dataset

ALTER TABLE olist_order_payments_dataset
ADD CONSTRAINT FK_payments_orders
FOREIGN KEY (order_id)
REFERENCES olist_orders_dataset(order_id)

--Connection between: olist_order_items_dataset and olist_products_dataset

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT FR_product_items_order
FOREIGN KEY (product_id)
REFERENCES olist_products_dataset(product_id)

--Connection between: olist_order_items_dataset and olist_sellers_dataset

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT FK_order_item_sellers
FOREIGN KEY (seller_id)
REFERENCES olist_sellers_dataset (seller_id)

--Connection between: olist_sellers_dataset and olist_geolocation_dataset

ALTER TABLE olist_geolocation_dataset
ADD CONSTRAINT FK_zipcode_sellets
FOREIGN KEY (geolocation_zip_code_prefix)
REFERENCES olist_sellers_dataset(seller_zip_code_prefix)


--Adding Primary Key to table product_category_name_translation
ALTER TABLE product_category_name_translation
ADD CONSTRAINT PK_translations
PRIMARY KEY (column1)

--Updating table to be able to make the connection between the translations and products
UPDATE olist_products_dataset
SET product_category_name = 'NE'
WHERE product_category_name IS NULL

--Inserting a Not Specified option in the cathegories for NULL Values
INSERT INTO product_category_name_translation
VALUES ('NE', 'Not Specified') 

--Deleting cathegory that does not match
DELETE FROM product_category_name_translation
WHERE column1 = 'product_category_name'

--Adding two other rows for categories not found un the translations table
INSERT INTO product_category_name_translation
VALUES ('portateis_cozinha_e_preparadores_de_alimentos
', 'portable_kitchen_and_food_preparators
'),
('pc_gamer'
,' pc_gamer'
)

--Finding categories that are not in the translation table:
SELECT DISTINCT p.product_category_name
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.column1
WHERE t.column1 IS NULL
  AND p.product_category_name IS NOT NULL;


--Inserting the last value that did not match
INSERT INTO product_category_name_translation
VALUES ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparators')


--Finally, adding the connections between the products table and the translations.
ALTER TABLE olist_products_dataset
ADD CONSTRAINT FK_translations_columns
FOREIGN KEY (product_category_name)
REFERENCES product_category_name_translation(column1)


----------------------------------------------------------------------------------------------------------------------------------
--Database is all set!
----------------------------------------------------------------------------------------------------------------------------------
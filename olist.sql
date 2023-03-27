-- Create the database that the csv files would be imported to
CREATE DATABASE olist
USE olist;

-- Data Preperation
--Task 1: Check for and remove any duplicate rows in the dataset to avoid skewing the analysis results.
--This query would show the values with duplicates
SELECT *, COUNT(*)
FROM customers
GROUP BY customer_unique_id, customer_id, customer_zip_code_prefix, customer_city, customer_state
HAVING COUNT(*) > 1;

SELECT *, COUNT(*)
FROM geolocation
GROUP BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state
HAVING COUNT(*) > 1;

SELECT *, COUNT(*) AS duplicate
FROM order_items
GROUP BY order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value
HAVING COUNT(*) > 1;

SELECT *, COUNT(*)
FROM order_payments
GROUP BY order_id, payment_sequential, payment_type, payment_installments, payment_value
HAVING COUNT(*) > 1;

SELECT *, COUNT(*)
FROM order_reviews
GROUP BY review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp
HAVING COUNT(*) > 1;

SELECT *, COUNT(*)
FROM orders
GROUP BY order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date
HAVING COUNT(*) > 1;

SELECT *, COUNT(*)
FROM product_category_name_translation
GROUP BY column1, column2
HAVING COUNT(*) > 1;

SELECT *, COUNT(*)
FROM products
GROUP BY product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm
HAVING COUNT(*) > 1;

SELECT *, COUNT(*)
FROM sellers
GROUP BY seller_id, seller_zip_code_prefix, seller_city, seller_state
HAVING COUNT(*) > 1;

-- Summary: Duplicate rows are in the geolocation table only.

-- Task 2: Remove duplicate rows in the geolocation table
-- This can be done using the DISTINCT function

WITH geolocation_c AS (
	SELECT DISTINCT *
	FROM geolocation
)

-- Task 3: Check for NULL values
SELECT *
FROM customers
WHERE customer_id IS NULL 
	OR customer_unique_id IS NULL 
	OR customer_zip_code_prefix IS NULL 
	OR customer_city IS NULL 
	OR customer_state IS NULL;

SELECT *
FROM geolocation_c
WHERE geolocation_city IS NULL 
	OR geolocation_zip_code_prefix IS NULL 
	OR geolocation_lat IS NULL 
	OR geolocation_lng IS NULL 
	OR geolocation_state IS NULL;

SELECT *
FROM order_items
WHERE order_item_id IS NULL 
	OR order_id IS NULL 
	OR product_id IS NULL 
	OR seller_id IS NULL 
	OR shipping_limit_date IS NULL 
	OR price IS NULL 
	OR freight_value IS NULL;

SELECT *
FROM order_payments
WHERE order_id IS NULL 
	OR payment_sequential IS NULL 
	OR payment_installments IS NULL 
	OR payment_type IS NULL 
	OR payment_value IS NULL;

SELECT *
FROM order_reviews
WHERE order_id IS NULL 
	OR review_answer_timestamp IS NULL 
	OR review_comment_message IS NULL 
	OR review_comment_title IS NULL 
	OR review_id IS NULL 
	OR review_creation_date IS NULL 
	OR review_score IS NULL;

SELECT *
FROM orders
WHERE order_id IS NULL 
	OR order_approved_at IS NULL 
	OR customer_id IS NULL 
	OR order_delivered_carrier_date IS NULL 
	OR order_delivered_customer_date IS NULL 
	OR order_estimated_delivery_date IS NULL 
	OR order_purchase_timestamp IS NULL
	OR order_status IS NULL;

SELECT *
FROM product_category_name_translation
WHERE column1 IS NULL 
	OR column2 IS NULL;

SELECT *
FROM products
WHERE product_id IS NULL 
	OR product_category_name IS NULL 
	OR product_description_lenght IS NULL
	OR product_height_cm IS NULL
	OR product_length_cm IS NULL
	OR product_name_lenght IS NULL
	OR product_photos_qty IS NULL
	OR product_weight_g IS NULL
	OR product_width_cm IS NULL;

SELECT *
FROM sellers
WHERE seller_id IS NULL 
	OR seller_zip_code_prefix IS NULL 
	OR seller_city IS NULL
	OR seller_state IS NULL;

-- Summary: There are NULL values in the order_reviews, orders, and products table.

-- Task 4: Handle columns with NULL values
UPDATE products
SET product_category_name = 'N/A'
WHERE product_category_name IS NULL;

UPDATE products
SET product_name_lenght = 0
WHERE product_name_lenght IS NULL;

UPDATE products
SET product_description_lenght = 0
WHERE product_description_lenght IS NULL;

UPDATE products
SET product_photos_qty = 0
WHERE product_photos_qty IS NULL;

UPDATE products
SET product_weight_g = 0
WHERE product_weight_g IS NULL;

UPDATE products
SET product_length_cm = 0
WHERE product_length_cm IS NULL;

UPDATE products
SET product_height_cm = 0
WHERE product_height_cm IS NULL;

UPDATE products
SET product_width_cm = 0
WHERE product_width_cm IS NULL;

UPDATE order_reviews
SET review_comment_title = 'N/A'
WHERE review_comment_title IS NULL;

UPDATE order_reviews
SET review_comment_message = 'N/A'
WHERE review_comment_message IS NULL;

-- To handle the NULL values in the respective columns, It is better to drop them as they are date columns.
-- Create a temporary table with the same schema as the orders table
SELECT *
INTO #temp_orders
FROM orders
WHERE 1 = 0;

---- Insert all rows from the orders table into the temporary table
INSERT INTO #temp_orders
SELECT *
FROM orders;

---- Select from the temporary table to verify the data before committing the deletion
SELECT *
FROM #temp_orders;

-- Delete rows from the orders table where order_delivered_customer_date is null
DELETE FROM orders
WHERE order_delivered_customer_date IS NULL
	  OR order_approved_at IS NULL
	  OR order_delivered_carrier_date IS NULL;

-- Task 5: Check for the tables data types
-- This command would retrieve the data type of each column in tables
EXEC sp_columns orders;

EXEC sp_columns customers;

EXEC sp_columns geolocation;

EXEC sp_columns order_items;

EXEC sp_columns order_payments;

EXEC sp_columns order_reviews;

EXEC sp_columns product_category_name_translation;

EXEC sp_columns products;

EXEC sp_columns sellers; 

-- Summary: 
--			orders -> order_status changed to varchar
--			customers -> customer_city and customer_state to varchar, zip_code_prefix -> nvarchar
--			geolocation -> city and state to varchar
--			order_items -> none
--			order_payments -> payment_type -> variable character
--			order_reviews -> comment_title and message to varchar
--			pcnt -> none
--			products -> category_name ->varchar, product weight g -> tinyint
--			sellers -> zip code prefix -> nvarchar, city and state -> varchar

-- Task 6: Convert data types
--orders table
ALTER TABLE orders
ALTER COLUMN order_status varchar(50)

-- customers table
ALTER TABLE customers
ALTER COLUMN customer_city varchar(100)
ALTER COLUMN customer_state varchar(100)
ALTER COLUMN customer_zip_code_prefix nvarchar(10)

---- geolocation table
ALTER TABLE geolocation
ALTER COLUMN geolocation_city varchar(100)
ALTER COLUMN geolocation_state varchar(100)

---- order_payments table
ALTER TABLE order_payments
ALTER COLUMN payment_type varchar(50)

---- order_reviews table
ALTER TABLE order_reviews
ALTER COLUMN review_comment_title varchar(255)
ALTER COLUMN review_comment_message varchar(MAX)

---- products table
ALTER TABLE products
ALTER COLUMN product_category_name varchar(100)
ALTER COLUMN product_weight_g INT

---- sellers table
ALTER TABLE sellers
ALTER COLUMN seller_zip_code_prefix nvarchar(10)
ALTER COLUMN seller_city varchar(100)
ALTER COLUMN seller_state varchar(100)

-- Task 7: Remane columns
EXEC sp_rename 'sellers.id', 'seller_id', 'COLUMN';
EXEC sp_rename 'sellers.seller_zip_code_prefix', 'zip_code_prefix', 'COLUMN';
EXEC sp_rename 'sellers.seller_city', 'city', 'COLUMN';
EXEC sp_rename 'sellers.seller_state', 'state', 'COLUMN';

EXEC sp_rename 'products.id', 'product_id', 'COLUMN';
EXEC sp_rename 'products.product_category_name', 'category_name', 'COLUMN';
EXEC sp_rename 'products.product_name_lenght', 'name_length', 'COLUMN';
EXEC sp_rename 'products.product_description_lenght', 'description_length', 'COLUMN';
EXEC sp_rename 'products.product_photos_qty', 'num_of_photos', 'COLUMN';
EXEC sp_rename 'products.product_weight_g', 'weight_g', 'COLUMN';
EXEC sp_rename 'products.product_length_cm', 'length_cm', 'COLUMN';
EXEC sp_rename 'products.product_height_cm', 'height_cm', 'COLUMN';
EXEC sp_rename 'products.product_width_cm', 'width_cm', 'COLUMN';

EXEC sp_rename 'product_category_name_translation.column1', 'category_name_spanish', 'COLUMN'
EXEC sp_rename 'product_category_name_translation.column2', 'category_name_english', 'COLUMN'

EXEC sp_rename 'orders.order_status', 'status', 'COLUMN';
EXEC sp_rename 'orders.order_purchase_timestamp', 'purchase_timestamp', 'COLUMN';
EXEC sp_rename 'orders.order_approved_at', 'approved_at', 'COLUMN';
EXEC sp_rename 'orders.order_delivered_carrier_date', 'delivered_carrier_date', 'COLUMN';
EXEC sp_rename 'orders.order_delivered_customer_date', 'delivered_customer_date', 'COLUMN';
EXEC sp_rename 'orders.order_estimated_delivery_date', 'estimated_delivery_date', 'COLUMN';

EXEC sp_rename 'order_reviews.review_score', 'score', 'COLUMN';
EXEC sp_rename 'order_reviews.review_comment_title', 'comment_title', 'COLUMN';
EXEC sp_rename 'order_reviews.review_comment_message', 'comment_message', 'COLUMN';
EXEC sp_rename 'order_reviews.review_creation_date', 'creation_date', 'COLUMN';
EXEC sp_rename 'order_reviews.review_answer_timestamp', 'answer_timestamp', 'COLUMN';

EXEC sp_rename 'geolocation.geolocation_zip_code_prefix', 'zip_code_prefix', 'COLUMN';
EXEC sp_rename 'geolocation.geolocation_lat', 'latitude', 'COLUMN'
EXEC sp_rename 'geolocation.geolocation_lng', 'longtitude', 'COLUMN'
EXEC sp_rename 'geolocation.geolocation_city', 'city', 'COLUMN'
EXEC sp_rename 'geolocation.geolocation_state', 'state', 'COLUMN'

EXEC sp_rename 'customers.customer_zip_code_prefix', 'zip_code_prefix', 'COLUMN'
EXEC sp_rename 'customers.customer_city', 'city', 'COLUMN'
EXEC sp_rename 'customers.customer_state', 'state', 'COLUMN'

-- Task8: Delete first row of the product_category_name_translation column
DELETE 
FROM product_category_name_translation 
WHERE category_name_english = 'product_category_name_english'

-- Task 9: Change underscores to space
UPDATE product_category_name_translation SET category_name_english = REPLACE(category_name_english, '_', ' ');
UPDATE product_category_name_translation SET category_name_spanish = REPLACE(category_name_spanish, '_', ' ');
UPDATE products SET category_name = REPLACE(category_name, '_', ' ')

-- Task 10: Transform the data
-- Create the order total column in order_items table

ALTER TABLE order_items ADD order_total VARCHAR(20);
UPDATE order_items SET order_total = price + freight_value

-- Change order_total column to a float
ALTER TABLE order_items
ALTER COLUMN order_total FLOAT;

-- Create order_size_cohort table
ALTER TABLE order_items ADD order_size_cohort VARCHAR(20);

-- Insert the values based on the criteria
UPDATE order_items SET order_size_cohort = 
    CASE 
        WHEN order_total < 50 THEN 'Small'
        WHEN order_total BETWEEN 50 AND 200 THEN 'Medium'
        WHEN order_total > 200 THEN 'Large'
    END;

-- Create dataset for analysis
CREATE VIEW product_size_cohorts AS
SELECT
    orders.customer_id,
	customers.customer_unique_id,
    orders.order_id,
    CAST(orders.purchase_timestamp AS DATE) AS order_date,
    (SELECT category_name_english
     FROM product_category_name_translation
     WHERE category_name_spanish = products.category_name) AS product_category,
    order_items.order_size_cohort,
	  order_items.order_total
FROM
    orders
    LEFT JOIN order_items ON orders.order_id = order_items.order_id
    LEFT JOIN customers ON orders.customer_id = customers.customer_id
    LEFT JOIN products ON order_items.product_id = products.product_id;


--Clean the data
 Check for duplicate values
SELECT *, COUNT(*)
FROM product_size_cohorts
GROUP BY customer_id, customer_unique_id, order_id, order_date, product_category, order_size_cohort, order_total
HAVING COUNT(*) > 1;

-- Remove duplicate rows
SELECT DISTINCT *
FROM product_size_cohorts

-- Check for NULL values
SELECT *
FROM product_size_cohorts
WHERE customer_id IS NULL 
	OR customer_unique_id IS NULL 
	OR order_id IS NULL 
	OR order_date IS NULL 
	OR product_category IS NULL
	OR order_size_cohort IS NULL
  OR order_total IS NULL

-- Replace NULL values with N/A
-- Null values can not be replaced bacause the columns a stored in a view so it woud be done in Power BI
-- END OF DATA PREPERATION



-- Analysis
-- Cohort analysis
-- Task 1: Calculate the frequency, recency, and monetary value of each customer in order to capture important information about customer behavior
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS frequency,
    DATEDIFF(day, MAX(order_date), (SELECT MAX(order_date) FROM product_size_cohorts)) AS recency,
    AVG(order_total) AS monetary_value
FROM
    product_size_cohorts
GROUP BY
    customer_unique_id;

-- Next calculate the amount of customers in each cohort






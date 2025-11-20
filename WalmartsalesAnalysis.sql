
CREATE DATABASE salesdataWalmart;


CREATE TABLE IF NOT EXISTS sales(
    Invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    Branch VARCHAR(5) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    VAT NUMERIC(6,4) NOT NULL,
    Total DECIMAL(12,4) NOT NULL,
    Date TIMESTAMP NOT NULL,
    Time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    Gross_margin_pct NUMERIC(11,9),
    Gross_income DECIMAL(12,4) NOT NULL,
    Rating NUMERIC(3,1)
);

SELECT * FROM sales;

SELECT time FROM sales;

--Finding time_of_day--
SELECT 
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day =(
	CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
);

SELECT * FROM sales;

--Finding day_name--
SELECT
    date,
    TO_CHAR(date, 'Day') AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = TO_CHAR(date, 'Day');

---finding month_name---

SELECT 
	date,
	TO_CHAR(date, 'Month') AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = TO_CHAR(date, 'Month');

``````````````````````````````````````````````````````````````````````````````````````````````````````````````
--How many unique cities does Walmart have?
SELECT
  
  DISTINCT city
  
 FROM sales;

--What are the branches of Walmart in each unique city?

SELECT
  
  DISTINCT city, branch
  
 FROM sales;

--Write a SQL query to retrieve all columns for sales made on '2019-03-04'
SELECT *
FROM sales
WHERE date = '2019-03-04'

----Write the sql query to calculate the total sales for each product_line.
SELECT 
    product_line,
    SUM(total) AS net_sale,
    COUNT(*) AS total_orders
FROM sales
GROUP BY product_line;

--Write an sql query to find all transactions where the total_sales is greater than 1000.
SELECT 
	invoice_id,total
FROM sales
WHERE total>1000
GROUP BY invoice_id,total


---Write  an sql query to calculate the average sale for each month, also find the best selling month for each year.
SELECT year, month_name, avg_sales
FROM (
    SELECT 
        EXTRACT(YEAR FROM date) AS year,
        TO_CHAR(date, 'Month') AS month_name,
        ROUND(AVG(total),2) AS avg_sales,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM date)
            ORDER BY AVG(total) DESC
        ) AS rank
    FROM sales
    GROUP BY
        EXTRACT(YEAR FROM date),
        TO_CHAR(date, 'Month')
) AS t1
WHERE rank = 1;


--Write an sql query to find the top 3 customers based on the highest total sales.
SELECT 
    invoice_id,
    SUM(total) AS total_sales
FROM sales
GROUP BY invoice_id
ORDER BY total_sales DESC
LIMIT 3;

--How many unique product lines are in the dataset?
 SELECT
 	 COUNT(DISTINCT product_line)
FROM sales;

---Find out the most common method for payment
SELECT payment_method,
	COUNT(payment_method) as frequency 
FROM sales
GROUP BY payment_method
ORDER BY frequency DESC;

--What is the most selling product_line?

SELECT product_line,
	COUNT(product_line) as frequency 
FROM sales
GROUP BY product_line
ORDER BY frequency DESC;

----What is the total revenue by month?

SELECT 
	month_name AS month,
	ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

---Which month had the largest cogs?
SELECT 
	month_name AS month,
	SUM(cogs) as total_cogs
FROM sales
GROUP by month_name
ORDER BY total_cogs DESC;

--What product_line had the largest revenue?
SELECT
	product_line,
	ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

--What city had the largest revenue?
SELECT city,branch,
	ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY city,branch
ORDER BY total_revenue DESC;

--Which product_line has the largest VAT?

SELECT 
    product_line,
    VAT
FROM sales
ORDER BY VAT DESC
LIMIT 1;

--Which branch sold more products than average product sold?
SELECT branch,
	SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG (quantity) FROM sales);

--What is the most common product line by gender?
SELECT gender,
	product_line,
	COUNT(gender) AS total_gender_ct
FROM sales
GROUP BY gender,product_line
ORDER BY total_gender_ct DESC;

--What is the average rating of each product line?
SELECT
	product_line,
	ROUND(AVG(rating),2) AS avg_rating
	FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


--What is the number of sales made in each time of the day per weekday
SELECT
 	time_of_day, day_name,
 	COUNT(*) AS total_sales
FROM sales
GROUP BY time_of_day,day_name
ORDER BY total_sales DESC;

--Which of the customer types brings the most revenue?
SELECT 
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

--Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city, VAT
FROM sales
ORDER BY VAT DESC
LIMIT 1;

--Which customer type pays the most in VAT?

SELECT 
	customer_type,
	ROUND(AVG(VAT),2) AS avg_VAT
FROM sales
GROUP BY customer_type
ORDER BY avg_VAT DESC;

--How many customer types does the data have/Which customer type buys the most?
SELECT 
	customer_type,
	COUNT(*) AS customer_count
FROM sales
GROUP BY customer_type
ORDER BY COUNT(customer_type); 


--How many unique customer types does the data have?

SELECT 
	COUNT(DISTINCT customer_type)
FROM sales;

--How many unique payment methods does the data have?

SELECT 
	COUNT(DISTINCT payment_method)
FROM sales;

--What is the gender of most of the customers?

SELECT 
	gender,
	COUNT(*) as gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

--What is the gender distribution per branch?

SELECT 
	gender, branch,
	COUNT(*) as gender_count
FROM sales
GROUP BY gender, branch
ORDER BY branch,gender_count DESC;

--Which time of the day do customers give most ratings per branch and what are the customer types and their gender?
SELECT
	time_of_day,branch,customer_type, gender,
	ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY time_of_day,branch,customer_type,gender
ORDER BY branch,avg_rating DESC;

--Which day of the week has the best average ratings per branch?
SELECT 
	day_name,branch,
	ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY day_name,branch
ORDER BY avg_rating DESC;

````````````````````````````````````````````````````END```````````````````````````````````````````````````````````````````
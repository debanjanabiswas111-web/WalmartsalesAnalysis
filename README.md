# Walmart Sales Analysis SQL Project

## Project Overview
This project explores Walmart sales data to identify top-performing branches and products, analyze sales trends, and understand customer behavior. The dataset comes from the Kaggle Walmart Sales Forecasting Competition (https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting), which provides historical data from 45 stores across multiple regions, including the impact of holiday markdowns on departmental sales.

The goal is to showcase practical SQL skills used in real-world retail analytics—setting up a sales database, performing exploratory analysis, and answering key business questions.

## Objectives
1. **Set up Walmart sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values. There are no null values in the respective database, hence null values are filtered out.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `salesdataWalmart`.
- **Table Creation**: A table named `sales` is created to store the sales data. The table structure includes columns for invoice_id, branch, city, customer_type, gender, product_line,unit_price, quantity, tax_pct, total, date,time, payment, cogs, gross_margin_pct, gross_income and rating.

```sql


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


### 2. Data Exploration & Cleaning
- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql

SELECT * FROM sales;

SELECT time FROM sales;

**--Finding time_of_day--**
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


**--Finding day_name--**
SELECT
    date,
    TO_CHAR(date, 'Day') AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = TO_CHAR(date, 'Day');

**--finding month_name--**

SELECT 
	date,
	TO_CHAR(date, 'Month') AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = TO_CHAR(date, 'Month');


--How many unique cities does Walmart have?
SELECT
   DISTINCT city
 FROM sales;

--What are the branches of Walmart in each unique city?

SELECT
   DISTINCT city, branch
FROM sales;

--How many unique product lines are in the dataset?
 SELECT
 	 COUNT(DISTINCT product_line)
FROM sales;

--What is the most selling product_line?

SELECT product_line,
	COUNT(product_line) as frequency 
FROM sales
GROUP BY product_line
ORDER BY frequency DESC;

--How many unique customer types does the data have?

SELECT 
	COUNT(DISTINCT customer_type)
FROM sales;

--How many unique payment methods does the data have?

SELECT 
	COUNT(DISTINCT payment_method)
FROM sales;

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

**Write a SQL query to retrieve all columns for sales made on '2019-03-04'**
```sql
SELECT *
FROM sales
WHERE date = '2019-03-04';
```

**Write the sql query to calculate the total sales for each product_line*
```sql
SELECT 
    product_line,
    SUM(total) AS net_sale,
    COUNT(*) AS total_orders
FROM sales
GROUP BY product_line;
```

**Write an sql query to find all transactions where the total_sales is greater than 1000**
```sql
SELECT 
	invoice_id,total
FROM sales
WHERE total>1000
GROUP BY invoice_id,total;
```

**Write  an sql query to calculate the average sale for each month, also find the best selling month for each year**
```sql
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
```
**Write an sql query to find the top 3 customers based on the highest total sales**
```sql
SELECT 
    invoice_id,
    SUM(total) AS total_sales
FROM sales
GROUP BY invoice_id
ORDER BY total_sales DESC
LIMIT 3;
```

**Find out the most common method for payment**
```sql
SELECT payment_method,
	COUNT(payment_method) as frequency 
FROM sales
GROUP BY payment_method
ORDER BY frequency DESC;
```

**What is the total revenue by month?**
```sql
SELECT 
	month_name AS month,
	ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;
```

**Which month had the largest cogs?**
```sql
SELECT 
	month_name AS month,
	SUM(cogs) as total_cogs
FROM sales
GROUP by month_name
ORDER BY total_cogs DESC;
```

**What product_line had the largest revenue?**
```sql
SELECT
	product_line,
	ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;
```

**What city had the largest revenue?**
```sql
SELECT city,branch,
	ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY city,branch
ORDER BY total_revenue DESC;
```

**Which product_line has the largest VAT?**
```sql
SELECT 
    product_line,
    VAT
FROM sales
ORDER BY VAT DESC
LIMIT 1;
```

**Which branch sold more products than average product sold?**
```sql
SELECT branch,
	SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG (quantity) FROM sales);
```

**What is the most common product line by gender?**
```sql
SELECT gender,
	product_line,
	COUNT(gender) AS total_gender_ct
FROM sales
GROUP BY gender,product_line
ORDER BY total_gender_ct DESC;
```

**What is the average rating of each product line?**
```sql
SELECT
	product_line,
	ROUND(AVG(rating),2) AS avg_rating
	FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;
```

**What is the number of sales made in each time of the day per weekday**
```sql
SELECT
 	time_of_day, day_name,
 	COUNT(*) AS total_sales
FROM sales
GROUP BY time_of_day,day_name
ORDER BY total_sales DESC;
```

**Which of the customer types brings the most revenue?**
```sql
SELECT 
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;
```

**Which city has the largest tax percent/ VAT (Value Added Tax)?**
```sql
SELECT city, VAT
FROM sales
ORDER BY VAT DESC
LIMIT 1;
```

**Which customer type pays the most in VAT?**
```sql
SELECT 
	customer_type,
	ROUND(AVG(VAT),2) AS avg_VAT
FROM sales
GROUP BY customer_type
ORDER BY avg_VAT DESC;
```

**What is the gender of most of the customers?**
```sql
SELECT 
	gender,
	COUNT(*) as gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;
```

**What is the gender distribution per branch?**
```sql
SELECT 
	gender, branch,
	COUNT(*) as gender_count
FROM sales
GROUP BY gender, branch
ORDER BY branch,gender_count DESC;
```

**Which time of the day do customers give most ratings per branch and what are the customer types and their gender?**
```sql
SELECT
	time_of_day,branch,customer_type, gender,
	ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY time_of_day,branch,customer_type,gender
ORDER BY branch,avg_rating DESC;
```

**Which day of the week has the best average ratings per branch?**
```sql
SELECT 
	day_name,branch,
	ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY day_name,branch
ORDER BY avg_rating DESC;

## Findings
**Customer Demographics**: The dataset includes shoppers from multiple branches across different cities, with demographic attributes such as gender and customer type (Member vs. Normal).
These attributes were analyzed to understand how different groups contribute to overall sales performance.

**High-Value Transactions**: Identified transactions where the total sale exceeded 1000, highlighting premium purchases and high-spending customer behavior. It is useful for detecting revenue spikes and understanding what product lines drive large orders.

**Sales Trends**: Time-based analyses (by month, weekday, and time of day) were performed to reveal clear sales patterns and peak sales hours, best-performing months, and branch-level performance differences were discovered. SQL functions like EXTRACT(), TO_CHAR(), CASE, GROUP BY, and window functions were used to derive insights.

**Customer Insights**: Analyzed product-line preferences across gender and customer types to uncover buying patterns and evaluated customer ratings by branch, time of day, and weekday to understand satisfaction levels. These insights help identify high-demand categories, customer behavior trends, and service quality indicators.

## Reports
**Sales Summary**: A detailed summary of total sales and revenue, customer demographics and product line performance.
**Trend Analysis**: Insights regarding sales trends across different shifts and months of the year.
**Customer Insights**: Reports on customer type and gender per product line.

## Conclusion
Built a clean, normalized PostgreSQL database from raw Walmart sales data and applied SQL constraints for accurate analysis. Analyzed 1,000+ sales records using GROUP BY, CASE, window functions, and aggregations to uncover trends in product performance, VAT, sales timing, and customer behavior. Delivered insights on peak sales hours, top product lines, and city-wise tax patterns.

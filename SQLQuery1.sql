Select * from df_orders;

-- find top 10 highest revenue generating products

SELECT TOP 10 product_id,sum(sale_price) as Sales from df_orders group by product_id order by Sales DESC;

-- find top 5 highest selling product in each region

WITH CTE AS (SELECT region,product_id,sum(sale_price) AS Sales FROM df_orders 
GROUP BY region,product_id) SELECT * from ( SELECT *, ROW_NUMBER() OVER(PARTITION BY region ORDER BY Sales DESC) as RN FROM CTE) A WHERE RN<=5;

-- find month over month growth comparison for 2022 and 2023 sales eg. Jan 2022 vs Jan 2023

WITH CTE as (SELECT YEAR(order_date) AS order_year,MONTH(order_date) AS order_month,SUM(sale_price) AS Sales FROM df_orders 
GROUP BY YEAR(order_date),MONTH(order_date)
--ORDER BY YEAR(order_date),MONTH(order_date)
)
SELECT order_month,
SUM(CASE WHEN order_year=2022 then Sales else 0 end )as sales_2022,
SUM(CASE WHEN order_year=2023 then Sales else 0 end )as sales_2023
from CTE GROUP BY order_month ORDER BY order_month;

-- for each category which month had highest sales
WITH CTE as (SELECt category,FORMAT(order_date,'yyyyMM') AS order_year_month,SUM(sale_price) as sales FROM df_orders
GROUP BY category,FORMAT(order_date,'yyyyMM')
--ORDER BY category,FORMAT(order_date,'yyyyMM')
)
SELECT * from (SELECT *,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) as RN
from CTE) as A where RN=1;

-- which subcategory has highest growth by profit in 2023 compare to 2022

WITH CTE as (SELECT sub_category,YEAR(order_date) AS order_year,
SUM(sale_price) AS Sales FROM df_orders 
GROUP BY sub_category,YEAR(order_date)
)
, CTE2 as (
SELECT sub_category,
SUM(CASE WHEN order_year=2022 then Sales else 0 end )as sales_2022,
SUM(CASE WHEN order_year=2023 then Sales else 0 end )as sales_2023
from CTE 
GROUP BY sub_category 
)
SELECT TOP 1 *,
(sales_2023-sales_2022)*100/sales_2022 as growth_percent
FROM CTE2 ORDER BY growth_percent DESC
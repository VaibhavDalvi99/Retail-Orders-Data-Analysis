create database sql_python;

use sql_python;

desc df_orders;

drop table df_orders;

create table df_orders (
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code varchar(20),
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
quantity int,
discount decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2)
);

select * from df_orders;

-- Find top10 highest revenue generating products
select product_id, sum(sale_price) as sales 
from df_orders 
group by product_id 
order by sales desc 
limit 10;

-- Find top 5 highest selling products in each region
with cte as
(select region, product_id, sum(sale_price) as sales 
from df_orders 
group by region, product_id 
order by region, sales desc)
select * from (
select *, rank() over(partition by region order by sales desc) as rnk 
from cte) A
where A.rnk < 6;

-- Find month over month comparison for 2022 and 2023 sales eg : Jan2022 and Jan2023
with cte as (
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from df_orders
group by order_year, order_month
order by order_year, order_month)
select
order_month,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- For each category which month has highest sales.
with cte as (
select category, year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from df_orders
group by category, order_year, order_month
order by category, sales desc)
select * from (
select 
*, row_number() over(partition by category order by sales desc) as rn
from cte) A
where rn < 2;

-- OR

with cte as (
select category, date_format(order_date,'%Y%m') as order_year_month, sum(sale_price) as sales
from df_orders
group by category, order_year_month
order by category, sales desc)
select * from (
select 
*, row_number() over(partition by category order by sales desc) as rn
from cte) A
where rn < 2;

-- Which sub category had highest growth by profit in 2023 compare to 2022
select * from df_orders;

with cte as (
select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by sub_category, order_year
order by sub_category, order_year),
cte2 as (
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
order by sub_category)
select *, (sales_2023 - sales_2022)*100/sales_2022 as percentage
from cte2
order by percentage desc;



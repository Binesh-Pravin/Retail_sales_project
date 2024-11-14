-- Create table for import the data
create table retail_sale(transactions_id int primary key,
						  sale_date date,
						  sale_time time,
						  customer_id int,
						  gender varchar(10),
						  age int,
						  category varchar(15),
						  quantity int,
						  price_per_unit float,
						  cogs float,
						  total_sale float
						  );


select * from retail_sale;

-- Data Cleaning
-- Identifying the null values

select 
	* 
from 
	retail_sale
where
	transactions_id	is null
	or
	sale_date is null
	or 
	sale_time is null
	or
	customer_id is null
	or
	gender is null
	or
	age is null
	or
	category is null
	or 
	quantity is null
	or
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null;


/* Removing rows from the columns 
		Quantity,
		Price_per_unit,
		Cogs,
		Total_sale 
	containg null values 
*/

Delete from
	retail_sale
where
	transactions_id	is null
	or
	sale_date is null
	or 
	sale_time is null
	or
	customer_id is null
	or
	gender is null
	or
	category is null
	or 
	quantity is null
	or
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null;

-- Replace Age with AVG of age containing null values

-- Replaced null values with avg age of male customers for male customers
Update 
	retail_sale
set
	age = (select avg(age) from retail_sale where age is not null and gender = 'Male')
where
	age is null
	and
	gender = 'Male';

-- Replaced null values with avg age of female customers for female customers
Update 
	retail_sale
set
	age = (select avg(age) from retail_sale where age is not null and gender = 'Female')
where
	age is null
	and
	gender = 'Female';


-- Data Exploration

-- Available categories
select 
	distinct category as Categories 
from 
	retail_sale;

-- Total customers 
select 
	count(distinct(customer_id)) as Total_customers 
from 
	retail_sale;


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
select
	*
from 
	retail_sale
where
	sale_date = '2022-11-05';
	
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022


select 
	* 
from 
	retail_sale
where 
		extract(month from sale_date) = 11 
	and 
		extract(year from sale_date) = 2022
	and 
		category = 'Clothing'
	and 
		quantity > 10;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select 
	distinct category as categories,
	sum(total_sale) as Sales
from
	retail_sale
group by
	categories;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select 
	round(avg(age),0) as AVG_age
from 
	retail_sale
where
	category like 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select 
	* 
from 
	retail_sale
where
	total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select
	category,
	gender,
	count(transactions_id) as total_transactions
from 
	retail_sale
group by
		category,
		gender;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select
	extract(year from sale_date) as year,
	to_char(sale_date,'Month') as month,
	avg(total_sale) as total_sales
from
	retail_sale
group by
	1,
	to_char(sale_date,'Month'),
	extract(month from sale_date)
order by
	1,3 desc;

-- Find out best selling month in each year
with cte as (select 
				extract (year from sale_date) as year,
				extract (month from sale_date) as month,
				to_char(sale_date,'Month') as month_name,
				sum(total_sale) as total_sale,
				dense_rank() over(partition by extract(year from sale_date) order by sum(total_sale) desc) as rank
			 from 
				retail_sale
			 group by
				extract (year from sale_date),
				extract (month from sale_date),
				to_char(sale_date,'Month')
	
			 order by
				extract(year from sale_date),
				extract(month from sale_date)
			)
			select
				year,
				month_name,
				total_sale
			from 
				cte
			where 
				rank = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select 
	customer_id,
	sum(total_sale) as total_sale
from 
	retail_sale
group by	
	customer_id
order by 
	sum(total_sale) desc
limit 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select 
	category,
	count(distinct customer_id) as cnt
from 
	retail_sale
group by
 	1
 ;  			 


				
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
with cte as (
select
	*,
	case 
		when extract (hour from sale_time) <= 12 then 'Morning'
		when extract (hour from sale_time) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end as shift
from
	retail_sale
)
select
	shift,
	count(*) as total_orders
from 
	cte
group by 
	shift
order by 
	count(*) desc;






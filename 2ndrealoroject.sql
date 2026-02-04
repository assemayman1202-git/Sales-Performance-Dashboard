select * from  fact_sales_denormalized
select * from  dim_stores
select * from  dim_salespersons
select * from  dim_products
select * from  dim_dates
select * from  dim_customers
select * from  dim_campaigns

----------------------------------------------------------------------------------
-- check duplicates
select campaign_id,count(*) as count
from dim_campaigns
group by campaign_id
having count(*) >1;

----------------------------------------------------------------------------------

--- change columns type
alter table dim_campaigns
alter column start_date_sk int 

alter table dim_campaigns
alter column end_date_sk int

alter table dim_campaigns
alter column campaign_budget int 
----------------------------------------------------------------------------------
---- extract month,day and quarter names
select * from  dim_dates
alter table dim_dates
add month_name varchar(50) ,
day_name varchar(50)  ,
quarter_name varchar(50) ; 
update dim_dates
set month_name = DATENAME(Month,full_date) 

update dim_dates
set day_name = datename(weekday,full_date)

update dim_dates
set quarter_name = 'Q' + cast(quarter as varchar(1))

--- merge full name
alter table dim_customers
add full_name varchar(50)
update dim_customers
set full_name = concat(first_name , ' '  ,last_name)

-- drop columns
alter table dim_customers
drop column first_name
alter table dim_customers
drop column last_name
----------------------------------------------------------------------------------
----- add column date only to fact table & dim date table 
alter table fact_sales_denormalized 
add  date_only date

update fact_sales_denormalized
set date_only = cast(sales_date as date)

select * from fact_sales_denormalized 
----
alter table dim_dates 
add  date_only date

update dim_dates
set date_only = cast(full_date as date)

----------------------------------------------------------------------------------
--- add dates to start & end date for campaigns 
alter table dim_campaigns
add start_date DATE, 
end_date Date ,
campaign_duration INT

update dim_campaigns
set start_date = ( select date_only from dim_dates where date_sk = dim_campaigns.start_date_sk)

update dim_campaigns
set end_date = ( select date_only from dim_dates where date_sk = dim_campaigns.end_date_sk)

update dim_campaigns
set campaign_duration = datediff(day,start_date,end_date)


----------------------------------- TIME FOR ANALYSIS ----------------------------------------------


------------------------- BRANDS & CATEGORY ------------------
---- total amount
select sum(total_amount) as total_amount
from fact_sales_denormalized


-- count of brands
select  count(distinct brand) as brands
from dim_products


--- categories
select  count(distinct category) as categoris
from dim_products


--- total amount by category
select distinct category, sum(total_amount) as total_amount
from fact_sales_denormalized
group by category
order by total_amount desc


--- total amount by brand
select distinct p.brand , sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_products as p
on f.product_sk = p.product_sk
group by p.brand
order by total_amount desc


---- total amount by product name top 10 
select distinct top 10 p.product_name , sum(f.total_amount) as total_amount 
from fact_sales_denormalized as f
join dim_products as p 
on f.product_sk = p.product_sk
group by p.product_name
order by total_amount desc


---- total amount by product name bottom 10 
select distinct top 10 p.product_name , sum(f.total_amount) as total_amount 
from fact_sales_denormalized as f
join dim_products as p 
on f.product_sk = p.product_sk
group by p.product_name
order by total_amount asc



---------------- CUSTOMERS ----------

---- total amount
select sum(total_amount) as total_amount
from fact_sales_denormalized

-- count of customers
select distinct count(customer_id) AS total_customers
from dim_customers

---customer segment
select  count(distinct customer_segment) as segments
from fact_sales_denormalized


---- total amount by product name top 10 
select distinct top 10 p.product_name , sum(f.total_amount) as total_amount 
from fact_sales_denormalized as f
join dim_products as p 
on f.product_sk = p.product_sk
group by p.product_name
order by total_amount desc


---- total amount by product name bottom 10 
select distinct top 10 p.product_name , sum(f.total_amount) as total_amount 
from fact_sales_denormalized as f
join dim_products as p 
on f.product_sk = p.product_sk
group by p.product_name
order by total_amount asc


---- number of customers by segment
select  customer_segment  ,  count(distinct customer_id) AS total_customers
from dim_customers 
group by customer_segment
order by total_customers desc


--- total amount by segment
select distinct customer_segment, sum(total_amount) as total_amount
from fact_sales_denormalized
group by customer_segment
order by total_amount desc


--- top 10 customers by amount 

select distinct top 10 c.full_name , sum(f.total_amount) as total_amount 
from fact_sales_denormalized as f
join dim_customers as c 
on f.customer_sk = c.customer_sk
group by c.full_name
order by total_amount desc


------------- PRODUCTS & STORES -------------------

---- total amount
select sum(total_amount) as total_amount
from fact_sales_denormalized

-- count of products
select distinct count(product_id) as total_products
from dim_products

-- stores
select distinct count(store_id) as stores
from dim_stores

--- number of store_location
select   count(distinct store_location) as store_location
from dim_stores

---- total amount by product name top 10 
select distinct top 10 p.product_name , sum(f.total_amount) as total_amount 
from fact_sales_denormalized as f
join dim_products as p 
on f.product_sk = p.product_sk
group by p.product_name
order by total_amount desc


---- total amount by product name bottom 10 
select distinct top 10 p.product_name , sum(f.total_amount) as total_amount 
from fact_sales_denormalized as f
join dim_products as p 
on f.product_sk = p.product_sk
group by p.product_name
order by total_amount asc


-- total amount by store type 
select distinct s.store_type , sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_stores as s
on f.store_sk = s.store_sk
group by s.store_type
order by total_amount desc


---- number of stores(store_id) by store_location
select  top 10 count(distinct store_id) as stores ,  store_location as locations
from dim_stores
group by store_location
order by stores desc


-- total amount by store location
select distinct top 10 s.store_location as locations , sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_stores as s
on f.store_sk = s.store_sk
group by s.store_location 
order by total_amount desc


------------ SALESPERSON ----------------

---- total amount
select sum(total_amount) as total_amount
from fact_sales_denormalized

--- salesperson
select distinct count(salesperson_id) as salespersons
from dim_salespersons


---- total amount by salesperson role
select distinct s.salesperson_role, sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_salespersons as s
on f.salesperson_sk = s.salesperson_sk
group by s.salesperson_role
order by total_amount desc

--- salesperson role count
select salesperson_role ,count(*) as number_of_persons 
from dim_salespersons
group by salesperson_role
order by number_of_persons desc


---- total amount by salesperson role & name 
select distinct top 10 s.salesperson_name ,  s.salesperson_role , sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_salespersons as s
on f.salesperson_sk = s.salesperson_sk
group by s.salesperson_name,s.salesperson_role
order by total_amount desc


-------------- DATES ------------------


--- amount by month
select d.month_name, sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_dates as d
on f.date_only = d.date_only
group by d.month_name


---- total amount by quarter 
select d.quarter_name, sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_dates as d
on f.date_only = d.date_only
group by d.quarter_name
order by total_amount desc


------ TOTAL AMOUNT BY DATES
select d.date_only , sum(f.total_amount) as total_amount
from fact_sales_denormalized as f
join dim_dates as d
on f.date_only = d.date_only
group by d.date_only
order by total_amount desc


-------------- CAMPAIGNS _--------------
---- total amount
select sum(total_amount) as total_amount
from fact_sales_denormalized


--- campaign budget 
select sum(campaign_budget) as budget_campaings
from dim_campaigns


--- count of campaigns
select distinct count(campaign_id) as total_campaigns
from dim_campaigns 



----- total amount by campaign name and category 

    SELECT 
       distinct c.campaign_name as campaigns,
    SUM(CASE WHEN f.category = 'Clothing' THEN f.total_amount ELSE 0 END) AS Clothing,
    SUM(CASE WHEN f.category = 'Electronics' THEN f.total_amount ELSE 0 END) AS Electronics,
    SUM(CASE WHEN f.category = 'Furniture' THEN f.total_amount ELSE 0 END) AS Furniture,
    SUM(CASE WHEN f.category = 'Groceries' THEN f.total_amount ELSE 0 END) AS Groceries,
    SUM(CASE WHEN f.category = 'Home Appliances' THEN f.total_amount ELSE 0 END) AS Home_Appliances,
    SUM(CASE WHEN f.category = 'Sports & Outdoors' THEN f.total_amount ELSE 0 END) AS Sports_and_Outdoors,
    SUM(f.total_amount) AS total_amount
    FROM fact_sales_denormalized as f
    join dim_campaigns as c
    on f.campaign_sk = c.campaign_sk
    GROUP BY c.campaign_name
    order by total_amount desc



--- campaign name,start & end date, duration  and its budget 
select distinct campaign_name as campaign_name,
start_date,end_date,campaign_duration,
sum(campaign_budget) as campaign_budget
from dim_campaigns
group by campaign_name,campaign_duration,start_date,end_date
order by campaign_budget desc



------ overlap between campaigns in one time
select d.date_only , 
count(distinct c.campaign_sk) as Active_Campaigns_Count,
SUM(f.total_amount) AS total_amount
FROM  dim_dates as d
join  dim_campaigns as c
on  d.date_only between (select date_only from dim_dates where date_sk = c.start_date_sk)
and (select date_only from dim_dates where date_sk = c.end_date_sk)
join fact_sales_denormalized as f
on f.date_only = d.date_only
group by d.date_only
having count(distinct c.campaign_sk) > 0 
order by d.date_only
---- view for products 
create view v_product as 
select product_id,product_name,product_sk,TRIM(brand) as brand ,category ,origin_location from dim_products 
where product_id IS NOT NULL 
and product_name IS NOT NULL 

-- view for salesperson 
create view v_salesperson as
select salesperson_id,salesperson_name,salesperson_sk,salesperson_role from dim_salespersons 
where salesperson_id IS NOT NULL 
and salesperson_name IS NOT NULL

--- view for store 
create view v_store as 
select store_id,store_sk,store_type,TRIM(store_location) as store_location  from dim_stores 
where store_id IS NOT NULL 
and store_location IS NOT NULL

--- view for customers 
create view c_customers as 
select customer_id,customer_sk,customer_segment,TRIM(email) as email,full_name,residential_location  from dim_customers 
where customer_id IS NOT NULL
---- view for campaign 
create view V_campaign as
select campaign_id,campaign_name,campaign_sk,start_date_sk,end_date_sk,campaign_budget,
campaign_duration,start_date,end_date   from dim_campaigns 
where campaign_id IS NOT NULL 
AND campaign_name IS NOT NULL 
--- view for date
create view V_dates as
select date_sk,full_date,weekday,day,year,quarter,month,day_name,month_name,quarter_name,date_only from dim_dates 















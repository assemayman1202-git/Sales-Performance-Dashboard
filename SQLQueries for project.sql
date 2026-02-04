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
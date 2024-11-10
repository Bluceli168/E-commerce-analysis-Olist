with SalesFiltered as(
   select category,
         sum(sales_value) as total_sales
   from bluce_table
   where (month(order_date) = 12 AND day(order_date) >=20) 
        or (month(order_date) = 1 AND day(order_date) <=2) 
   group by category
),
SalesRank as (
   select category,
       total_sales,
       rank() over( order by total_sales DESC ) as sales_rank
   from SalesFiltered
)
select category,
	   total_sales,
	   sales_rank
from SalesRank
where sales_rank <=5
order by sales_rank;



-- for whole table calculate each dayname's average sales

with WeeklySales as (
    select 
        dayname(order_date) as weekday,
        sum(sales_value) as total_sales,
        count(distinct date(order_date)) as day_count
	from bluce_table
    group by dayname(order_date)
),
AverageSales as (
select
   weekday,
   total_sales,
   total_sales/day_count as average_sales
from WeeklySales
)
select weekday,
       total_sales,
       round(average_sales,2) as average_sales
from AverageSales
order by field(weekday,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


-- for whole table calculate each hour's sales and percentage

-- with HourlySales as (
--     select
--         HOUR(order_date) as hour,
--         sum(sales_value) as total_sales
-- 	from bluce_table
--     group by HOUR(order_date)
-- )
-- select  hs.hour,
-- 		hs.total_sales,
--         concat(round((hs.total_sales/(select sum(sales_value) from bluce_table))*100,1),'%') as sales_percentage
-- from HourlySales as hs
-- order by hs.hour;

with HourlySales as (
     select HOUR(order_date) as hour,
            sum(sales_value) as total_sales
	 from bluce_table
     group by HOUR(order_date)
),
TotalSales as (
     select sum(sales_value) as grand_total
     from bluce_table
)
select hs.hour,
       hs.total_sales,
       concat(round((hs.total_sales/ts.grand_total)*100,1),'%') as sales_percentage
from HourlySales hs
cross join TotalSales ts
order by hs.hour;

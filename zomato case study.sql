SELECT * FROM swiggy.`zomato-schema`;

select * 
from `order details`;

-- 1. Find customers who have never ordered
select s.name
from `zomato-schema` s
where s.user_id not in (
select z.user_id
from `zomato-schema` z
join orders o
where o.user_id = z.user_id);


select s.name
from `zomato-schema` s
where s.user_id not in (
select o.user_id
from orders o);

-- 2. Average Price/dish
select s.f_id, f.f_name, s.avg_price
from
(select f_id, round(avg(price), 2) as avg_price
from menu m
group by f_id) s
join food f
where f.f_id = s.f_id;

select f.f_name, round(avg(price), 2) as avg_price
from menu m
join food f
on f.f_id = m.f_id
group by f.f_name;

-- 3. Find the top restaurant in terms of the number of orders for a given month
select r.r_name, count(o.r_id) as order_num
from orders o
join resturants r
on r.r_id = o.r_id
where monthname(date) = "June"
group by o.r_id, r.r_name
order by 2 desc
limit 1;


select r.r_name, count(o.r_id) as order_num
from orders o
join resturants r
on r.r_id = o.r_id
where monthname(date) = "May"
group by o.r_id, r.r_name
order by 2 desc
limit 1;

-- 4. restaurants with monthly sales greater than x for 
select r.r_name, sum(o.amount) as revenue
from orders o
join resturants r
on r.r_id = o.r_id
where monthname(date) = "June" 
group by r.r_name
having sum(amount) > 500
order by 2 desc;

-- 5. Show all orders with order details for a particular customer in a particular date range
select o.order_id, o.date, o.user_id, o.r_id, r.r_name, od.f_id, f.f_name, o.amount
from orders o
join resturants r on r.r_id = o.r_id
join `order details` od on od.order_id = o.order_id
join food f on f.f_id = od.f_id
where o.user_id = (select user_id from `zomato-schema` where name = "Ankit")
and date > "2022-06-10" and date < "2022-07-10"
;

select o.order_id, o.date, o.user_id, o.r_id, r.r_name, od.f_id, f.f_name, o.amount
from orders o
join resturants r on r.r_id = o.r_id
join `order details` od on od.order_id = o.order_id
join food f on f.f_id = od.f_id
where o.user_id = (select user_id from `zomato-schema` where name = "Nitish")
and date > "2022-06-10" and date < "2022-07-10";


-- 6. Find restaurants with max repeated customers 
select r.r_name, count(*) as max_repeated_customers
from (
select o.r_id, o.user_id, count(*) as no_of_orders
from orders o
group by r_id, user_id
having count(*) > 1) t
join resturants r on r.r_id = t.r_id
group by r.r_name
order by 2 desc
limit 1;


-- 7. Month over month revenue growth of swiggy
select month, ((revenue - prev)/prev)*100 as growth_rate
from (
with sales as(
select monthname(date) as `month`, sum(amount) as `revenue`
from orders
group by `month`)
select month, revenue, lag(revenue, 1) over (order by revenue) as prev
from sales) t;


-- 8. Customer - favorite food
select z.name, f.f_name
from (
with temp as (
select o.user_id, od.f_id, count(od.f_id) as food_count
from orders o
join `order details` od
on od.order_id = o.order_id
group by o.user_id, od.f_id)
select * 
from temp t1
where food_count = (select max(food_count) from temp t2 where t2.user_id = t1.user_id)) s
join `zomato-schema` z on z.user_id = s.user_id
join food f on f.f_id = s.f_id
;


-- Find the most loyal customers for all restaurant
select r.r_name, z.name
from (
select o.r_id, o.user_id, count(*) as no_of_orders
from orders o
group by r_id, user_id
having count(*) > 1
) s
join resturants r on r.r_id = s.r_id
join `zomato-schema` z on z.user_id = s.user_id
order by r_name;


-- Month over month revenue growth of a restaurant
select month, ((revenue - prev)/prev)*100 as growth_rate
from (
with sales as(
select monthname(date) as `month`, sum(amount) as `revenue`
from orders
where r_id = (select r_id from resturants where r_name like 'kfc')
group by `month`)
select month, revenue, lag(revenue, 1) over (order by revenue) as prev
from sales) t;


-- Name: Daniela 
-- Title: DB Assignment 3 
-- Date: 10/21/2025

set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

use hw3;

-- *************************************************************
-- Create the tables merchants-sell-products-cointain-order-place-customer
-- *************************************************************
create table merchants (
    mid int primary key,   -- PK constaint
    name varchar(50),
    city varchar(50),
    state varchar(50)
);

create table products (
    pid int primary key,   -- PK constaint
    name varchar(50),
    category varchar(50),
    description varchar(500),
	check (name in ('Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive', 'Laptop','Router', 'Network Card', 'Super Drive', 'Monitor')),
	check (category in ('Peripheral', 'Networking', 'Computer'))
   
);

create table sell (
    mid int,                     -- FK
    pid int,                     -- FK
    price numeric(20,2),
    quantity_available int,
    check (price between 0 and 100000),
    check (quantity_available between 0 and 1000),

    -- foreign key constraints
    foreign key (mid) references merchants(mid),
    foreign key (pid) references products(pid) 
);

create table orders (
	oid int primary key,
    shipping_method varchar(50),
    shipping_cost float,
    check (shipping_method in ('UPS', 'FedEx', 'USPS')),
    check (shipping_cost between 0 and 500)
);

create table contain (
	oid int,                     -- FK
    pid int,                     -- FK
    
    -- foreign key constraints
    foreign key (oid) references orders(oid),
    foreign key (pid) references products(pid) 
	
);

create table customers (
	cid int primary key,
    fullname varchar(50),
    city varchar(50),
    state varchar(50)
);
    
    create table place (
	cid int,   
	oid int, 				-- FK
    order_date date,
    
    -- foreign key constraints
    foreign key (oid) references orders(oid), 
    foreign key (cid) references customers(cid) 
          
);

-- *************************************************************
-- Insert data into tables
-- *************************************************************

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/merchants.txt'
INTO TABLE merchants
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.txt'
INTO TABLE products
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sell.txt'
INTO TABLE sell
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders2.txt'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/contain.txt'
INTO TABLE contain
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.txt'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/place.txt'
INTO TABLE place
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n';

-- *************************************************************
-- Solve Problems 
-- *************************************************************

-- Problem 1: List names and sellers of products that are no longer available (quantity=0)
select merchants.name as seller, products.name as product, quantity_available
from    merchants, sell,products
where   (merchants.mid = sell.mid) and (sell.pid = products.pid) and quantity_available = 0;

-- Problem 2: List names and descriptions of products that are not sold.
-- aka products that are not in order
select products.name, description
from products left outer join contain 
     using (pid) 
where contain.pid is null;

-- Problem 3: How many customers bought SATA drives but not any routers?
select count(distinct fullname) as bought_SATA_no_router
from (
select customers.fullname                            -- customers who bought a SATA driver
from customers join place on customers.cid = place.cid
            join orders on place.oid = orders.oid
            join contain on orders.oid = contain.oid
            join products on contain.pid = products.pid
where products.description like '%SATA%'
except
select customers.fullname                             -- cusomters who bought a driver
from customers join place on customers.cid = place.cid      
            join orders on place.oid = orders.oid
            join contain on orders.oid = contain.oid
            join products on contain.pid = products.pid
where products.name = 'Router'
) as number_of_customers_that_have_SATA_but_no_routers;



-- Problem 4: HP has a 20% sale on all its Networking products
select merchants.name, products.name as product_name, products.category, sell.price as orginal_price, sell.price*.8 as discounted_price
from merchants join sell on merchants.mid = sell.mid
            join products on products.pid = sell.pid
            where products.category = 'Networking' and merchants.name = "HP";
  
    
    
-- Problem 5: What did Uriel Whitney order? (make sure to at least retrieve product names and prices).
select merchants.name, customers.fullname, products.pid, products.name as product_name, sell.price
	from merchants join sell on merchants.mid = sell.mid
				join products on products.pid = sell.pid
				join contain on contain.pid = products.pid
				join orders on orders.oid = contain.oid
				join place on place.oid = orders.oid
				join customers on place.cid = customers.cid             
where customers.fullname = 'Uriel Whitney'
group by merchants.name, customers.fullname, products.pid,product_name, sell.price    
order by pid; 

-- What Urial ordered concerned only with products
select customers.fullname, products.name as product_name
	from merchants join sell on merchants.mid = sell.mid
				join products on products.pid = sell.pid
				join contain on contain.pid = products.pid
				join orders on orders.oid = contain.oid
				join place on place.oid = orders.oid
				join customers on place.cid = customers.cid             
where customers.fullname = 'Uriel Whitney'
group by customers.fullname,product_name;

-- Problem 6: List the annual total sales for each company (sort the results along the company and the year attributes
select merchants.name, format(sum(sell.price * sell.quantity_available),2) as total_price, year(place.order_date)
from merchants join sell on merchants.mid = sell.mid
			join products on products.pid = sell.pid
			join contain on contain.pid = products.pid
            join orders on orders.oid = contain.oid
			join place on place.oid = orders.oid
            join customers on place.cid = customers.cid
group by merchants.name, year(place.order_date)
order by merchants.name,year(place.order_date);


-- Problem 7: Which company had the highest annual revenue and in what year?
select merchants.name, sum(sell.price * sell.quantity_available) as total_price, year(place.order_date)
from merchants join sell on merchants.mid = sell.mid
			join products on products.pid = sell.pid
			join contain on contain.pid = products.pid
            join orders on orders.oid = contain.oid
			join place on place.oid = orders.oid
            join customers on place.cid = customers.cid
group by merchants.name, year(place.order_date)
order by total_price desc
limit 1;


-- Problem 8: On average, what was the cheapest shipping method used ever?
select orders.shipping_method, round(avg(orders.shipping_cost),2)
from orders
group by orders.shipping_method
order by avg(orders.shipping_cost)
limit 1;

-- Problem 9: What is the best sold ($) category for each company?
With company_category as  (
	select merchants.name as company, products.category as category, sum(sell.price * sell.quantity_available) as revenue
	from merchants join sell on merchants.mid = sell.mid
				join products on products.pid = sell.pid
				join contain on contain.pid = products.pid
				join orders on orders.oid = contain.oid
				join place on place.oid = orders.oid
				join customers on place.cid = customers.cid
group by merchants.name, products.category
),
Max_revenue as (                                 -- aggregates the max revenue for each company
select company ,max(revenue) as max_revenue
from company_category
group by company)

select cc.company, cc.category, cc.revenue
from company_category cc
JOIN Max_revenue mr on cc.company = mr.company and cc.revenue = mr.max_revenue
ORDER BY cc.revenue;



-- Problem 10: For each company find out which customers have spent the most and the least amounts
With company_customers as  (
	select merchants.name as company, customers.fullname as customer, sum(sell.price) as amount_spent
	from merchants join sell on merchants.mid = sell.mid
				join products on products.pid = sell.pid
				join contain on contain.pid = products.pid
				join orders on orders.oid = contain.oid
				join place on place.oid = orders.oid
				join customers on place.cid = customers.cid
group by merchants.name, customers.fullname 
),
Highest as (                         -- aggregates the highest spender amount and name
select c1.company, amount_spent as Highest_max_price, c1.customer as h_customer
from company_customers c1 
where amount_spent = 
(select max(amount_spent) 
from company_customers c2 
where c2.company = c1.company)
),
Lowest as (                          -- aggregates the lowest spender amount and name
select c1.company, amount_spent as lowest_min_price, c1.customer as l_customer
from company_customers c1
where amount_spent = (select min(amount_spent) 
from company_customers c3 
where c3.company = c1.company)
)
select * from Highest, Lowest                 -- joins the two subqueries 
where Highest.company = Lowest.company;

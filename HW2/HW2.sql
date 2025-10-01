-- Title: DBMS HW2
-- Date: 9/30/2025

set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

use hw2;

-- Problem 1: Average Price of Foods at Each Restaurant
select distinct restaurants.name, avg(price)
from    restaurants, serves,foods
where   (restaurants.restID = serves.restID) and (foods.FoodID = serves.foodID)
group by restaurants.name;

-- Problem 2: Maximum Food Price at Each Restaurant
select distinct restaurants.name, MAX(price)
from    restaurants, serves,foods
where   (restaurants.restID = serves.restID) and (foods.FoodID = serves.foodID)
group by restaurants.name;

-- Problem 3: Count of Different Food Types Served at Each Restaurant
select distinct restaurants.name, count(distinct type)
from    restaurants, serves,foods
where   (restaurants.restID = serves.restID) and (foods.FoodID = serves.foodID)
group by restaurants.name;

-- Problem 4: Average Price of Foods Served by Each Chef
select distinct chefs.name, avg(price)
from    chefs, works,restaurants,serves,foods
where   (chefs.chefID = works.chefID) and (works.restID = restaurants.restID) and (restaurants.restID = serves.restID) and (foods.FoodID = serves.foodID)
group by chefs.name;


-- Problem 5: Find the Restaurant with the Highest Average Food Price 
select distinct restaurants.name, avg(price)
from    restaurants, serves,foods
where   (restaurants.restID = serves.restID) and (foods.FoodID = serves.foodID)
group by restaurants.name
having (avg(price)) >= all
	(select avg(price) from restaurants, serves,foods
	group by restaurants.name);
    

-- Name: Daniela 
-- Title: DB Assignment 4
-- Date: 11/04/2025

set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

use hw4;

-- *************************************************************
-- Set PK Constraints 
-- *************************************************************
alter table actor
add constraint PK_constraint1 primary key(actor_id);

alter table address 
add constraint PK_constraint2 primary key(address_id);

alter table category
add constraint PK_constraint3 primary key(category_id);

alter table city 
add constraint PK_constraint4 primary key(city_id);

alter table country
add constraint PK_constraint5 primary key(country_id);

alter table customer 
add constraint PK_constraint6 primary key(customer_id);

alter table film
add constraint PK_constraint7 primary key(film_id);

alter table film_actor
add constraint PK_constraint8 primary key(actor_id, film_id);

alter table rental 
add constraint PK_constraint9 primary key(rental_id);

alter table staff
add constraint PK_constraint10 primary key(staff_id);

alter table store 
add constraint PK_constraint11 primary key(store_id);

alter table film_category
add constraint PK_constraint12 primary key(film_id, category_id);

alter table inventory
add constraint PK_constraint13 primary key(inventory_id);

alter table language
add constraint PK_constraint14 primary key(language_id);

alter table payment
add constraint PK_constraint15 primary key(payment_id);

-- *************************************************************
-- Set FK and U
-- *************************************************************
alter table address 
add constraint FK_constraint1 foreign key(city_id) references city(city_id);

alter table city 
add constraint FK_constraint2 foreign key(country_id) references country(country_id);

alter table customer 
add constraint FK_constraint3 foreign key(store_id) references store(store_id),
add constraint FK_constraint4 foreign key(address_id) references address(address_id);

alter table film
add constraint FK_constraint5 foreign key(language_id) references language(language_id);

alter table film_actor
add constraint FK_constraint6 foreign key(actor_id) references actor(actor_id),
add constraint FK_constraint7 foreign key(film_id) references film(film_id);

alter table rental 
add constraint UQ_constraint unique(rental_date,inventory_id,customer_id),
add constraint FK_constraint8 foreign key(inventory_id) references inventory(inventory_id),
add constraint FK_constraint9 foreign key(customer_id) references customer(customer_id),
add constraint FK_constraint10 foreign key(staff_id) references staff(staff_id);

alter table staff
add constraint FK_constraint11 foreign key(address_id) references address(address_id),
add constraint FK_constraint12 foreign key(store_id) references store(store_id);

alter table store 
add constraint FK_constraint13 foreign key(address_id) references address(address_id);

alter table film_category
add constraint FK_constraint14 foreign key(film_id) references film(film_id),
add constraint FK_constraint15 foreign key(category_id) references category(category_id);

alter table inventory
add constraint FK_constraint16 foreign key(film_id) references film(film_id),
add constraint FK_constraint17 foreign key(store_id) references store(store_id);


alter table payment
add constraint FK_constraint18 foreign key(customer_id) references customer(customer_id),
add constraint FK_constraint19 foreign key(staff_id) references staff(staff_id),
add constraint FK_constraint20 foreign key(rental_id) references rental(rental_id);

-- *************************************************************
-- Set additional constraints 
-- *************************************************************

alter table category 
add constraint check_cat_names check (name in ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games'
,'New', 'Documentary', 'Sports', 'Music'));

alter table film
add constraint check_film_specials check (special_features REGEXP '^(Behind the Scenes|Commentaries|Deleted Scenes|Trailers)(, (Behind the Scenes|Commentaries|Deleted Scenes|Trailers))*$'),
add constraint check_rental_duration check (rental_duration between 2 and 8),
add constraint check_rental_rate check (rental_rate between 0.99 and 6.99),
add constraint check_film_length check (length between 30 and 200),
add constraint check_ratings check (rating in ('PG', 'G', 'NC-17', 'PG-13', 'R')),
add constraint check_replacement_cost check (replacement_cost between 5.00 and 100.00);

alter table customer
add constraint check_active check (active between 0 and 1);

alter table staff
add constraint check_active2 check (active between 0 and 1);

alter table payment
add constraint check_payment check (amount >=0);

alter table film
modify release_year year;


-- *************************************************************
-- Solve Problems 
-- *************************************************************

-- Problem 1: What is the average length of films in each category? List the results in alphabetic order of categories.
select category.name, avg(film.length) as average_length
from category join film_category on category.category_id = film_category.category_id
join film on film.film_id = film_category.film_id
group by category.name
order by category.name;


-- Problem 2: Which categories have the longest and shortest average film lengths?
With cat_avg as  (
select category.name as category, avg(film.length) as average_length
from category join film_category on category.category_id = film_category.category_id
join film on film.film_id = film_category.film_id
group by category.name
order by category.name
),
Max_l as (                                 -- aggregates the max length for each category
select max(average_length) as highest_legnth
from cat_avg
),
Min_l as (                                 -- aggregates the min length for each category 
select min(average_length) as lowest_length
from cat_avg
)
select ca.category, ca.average_length
from cat_avg ca
join Max_l ml on ca.average_length = ml.highest_legnth 
union
select ca.category, ca.average_length
from cat_avg ca
join Min_l minl on ca.average_length = minl.lowest_length;


-- Problem 3: Which customers have rented action but not comedy or classic movies?
select customer.first_name, customer.last_name, customer.customer_id                          -- customers who rented a action movie 
from customer join rental on customer.customer_id = rental.customer_id
            join inventory on rental.inventory_id = inventory.inventory_id
            join film on inventory.film_id = film.film_id
            join film_category on film_category.film_id = film.film_id
            join category on film_category.category_id = category.category_id
where category.name = 'Action'
except
select distinct customer.first_name, customer.last_name, customer.customer_id                           -- cusomters who rented a comedy or classic movue 
from customer join rental on customer.customer_id = rental.customer_id
            join inventory on rental.inventory_id = inventory.inventory_id
            join film on inventory.film_id = film.film_id
            join film_category on film_category.film_id = film.film_id
            join category on film_category.category_id = category.category_id
where category.name = 'Comedy' or category.name = 'Classics';

 
-- Problem 4 Which actor has appeared in the most English-language movies?
select actor.actor_id, first_name, actor.last_name, count(film.film_id) as number_of_English_films
from actor join film_actor on actor.actor_id = film_actor.actor_id
            join film on film_actor.film_id = film.film_id
            join language on film.language_id = language.language_id
where language.name = 'English'
group by actor.actor_id, actor.first_name, actor.last_name
order by count(film.film_id) desc
limit 1;


-- Problem 5: How many distinct movies were rented for exactly 10 days from the store where Mike works?
select distinct count(film.title) number_of_films_rented_for_10_days_where_Mike_works
from film join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join staff on rental.staff_id = staff.staff_id
join store on store.store_id = staff.store_id
where DATEDIFF(rental.return_date,rental.rental_date) = 10 and staff.first_name = 'Mike' and staff.last_name = 'Hillyer'
group by store.store_id;


-- Problem 6: Alphabetically list actors who appeared in the movie with the largest cast of actors.
With film_and_highest_cast as  (
select film.title as movie_with_largest_cast, count(film_actor.actor_id) as number_of_actors
from actor join film_actor on actor.actor_id = film_actor.actor_id
            join film on film_actor.film_id = film.film_id
group by movie_with_largest_cast
having count(film_actor.actor_id) >= all (
	select count(film_actor.actor_id) 
	from actor join film_actor on actor.actor_id = film_actor.actor_id
    join film on film_actor.film_id = film.film_id 
    group by film.title
)
),
actors_in_film as (
select film.title as title, actor.first_name as first_name, actor.last_name as last_name, actor.actor_id
from actor join film_actor on actor.actor_id = film_actor.actor_id
join film on film_actor.film_id = film.film_id 
group by film.title, actor.first_name, actor.last_name, actor.actor_id
)
select fc.movie_with_largest_cast, ac.first_name, ac.last_name, ac.actor_id
from film_and_highest_cast fc join actors_in_film ac on fc.movie_with_largest_cast = ac.title
order by ac.first_name;










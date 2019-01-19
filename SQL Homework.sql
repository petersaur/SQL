-- Use Database and Select
USE sakila;
select * from actor limit 10;

-- 1a. Display the first and last names of all actors from the table `actor`. 
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
select CONCAT(first_name," ",last_name) as "Actor Name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT
	actor_id,
    first_name,
    last_name
FROM
	actor
WHERE
	first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT
	actor_id,
    first_name,
    last_name
FROM
	actor
WHERE
	last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT
	actor_id,
    first_name,
    last_name
FROM
	actor
WHERE
	last_name like '%LI%'
ORDER BY
	last_name,
    first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT
	country_id,
    country
FROM
	country
WHERE
	country in ('Afghanistan','Bangladesh','China');
	
-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `middle_name` VARCHAR(45) NULL AFTER `first_name`;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE `sakila`.`actor` 
CHANGE COLUMN `middle_name` `middle_name` BLOB NULL DEFAULT NULL ;

-- 3c. Now delete the `middle_name` column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `middle_name`;

-- 4a. List the last names of actors, as well as how many actors have that last name. 
SELECT
	last_name as 'last name',
    count(1) as 'same name'
    
FROM
	actor
GROUP BY
	last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT
	last_name,
    count(1)
FROM
	actor
GROUP BY
	last_name
HAVING 
	count(1)>1; 
    
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
-- the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
UPDATE actor
set first_name='HARPO', last_name='WILLIAMS'
where first_name='GROUCHO' and last_name='WILLIAMS';


-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
select * from actor where first_name='HARPO' and last_name='WILLIAMS';

UPDATE actor 
SET first_name = CASE
    WHEN first_name='HARPO' THEN 'GROUCHO'
    ELSE 'MUCHO GROUCHO'
    END
WHERE actor_id=172;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE address_name(
address_id smallint(5) unsigned,
address varchar(50),
address2 varchar(50),
district varchar(20),
city_id smallint(5) unsigned,
postal_code varchar(10),
phone varchar(20),
location geometry,
last_update timestamp);

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT
	s.first_name,
    s.last_name,
    ad.address
FROM
	staff s
INNER JOIN
	address ad ON s.address_id=ad.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT
	s.first_name,
    s.last_name,
    sum(p.amount) as total_amount
FROM
	staff s
INNER JOIN
	payment p ON s.staff_id=p.staff_id
GROUP BY
	s.first_name,
    s.last_name;
    
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select * from payment limit 10;
SELECT
	f.title,
    count(distinct fa.actor_id) as actors
FROM
	film f
INNER JOIN
	film_actor fa ON f.film_id=fa.film_id
GROUP BY f.title;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT
	f.title,
    count(*) as inventory
FROM
	film f
INNER JOIN
	inventory i ON f.film_id=i.film_id
GROUP BY
	f.title;
    
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT
	cus.first_name as 'first name',
    cus.last_name as 'last name',
    sum(pay.amount) as 'total amount paid'
FROM
	customer cus
INNER JOIN
	payment pay ON cus.customer_id=pay.customer_id
GROUP BY
	cus.customer_id
ORDER BY
	cus.last_name;
    
	
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT
	f.title
FROM(
    SELECT *
    FROM film
    WHERE language_id=1
    AND (LEFT(title,1)='K' OR LEFT(title,1)='Q')) f;
    
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT * from film_actor;   
SELECT
	fa.actor_id as 'actor id'
FROM(
    SELECT film_id
    FROM film
    WHERE title='ALONE TRIP') f
INNER JOIN
		film_actor fa ON f.film_id=fa.film_id ;  
   
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select * from customer;
select * from address;
SELECT
	cus.first_name,
    cus.last_name,
    cus.email
FROM
	customer cus
INNER JOIN
	address a on cus.address_id=a.address_id
INNER JOIN
	city c ON a.city_id=c.city_id
INNER JOIN
	country co ON c.country; 
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
select title 
from film f
join (
		select film_id 
        from film_category fc 
        join category c using(category_id) 
        where c.name = 'Family'
		) fc using(film_id);

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(*) as 'rental number'
from film f
join inventory i using(film_id)
join rental r using(inventory_id)
group by f.title
order by 2 desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as 'total spend' 
from store s
join inventory i using(store_id)
join rental r using(inventory_id)
join payment p using(rental_id)
group by s.store_id
order by 2 desc;

-- 7g. Write a query to display for each store its store ID, city, and country.
select 
s.store_id, 
c.city, co.country
from store s
join address a using(address_id)
join city c using(city_id)
join country co using(country_id);
    
-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from film f 
join film_category fc using(film_id)
join category cat using(category_id)
join inventory i using(film_id)
join rental r using(inventory_id)
join payment p using(rental_id)
limit 10;

select 
cat.name as genre,
sum(p.amount) as 'gross revenue'
from film f
join film_category fc using(film_id)
join category cat using(category_id)
join inventory i using(film_id)
join rental r using(inventory_id)
join payment p using(rental_id)
group by cat.name
order by 2 desc;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres as
select 
cat.name as genre,
sum(p.amount) as 'revenue'
from film f
join film_category fc using(film_id)
join category cat using(category_id)
join inventory i using(film_id)
join rental r using(inventory_id)
join payment p using(rental_id)
group by cat.name
order by 2 desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres

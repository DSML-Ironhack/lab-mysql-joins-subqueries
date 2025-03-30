USE sakila;

-- Q1 How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(inventory.inventory_id) AS nr_copies
FROM film 
JOIN inventory ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible";

-- Q2 List all films whose length is longer than the average of all the films.

SELECT AVG(length) as AVG from film;

SELECT film_id, title, length
FROM film
WHERE length > (SELECT AVG(length) AS average from film);

-- Q3 Use subqueries to display all actors who appear in the film Alone Trip.
SELECT film.title, actor.actor_id, actor.first_name, actor.last_name 
FROM film_actor
JOIN film ON film_actor.film_id = film.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film.title = "Alone Trip";

-- Q4 Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select * from category;
SELECT film.film_id, film.title, category.name
FROM film_category
JOIN film ON film_category.film_id = film.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = "Family";

-- Q5 Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id in (SELECT address_id FROM address WHERE city_id IN
						(SELECT city_id FROM city WHERE country_id IN
							(SELECT country_id FROM country WHERE country = "Canada")));

-- Q6 Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
CREATE TEMPORARY TABLE prolific_actor
SELECT actor.actor_id, actor.first_name, actor.last_name, COUNT(film_actor.film_id) AS nr_movies
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY nr_movies DESC
LIMIT 1; -- Gina Degeneres ID 107

SELECT film.title 
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
WHERE film_actor.actor_id = 107;

-- Q7 Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
CREATE TEMPORARY TABLE most_profitable_customer
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount) AS total_amount_spent
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total_amount_spent DESC
LIMIT 1; -- Karl Seal ID 526

SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM inventory WHERE inventory_id in
					(SELECT inventory_id FROM rental WHERE customer_id = 526));

-- Q8 Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
CREATE TEMPORARY TABLE spendings_by_customers
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount) AS total_amount_spent
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name;

SELECT customer_id, total_amount_spent
FROM 
(SELECT customer.customer_id, SUM(payment.amount) AS total_amount_spent
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id) AS spending_per_customer
WHERE total_amount_spent > 
(SELECT AVG (total_amount_spent) FROM (SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id) AS AVG_spending);







USE sakila;

-- Ejercicio 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.

SELECT DISTINCT title
FROM film_text;


-- Ejercicio 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".

SELECT title
FROM film
WHERE rating = 'PG-13';


-- Ejercicio 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.

SELECT title, description
FROM film_text
WHERE description LIKE '%amazing%';


-- Ejercicio 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.

SELECT title
FROM film
WHERE length > 120;


-- Ejercicio 5. Recupera los nombres de todos los actores.

SELECT DISTINCT CONCAT(first_name, ' ', last_name) AS name
FROM actor;

-- Susan Davis está duplicada. Tiene asignado el actor_id 101 y 110
SELECT actor_id, CONCAT(first_name, ' ', last_name) AS actor_name -- Obtenemos nombre y id de los actores duplicados
FROM actor 
WHERE CONCAT(first_name, ' ', last_name) = (
	SELECT name   -- Seleccionamos los nombres duplicados
	FROM (
		SELECT name, COUNT(*)   -- Obtenemos los nombres duplicados en la tabla
		FROM (
			SELECT CONCAT(first_name, ' ', last_name) AS name   -- Obtenemos el nombre completo de los actores
			FROM actor) AS full_name
		GROUP BY name
		HAVING COUNT(*) > 1) AS duplicated_name
);


-- Ejercicio 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.

SELECT last_name, first_name
FROM actor
WHERE last_name = 'Gibson';


-- Ejercicio 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.

SELECT CONCAT(first_name, ' ', last_name) AS fullName
FROM actor
WHERE actor_id BETWEEN 10 AND 20;


-- Ejercicio 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.

SELECT title
FROM film
WHERE rating NOT IN ('R', 'PG-13');


-- Ejercicio 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.

SELECT rating, COUNT(*) AS films_per_rating
FROM film
GROUP BY rating;


/* 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la 
cantidad de películas alquiladas.*/

-- Primera opción
SELECT customer_id, first_name, last_name, rentals_per_customer
FROM customer
INNER JOIN (
	SELECT customer_id, COUNT(*) AS rentals_per_customer -- Obtengo una tabla con el numero de películas alquiladas por cada cliente
	FROM rental
	GROUP BY customer_id
) AS count
USING (customer_id);
-- Es la consulta más rápida, más fácil de leer y es modular por lo que permite la reutilización y facilita el mantenimiento.

-- Seguda opción
SELECT customer_id, first_name, last_name, COUNT(*) AS rentals_per_customer
FROM customer
INNER JOIN rental
USING (customer_id)
GROUP BY customer_id, first_name, last_name;
-- Es una consulta más compacta. Es directa y fácil de escribir. Los elementos en GROUP By son repetitivos


-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.

-- Opción 1:
SELECT name, rentals_per_category
FROM category
INNER JOIN (
	SELECT category_id, COUNT(*) rentals_per_category -- Obtenemos una tabla con el número de alquileres por categoría
	FROM rental
		INNER JOIN inventory
	USING (inventory_id)   
		INNER JOIN film_category
	USING (film_id)  
	GROUP BY category_id) AS rentalsPCategory
USING (category_id);  
-- Es la consulta más rápida, más fácil de mantener

-- Opción 2:
SELECT name, COUNT(*) rentals_per_category
FROM rental
	INNER JOIN inventory
USING (inventory_id)   
	INNER JOIN film_category
USING (film_id)
	INNER JOIN category
USING (category_id)    
GROUP BY name;
-- Consulta más lenta pero más fácil de escribir

  
/*  12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el 
promedio de duración.*/

SELECT rating, ROUND(AVG(length)) avg_length_per_rating
FROM film
GROUP BY rating;


-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

SELECT DISTINCT first_name, last_name
FROM actor
	INNER JOIN film_actor
USING (actor_id)
	INNER JOIN film_text
USING (film_id)
WHERE title = 'Indian Love';


-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.

SELECT title
FROM film_text
WHERE title LIKE '%dog%' OR title LIKE '%cat%';


-- 15. Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor.

SELECT DISTINCT last_name, first_name
FROM actor
WHERE actor_id NOT IN (
	SELECT actor_id  -- Obtenemos todos los actor_id de actores que han actuado en películas
    FROM film_actor
);


-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.

SELECT title, release_year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;


-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".

-- Título de las películas de la categoría 'Family'
SELECT title
FROM category
	INNER JOIN film_category
USING (category_id)    
	INNER JOIN film_text
USING (film_id)    
WHERE name = 'Family';
    
    
-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.

-- Primera opción
SELECT DISTINCT first_name, last_name
FROM actor
INNER JOIN (
	SELECT actor_id, COUNT(*) AS number_of_films -- Actores que han participado en más de 10 películas
	FROM film_actor
	GROUP BY actor_id
	HAVING number_of_films >10
) AS films_per_actor
USING (actor_id);
-- Consulta más rápida, más fácil de mantener, más fácil de entender

-- Segunda opción
SELECT DISTINCT first_name, last_name
FROM (
	SELECT DISTINCT first_name, last_name, COUNT(*) AS number_of_films -- Tabla actores y número de películas cuando los actores han actuado en más de 10 películas
	FROM actor
	INNER JOIN film_actor
	USING (actor_id)
	GROUP BY actor_id, first_name, last_name
	HAVING number_of_films > 10) AS actor_number_of_films;
-- Consulta que se escribe más rápido pero es más lenta en ejecución, es repetitiva y no modular por lo que es más difícil de mantener, es
-- más difícil de mantener;


-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.

SELECT title
FROM film
WHERE rating = 'R' AND length > 120;


/* 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría 
junto con el promedio de duración.*/

-- Primera opción:
SELECT name AS category_name, ROUND(AVG(length)) AS avg_length
FROM film_category
	INNER JOIN category
USING (category_id)
	INNER JOIN film
USING (film_id)
GROUP BY name
HAVING avg_length > 120;    


-- Segunda opción:
SELECT name AS category_name, avg_length
FROM category
INNER JOIN (
	SELECT ROUND(AVG(length)) AS avg_length, category_id -- Películas por categpría con duración media > 120 minutos
	FROM film
	INNER JOIN film_category
	USING (film_id)
	GROUP BY category_id
	HAVING avg_length > 120) AS a
USING (category_id);


/* 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las 
que han actuado.*/

SELECT CONCAT(first_name, ' ', last_name) AS name , number_of_films
FROM actor
INNER JOIN (
	SELECT actor_id, COUNT(*) AS number_of_films -- Número de películas en que ha actuado cada actor
	FROM film_actor
	GROUP BY actor_id
	HAVING number_of_films >= 5) AS act_num_film 
USING (actor_id);
-- SUSAN DAVIS aparece 2 veces. Una con 33 películas y otra con 22


/* 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids 
con una duración superior a 5 días y luego selecciona las películas correspondientes.*/

SELECT DISTINCT title 
FROM inventory
	INNER JOIN film_text
USING (film_id)
	INNER JOIN rental
USING (inventory_id)
WHERE rental_id IN(
	SELECT rental_id  -- Obtenemos los rental_id de las películas que han estado alquiladas durante más de 5 días
	FROM rental
	WHERE DATEDIFF (return_date, rental_date) > 5);
   

/* 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta 
para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.*/

SELECT last_name, first_name
FROM actor
WHERE actor_id NOT IN (
	SELECT actor_id -- Obtenemos el actor_id para los actores que han participado en películas de terror
	FROM film_actor
		INNER JOIN film_category
	USING (film_id)
		INNER JOIN category
	USING (category_id) 
	WHERE name ='Horror'   
	GROUP BY actor_id);


/* 24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.*/
   
SELECT title 
FROM film
WHERE film_id IN(
	SELECT film_id -- Obtenemos el film_id de las películas de comedia
	FROM film_category
	WHERE category_id = ( 
		SELECT category_id -- Averiguamos el category_id que corresponde a comedia
		FROM category
		WHERE name = 'Comedy'))
AND  length > 180;  

 
/* 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. La consulta debe mostrar el nombre y apellido 
 de los actores y el número de películas en las que han actuado juntos.*/
 
SELECT b.full_name, actor_id_name2.full_name2, b.number_of_films_together -- Incluimos el nombre de los actores correspondientes al actor_id2 o segundo actor de la pareja
FROM (
	SELECT actor_id, CONCAT(first_name, ' ', last_name) AS full_name2 -- Obtenemos el nombre completo de los actores
	FROM actor) AS actor_id_name2
INNER JOIN ( 
	-- Incluimos el nombre de los actores correspondientes al actor_id1 o primer actor de la pareja
	SELECT couples_number_of_films.actor_id1, actor_id_name.full_name , couples_number_of_films.actor_id2, couples_number_of_films.number_of_films_together
	FROM (
		SELECT actor_id, CONCAT(first_name, ' ', last_name) AS full_name -- Obtenemos el nombre completo de los actores
		FROM actor) AS actor_id_name
	INNER JOIN (
		SELECT a.actor_id1, a.actor_id2, COUNT(*) AS number_of_films_together -- Contamos el númrero de películas por pareja de actores
		FROM (
			SELECT fa1.actor_id AS actor_id1, fa2.actor_id AS actor_id2, fa1.film_id -- Actores que han actuado juntas y el número de películas que han hecho juntos
			FROM film_actor AS fa1, film_actor AS fa2
			WHERE fa1.film_id = fa2.film_id AND fa1.actor_id <> fa2.actor_id
		) AS a
		GROUP BY a.actor_id1, a.actor_id2) AS couples_number_of_films
	ON couples_number_of_films.actor_id1 = actor_id_name.actor_id) AS b
ON actor_id_name2.actor_id = b.actor_id2;
-- Los resultados están todos duplicados: La pareja PENELOPE GUINESS, CHRISTIAN GABLE aparece también como CHRISTIAN GABLE, PENELOPE GUINESS y así con todas


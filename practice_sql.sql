create table movies (
  movie_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT UNIQUE NOT NULL, 
  released INTEGER NOT NULL CHECK (released > 0),
  overview TEXT NOT NULL CHECK (LENGTH(overview) < 30), 
  rating REAL NOT NULL CHECK (rating BETWEEN 0 AND 10),
  director TEXT,
  for_kids INTEGER NOT NULL DEFAULT 0 CHECK (for_kids = 0 OR for_kids = 1 OR for_kids > -1 OR for_kids < 2 OR for_kids BETWEEN 0 AND 1) -- 0 or 1
  -- poster BLOB
  ) STRICT;
  
DROP TABLE movies;

INSERT INTO movies VALUES (
  2,
  'The Godfather', 
  1980,
  'The best movie in the world', 
  10, 
  'F.F.C',
  1
  ),
  (
   3,
  '1984', 
  1983,
  'super good', 
  10, 
  'dont know',
    1
);
    
INSERT INTO movies (title, rating, released, overview) VALUES ('The Lord of The Rings', 0.5, 1999, 'Rings and hobbits'), ('Dune: Part One', 10, 1, 'Sand');

-- UPDATE
UPDATE movies SET director = 'Unknown' WHERE director IS NULL AND rating = 10;

-- DELETE
DELETE FROM movies WHERE movie_id = 2;

SELECT 1+1, 2+2, UPPER('hello');
SELECT title, rating FROM movies;
SELECT 
	REPLACE (
    title, ': Part One', ' I') AS title,
    rating * 2  AS double_rating,
    UPPER(overview) AS overview_upp
  FROM
  	movies;

SELECT * FROM movies WHERE director = 'Guy Ritchie' AND original_language <> 'en'; -- <>은 !=와 같음
SELECt * FROM movies WHERE rating > 9 OR (rating IS NULL AND genres = 'Documentary');
SELECT * FROM movies WHERE release_date BETWEEN 2020 AND 2024;
SELECT * FROM movies WHERE genres IN ('Documentary', 'Comedy');
SELECT * FROM movies WHERE original_language NOT IN ('en', 'es', 'de');
SELECT * FROM movies WHERE title LIKE 'The%';
SELECT * FROM movies WHERE title LIKE '___ing';
SELECT
	title,
  CASE WHEN rating >= 8 THEN
  	'👍🏻'
  WHEN rating <= 6 THEN
  	'👎🏻'
  ELSE
  	'👀'
  END AS good_or_not
FROM
	movies;
SELECT * FROM movies WHERE director = 'Darren Aronofsky' ORDER BY release_date, revenue DESC;
SELECT * FROM movies LIMIT 5 OFFSET 1 * 5;
SELECT director, SUM(revenue) AS total_revenue FROM movies WHERE director IS NOT NULL AND revenue IS NOT NULL GROUP BY director ORDER BY total_revenue DESC;
SELECT release_date, ROUND(AVG(rating), 2) AS avg_rating FROM movies WHERE rating IS NOT NULL AND release_date IS NOT NULL GROUP BY release_date ORDER BY avg_rating DESC;
SELECT release_date, rating AS avg_rating FROM movies WHERE rating IS NOT NULL AND release_date IS NOT NULL ORDER BY avg_rating DESC;
SELECT release_date, round(AVG(rating), 2) AS avg_rating FROM movies WHERE rating IS NOT NULL AND release_date IS NOT NULL GROUP BY release_date HAVING avg_rating > 6 ORDER BY avg_rating DESC;

-- What is the average rating of each director*?
SELECT director, AVG(rating) AS avg_rating FROM movies WHERE director IS NOT NULL AND rating IS NOT NULL GROUP BY director ORDER BY avg_rating DESC; 

-- * that has more than 5 movies
SELECT 
	director, 
  AVG(rating) AS avg_rating
  -- COUNT(*) AS total_movies
FROM 
	movies 
WHERE 
	director IS NOT NULL AND rating IS NOT NULL 
GROUP BY 
	director 
HAVING
	-- total_movies > 5
  COUNT(*) > 5
ORDER BY 
	avg_rating DESC;
  -- total_movies DESC;
  
-- How many movies are in each genre?
SELECT genres, COUNT(*) as total_movies FROM movies WHERE genres IS NOT NULL GROUP BY genres ORDER BY total_movies DESC;

-- How many movies have a rating greater than 6? What is the rating the most common?
SELECT rating, COUNT(*) AS total_movies FROM movies WHERE rating > 6 GROUP BY rating ORDER BY total_movies DESC;

-- 1. Find the number of movies released each year.
SELECT release_date, COUNT(*) AS total_movies FROM movies WHERE release_date IS NOT NULL GROUP BY release_date ORDER BY total_movies DESC;

-- 2. List the top 10 years with the highest average movie runtime
SELECT release_date, AVG(runtime) AS total_runtime FROM movies GROUP BY release_date ORDER BY total_runtime DESC LIMIT 10;

-- 3. Calculate the average rating for movies released in the 21st century
SELECT AVG(rating) AS average_rating FROM movies WHERE release_date >= 2000;

-- 4. Find the director with the hightest average movie runtime.
SELECT director, AVG(runtime) AS average_runtime, COUNT(*) as total_movies FROM movies WHERE director IS NOT NULL AND runtime IS NOT NULL GROUP BY director ORDER BY average_runtime DESC LIMIT 1;

-- 5. List the top 5 most prolific directors (thoes who have directed the most movies).
SELECT director, COUNT(*) AS the_number_of_movies FROM movies WHERE director IS NOT NULL GROUP BY director ORDER BY the_number_of_movies DESC LIMIT 5;

-- 6. Find the highest and lowest rating of each director.
SELECT director, MIN(rating) AS lowest_rating, MAX(rating) AS highest_rating FROM movies WHERE director is NOT NULL AND rating IS NOT NULL GROUP BY director HAVING COUNT(*) > 5;

-- 7. Find the director that has made the most money (revenue - budget)
SELECT director, SUM(revenue) - SUM(budget) AS money FROM movies WHERE director IS NOT NULL AND revenue IS NOT NULL AND budget IS NOT NULL GROUP BY director ORDER BY money DESC LIMIT 5;

-- 8. Calculate the average rating for movies longer than 2 hours.
SELECT AVG(rating) AS average_rating FROM movies WHERE rating IS NOT NULL AND runtime > 120 ORDER BY average_rating DESC;

-- 9. Find the year with the most movies released.
SELECT release_date, COUNT(*) AS total_movies FROM movies WHERE release_date IS NOT NULL GROUP BY release_date ORDER BY total_movies DESC;

-- 10. Find the average runtime of movies for each decade.
SELECT (release_date / 10) * 10 AS decade, count(*) AS total_movies FROM movies WHERE release_date IS NOT NULL GROUP BY decade ORDER BY total_movies;

-- 11. List the top 5 years where the difference between the highest and lowest rated movie was the greatest.
SELECT release_date, MAX(rating) - MIN(rating) AS difference FROM movies WHERE rating IS NOT NULL AND release_date IS NOT NULL GROUP BY release_date ORDER BY difference DESC LIMIT 5;

-- 12. List directors who have never made a movie shorter than 2 hours.
SELECT director, MIN(runtime) AS min_runtime FROM movies WHERE director IS NOT NULL GROUP BY director HAVING MIN(runtime) >= 120;

-- 13. Calculate the percentage of movies with a rating above 8.0
SELECT COUNT(CASE WHEN rating > 8 THEN 1 END) * 100.0 / COUNT(*) AS percentage FROM movies;

-- 14. Find the director with the highest ratio of movies rated above 7.0
SELECT director, COUNT(CASE WHEN rating > 7.0 THEN 1.0 END) * 100.0 / COUNT(*) AS '%' FROM movies WHERE director IS NOT NULL GROUP BY director HAVING COUNT(*) >= 2;

-- 15. Categorize and group movies by length.
SELECT CASE WHEN runtime < 90 THEN 'Short' WHEN runtime BETWEEN 90 AND 120 THEN 'Normal' WHEN runtime > 120 THEN 'Long' END AS runtime_category, COUNT(*) AS total_movies FROM movies GROUP BY runtime_category;

-- 16. Categorize and group movies by flop or not.
SELECT CASE WHEN revenue < budget THEN 'Flop' ELSE 'Success' END AS flop_or_not, COUNT(*) AS total_movies FROM movies WHERE budget IS NOT NULL AND revenue IS NOT NULL GROUP BY flop_or_not;

CREATE VIEW v_flop_or_not AS SELECT CASE WHEN revenue < budget THEN 'Flop' ELSE 'Success' END AS flop_or_not, COUNT(*) AS total_movies FROM movies WHERE budget IS NOT NULL AND revenue IS NOT NULL GROUP BY flop_or_not;SELECT CASE WHEN revenue < budget THEN 'Flop' ELSE 'Success' END AS flop_or_not, COUNT(*) AS total_movies FROM movies WHERE budget IS NOT NULL AND revenue IS NOT NULL GROUP BY flop_or_not;

SELECT * FROM v_flop_or_not;

DROP VIEW v_flop_or_not;

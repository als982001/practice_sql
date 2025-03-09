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
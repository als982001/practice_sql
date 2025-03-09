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
    
INSERT INTO movies (title, rating, released, overview) VALUES ('TLOTR III', 10, 1999, 'abcde');
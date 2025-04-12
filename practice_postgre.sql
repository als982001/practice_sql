CREATE TYPE gender_type AS ENUM ('male', 'female');

CREATE TABLE users (
  username CHAR(10) NOT NULL UNIQUE, -- 남은 자리는 전부 공백으로 채워짐
  email VARCHAR(50) NOT NULL UNIQUE,
  gender gender_type NOT NULL,
  
  -- TEXT 최대 크기: 1GB
  --> TOAST: 2KB (the oversized-attribute storage technique)
  interests TEXT[] NOT NULL,
  bio TEXT,
  profile_photo BYTEA,
  
  -- SMALLINT Signed: -32,768 to 32.767 
  -- INTEGER Signed: -2,147,483,648 to 2,147,483,647 
  -- BIGINT Signed: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
  age SMALLINT NOT NULL CHECK (age >= 0), -- Unsigned가 없어서 이렇게 
  
  -- Serial: 1부터 시작, Auto-increment
  -- SMALLSERIAL: 1 to 32767
  -- SERIAL: 1 to 2147483647
  -- BIGSERIAL: 1 to 9223372036854775807
  
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- TIMESTAMP: 4713 BC to 294276 AD
  joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL, -- "TIMESTAMP WITH TIME ZONE"를 줄여쓴 것
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  birth_date DATE NOT NULL,
  bed_time TIME NOT NULL,
  graduation_year INTEGER NOT NULL CHECK (graduation_year BETWEEN 1901 AND 2115),
  internship_period INTERVAL 
);  

DROP TABLE users;
 
INSERT INTO users (
  username,
  email,
  gender,
  interests,
  bio,
  age,
  is_admin,
  birth_date,
  bed_time,
  graduation_year,
  internship_period
) VALUES (
  'james',
  'james@email.com',
  'male',
  ARRAY['tech', 'music', 'travel'],
  'i like eating and traveling',
  18, 
  TRUE,
  '1990-01-01',
  '21:00:00',
  1993,
  INTERVAL '6 months'
);
  
-- ::타입 -> 해당 타입으로 변환  
SELECT joined_at::DATE FROM users;  

-- AGE: 입력한 DATE로부터 시간이 얼마나 지났는지 알려주는 함수
-- JUSTIFY_INTERVAL: 입력된 값을 년, 월, 일, 시간으로 변환
SELECT 
	joined_at::DATE AS joined_date,
  EXTRACT(YEAR FROM joined_at) AS joined_year,
  joined_at - INTERVAL '1 day' AS day_before_joining,
  AGE(birth_date) AS age,
  JUSTIFY_INTERVAL(INTERVAL '38493 hours')
FROM users;

-- 아래는 movies 정규화

CREATE TABLE genres (
  genre_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(50) UNIQUE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- STRING_TO_ARRAY: 문자열을 지정한 기준으로 나눠서 배열로 만들어주는 함수
-- UNNEST: 
-- SELECT DISTINCT: 중복값 제거
INSERT INTO genres (name)
SELECT DISTINCT UNNEST(STRING_TO_ARRAY(genres, ',')) FROM movies GROUP BY genres;

CREATE TABLE movies_genres (
  movie_id BIGINT NOT NULL,
  genre_id BIGINT NOT NULL,
  PRIMARY KEY (movie_id, genre_id),
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY (movie_id) REFERENCES movies (movie_id),
  FOREIGN KEY (genre_id) REFERENCES genres (genre_id)
);

SELECT * FROM genres;

INSERT INTO movies_genres (movie_id, genre_id)
SELECT 
  movies.movie_id,
  genres.genre_id
FROM movies
	JOIN genres ON movies.genres LIKE '%' || genres.name || '%';

ALTER TABLE movies DROP COLUMN genres;



















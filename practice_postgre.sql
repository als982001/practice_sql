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

-- Function, Procedure 연습

CREATE OR REPLACE FUNCTION hello_world()
RETURNS TEXT AS 
$$
	SELECT 'hello_world';
$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION hello_world(user_name TEXT)
RETURNS TEXT AS 
$$
	SELECT 'hello ' || user_name;
$$
LANGUAGE SQL;

-- 2개의 TEXT를 입력으로 받음
-- parameter에 이름이 없기 때문에 위치로 나타낼 수 있음
CREATE OR REPLACE FUNCTION hello_world(TEXT, TEXT)
RETURNS TEXT AS 
$$
	SELECT 'hello ' || $1 || ' and ' || $2;
$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION hello_world_user(user_name TEXT)
RETURNS TEXT AS 
$$
	SELECT 'hello ' || user_name;
$$
LANGUAGE SQL;

SELECT hello_world();
SELECT hello_world_user('nico') FROM movies;

-- PostgreSQL은 function의 이름과 입력값, 출력값을 모두 보기 때문에 전부 다 다른게 실행됨.
SELECT hello_world() FROM movies;
SELECT hello_world('nico') FROM movies;
SELECT hello_world('nico', 'james') FROM movies;

CREATE OR REPLACE FUNCTION is_hit_or_flop(movie movies)
RETURNS TEXT AS
$$
	SELECT CASE
  	WHEN movie.revenue > movie.budget THEN 'Hit'
    WHEN movie.revenue < movie.budget THEN 'Flop'
    ELSE 'N/A'
  END
$$
LANGUAGE SQL;

DROP FUNCTION is_hit_or_flop(movies);

/*
-- 함수 기본 설정: VOLATILE -> LANGUAGE SQL VOLATILE;
-- volatile function은 같은 인자를 넣어도 다른 결과를 return할 수 있음
-- stable function: database를 수정할 수 없는 function. 단일 구문 내의 모든 row에 동일한 argument에 대해서 같은 결과를 return한다.
-- immutable function: database 수정이 불가능하고 동일한 argument가 주어질 경우 영원히 같은 결과를 return 한다.
*/

CREATE OR REPLACE FUNCTION is_hit_or_flop(movie movies)
RETURNS TABLE (hit_or_flop TEXT, other_thing NUMERIC) AS
$$
	SELECT CASE
  	WHEN movie.revenue > movie.budget THEN 'Hit'
    WHEN movie.revenue < movie.budget THEN 'Flop'
    ELSE 'N/A'
  END, 11111;
$$
LANGUAGE SQL IMMUTABLE;

SELECT 
	title, 
  (is_hit_or_flop(movies.*)).*
FROM movies;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS
$$
	BEGIN
  	NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
  END
$$
LANGUAGE PLPGSQL; -- plpgsql: PostgreSQL이 지원하는 언어로, Procedual Language PostgreSQL을 의미함.

CREATE TRIGGER updated_at
BEFORE UPDATE
ON movies
FOR EACH ROW EXECUTE PROCEDURE set_updated_at();


-- function은 무엇인가를 return하도록 되어 있다. procedure은 return할 필요가 없다.
-- function은 DML command 안에서 호출된다. procedure은 DML command에서 호출되지 않고, CALL 뒤에 procedure의 이름을 붙여서 호출함

CREATE PROCEDURE set_zero_revenue() AS
$$
	UPDATE movies SET revenue = NULL WHERE revenue = 0;
$$
LANGUAGE SQL;

CALL set_zero_revenue();

-- 입력값, 출력값 같으면 INOUT 이용 가능
CREATE PROCEDURE hello_world_p(IN name TEXT, OUT greeting TEXT) AS
$$
	BEGIN
  	greeting = 'Hello ' || name;
  END;
$$
LANGUAGE PLPGSQL;
                                                           
CALL hello_world_p('nico', NULL);

CREATE EXTENSION plpython3u;

CREATE OR REPLACE FUNCTION hello_world_py(name TEXT)
RETURNS TEXT AS
$$
  return f'hello {name}'
$$
LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION log_updated_at_py()
RETURNS TRIGGER AS
$$
    import json, requests
    requests.post(
        'http://localhost:3000',
        data=json.dumps({'td': TD}),
        headers={'Content-Type': 'application/json'}
    )
    return NEW
$$
LANGUAGE plpython3u;

SELECT hello_world_py('nico');

CREATE TRIGGER updated_at_py
BEFORE UPDATE
ON movies
FOR EACH ROW EXECUTE PROCEDURE log_updated_at_py();

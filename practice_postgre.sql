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

CREATE TABLE accounts (
  account_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  account_holder VARCHAR(100) NOT NULL,
  balance DECIMAL(10, 2) NOT NULL CHECK (balance >= 0)
);

DROP TABLE accounts;

INSERT INTO accounts (account_holder, balance) VALUES
('nico', 1000.00),
('lynn', 2000.00);

SELECT * FROM accounts;

BEGIN; -- start transaction
  UPDATE 
    accounts 
  SET 
    balance = balance + 1500 
  WHERE account_holder =  'lynn';

  SAVEPOINT transfer_one;

  SELECT * FROM accounts;
  
  UPDATE 
    accounts 
  SET 
  	account_holder = 'rich'
  WHERE account_holder =  'lynn';
  
  ROLLBACK TO SAVEPOINT transfer_one;

  UPDATE 
    accounts 
  SET 
    balance = balance - 1500 
  WHERE account_holder = 'nico';

ROLLBACK;

COMMIT; -- end transaction



/*
ACID qualities (Atomic, Consistent, Isolated, Durable)

Atomicity: all or nothing
Consistency: valid state -> valid state
Isolation: 하나의 transaction에서 실행된 변경사항이 commit 되기 전까지는 다른 transaction에는 보이지 않는 것
Durability: 변경사항이 적용되면(transaction이 commited되면) 변경 사항이 그대로 유지되어야 함

auto commit mode: SELECT FROM, UPDATE, DELETE 등 모든 명령문이 그 자체로 하나의 작은 transaction으로 취급됨
*/

/*
Isolation Level: transaction 외부 데이터에 대한 가시성 수준을 제어하는 것
- read uncommitted: 한 transaction에서 일어난 변경 사항을 commit되기 전에도 다른 transaction에서 볼 수 있는 것
- read committed: commit 되기 전에 만들어진 변경사항은 다른 transaction에서 볼 수 없는 것
- repeatable read: 데이터 읽을 때 스냅샷
- serializable: 아래의 모든 현상을 방지함. 하나씩 차례대로 실행


- dirty read: transaction이 commit 되지 않은 transaction이 작성한 데이터를 읽는 것
- non-repeatable read: transaction이 데이터를 다시 읽으려고 할 때 발생
- phantom read: 행 집압을 반환하는 쿼리를 transaction 안에서 재실행할 때, 최근에 commit된 다른 transaction에 의해서 그 결과가 이전과 다르게 변경되는 것
- serialization anomaly: 여러 트랜잭션의 성공적인 커밋 결과가 가능한 모든 순서로 트랜잭션을 순차적으로 실행한 결과와 일치하지 않을 때 발생.
*/

/*
lock: 다른 transaction이 먼저 commit/rollback될 때까지 기다리는 거???
committed read에서는 에러 발생 안하고 transaction 실행 됨
repeatable read에서는 다른 transaction 완료되면 에러 발생, 이유: ???
*/

-- Shared Locks
BEGIN;
	SELECT
  	balance
  FROM
  	accounts
  WHERE
  	account_holder = 'lynn'
  FOR UPDATE;
COMMIT;

-- SELECT ... FOR UPDATE/SHARE: 이 코드가 실행되고 나면 commit할 때까지 아무도 해당 row를 건드릴 수 없다
	-- UPDATE: exclusive lock
  -- SHARE: 여러 개의 transaction에서 같은 row를 lock할 수 있음

CREATE ROLE marketer WITH login PASSWORD 'marketing4ever';

GRANT SELECT, UPDATE ON movies TO marketer;

GRANT SELECT, INSERT ON statuses, directors TO marketer;

GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO marketer; -- public schema에 있는 모든 테이블에 접근 가능하게 해줌 

REVOKE INSERT ON statuses, directors FROM marketer;

GRANT INSERT ON ALL TABLES IN SCHEMA PUBLIC TO marketer;

REVOKE INSERT ON ALL TABLES IN SCHEMA PUBLIC FROM marketer;

-- ///// 

CREATE ROLE editor;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA PUBLIC TO editor;

CREATE USER editor_one WITH PASSWORD 'words4ever';

GRANT editor TO editor_one;

REVOKE ALL ON movies FROM editor;

GRANT SELECT (title) ON movies TO editor;
GRANT UPDATE (budget) ON movies TO editor;

ALTER ROLE editor_one WITH CONNECTION LIMIT 1;


-- /// 

-- JSON 타입: 입력된 TEXT를 그대로 복사해서 저장
-- JSONB 타입: 분해된 Binary 형식으로 저장
CREATE TABLE users (
  user_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  profile JSONB
);

DROP TABLE users;

INSERT INTO users (profile) VALUES
('{"name": "Taco", "age": 30, "city": "Budapest"}'),
('{"name": "Giga", "age": 25, "city": "Tbilisi", "hobbies": ["reading", "climbing"]}');
  

-- JSON_BUILD_OBJECT: 객체로 만들어주는 함수
SELECT JSON_BUILD_OBJECT('name', 'Taco', 'age', 30, 'city', 'Budapest');
  
-- 찾기  
  
SELECT 
	profile ->> 'name' AS name, -- ->> 처럼 > 두 번 적으면 따옴표 없어짐
  profile -> 'city' AS city, 
  profile -> 'age' AS age,
  profile -> 'hobbies' -> 0 AS first_hobby -- 첫 번째 hobby
FROM 
	users;
  
SELECT 
	profile ->> 'name' AS name, -- ->> 처럼 > 두 번 적으면 ??
  profile -> 'city' AS city, 
  profile -> 'age' AS age,
  profile -> 'hobbies' -> 0 AS first_hobby -- 첫 번째 hobby
FROM 
	users
WHERE profile ? 'hobbies'; 
  
SELECT 
	profile ->> 'name' AS name, 
  profile -> 'city' AS city, 
  profile -> 'age' AS age,
  profile -> 'hobbies' -> 0 AS first_hobby -- 첫 번째 hobby
FROM 
	users
WHERE profile -> 'hobbies' ? 'climbing';  

SELECT 
	profile ->> 'name' AS name,
  profile -> 'city' AS city, 
 	JSONB_ARRAY_LENGTH(profile -> 'hobbies') AS total_hobbies
FROM 
	users;
  
SELECT 
	profile ->> 'name' AS name,
  profile -> 'city' AS city, 
 	JSONB_ARRAY_LENGTH(profile -> 'hobbies') AS total_hobbies
FROM 
	users
WHERE (profile ->> 'age')::INTEGER < 30; 
  
  
SELECT 
	profile ->> 'name' AS name,
  profile -> 'city' AS city, 
 	JSONB_ARRAY_LENGTH(profile -> 'hobbies') AS total_hobbies
FROM 
	users
WHERE profile -> 'hobbies' ?| ARRAY['reading', 'traveling'];
  
SELECT 
	profile ->> 'name' AS name,
  profile -> 'city' AS city, 
 	JSONB_ARRAY_LENGTH(profile -> 'hobbies') AS total_hobbies
FROM 
	users
WHERE profile ?| ARRAY['name', 'email'];
  
SELECT 
	profile ->> 'name' AS name,
  profile -> 'city' AS city, 
 	JSONB_ARRAY_LENGTH(profile -> 'hobbies') AS total_hobbies
FROM 
	users
WHERE profile ->> 'city' LIKE 'B%';
  
  
-- 수정
  
UPDATE users
SET profile = profile || JSONB_BUILD_OBJECT('email', 'x@x,com');

UPDATE 
	users
SET 
	profile = profile - 'email'
WHERE profile ->> 'name' = 'Giga';

UPDATE 
	users
SET 
	profile = profile || JSONB_BUILD_OBJECT('hobbies', JSONB_BUILD_ARRAY('climbing', 'traveling'))
WHERE profile ->> 'name' = 'Taco';

SELECT 
	(profile -> 'hobbies') - 'climbing'
FROM
	users;
  
UPDATE
	users
SET 
	profile = profile || JSONB_SET(
    profile, 
    '{hobbies}', 
    (profile -> 'hobbies') || JSONB_BUILD_ARRAY('cooking')
);

SELECT * FROM pg_available_extensions;

-- Extension 01: hstore
CREATE EXTENSION hstore;
DROP EXTENSION hstore;

DROP TABLE users;

CREATE TABLE users (
  user_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  prefs HSTORE
);

INSERT INTO users (prefs) VALUES
('theme => dark, lang => kr, notifications => off'),
('theme => light, lang => es, notifications => on, push_notifications => on, email_notifications => off'),
('theme => dark, lang => it, start_page => dashboard, font_size => large');

SELECT * FROM users;

SELECT 
	user_id,
  prefs -> 'theme',
  prefs -> ARRAY['lang', 'notifications'],
  prefs ? 'font_size' AS has_font_size, -- ?: 해당 key가 존재하는지
  prefs ?| ARRAY['push_notifications', 'start_page'], -- ?|: 배열에 있는 것들이 존재하는지
	AKEYS(prefs), -- akeys: 모든 key들
  AVALS(prefs), -- avals: 모든 value들
  EACH(prefs)
FROM users;

UPDATE 
	users
SET
	prefs['theme'] = 'light'
WHERE user_id = 1;

UPDATE 
	users
SET
	prefs = prefs || hstore(
  	ARRAY['currency', 'cookies_ok'],
    ARRAY['krw', 'yes']
  )
WHERE user_id = 1;

UPDATE 
	users
SET
	prefs = DELETE(prefs, 'cookies_ok')
WHERE user_id = 1;

-- Extension 02: PGCrypto
CREATE EXTENSION pgcrypto;
DROP TABLE users;
CREATE TABLE users (
  user_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  username VARCHAR(100), 
  password VARCHAR(100)
);

INSERT INTO users (username, password)
VALUES 
	('nico', CRYPT('user_password', GEN_SALT('bf'))),
	('testUser02', CRYPT(CRYPT('user_password', GEN_SALT('bf')), GEN_SALT('bf')));

SELECT 
	username 
FROM 
	users 
WHERE
	username = 'nico' 
	AND password = CRYPT('user_password', password);


-- Extension 01: uuid-ossp 
DROP TABLE users;

CREATE EXTENSION "uuid-ossp";

CREATE TABLE users (
	user_id UUID PRIMARY KEY DEFAULT(UUID_GENERATE_V4()),
  username VARCHAR(100), 
  password VARCHAR(100)
);

INSERT INTO users (username, password)
VALUES ('nico', '1234');

SELECT * FROM users;






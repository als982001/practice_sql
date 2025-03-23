CREATE TABLE users (
  user_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  username CHAR(10) NOT NULL UNIQUE, -- 10자 고정
  email VARCHAR(50) NOT NULL UNIQUE, -- 가변적
  gender ENUM('Male', 'Female') NOT NULL,
  interests SET(
    'Technology', 
    'Sports', 
    'Music', 
    'Art', 
    'Travel', 
    'Food', 
    'Fashion', 
    'Science'
  ) NOT NULL,
  bio TEXT NOT NULL, -- TINYTEXT, TEXT, MEDIUMTEXT, LONGTEXT
  profile_picture TINYBLOB, -- TINYBLOB, BLOB, MEDIUMBLOB, LONGBLOB
  /*
  -- TINYINT
  -- Signed: -128 to 127
  -- Unsigned: 0 to 255
  
  -- SMALLINT
  -- Signed: -32,768 to 32,767
  -- Unsigned: 0 to 65,535
  
  -- MEDIUMINT
  -- Signed: -8,388,608 to 8,388,607
  -- Unsigned: 0 to 16,777,215
  
  -- INT
  -- Signed: -2,147,483,648 to 2,147,483,647
  -- Unsigned: 0 to 4,294,967,295
  
  -- BIGINT
  -- Signed: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
 	-- Unsigned: 0 to 18,446,744,073,709,551,615
  */
  age TINYINT UNSIGNED NOT NULL,
  is_admin BOOLEAN DEFAULT FALSE NOT NULL, -- TINYINT(1, 0)
  balance FLOAT DEFAULT 0.0 NOT NULL, -- DECIMAL(p, s)
  /*
  -- TIMESTAMP -> '1970-01-01 00:00:01' UTC to '2038-01-19 03:14:07' UTC
  -- DATETIME -> '1000-01-01 00:00:00' to '9999-12-31 23:59:59'
  */
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
  birth_date DATE NOT NULL, 
  bed_time TIME NOT NULL,
  graduation_year YEAR NOT NULL, -- 1901 to 2155

	CONSTRAINT chk_age CHECK (age < 100),
  CONSTRAINT uq_email UNIQUE (email)


)

DROP TABLE users;


/*
CREATE TABLE users (
  username CHAR(10) NOT NULL UNIQUE, -- 10자 고정
  email VARCHAR(50) NOT NULL UNIQUE, -- 가변적
  gender ENUM('Male', 'Female') NOT NULL,
  interests SET(
    'Technology', 
    'Sports', 
    'Music', 
    'Art', 
    'Travel', 
    'Food', 
    'Fashion', 
    'Science'
  ) NOT NULL,
  bio TEXT NOT NULL, -- TINYTEXT, TEXT, MEDIUMTEXT, LONGTEXT
  profile_picture TINYBLOB, -- TINYBLOB, BLOB, MEDIUMBLOB, LONGBLOB

  age TINYINT UNSIGNED NOT NULL CHECK (age < 100),

  is_admin BOOLEAN NOT NULL DEFAULT FALSE, -- BOOLEAN은 내부적으로 TINYINT(1)

  balance FLOAT NOT NULL DEFAULT 0.0, -- 또는 DECIMAL(10, 2) 등으로 변경 가능

  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  birth_date DATE NOT NULL, 
  bed_time TIME NOT NULL,
  graduation_year YEAR NOT NULL, -- 1901 ~ 2155

  -- 제약 조건 (이미 email에 UNIQUE가 있으므로 아래는 생략 가능)
  -- CONSTRAINT chk_age CHECK (age < 100),
  -- CONSTRAINT uq_email UNIQUE (email)
  
  -- 필요한 경우 PRIMARY KEY 추가 가능 (예: username 또는 email)
  PRIMARY KEY (username)
);
*/





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
  graduation_year
) VALUES (
  'mr.nobody',
  'mr@nobody.com',
  'Male',
  'Travel,Food,Technology',
  'I like traveling and eating',
  88,
  TRUE,
  '1999.05.08', -- 19990508 1999-05-08 1999/05/08
  '22:30', -- 223000 22:30:00 22
  '1976'
);

-- drop column
ALTER TABLE users DROP COLUMN profile_picture;

-- rename column
ALTER TABLE users CHANGE COLUMN about_me bio TINYTEXT;
ALTER TABLE users CHANGE COLUMN about_me about_me TEXT;

-- change the column type
ALTER TABLE users MODIFY COLUMN about_me TINYTEXT;

-- rename database
ALTER TABLE users RENAME TO customers;
ALTER TABLE customers RENAME TO users;

-- drop constraints
ALTER TABLE users DROP CONSTRAINT uq_email;
ALTER TABLE users
	DROP CONSTRAINT username, -- username의 UNIQUE
  DROP CONSTRAINT chk_age,
  DROP CONSTRAINT uq_email;
  
-- adding constraints
ALTER TABLE users
	ADD CONSTRAINT uq_email UNIQUE (email),
  ADD CONSTRAINT uq_username UNIQUE (username),
  ADD CONSTRAINT chk_age CHECK (age < 100);
  
ALTER TABLE users MODIFY COLUMN bed_time TIME NULL; -- NULL을 추가하는 것으로, NULL도 허용 가능
ALTER TABLE users MODIFY COLUMN bed_time TIME NOT NULL; -- NOT NULL을 추가하는 것으로, NULL 허용 안하게 변경

SHOW CREATE TABLE users;

-- Incorrect date value: '1976' for column 'graduation_year' at row 1
ALTER TABLE users MODIFY COLUMN graduation_year DATE;

-- 해결법 1. 컬럼 새로 생성 후 적용
ALTER TABLE users ADD COLUMN graduation_date DATE;
SELECT graduation_year, MAKEDATE(graduation_year, 1) FROM users;
UPDATE users SET graduation_date = MAKEDATE(graduation_year, 1);
ALTER TABLE users DROP COLUMN graduation_year;
ALTER TABLE users MODIFY COLUMN graduation_date DATE NOT NULL;

CREATE TABLE users_v2( 
  user_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  full_name VARCHAR(101) GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) STORED
);
  
INSERT INTO users_v2 (
  first_name, last_name, email
) VALUES ('aaa', 'bbbbb', 'aaa@email.com');

SELECT * FROM users_v2;

ALTER TABLE users_v2 ADD COLUMN email_domain VARCHAR(50) GENERATED ALWAYS AS (SUBSTRING_INDEX(email, '@', -1)) VIRTUAL;
                                              
DROP TABLE users_v2;                                              




                                              
/*
SHOW CREATE TABLE users;의 결과 예시 

CREATE TABLE `users` (
  `user_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` char(10) NOT NULL,
  `email` varchar(50) NOT NULL,
  `gender` enum('Male','Female') NOT NULL,
  `interests` set('Technology','Sports','Music','Art','Travel','Food','Fashion','Science') NOT NULL,
  `bio` text NOT NULL,
  `profile_picture` tinyblob,
  `age` tinyint unsigned NOT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `balance` float NOT NULL DEFAULT '0',
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `birth_date` date NOT NULL,
  `bed_time` time NOT NULL,
  `graduation_year` year NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `uq_email` (`email`),
  UNIQUE KEY `uq_username` (`username`),
  CONSTRAINT `chk_age` CHECK ((`age` < 100))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
*/


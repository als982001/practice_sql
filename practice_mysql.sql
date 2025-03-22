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






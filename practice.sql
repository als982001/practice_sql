use movies;

CREATE TABLE movies (
	movie_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(300),
    original_title VARCHAR(300),
    original_language CHAR(2),
    overview TEXT,
    release_date SMALLINT,
    revenue BIGINT,
    budget BIGINT,
    homepage TEXT,
    runtime SMALLINT,
    rating TINYINT CHECK (rating BETWEEN -1 AND 10),
    status ENUM (
		'Canceled',
        'In Production',
        'Planned',
        'Post Productuon',
        'Released',
        'Rumored' ),
	country TINYTEXT,
    genres TINYTEXT,
    director TINYTEXT,
    spoken_languages TINYTEXT
);
    
DROP table movies;

CREATE TABLE dogs (
  dog_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  date_of_birth DATE,
  weight DECIMAL(5, 2),
  owner_id BIGINT UNSIGNED,
  breed_id BIGINT UNSIGNED,
  FOREIGN KEY (owner_id) REFERENCES owners (owner_id),
  CONSTRAINT breed_fk FOREIGN KEY (breed_id) REFERENCES breeds (breed_id)
);

CREATE TABLE owners (
  owner_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(20),
  address TINYTEXT
);

CREATE TABLE breeds (
  breed_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  size_category ENUM('small', 'medium', 'big') DEFAULT 'small',
  typical_lifespan TINYINT
);
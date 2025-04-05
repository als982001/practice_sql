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

DROP TABLE dogs, owners, breeds, pet_passports, tricks, dog_tricks;

CREATE TABLE dogs (
  dog_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  date_of_birth DATE,
  weight DECIMAL(5, 2),
  owner_id BIGINT UNSIGNED,
  breed_id BIGINT UNSIGNED,
  FOREIGN KEY (owner_id) REFERENCES owners (owner_id) ON DELETE SET NULL, 
  CONSTRAINT breed_fk FOREIGN KEY (breed_id) REFERENCES breeds (breed_id) ON DELETE SET NULL
);

## CONSTRAINT 제약_이름: ## 제약에 이름 붙이는 거

## ON DELETE	옵션
	## Cascade: 관련된 레코드가 삭제되면, 그것과 연결된 다른 레코드도 삭제되는 것
	## SET NULL: dogs table의 owner_id column을 Null로 설정하는 것. 이를 위해서는 NOT NULL 제약이 있는지 확인 필요
	## SET DEFUALT: 삭제되면 기본값으로 설정되게 하는 것

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

## 1:1 Relationship
CREATE TABLE pet_passports (
  pet_passports_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  blood_type VARCHAR(10),
  allergies TEXT,
  last_checkup_date DATE,
  dog_id BIGINT UNSIGNED UNIQUE,
  FOREIGN KEY (dog_id) REFERENCES dogs (dog_id) ON DELETE CASCADE
);

## N:N RelationShip 구현: dogs(1) <-> (N)dog_tricks(N) <-> (1)tricks 
## 중간 table(link table, bridge table)이 필요함

## composite key(복합키): primary key가 두 개의 컬럼으로 구성된 것
CREATE TABLE dog_tricks (
  dog_id BIGINT UNSIGNED,
  trick_id BIGINT UNSIGNED,
  proficiency ENUM('beginner', 'intermediate', 'expert') NOT NULL DEFAULT 'beginner',
  date_learned TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (dog_id, trick_id),
  FOREIGN KEY (dog_id) REFERENCES dogs (dog_id) ON DELETE CASCADE, 
  FOREIGN KEY (trick_id) REFERENCES tricks (trick_id) ON DELETE CASCADE
);

CREATE TABLE tricks (
  trick_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) UNIQUE NOT NULL,
  difficulty ENUM('easy', 'medium', 'hard') NOT NULL DEFAULT 'easy'
);

/*
INSERT INTO dogs (name, date_of_birth, weight, breed_id, owner_id)
	VALUES ('Champ', '2022-03-15', 10.5, 1, 1);

INSERT INTO dogs (name, date_of_birth, weight, breed_id, owner_id)
	VALUES ('Buddy', '2022-03-15', 10.5, 6, 7);

INSERT INTO owners (name, email, phone, address) 
	VALUES ('John', 'john@email.com', '01012345678', '9101 St. Scotland'); 

DELETE FROM owners WHERE owner_id = 1;
*/

-- INSERT
INSERT INTO breeds (name, size_category, typical_lifespan) VALUES
  ('Labrador Retriever', 'big', 12),
  ('German Shepherd', 'big', 11),
  ('Golden Retriever', 'big', 11),
  ('French Bulldog', 'small', 10),
  ('Beagle', 'medium', 13),
  ('Poodle', 'medium', 14),
  ('Chihuahua', 'small', 15);

INSERT INTO owners (name, email, phone, address) VALUES
  ('John Doe', 'john@example.com', '123-456-7890', '123 Main St, Anytown, USA'),
  ('Jane Smith', 'jane@example.com', '234-567-8901', '456 Elm St, Someplace, USA'),
  ('Bob Johnson', 'bob@example.com', '345-678-9012', '789 Oak St, Elsewhere, USA'),
  ('Alice Brown', 'alice@example.com', '456-789-0123', '321 Pine St, Nowhere, USA'),
  ('Charlie Davis', 'charlie@example.com', '567-890-1234', '654 Maple St, Somewhere, USA'),
  ('Eva Wilson', 'eva@example.com', '678-901-2345', '987 Cedar St, Anyville, USA'),
  ('Frank Miller', 'frank@example.com', '789-012-3456', '246 Birch St, Otherville, USA'),
  ('Grace Lee', 'grace@example.com', '890-123-4567', '135 Walnut St, Hereville, USA'),
  ('Henry Taylor', 'henry@example.com', '901-234-5678', '864 Spruce St, Thereville, USA'),
  ('Ivy Martinez', 'ivy@example.com', '012-345-6789', '753 Ash St, Whereville, USA'),
  ('Jack Robinson', 'jack@example.com', '123-234-3456', '951 Fir St, Thatville, USA'),
  ('Kate Anderson', 'kate@example.com', '234-345-4567', '159 Redwood St, Thisville, USA');
  
INSERT INTO dogs (name, date_of_birth, weight, breed_id, owner_id) VALUES
  ('Max', '2018-06-15', 30.5, 1, 1),
  ('Bella', '2019-03-22', 25.0, NULL, 2),
  ('Charlie', '2017-11-08', 28.7, 2, 3),
  ('Lucy', '2020-01-30', 8.2, NULL, NULL),
  ('Cooper', '2019-09-12', 22.3, 5, 5),
  ('Luna', '2018-07-05', 18.6, 6, 6),
  ('Buddy', '2016-12-10', 31.2, 1, 7),
  ('Daisy', '2020-05-18', 6.8, NULL, 8),
  ('Rocky', '2017-08-25', 29.5, 2, 9),
  ('Molly', '2019-11-03', 24.8, 3, NULL),
  ('Bailey', '2018-02-14', 21.5, 5, 11),
  ('Lola', '2020-03-27', 7.5, 4, 12),
  ('Duke', '2017-05-09', 32.0, NULL, 1),
  ('Zoe', '2019-08-11', 17.8, 6, 2),
  ('Jack', '2018-10-20', 23.6, NULL, 3),
  ('Sadie', '2020-02-05', 26.3, 3, 4),
  ('Toby', '2017-07-17', 8.9, 7, NULL),
  ('Chloe', '2019-04-30', 20.1, 6, 6),
  ('Bear', '2018-01-08', 33.5, 2, 7),
  ('Penny', '2020-06-22', 7.2, 4, NULL);

INSERT INTO tricks (name, difficulty) VALUES
  ('Sit', 'easy'),
  ('Stay', 'medium'),
  ('Fetch', 'easy'),
  ('Roll Over', 'hard'),
  ('Shake Hands', 'medium');

INSERT INTO dog_tricks (dog_id, trick_id, proficiency, date_learned) VALUES
  (1, 1, 'expert', '2019-01-15'),
  (1, 2, 'intermediate', '2019-03-20'),
  (14, 3, 'expert', '2019-02-10'),
  (2, 1, 'expert', '2019-07-05'),
  (2, 3, 'intermediate', '2019-08-12'),
  (3, 1, 'expert', '2018-03-10'),
  (3, 2, 'expert', '2018-05-22'),
  (13, 4, 'beginner', '2019-11-30'),
  (4, 1, 'intermediate', '2020-05-18'),
  (5, 1, 'expert', '2020-01-07'),
  (11, 3, 'expert', '2020-02-15'),
  (5, 5, 'intermediate', '2020-04-22'),
  (7, 1, 'expert', '2017-06-30'),
  (7, 2, 'expert', '2017-08-14'),
  (12, 3, 'expert', '2017-07-22'),
  (16, 4, 'intermediate', '2018-01-05'),
  (7, 5, 'expert', '2017-09-18'),
  (10, 1, 'intermediate', '2020-03-12'),
  (10, 3, 'beginner', '2020-05-01'),
  (15, 1, 'expert', '2019-02-28'),
  (14, 2, 'intermediate', '2019-04-15'),
  (18, 1, 'intermediate', '2019-09-10'),
  (18, 5, 'beginner', '2020-01-20');

INSERT INTO pet_passports (dog_id, blood_type, allergies, last_checkup_date) VALUES
  (1, 'DEA 1.1+', 'None', '2023-01-05'),
  (2, 'DEA 1.1-', 'Chicken', '2023-02-22'),
  (3, 'DEA 4+', 'None', '2023-03-08'),
  (5, 'DEA 7+', 'Beef', '2023-04-12'),
  (7, 'DEA 1.1+', 'None', '2023-01-10'),
  (10, 'DEA 3-', 'Dairy', '2023-05-03'),
  (12, 'DEA 5-', 'None', '2023-03-27'),
  (15, 'DEA 1.1-', 'Grains', '2023-04-20'),
  (18, 'DEA 7+', 'None', '2023-04-03'),
  (20, 'DEA 4+', 'Pollen', '2023-06-22');

-- CROSS JOIN: 그냥 다 연결시킴
SELECT * FROM dogs CROSS JOIN owners;

-- JOIN과 INNER JOIN은 같은 것
-- INNER JOIN: table간 교집합
SELECT * FROM dogs JOIN owners ON dogs.owner_id = owners.owner_id;
SELECT
	dogs.name as dog_name,
  owners.name as owner_name,
  breeds.name as breed_name
FROM
	dogs 
  JOIN owners ON dogs.owner_id = owners.owner_id
  JOIN breeds USING (breed_id); -- column 이름 같을 경우 USING으로 줄일 수 있음

-- left/right outer join에서 outer는 작성하지 않아도 됨
-- OUTER JOIN: 애매하거나 의미가 불분명한 row를 확인할 때
-- 이 쿼리문에서 LEFT JOIN: owner가 NULL인 dogs도 보여줌
-- 이 쿼리문에서 RIGHT JOIN: dog가 NULL인 owner도 보여줌
-- dangling row: 교집합 아닌 거
SELECT
	dogs.name as dog_name,
  owners.name as owner_name
FROM
	dogs 
  RIGHT JOIN owners ON dogs.owner_id = owners.owner_id;
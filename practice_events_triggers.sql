-- table 구조 복사
CREATE TABLE archived_movies LIKE movies;

DROP TABLE archived_movies;

-- STARTS: 얼마나 시간이 지나고 시작할지 지정. 없으면 바로 시작함
DELIMITER $$
CREATE EVENT archive_old_movies 
ON SCHEDULE EVERY 2 MINUTE
STARTS CURRENT_TIMESTAMP + INTERVAL 2 MINUTE
-- DO는 오직 statement가 1개일 때만 작동
-- INSERT, DELETE 2개의 분리된 statement를 가지고 있으므로 BEGIN + END 입력
-- delimiter 변경도 필요
DO
BEGIN
	INSERT INTO archived_movies
  SELECT * FROM movies 
  WHERE release_date < YEAR(CURDATE()) - 20;
	DELETE FROM movies release_date < YEAR(CURDATE()) - 20; 
END$$
DELIMITER ;

CREATE EVENT archive_old_movies 
ON SCHEDULE 
  EVERY 2 MINUTE 
  STARTS CURRENT_TIMESTAMP + INTERVAL 2 MINUTE
DO
BEGIN
  INSERT INTO archived_movies
  SELECT * FROM movies 
  WHERE release_date < YEAR(CURDATE()) - 20;

  DELETE FROM movies 
  WHERE release_date < YEAR(CURDATE()) - 20;
END;

DROP EVENT archive_old_movies;

SHOW events;

-- BEFORE: INSERT, UPDATE, DELETE
-- AFTER: INSERT, UPDATE, DELETE

CREATE TABLE records (
  record_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  changes TINYTEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TRIGGER before_movie_insert
BEFORE INSERT
ON movies
FOR EACH ROW
INSERT INTO records (changes) VALUES (CONCAT('Will Insert ', NEW.title));

CREATE TRIGGER after_movie_insert
AFTER INSERT
ON movies
FOR EACH ROW
INSERT INTO records (changes) VALUES (CONCAT('Insert completed: ', NEW.title));

CREATE TRIGGER before_movie_update
BEFORE UPDATE
ON movies
FOR EACH ROW
INSERT INTO records (changes) VALUES (CONCAT('Will update title: ', OLD.title, ' -> ', NEW.title));

CREATE TRIGGER after_movie_update
AFTER UPDATE
ON movies
FOR EACH ROW
INSERT INTO records (changes) VALUES (CONCAT('Will update title: ', OLD.title, ' -> ', NEW.title));

CREATE TRIGGER before_movie_delete
BEFORE DELETE
ON movies
FOR EACH ROW
INSERT INTO records (changes) VALUES (CONCAT('Will deleted: ', OLD.title));

CREATE TRIGGER after_movie_delete
AFTER DELETE
ON movies
FOR EACH ROW
INSERT INTO records (changes) VALUES (CONCAT('bye bye ', OLD.title));


INSERT INTO movies SELECT * FROM archived_movies WHERE movie_id = 2;

SHOW TRIGGERS;

DROP TRIGGER after_movie_update;

TRUNCATE TABLE records;

CREATE TRIGGER after_movie_update
AFTER UPDATE
ON movies
FOR EACH ROW
BEGIN
	DECLARE changes TINYTEXT DEFAULT '';
  
  IF NEW.title <> OLD.title THEN 
  	SET changes = CONCAT('Title changed ', OLD.title, ' -> ', NEW.title, '\n');
  END IF;
  
  IF NEW.budget <> OLD.budget THEN
  	SET changes = CONCAT(changes, 'Budget changed ', OLD.budget, ' -> ', NEW.budget);
  END IF;
  
  INSERT INTO records (changes) VALUES (changes);
END;

DROP TRIGGER after_movie_update;

CREATE FULLTEXT INDEX idx_overview ON movies(overview);

-- Natural Language Search
SELECT
	title, overview, MATCH(overview) AGAINST ('the food and the drinks') AS score
FROM movies
WHERE MATCH(overview) AGAINST ('the food and the drinks');

-- Boolean Mode Search
SELECT
	title, 
  overview,
  MATCH(overview) AGAINST ('"food romance"@10' IN BOOLEAN MODE) AS score 
FROM
	movies
WHERE 
	MATCH(overview) AGAINST ('"food romance"@10' IN BOOLEAN MODE);

-- Query Expansion Search
-- 두 번 검색 -> 리소스 많이 든다
SELECT
	title, 
  overview, 
  MATCH(overview) AGAINST ('kimchi' WITH QUERY EXPANSION) AS score
FROM movies
WHERE MATCH(overview) AGAINST ('kimchi' WITH QUERY EXPANSION);




















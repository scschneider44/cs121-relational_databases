-- [Problem 3]
SELECT person_id, person_name
  FROM geezer NATURAL JOIN game_type 
       NATURAL JOIN game NATURAL JOIN game_score
  GROUP BY person_id, person_name
  HAVING COUNT(DISTINCT type_name) = 
         (SELECT COUNT(type_name) FROM game_type); 


-- [Problem 4]
DROP VIEW IF EXISTS top_scores;

CREATE VIEW top_scores AS
  SELECT type_id, type_name, person_id, person_name, score
  FROM geezer NATURAL JOIN game_type NATURAL JOIN game
       NATURAL JOIN game_score JOIN 
       (SELECT type_id AS id, MAX(score) AS max_score
        FROM game_score NATURAL JOIN game
        GROUP BY type_id) AS max_scores
        ON score = max_score 
           AND type_id = id
  ORDER BY type_id ASC, person_id ASC ;

-- [Problem 5]
-- This with counts how many times each game was played in this period
WITH counts AS 
(
    SELECT COUNT(DISTINCT game_id) AS game_counts
      FROM game_type NATURAL JOIN game
      WHERE game_date BETWEEN DATE('2000-04-18') - INTERVAL 2 WEEK AND 
                              DATE('2000-04-18')
      GROUP BY type_name
)
SELECT type_id
  FROM game_type NATURAL JOIN game 
  WHERE game_date BETWEEN DATE('2000-04-18') - INTERVAL 2 WEEK AND 
                          DATE('2000-04-18')
  GROUP BY type_id
  HAVING COUNT(DISTINCT game_id) > (SELECT AVG(game_counts) FROM counts);


-- [Problem 6]
CREATE TEMPORARY TABLE cribbage_ids (
    person_id INTEGER NOT NULL,
    game_id   INTEGER NOT NULL
);

INSERT INTO cribbage_ids
  SELECT person_id, game_id
    FROM game NATURAL JOIN game_type
         NATURAL JOIN game_score
         NATURAL JOIN geezer
    WHERE type_name = 'cribbage' AND 
          person_name = 'Ted Codd';

DELETE FROM game_score 
WHERE (game_id) IN (SELECT game_id 
                      FROM cribbage_ids);

DELETE FROM game 
WHERE (game_id) IN (SELECT game_id 
                      FROM cribbage_ids);
                      
DROP TEMPORARY TABLE IF EXISTS cribbage_ids;

-- [Problem 7]
UPDATE geezer NATURAL JOIN game_score NATURAL JOIN game NATURAL JOIN game_type
SET prescriptions = CONCAT(IFNULL(prescriptions, ''), 
                           ' Extra pudding on Thursdays!')
WHERE (type_name = 'cribbage');


-- [Problem 8]
-- This with gets the max score of each game
-- If there are more than 1 instances of max score it was a 
-- tie and the max score players get 0.5, otherwise the max score
-- person gets 1. Then points are summed.
WITH 
max_scores AS
(
    SELECT game_id, max(score) as max_score
    FROM game_score NATURAL JOIN game NATURAL JOIN game_type
    WHERE min_players > 1
    GROUP BY game_id
)
SELECT person_id, person_name, SUM(points) AS total_points 
  FROM (SELECT game_id, 
           CASE
           WHEN COUNT(*) = 1 THEN 1
           ELSE 0.5
           END AS points
        FROM game_score NATURAL JOIN max_scores
        WHERE score = max_score
        GROUP BY game_id) AS pts NATURAL JOIN game_score 
                                 NATURAL JOIN geezer 
                                 NATURAL JOIN max_scores  
  WHERE score = max_score
  GROUP BY person_id, person_name
  ORDER BY total_points DESC;
  
  
  
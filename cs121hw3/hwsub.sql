-- [Problem 1a]
SELECT SUM(perfectscore) AS perfect_score
  FROM assignment;


-- [Problem 1b]
SELECT sec_name, COUNT(DISTINCT username) AS num_students
  FROM section NATURAL JOIN student
  GROUP BY sec_name;


-- [Problem 1c]
CREATE VIEW totalscores AS
  SELECT username, SUM(score) AS class_score
  FROM submission
  WHERE graded = true
  GROUP BY username;

-- [Problem 1d]
CREATE VIEW passing AS 
  SELECT username, class_score
  FROM totalscores
  WHERE class_score >= 40;

-- [Problem 1e]
CREATE VIEW failing AS 
  SELECT username, class_score
  FROM totalscores
  WHERE class_score < 40;


-- [Problem 1f]
/* 
Result of query:
username
harris
ross
miller
turner
edwards
murphy
simmons
tucker
coleman
flores
gibson
*/
SELECT DISTINCT username
  FROM assignment NATURAL JOIN submission 
       NATURAL LEFT JOIN fileset
       NATURAL JOIN passing
  WHERE shortname LIKE 'lab%' AND fset_id IS NULL;
  
-- [Problem 1g]
/*
Result of query:
username
collins
*/

SELECT DISTINCT username
  FROM assignment NATURAL JOIN submission 
       NATURAL LEFT JOIN fileset
       NATURAL JOIN passing
  WHERE (shortname LIKE 'midterm' AND fset_id IS NULL) OR 
        (shortname LIKE 'final' AND fset_id IS NULL);
  
-- [Problem 2a]
SELECT DISTINCT username
  FROM assignment NATURAL JOIN submission 
       NATURAL JOIN fileset 
  WHERE shortname LIKE 'midterm' AND sub_date > due;


-- [Problem 2b]
SELECT EXTRACT (HOUR from sub_date) AS hour, 
       COUNT(DISTINCT fset_id) AS num_submits
  FROM fileset NATURAL JOIN submission NATURAL JOIN assignment
  WHERE shortname LIKE 'lab%'
  GROUP BY hour;


-- [Problem 2c]
SELECT COUNT(*) AS finals_near_deadline
  FROM assignment NATURAL JOIN fileset
  WHERE shortname LIKE 'final' AND
        sub_date BETWEEN due - INTERVAL 30 MINUTE AND due;
  


-- [Problem 3a]
ALTER TABLE student
ADD email VARCHAR(200);

UPDATE student
SET email = CONCAT(username, '@school.edu');

ALTER TABLE student CHANGE email email VARCHAR(200) NOT NULL;

-- [Problem 3b]
ALTER TABLE assignment
ADD submit_files BOOLEAN DEFAULT TRUE;

UPDATE assignment
SET submit_files = FALSE
WHERE shortname LIKE 'dq%';

-- [Problem 3c]
DROP TABLE IF EXISTS gradescheme;

CREATE TABLE gradescheme (
    scheme_id   INTEGER      PRIMARY KEY,
    scheme_desc VARCHAR(100) NOT NULL
);

INSERT INTO gradescheme VALUES (0, 'Lab assignment with min-grading');
INSERT INTO gradescheme VALUES (1, 'Daily quiz');
INSERT INTO gradescheme VALUES (2, 'Midterm or final exam');

ALTER TABLE assignment
CHANGE gradescheme scheme_id INTEGER NOT NULL;

ALTER TABLE assignment
ADD FOREIGN KEY (scheme_id)
REFERENCES gradescheme(scheme_id);

-- [Problem 4a]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DELIMITER !
-- Given a date value, returns TRUE if it is a weekend,
-- or FALSE if it is a weekday.
CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN
BEGIN
-- make local variable and set to false
  DECLARE weekend BOOLEAN DEFAULT FALSE;
  
-- if day of week is sat or sun change boolean varible to true
  IF DAYOFWEEK(d) = 1 OR DAYOFWEEK(d) = 7 THEN SET weekend = TRUE;
  END IF;
-- return boolean  
  RETURN weekend;
END !
-- Back to the standard SQL delimiter
DELIMITER ;


-- [Problem 4b]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DELIMITER !
-- Given a date value, returns TRUE if it is a weekend,
-- or FALSE if it is a weekday.
CREATE FUNCTION is_holiday(h DATE) RETURNS VARCHAR(20)
BEGIN
-- make local variables to get month, day of week, and
-- day of month as well as a variable we will return
  DECLARE holiday VARCHAR(20) DEFAULT NULL;
  DECLARE day_of_week INTEGER DEFAULT DAYOFWEEK(h);
  DECLARE day_of_month INTEGER DEFAULT DAYOFMONTH(h);
  DECLARE month_of_date INTEGER DEFAULT MONTH(h);  

-- For New Year's
  IF day_of_month = 1 AND month_of_date = 1 
    THEN SET holiday = 'New Year\s Day';
-- For Memorial day
  ELSEIF day_of_week = 2 AND month_of_date = 5 
    AND day_of_month BETWEEN 25 AND 31
    THEN SET holiday = 'Memorial Day';
-- For July 4th
  ELSEIF month_of_date = 7 AND day_of_month = 4
    THEN SET holiday = 'Independence Day';
-- For Labor day
  ELSEIF day_of_week = 2 AND month_of_date = 9 
    AND day_of_month BETWEEN 1 AND 7
    THEN SET holiday = 'Labor Day';
-- For thanksgiving
  ELSEIF day_of_week = 5 AND month_of_date = 11 
    AND day_of_month BETWEEN 22 AND 28
    THEN SET holiday = 'Thanksgiving';  
  END IF;
-- Return null if not a holliday or a string if it is
  RETURN holiday;
END !
-- Back to the standard SQL delimiter
DELIMITER ;

 -- [Problem 5a]
SELECT is_holiday(sub_date) AS holiday_of_sub, 
       COUNT(fset_id) AS subs
  FROM fileset
  GROUP BY holiday_of_sub;

-- [Problem 5b]
SELECT CASE is_weekend(sub_date) WHEN 1 THEN 'weekend' ELSE 'weekday' END 
       AS weekend_status, COUNT(fset_id) AS subs
  FROM fileset
  GROUP BY weekend_status;


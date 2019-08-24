-- [Problem 1]
DROP FUNCTION IF EXISTS min_submit_interval;

DELIMITER !

CREATE FUNCTION min_submit_interval(submit_id INTEGER) 
                RETURNS INTEGER
BEGIN
  -- checks if there is another sumbission date, if not then exits 
  -- while loop
  DECLARE done BINARY DEFAULT FALSE;
  -- stores a submission date
  DECLARE sub1 INTEGER;
  -- also stores a submission date
  DECLARE sub2 INTEGER;
  -- holds the smallest interval, this will be returned
  DECLARE min_interval INTEGER DEFAULT NULL;
  -- declares cursor to iterate through rows
  DECLARE cur CURSOR FOR SELECT UNIX_TIMESTAMP(sub_date) AS unix_date 
                         FROM fileset WHERE sub_id = submit_id
                         ORDER BY sub_date ASC;
  -- stops while loop if done is true
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  -- gets first submission date
  FETCH cur INTO sub1;
  -- this checks if there is at least one submission
  WHILE NOT done DO
     -- gets second sub date
     FETCH cur INTO sub2;
     -- checks if there are at least two submissions
     -- this will also stop when all the sub dates are iterated through
     IF NOT done THEN
       -- if it's the first 2 sub dates then create min interval
       IF min_interval IS NULL 
         THEN SET min_interval = (sub2 - sub1);
       -- if not first 2 sub dates then check if interval is 
       -- smaller than smallest interval
       ELSEIF (sub2 - sub1) < min_interval 
           THEN SET min_interval = (sub2 - sub1);
       END IF;
     END IF;
     -- reset first cursor so that it iterates through all rows
     SET sub1 = sub2;
  END WHILE;
  CLOSE cur;
  RETURN min_interval;
END !
DELIMITER ;


-- [Problem 2]
DROP FUNCTION IF EXISTS max_submit_interval;

DELIMITER !

CREATE FUNCTION max_submit_interval(submit_id INTEGER) 
                RETURNS INTEGER
BEGIN
  -- checks if there is another sumbission date, if not then exits 
  -- while loop
  DECLARE done BINARY DEFAULT FALSE;
  -- stores a submission date
  DECLARE sub1 INTEGER;
  -- also stores a submission date
  DECLARE sub2 INTEGER;
  -- holds the largest interval, this will be returned
  DECLARE max_interval INTEGER DEFAULT NULL;
  -- declares cursor to iterate through rows
  DECLARE cur CURSOR FOR SELECT UNIX_TIMESTAMP(sub_date) AS unix_date 
                         FROM fileset WHERE sub_id = submit_id
                         ORDER BY sub_date ASC;
  -- stops while loop if done is true                              
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  -- gets first submission date
  FETCH cur INTO sub1;
  -- this checks if there is at least one submission
  WHILE NOT done DO
     -- gets second sub date
     FETCH cur INTO sub2;
     -- checks if there are at least two submissions
     -- this will also stop when all the sub dates are iterated through
     IF NOT done THEN
       -- if it's the first 2 sub dates then create max interval
       IF max_interval IS NULL 
         THEN SET max_interval = (sub2 - sub1);
       -- if not first 2 sub dates then check if interval is greater than
       -- max_interval
       ELSEIF (sub2 - sub1) > max_interval 
           THEN SET max_interval = (sub2 - sub1);
       END IF;
     END IF;
     -- reset first cursor so that it iterates through all rows
     SET sub1 = sub2;
  END WHILE;
  CLOSE cur;
  RETURN max_interval;
END !
DELIMITER ;


-- [Problem 3]
DROP FUNCTION IF EXISTS avg_submit_interval;

DELIMITER !

CREATE FUNCTION avg_submit_interval(submit_id INTEGER) 
                RETURNS DOUBLE
BEGIN
  -- holds latest sub date
  DECLARE late_sub INTEGER;
  -- holds earliest sub date
  DECLARE early_sub INTEGER;
  -- holds number of submissions 
  DECLARE num_subs INTEGER;
  -- holds avergae interval, this will be returned
  DECLARE avg_sub_interval DOUBLE DEFAULT NULL;

  -- fills in variables with desired values
  SELECT UNIX_TIMESTAMP(max(sub_date)), UNIX_TIMESTAMP(min(sub_date)),
         count(sub_date) INTO late_sub, early_sub, num_subs
    FROM fileset 
    WHERE sub_id = submit_id;
    -- if an interval exists than calculate avg
    IF num_subs > 1 
      THEN SET avg_sub_interval = (late_sub - early_sub) / (num_subs - 1);
    END IF;
  RETURN avg_sub_interval;
END !
DELIMITER ;


-- [Problem 4]
CREATE INDEX idx_sub_id ON fileset (sub_id);




-- [Problem 1] 
-- I cross weblog with itself and I then select distinct ip_addresses
-- from one of the weblog instnaces, the logtime from on of the
-- weblog instances and the minimum time to the next request from 
-- the first logtime. I select distinct because two requests at the same 
-- time can be treated as one request as only time matters.
-- I then count all the times where the closest request is 30 mins or more 
-- away and I add that to the number of IP addresses. I do this addition because
-- the first visit isn't recorded when checking for the 30 minute condition
-- thus by adding all the IPs we get all the visits.

SELECT COUNT(*) + (SELECT COUNT(DISTINCT ip_addr) FROM weblog) AS visits
  FROM (SELECT DISTINCT w1.ip_addr, w1.logtime, MIN(w2.logtime) AS min_time
        FROM weblog AS w1 JOIN weblog AS w2 ON w1.ip_addr = w2.ip_addr
        WHERE w2.logtime > w1.logtime
        GROUP BY w1.ip_addr, w1.logtime) AS times
  WHERE min_time >= logtime + INTERVAL 30 MINUTE;

-- [Problem 2]
-- The above query is slow because mysql struggles with queries 
-- against tables without indexes. This is because it does a file
-- scan for attributes that aren't indexed and that is fairly slow.
-- Furthermore, the join takes a long time because joins of large
-- tables usually do.
-- I speed this query up by adding indexes to ip_addr and logtime 
-- as well as store the complicated intermediate steps in a temporary
-- table.

CREATE INDEX idx_ip_addr on weblog (ip_addr);
CREATE INDEX idx_lt on weblog (logtime);

CREATE TEMPORARY TABLE times (
  ip_addr1 VARCHAR(100),
  logtime1 TIMESTAMP,
  logtime2 TIMESTAMP
);

INSERT INTO times
(                   
  SELECT DISTINCT w1.ip_addr, w1.logtime, MIN(w2.logtime) AS min_time
    FROM weblog AS w1 JOIN weblog AS w2 ON w1.ip_addr = w2.ip_addr
    WHERE w2.logtime > w1.logtime
    GROUP BY w1.ip_addr, w1.logtime
);

SELECT COUNT(*) + (SELECT COUNT(DISTINCT ip_addr) FROM weblog) AS visits
  FROM times
  WHERE logtime2 >= logtime1 + INTERVAL 30 MINUTE;

DROP TABLE IF EXISTS times;
-- [Problem 3]

DROP FUNCTION IF EXISTS num_visits;

DELIMITER !

CREATE FUNCTION num_visits() RETURNS INTEGER
BEGIN
-- checks if there is another sumbission date, if not then exits 
-- while loop
DECLARE done BINARY DEFAULT FALSE;
-- holds an ip_addr
DECLARE ip_addr1 VARCHAR(100);
-- holds an ip_addr
DECLARE ip_addr2 VARCHAR(100);
-- holds a logtime
DECLARE logtime1 INTEGER;
-- holds a logtime
DECLARE logtime2 INTEGER;
-- number of visits, default is 0 in case the table is empty
DECLARE visits INTEGER DEFAULT 0;
-- create cursor that will grab the ip_addr and timestamp of a row
DECLARE cur CURSOR FOR SELECT ip_addr, UNIX_TIMESTAMP(logtime) AS unix_logtime
                         FROM weblog 
                         ORDER BY ip_addr ASC, logtime ASC;
-- When there are no more rows, stop
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur;
  -- gets first ip_addr and logtime
  FETCH cur INTO ip_addr1, logtime1;
  -- if there is at least one visit add 1 to visits
  IF NOT done
    THEN SET visits = 1;
  END IF;
  -- while there are more than 1 rows do this loop
  WHILE NOT done DO
     -- gets second ip_addr and logtime
     FETCH cur INTO ip_addr2, logtime2;
     -- checks if there are at least two rows
     -- this will also stop when all the rows are iterated through
     IF NOT done THEN
       -- if the addresses are the same and the visits are at least 30 
       -- mins apart then add one to visits
       IF ip_addr1 = ip_addr2
           THEN IF logtime2 - logtime1 >= 1800
                   THEN SET visits = visits + 1;
                END IF;
       -- if it's the first request add 1 to visit
       ELSE SET visits = visits + 1;
       END IF;
     END IF;
     -- set the cursor so that it keeps looping
     SET logtime1 = logtime2;
     SET ip_addr1 = ip_addr2;
  END WHILE;
  CLOSE CUR;
  RETURN visits;
END !

DELIMITER ;

SELECT num_visits();


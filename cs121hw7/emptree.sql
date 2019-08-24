-- [Problem 1]

DROP FUNCTION IF EXISTS total_salaries_adjlist;

DELIMITER !

CREATE FUNCTION total_salaries_adjlist(empl_id INTEGER)
                RETURNS INTEGER
BEGIN
  -- declare a variable to hold the salary sum and a condition
  -- to see if the while loop is done.
  DECLARE total_salary INTEGER;
  DECLARE done BOOLEAN DEFAULT FALSE;
  -- create a temporary table that will initially hold
  -- the root of the tree
  DROP TEMPORARY TABLE IF EXISTS emps;
  CREATE TEMPORARY TABLE emps
    (emp_id      INTEGER NOT NULL,
     salary      INTEGER NOT NULL);
  -- insert the root of the tree
  INSERT INTO emps SELECT emp_id, salary
                     FROM employee_adjlist AS e
                     WHERE e.emp_id = empl_id;
  -- everyone who is managed, directly or indirectly, by the root
  -- gets put in the table with this loop
  WHILE NOT done DO
    INSERT INTO emps SELECT emp_id, salary
                       FROM employee_adjlist AS e
                       WHERE e.manager_id IN (SELECT emp_id FROM emps) AND
                             e.emp_id NOT IN (SELECT emp_id FROM emps);
    -- if this query doesn't change the table then were done
    IF ROW_COUNT() = 0
      THEN SET done = TRUE;
    END IF;
  END WHILE;
  -- sum up all the salaries of the people in the tables
  SELECT SUM(salary) AS total_sal INTO total_salary FROM emps;
  DROP TEMPORARY TABLE IF EXISTS emps;
  RETURN total_salary;
END !

DELIMITER ;  


-- [Problem 2]
DROP FUNCTION IF EXISTS total_salaries_nestset;

DELIMITER !

CREATE FUNCTION total_salaries_nestset(emp_id INTEGER)
                RETURNS INTEGER
BEGIN 
  -- store the high and low indexes of the root of the subtree 
  -- as well as a variable to hold the sum of salaries
  DECLARE low_idx INTEGER;
  DECLARE high_idx INTEGER;
  DECLARE total_salary INTEGER;
  -- get low and high index of the root
  SELECT low, high INTO low_idx, high_idx
    FROM employee_nestset AS e
    WHERE e.emp_id = emp_id;
  -- get the nodes that are contained by the low and high
  -- of the root and then sum the salaries.
  SELECT sum(salary) INTO total_salary
    FROM employee_nestset AS e
    WHERE e.low >= low_idx AND e.high <= high_idx;
  RETURN total_salary;
END !
DELIMITER ; 


-- [Problem 3]
-- check if the employee is a manager by seeing if
-- the emp_id is also a manager id. When manager is
-- null it's obviously not a leaf and it will mess up
-- the query so take out that case
SELECT DISTINCT emp_id, name, salary
  FROM employee_adjlist 
  WHERE emp_id NOT IN (SELECT manager_id
                         FROM employee_adjlist
                         WHERE manager_id IS NOT NULL);


-- [Problem 4]
-- compare two instances of employee nestset and
-- see if there are any instances of nodes with
-- a higher low and a lower high than each node. If there
-- isn't then we know it's a leaf
SELECT emp_id, name, salary
  FROM employee_nestset AS nest1
  WHERE NOT EXISTS (SELECT * 
                      FROM employee_nestset AS nest2
                      WHERE nest2.low > nest1.low AND 
                            nest2.high < nest1.high);


-- [Problem 5]
-- I chose the adjlist because it is easier to 
-- see who manages who with the attribute manager_id. 
-- THe nest list would require a bunch of comparisons
-- with low and high. Also finding the root is slightly easier.

DROP FUNCTION IF EXISTS tree_depth;

DELIMITER !

CREATE FUNCTION tree_depth()
                RETURNS INTEGER
BEGIN
  -- declare max_depth which will hold the max depth
  DECLARE max_depth INTEGER;
  -- recusively go through the tree and each time you
  -- get to a new level add one to depth
  WITH RECURSIVE empl AS (
      SELECT emp_id, 1 AS depth
        FROM employee_adjlist
        WHERE manager_id IS NULL
    UNION ALL
      SELECT a.emp_id, depth + 1 AS depth
        FROM employee_adjlist AS a JOIN empl AS e 
             ON a.manager_id = e.emp_id
  )
  -- find the max depth
  SELECT max(depth) INTO max_depth
    FROM empl;
  RETURN max_depth;
END !
DELIMITER ;

-- [Problem 6]
DROP FUNCTION IF EXISTS emp_reports;

DELIMITER !
-- function gets all the immediate children of a node.
CREATE FUNCTION emp_reports(empl_id INTEGER)
                RETURNS INTEGER
BEGIN
  DECLARE parent_low INTEGER;
  DECLARE parent_high INTEGER;
  DECLARE children INTEGER;
  SELECT low, high INTO parent_low, parent_high
    FROM employee_nestset
    WHERE emp_id = empl_id;
  DROP TEMPORARY TABLE IF EXISTS kids;
  -- create a temporary of all the nodes under a specific root
  CREATE TEMPORARY TABLE kids (kid_emp_id INTEGER,
                               kid_low    INTEGER,
                               kid_high   INTEGER);
  -- insert the children nodes
  INSERT INTO kids SELECT emp_id, low, high
                     FROM employee_nestset AS e
                     WHERE e.low > parent_low AND e.high < parent_high;
  -- check if there isn't a node that that contains a certain node. If there
  -- isn't then we know it's an immediate child.
  SELECT COUNT(*) INTO children
    FROM kids AS k1
    WHERE NOT EXISTS (SELECT * 
                      FROM kids AS k2
                      WHERE k2.kid_low < k1.kid_low AND 
                            k2.kid_high > k1.kid_high);
  DROP TEMPORARY TABLE IF EXISTS kids;
  RETURN children;
END !

DELIMITER ;
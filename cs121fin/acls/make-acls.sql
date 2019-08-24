-- [Problem 1.1]
DROP TABLE IF EXISTS acl;

-- Table with the list of access permissions 
CREATE TABLE acl (
    username     VARCHAR(20)    NOT NULL,
    -- path to a resource
    item_path    VARCHAR(1000)  NOT NULL,
    -- permission like execute, read, write, etc.
    item_perm    VARCHAR(20)    NOT NULL,
    -- accept or deny
    perm_grant   BOOLEAN        NOT NULL,
    PRIMARY KEY (username, item_path, item_perm)
);

-- [Problem 1.2]
DROP PROCEDURE IF EXISTS add_perm;

DELIMITER !
-- procedure that adds a permission to the acl
CREATE PROCEDURE add_perm(res_path   VARCHAR(1000), 
                          user       VARCHAR(20),
                          perm       VARCHAR(20),
                          grant_perm BOOLEAN)
BEGIN 
  -- simply inserting into a table
  INSERT INTO acl VALUES(user, res_path, perm, grant_perm);
END !
DELIMITER ;


-- [Problem 1.3]
DROP PROCEDURE IF EXISTS del_perm;

DELIMITER !
-- a procedure that deletes a permission from the acl
CREATE PROCEDURE del_perm(res_path   VARCHAR(1000), 
                          user       VARCHAR(20),
                          perm       VARCHAR(20))
BEGIN 
  -- delete the desired rows
  DELETE FROM acl 
    WHERE username = user AND item_path = res_path AND 
          item_perm = perm;
END !
DELIMITER ;


-- [Problem 1.4]
DROP PROCEDURE IF EXISTS clear_perms;

DELIMITER !
-- procedure that deletes all rows in the acl
CREATE PROCEDURE clear_perms()
BEGIN 
  -- delete all rows
  DELETE FROM acl;
END !
DELIMITER ;


-- [Problem 1.5]
DROP FUNCTION IF EXISTS has_perm;

DELIMITER !
-- function that checks if a user has a permission
CREATE FUNCTION has_perm(res_path VARCHAR(1000),
                         user     VARCHAR(20),
                         perm     VARCHAR(20))
                RETURNS BOOLEAN
BEGIN 
  -- returm variable which will be false by default
  DECLARE perm_valid BOOLEAN DEFAULT FALSE;
  
  DROP TEMPORARY TABLE IF EXISTS paths;
  -- temporary table to hold all the paths we care about
  CREATE TEMPORARY TABLE paths (
      user_name   VARCHAR(20),
      path        VARCHAR(1000),
      permission  VARCHAR(20),
      granted     BOOLEAN,
      path_len         INTEGER);
  -- insert paths into the table which are prefixes of the path we want 
  -- check as well as the length of each path added
  INSERT INTO paths (SELECT username, item_path, item_perm, perm_grant,
                            LENGTH(item_path) AS len
                     FROM acl
                     WHERE username = user AND item_perm = perm AND 
                           CONCAT(res_path, '/') LIKE CONCAT(item_path, '/%'));
  -- If permissions were specified then hold that grant/deny in a variable
  -- if no permissions were stated explicitly then that's a deny which is
  -- why our holding variable is false by default
  IF (SELECT COUNT(*) FROM paths) <> 0
    THEN SET perm_valid = (SELECT perm_grant 
                   FROM acl
                   WHERE username = user AND 
                         LENGTH(item_path) = (SELECT max(path_len) FROM paths));
  END IF;
  -- drop the temp table
  DROP TEMPORARY TABLE IF EXISTS paths;
  -- return whether the person has permission granted or not
  RETURN perm_valid;
END !

DELIMITER ;
  

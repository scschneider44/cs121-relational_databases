-- [Problem 1]
DROP TABLE IF EXISTS user_info;

-- This table holds the hashed passwords and salt
-- of users.
CREATE TABLE user_info (
    username      VARCHAR(20) NOT NULL,
    salt          VARCHAR(20)    NOT NULL,
    -- hashed password
    password_hash CHAR(64)    NOT NULL,
    PRIMARY KEY (username),
    -- The salt has to be at least 6 charachters.
    CHECK(LENGTH(salt) >= 6)
);


-- [Problem 2]
DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER !
-- adds news users passwords to the database
CREATE PROCEDURE sp_add_user(
  -- takes in a username and password
  IN new_username VARCHAR(20),
  IN password     VARCHAR(25)
)
BEGIN
  DECLARE salt        CHAR(10);
  DECLARE hashed      CHAR(64);
  -- Make a new salt to salt the password
  SELECT make_salt(10) INTO salt;
  -- concatonate the salt and password and then hash it
  SELECT SHA2(CONCAT(salt, password), 256) INTO hashed;
  INSERT INTO user_info VALUES(new_username, salt, hashed);
END !

DELIMITER ;
  
-- [Problem 3]
DROP PROCEDURE IF EXISTS sp_change_password;

DELIMITER !
-- procedure to change password
CREATE PROCEDURE sp_change_password(
  -- input existing username and a new password
  IN same_username VARCHAR(20),
  IN new_password     VARCHAR(25)
)
BEGIN
  DECLARE salt        CHAR(10);
  DECLARE hashed      CHAR(64);
  -- make new salt for the new password
  SELECT make_salt(10) INTO salt;
  -- hash the concatination of the new salt and the new password
  SELECT SHA2(CONCAT(salt, new_password), 256) INTO hashed;
  -- update the table
  UPDATE user_info 
    SET salt = salt, password_hash = hashed
    WHERE username = same_username;
END !

DELIMITER ;


-- [Problem 4]
DROP FUNCTION IF EXISTS authenticate;

DELIMITER !
-- function to see if a password is the correct one
CREATE FUNCTION authenticate(user_name VARCHAR(20),
                             user_password VARCHAR(25)) 
                RETURNS BOOLEAN
BEGIN
  DECLARE user_salt  CHAR(10);
  DECLARE hashed     CHAR(64);
  DECLARE authorized BOOLEAN DEFAULT FALSE;
  -- get salt and hashed password from desired user
  SELECT salt, password_hash INTO user_salt, hashed
    FROM user_info
    WHERE username = user_name;
  -- concatinate salt and hash and see if it matches the 
  -- hashed password in the table
  IF SHA2(CONCAT(user_salt, user_password), 256) = hashed
    THEN SET authorized = TRUE;
  END IF;
  RETURN authorized;
  -- if username doesn't exist in the table so the select statment
  -- will return nothing so the if statement will be false so 
  -- authorized will remain false so we don't have to explicitly 
  -- check for the username existing
END !
DELIMITER ;





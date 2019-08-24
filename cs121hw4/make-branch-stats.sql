-- [Problem 1]
CREATE INDEX idx_branch_name ON account (branch_name);


-- [Problem 2]
DROP TABLE IF EXISTS mv_branch_account_stats;

-- Table containing materilized view with summary account stats
CREATE TABLE mv_branch_account_stats (
    branch_name    VARCHAR(15)    NOT NULL,
    num_accounts   INTEGER        NOT NULL,
    total_deposits INTEGER        NOT NULL,
    min_balance    NUMERIC(12, 2) NOT NULL,
    max_balance    NUMERIC(12, 2) NOT NULL,
    PRIMARY KEY (branch_name)
);


-- [Problem 3]
INSERT INTO mv_branch_account_stats 
  SELECT branch_name,
         COUNT(*) AS num_accounts,
         SUM(balance) AS total_deposits,
         MIN(balance) AS min_balance,
         MAX(balance) AS max_balance
  FROM account
  GROUP BY branch_name;

-- [Problem 4]
DROP VIEW IF EXISTS branch_account_stats;

-- View containing stats from materialized view
-- also contains avg balance
CREATE VIEW branch_account_stats AS 
  SELECT *, 
         CAST((total_deposits / num_accounts) AS DECIMAL(12, 2)) AS avg_balance
    FROM mv_branch_account_stats;

-- [Problem 5]
DELIMITER !

CREATE PROCEDURE insert_prod(
  IN branch_name VARCHAR(20),
  IN balance NUMERIC(12, 2)
)
BEGIN
    -- if tuple being inserted is first from a branch
    -- insert into mv. If not, update mv
    INSERT INTO mv_branch_account_stats VALUES
                (branch_name, 1, balance, balance, balance)
    ON DUPLICATE KEY 
      UPDATE num_accounts = num_accounts + 1,
             total_deposits = total_deposits + balance,
             min_balance = LEAST(min_balance, balance),
             max_balance = GREATEST(max_balance, balance);
END !

DELIMITER ; 

DROP TRIGGER IF EXISTS trg_insert_accounts;

DELIMITER !

CREATE TRIGGER trg_insert_accounts 
               AFTER INSERT ON account FOR EACH ROW
BEGIN
    CALL insert_prod(NEW.branch_name, NEW.balance);
END !

DELIMITER ;

-- [Problem 6]
DROP PROCEDURE IF EXISTS delete_prod;

DELIMITER !

CREATE PROCEDURE delete_prod(
  IN branch_name VARCHAR(20),
  IN bal NUMERIC(12, 2)
)
BEGIN
  -- holds number of branches, minimum balance,
  -- and maximum balance of a branch from updated account
  DECLARE b_count INTEGER;
  DECLARE min_bal NUMERIC(12, 2);
  DECLARE max_bal NUMERIC(12, 2);
  SELECT COUNT(*), MIN(balance), MAX(balance)
  INTO b_count, min_bal, max_bal
  FROM account as a
  WHERE a.branch_name = branch_name;
  
  -- 0 because the trigger is after the delete
  -- if it was the last row deleted, delete the
  -- associated branch from mv. If not, update mv.
  IF b_count = 0 THEN
    DELETE FROM mv_branch_account_stats  
           WHERE mv_branch_account_stats.branch_name = branch_name;
  ELSE UPDATE mv_branch_account_stats
       SET num_accounts = num_accounts - 1,
           total_deposits = total_deposits - bal,
           min_balance = min_bal,
           max_balance = max_bal
       WHERE mv_branch_account_stats.branch_name = branch_name;
  END IF;
END !

DELIMITER ; 

DROP TRIGGER IF EXISTS trg_delete_accounts;

DELIMITER !

CREATE TRIGGER trg_delete_accounts 
               AFTER DELETE ON account FOR EACH ROW
BEGIN
    CALL delete_prod(OLD.branch_name, OLD.balance);
END !

DELIMITER ;


-- [Problem 7]
DROP TRIGGER IF EXISTS trg_update_accounts;

DELIMITER !

CREATE TRIGGER trg_update_accounts 
               AFTER UPDATE ON account FOR EACH ROW
BEGIN
    -- If account number or balance was changed then update mv
    IF NEW.branch_name = OLD.branch_name THEN
      UPDATE mv_branch_account_stats
        SET total_deposits = total_deposits + NEW.balance - OLD.balance,
            min_balance = LEAST(NEW.balance, min_balance),
            max_balance = GREATEST(NEW.balance, max_balance)
        WHERE branch_name = NEW.branch_name;
    -- If branch name was changed treat it as deletion of the old branch 
    -- and insertion of a new branch
    ELSE 
      CALL delete_prod(OLD.branch_name, OLD.balance);
      CALL insert_prod(NEW.branch_name, NEW.balance);
    END IF;
END !

DELIMITER ;


-- [Problem 1a]
SELECT loan_number, amount 
  FROM loan 
  WHERE amount >= 1000 AND amount <= 2000;


-- [Problem 1b]
SELECT loan_number, amount
  FROM customer NATURAL JOIN borrower NATURAL JOIN loan
  WHERE customer_name = 'Smith'
  ORDER BY loan_number;


-- [Problem 1c]
SELECT branch_city 
  FROM branch NATURAL JOIN account 
  WHERE account_number = 'A-446';
  

-- [Problem 1d]
SELECT customer_name, account_number, branch_name, balance
  FROM customer NATURAL JOIN depositor NATURAL JOIN branch NATURAL JOIN account
  WHERE customer_name REGEXP '^J.*'
  ORDER BY customer_name;


-- [Problem 1e]
SELECT customer_name
  FROM customer NATURAL JOIN depositor
  GROUP BY customer_name
  HAVING count(account_number) > 5;


-- [Problem 2a]
CREATE VIEW pownal_customers AS 
  SELECT customer_name, account_number
  FROM customer NATURAL JOIN depositor NATURAL JOIN account
  WHERE branch_name = 'Pownal';


-- [Problem 2b]
CREATE VIEW onlyacct_customers AS 
  SELECT customer_name, customer_street, customer_city
  FROM customer
  WHERE (customer_name) NOT IN (SELECT customer_name FROM borrower) 
         AND (customer_name) IN (SELECT customer_name FROM depositor);



-- [Problem 2c]
CREATE VIEW branch_deposits AS
  SELECT branch_name, IFNULL(SUM(balance), 0) AS total_balance, 
         AVG(balance) AS avg_balance
  FROM branch NATURAL LEFT JOIN account
  GROUP BY branch_name;
  
  
-- [Problem 3a]
SELECT DISTINCT customer_city
  FROM customer 
  WHERE (customer_city) NOT IN 
        (SELECT branch_city FROM branch)
  ORDER BY customer_city; 



-- [Problem 3b]
SELECT customer_name
  FROM customer
  WHERE (customer_name) NOT IN (SELECT customer_name FROM borrower) 
         AND (customer_name) NOT IN (SELECT customer_name FROM depositor);

-- [Problem 3c]
UPDATE account
SET balance = balance + 50
WHERE (branch_name) IN (SELECT branch_name 
                          FROM branch 
                          WHERE branch_city = 'Horseneck');


-- [Problem 3d]
UPDATE account NATURAL JOIN branch
SET balance = balance + 50
WHERE branch_city = 'Horseneck';

-- [Problem 3e]
SELECT account_number, branch_name, balance
  FROM account NATURAL JOIN (SELECT branch_name, max(balance) AS balance
                               FROM account 
                               GROUP BY branch_name) 
                               AS max_of_branches;


-- [Problem 3f]
SELECT *
  FROM account
  WHERE (branch_name, balance) IN
  (SELECT branch_name, max(balance) AS balance
    FROM account 
    GROUP BY branch_name);


-- [Problem 4]
SELECT b1.branch_name AS branch_name, 
       b1.assets AS assets, count(b1.assets) as rank
  FROM branch AS b1, branch AS b2
  WHERE b1.assets < b2.assets OR b1.branch_name = b2.branch_name
  GROUP BY b1.branch_name, b1.assets
  ORDER BY rank DESC, branch_name ASC;


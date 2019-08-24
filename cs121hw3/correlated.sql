-- [Problem a]
-- This query computes the number of loans each 
-- customer has.

SELECT customer_name, COUNT(DISTINCT loan_number) AS num_loans
  FROM customer NATURAL LEFT JOIN borrower 
  GROUP BY customer_name
  ORDER BY num_loans DESC;

-- [Problem b]
-- This computes the branches where thier loans
-- exceed their assets

SELECT branch_name 
  FROM branch NATURAL JOIN (SELECT branch_name, SUM(amount) AS total_loan
                              FROM loan
                              GROUP BY branch_name) AS sum_loans
  WHERE assets < total_loan;

-- [Problem c]
SELECT branch_name, 
  (SELECT COUNT(*)  
   FROM account AS a
   WHERE a.branch_name = b.branch_name) AS num_accounts,
  (SELECT COUNT(*)
   FROM loan AS l
   WHERE l.branch_name = b.branch_name) AS num_loans
   FROM branch AS b;

-- [Problem d]
SELECT branch_name, COUNT(DISTINCT account_number) AS num_accounts, 
       COUNT(DISTINCT loan_number) AS num_loans
  FROM branch NATURAL LEFT JOIN account NATURAL LEFT JOIN loan
  GROUP BY branch_name;



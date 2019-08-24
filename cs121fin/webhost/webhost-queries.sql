-- [Problem 1.4a]
SELECT hostname 
  FROM shared_server NATURAL JOIN (SELECT hostname, COUNT(*) AS sites
                             FROM customer_acct NATURAL JOIN 
                                  basic_customer
                             GROUP BY hostname) AS site     
  WHERE sites > max_sites;

-- [Problem 1.4b]
UPDATE customer_acct
SET sub_price = sub_price - 2
WHERE username IN (SELECT username
                   FROM basic_customer NATURAL JOIN
                        customer_software
                   GROUP BY username
                   HAVING COUNT(*) > 2);
                   

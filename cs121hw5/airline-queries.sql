-- [Problem 6a]
SELECT * FROM purchase JOIN ticket ON purchase.purchase_id = ticket.purchase_id
              JOIN plane_customer ON 
              ticket.customer_id = plane_customer.customer_id
  WHERE purchase.customer_id = 54321
  ORDER BY purchase_time DESC, flight_date, 
           last_name, first_name;

SELECT * FROM purchase JOIN ticket ON purchase.purchase_id = ticket.purchase_id
              JOIN plane_customer ON 
              ticket.customer_id = plane_customer.customer_id;
              
-- [Problem 6b]
WITH flights AS (
  SELECT type_code, sum(sale_price) as revenue
  FROM flight NATURAL JOIN ticket
  WHERE flight_date BETWEEN CURDATE() - INTERVAL 2 WEEK AND CURDATE()
  GROUP BY type_code
)
SELECT type_code, IFNULL(revenue, 0) AS revenue
  FROM airplane NATURAL LEFT JOIN flights;
  
-- [Problem 6c]
SELECT DISTINCT customer_id, first_name, last_name, email
  FROM flight NATURAL JOIN ticket NATURAL JOIN traveler
       NATURAL JOIN plane_customer
  WHERE international AND (ISNULL(passport_number) OR
                           ISNULL(country) OR
                           ISNULL(emergency_contact) OR
                           ISNULL(ec_phone_number));



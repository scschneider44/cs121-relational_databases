-- [Problem 1a]
SELECT DISTINCT name 
  FROM (takes NATURAL JOIN student) 
        INNER JOIN course USING (course_id)
  WHERE course.dept_name = 'Comp. Sci.';

-- [Problem 1b]
SELECT dept_name, MAX(salary) AS max_salary
  FROM department NATURAL JOIN instructor
  GROUP BY dept_name;

-- [Problem 1c]
SELECT MIN(max_salary) AS min_max_salary 
  FROM (SELECT dept_name, MAX(salary) AS max_salary
        FROM instructor
        GROUP BY dept_name) AS max_salaries;

-- [Problem 1d]
WITH max_salaries AS
(
  SELECT dept_name, MAX(salary) AS max_salary
    FROM instructor
    GROUP BY dept_name
)
SELECT MIN(max_salary) AS min_max_salary
  FROM max_salaries;

-- [Problem 2a]
INSERT INTO course VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', '3');

-- [Problem 2b]
INSERT INTO section VALUES ('CS-001', '1', 'Fall', '2009', NULL, NULL, NULL);

-- [Problem 2c]
INSERT INTO takes 
  SELECT DISTINCT ID, 'CS-001', '1', 'Fall', '2009', NULL 
  FROM takes NATURAL JOIN student 
  WHERE dept_name = 'Comp. Sci.';

-- [Problem 2d]
DELETE FROM takes 
WHERE (ID) IN (SELECT ID FROM student
               WHERE name = 'Chavez')
      AND course_id = 'CS-001'
      AND sec_id = '1'
      AND semester = 'Fall'
      AND year = 2009;

-- [Problem 2e]
DELETE FROM course WHERE course_id = 'CS-001';

-- If you do this before deleting the sections of this course
-- the sections in section and takes will get deleted when you 
-- delete the course. This is because of the foreign key relations
-- that the tables share. Thus the tables have referencial integrity.


-- [Problem 2f]
DELETE FROM takes 
WHERE (course_id) IN (SELECT course_id 
                        FROM course
                        WHERE LOWER(title) like '%database%');

-- [Problem 3a]
SELECT DISTINCT name 
  FROM member NATURAL JOIN book NATURAL JOIN borrowed
  WHERE publisher = 'McGraw-Hill';

-- [Problem 3b]
SELECT name FROM member NATURAL JOIN book NATURAL JOIN borrowed
  WHERE publisher = 'McGraw-Hill' 
  GROUP BY name
  HAVING COUNT(name) = (SELECT COUNT(isbn) 
                          FROM book 
                          WHERE publisher = 'McGraw-Hill');

-- [Problem 3c]
SELECT name
  FROM member NATURAL JOIN book NATURAL JOIN borrowed
  GROUP BY name, publisher
  HAVING COUNT(isbn) > 5;


-- [Problem 3d]
SELECT AVG(num_books) as avg_books
  FROM (SELECT COUNT(isbn) as num_books
          FROM member natural left join borrowed
          GROUP BY name) AS books_per_person;


-- [Problem 3e]
WITH books_per_person AS
(
 SELECT COUNT(isbn) AS num_books
   FROM member natural left join borrowed
   GROUP BY name
)
SELECT AVG(num_books) AS avg_books
  FROM books_per_person;



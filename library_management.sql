-- Library Management System Project 2

-- creating branch table

DROP TABLE IF EXISTS branch;
Create Table branch(
	branch_id	varchar(10) PRIMARY KEY,
	manager_id	varchar(10),
	branch_address	varchar(225),
	contact_no varchar (10)
	);

Alter table branch --changing the data type for some columns in branch table.
Alter column contact_no type varchar(50);

DROP TABLE IF EXISTS employees;
Create Table employees(
	emp_id	varchar(10) primary key,
	emp_name varchar (255),
	position varchar (25),	
	salary INT,
	branch_id varchar (25) --FK
	);


DROP TABLE IF EXISTS books;
Create Table books(
	isbn varchar(20) primary key,
	book_title varchar(75),
	category varchar(50),
	rental_price float,
	status varchar(15),
	author varchar(20),
	publisher varchar(55)
	);
	
Alter table books -- changing the data type for some columns in books table
Alter column category type varchar(50), 
Alter column author type varchar(50);



DROP TABLE IF EXISTS members;
Create Table members(
	member_id varchar(10) primary key,
	member_name varchar (25),
	member_address varchar(75),
	reg_date date
	);



DROP TABLE IF EXISTS issued_status;
Create Table issued_status(
	issued_id varchar(10) primary key,
	issued_member_id varchar(10), --FK
	issued_book_name varchar(75),	
	issued_date date,	
	issued_book_isbn varchar(25), --FK
	issued_emp_id varchar(10) --FK
	);



DROP TABLE IF EXISTS return_status;
Create Table return_status(
	return_id varchar(10) primary key,
	issued_id varchar(10), --FK
	return_book_name varchar(75),
	return_date date,
	return_book_isbn varchar(20)
	);


-- Defining the relationships between the keys

-- FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id); 

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn); 

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id); 

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id); 

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id); 


--Verifying if all tables have been successfully uploaded. 
Select * 
from books;

Select * 
from branch;

select *
from employees;

Select * 
from issued_status

Select * 
from members;

Select * 
from return_status;


--PROJECT TASK

/*Task 1. Create a New Book Record -- "978-1-60129-456-2', 
'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')" 
*/

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
Values 
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');


--Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'; 


--Task 3: Task 3: Delete a Record from the Issued Status Table  
--Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE from issued_status
WHERE 'issued_id' = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101'

--Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.


SELECT issued_emp_id,
	count(issued_id) as total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING count(issued_id) > 1


--CTA
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**


CREATE TABLE book_cnts
AS
SELECT 
	b.isbn,
	b.book_title,
	count (ist.issued_id) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
Group by b.isbn, b.book_title;


-- Task 7. Retrieve All Books in a Specific Category:
SELECT *
FROM books
WHERE category = 'Classic';


-- Task 8: Find Total Rental Income by Category:

SELECT 
	b.category,
	sum (b.rental_price) as rental_income,
	count(*) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
Group by category


--Task 9: List Members Who Registered in the Last 180 Days:

Select *
from members
where reg_date >= current_date - interval '180 days'

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

select 
	e1.*, 
	b.manager_id,
	e2.emp_name as manager
from employees as e1
join branch as b
on e1.branch_id = b.branch_id
join employees as e2
on b.manager_id = e2.emp_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
drop table if exists books_price_greater_than_7;
create table books_price_greater_than_7
as
select *
from books
Where rental_price > 7;


-- Task 12: Retrieve the List of Books Not Yet Returned

select 
	b.isbn,
	b.book_title,
	ist.issued_book_name,
	b.category
from books as b
join issued_status as ist
on b.isbn = ist.issued_book_isbn
left join return_status as rst
on ist.issued_id = rst.issued_id
where return_id is null 


/* Task 13: Identify members with overdue books
Write a query to identify members who have overdue books (assume a 300-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

Select 
	iss.issued_id,
	iss.issued_book_name as book_name,
	mem.member_name,
	iss.issued_date,
	current_date - iss.issued_date as over_dues
from issued_status as iss
left join members as mem
on iss.issued_member_id = mem.member_id
left join return_status as rs
on iss.issued_id = rs.issued_id

where rs.return_date is Null 
and (current_date - iss.issued_date) > 300

order by mem.member_id;


/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to 'Yes' when they are returned 
(based on entries in the return_status table)
*/


--Store Procedure
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR (10), p_issued_id VARCHAR (10))
LANGUAGE plpgsql
AS $$
DECLARE
	v_isbn VARCHAR (20);
	v_book_name VARCHAR (75);
BEGIN
-- all logic and code here
-- inserting into returns based on users input
	INSERT  INTO return_status(return_id, issued_id, return_date)
	VALUES
		(p_return_id, p_issued_id, current_date);

	SELECT
	issued_book_isbn,
	issued_book_name
	INTO
	v_isbn,
	v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET Status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;

END;
$$

CALL add_return_records('RS138', 'IS135');

/* Task 15: Branch Perfomance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned,
 and the total revenue generated from book rentals.

*/


Create table branch_report
As
Select 
	t1.branch_id, 
	t1.manager_id, 
	count(t1.issued_id) as issued_count, 
	count(t1.return_id) as return_count, 
	sum(t1.rental_price) as total_revenue
From
(
select 
	br.branch_id, 
	ist.issued_id, 
	ist.issued_date, 
	rt.return_date, 
	rt.return_id, 
	bk.book_title, 
	bk.rental_price, 
	br.manager_id
from issued_status as ist
left join employees as emp
on ist.issued_emp_id = emp.emp_id
left join branch as br
on emp.branch_id = br.branch_id
join books as bk
on ist.issued_book_isbn = bk.isbn
left join return_status as rt
on ist.issued_id = rt.issued_id

)as t1

Group by t1.branch_id, t1.manager_id;

/* Task 16: CTAS: Create a Table of Active Members
Use the Create Table as (CTAS) statement to create a new table ative_members containing 
members who have issued at least one book in the last 14 months. 

*/

Create table active_members
As
Select * from members
Where member_id in (Select
						Distinct issued_member_id
					From issued_status
					Where
						issued_date >= current_date - interval '14 months'
					)


/* Task 17: Find employees with the most book issues processed
Write a query to find te top 3 employees who have processed the most book issues. 
Display the employees name, number of books processed, and their branch. 
*/

Select emp.emp_name, emp.emp_id, count(ist.issued_id) as no_books_processed
From issued_status as ist
Join employees as emp
on ist.issued_emp_id = emp.emp_id

Group by emp.emp_name, emp.emp_id

Order by no_books_processed desc;


/*Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. The procedure
should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the 
status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should
return an error message indicating that the book is currently not available. 
*/


Create or Replace Procedure issue_book(p_issued_id Varchar(10), p_issued_member_id Varchar (10), p_issued_book_isbn Varchar(25), p_issued_emp_id Varchar(10))
Language plpgsql
As $$

Declare
-- all the variables
	v_status Varchar(15);

Begin
-- all the code and logic
	--checking if book is available 'yes'
	Select 
		status 
		Into
		v_status
	From books 
	Where isbn = p_issued_book_isbn;

	If v_status = 'yes' then
	
		Insert Into issued_status(issued_id,issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		Values 
			(p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id);

		Update books
			Set status = 'no'
		Where isbn = p_issued_book_isbn;

		Raise Notice 'Book records added successfully for book isbn: %', p_issued_book_isbn;
	Else
		Raise Notice 'Sorry the book you have requested is unavailable book isbn: %', p_issued_book_isbn;	
	End if;

End;
$$


Call issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104')



--End of Project















	
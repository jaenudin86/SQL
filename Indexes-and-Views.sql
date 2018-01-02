/*
INDEXES AND VIEWS
This assignment uses CommmunityAssist again:
*/
USE CommunityAssist
/*
All of these are nonclustered indexes
*/

--MY NOTES:
--Adding the NONCLUSTERED keyword to a simply nonclustered index is not necessary in SQL Server

--1.  Place an index on DonationDate in Donation
CREATE INDEX IndexDonationDate
ON Donation(DonationDate)

--2.  Place an index on PersonKey in Donation
CREATE INDEX IndexDonationPersonKey
ON Donation(PersonKey)

--3.  Place an index on PersonKey in PersonAddress
CREATE INDEX IndexPersonAddressPersonKey
ON PersonAddress(PersonKey)

--4.  Place an index on PersonKey in PersonContact
CREATE INDEX IndexPersonContactPersonKey
ON PersonContact(PersonKey)

--5.  Place an index on LastName in Person
CREATE INDEX IndexLastNamePerson
ON Person(PersonLastName)

--6.  Place a filtered index on GrantDate in serviceGrant where GrantReview date is null

--MY NOTES:
--The filter predicate can include columns that are not key columns in the filtered index.
--You create a filtered index using almost the same syntax for a standard non-clustered index.  The only difference is that you add a WHERE clause that determines which rows are indexed.  Also, add the NONCLUSTERED keyword.

CREATE NONCLUSTERED INDEX "FilteredIndexSGGrantDateWhereGrantReviewIsNull"
ON ServiceGrant(GrantDate)
WHERE GrantReviewDate IS NULL

/* 
--MY NOTES:
-- If you needed to drop an index, this is the syntax:
DROP INDEX FilteredIndexSGGrantDateWhereGrantReviewIsNull
ON ServiceGrant
*/

/*
Views
*/

--1.  Create a view that gives the employees first name, last name,  the date they were hired, their job title, their status and their salary.

--MY NOTES: This task uses the following tables:  Person, Employee, EmployeeJobTitle
GO --You must use the Go keyword
CREATE VIEW vwEmployee 
AS
SELECT p.PersonFirstName, p.PersonLastName, e.EmployeeHireDate, ejt.JobTitleKey, e.EmployeeStatus, e.EmployeeMonthlySalary
FROM Person p JOIN (
	Employee e JOIN EmployeeJobTitle ejt 
	ON e.EmployeeKey = ejt.EmployeeKey)
	ON p.PersonKey = e.PersonKey
GO

--2.  Create a view that gives the names and emails of all donors.

--MY NOTES:  This task uses the following tables: Donation, Person
GO 
CREATE VIEW vwDonor
AS
SELECT p.PersonLastName, p.PersonFirstName, p.PersonUsername
FROM Person P INNER JOIN Donation D
ON p.PersonKey = d.PersonKey
GO
 
--3.  Create a view that shows the total grants requested, and the total allocated by year and month.
--MY NOTES:  This uses ServiceGrant
GO
CREATE VIEW vwTotalGrants2
AS
SELECT 'Year' = YEAR(GrantDate), 'Month' = MONTH(GrantDate), 'Total Grants Requested' = COUNT(GrantKey), 'Total Allocated' = SUM(GrantAllocation) 
FROM ServiceGrant
GROUP BY YEAR(GrantDate), MONTH(GrantDate)
GO
--4.  Create a view that shows the number of grants reviewed per year and month.
GO
CREATE VIEW vwTotalGrants1
AS
SELECT 'Year' = YEAR(GrantDate), 'Month' = MONTH(GrantDate), 'Total Grants Reviewed' = COUNT(gr.GrantKey)
FROM ServiceGrant sg JOIN GrantReview gr
ON sg.GrantKey = gr.GrantKey
GROUP BY YEAR(GrantDate), MONTH(GrantDate)
GO

/*MY NOTES:
--Clustered indexes is the system's defaut indexing process
It will store the data on disk, sorted (indexed) by primary key column
--Non-clustered indexes make a copy of your table data, store it on disk, and have it sorted by whatever you designate (instead of the primary key)

	The SQL Server query optimizer will use your nonclustered index to search for that designated thing when you use a SELECT statement to find it.

--Example:  You create a nonclustered index on LastName.  
--SELECT LastName FROM  ExampleTable.  This SELECT statement uses the nonclustered index for LastName.

--You can alter the default clustered index, but you may only have one (1) clustered index per table (so choose wisely).
Altering the clusterd index creates some performance issues:  Inserts are sloswer, and lookups from non-clustered indexes must look up the query pointer in teh clustered ine to get the pointer to the actual data reacords instead of going directly to the data on disk (this is a negligible performance hit).

--Nonclustered indexes are not copies of the table but a soring of the columns you specify that "point" back to the data pages in teh clustered index.  This is why the clustered index you choose is so important because it effects all other indexes.

--There are two(2) modes for nonclustered indexs: Non-unique and unique.  
Non-unique means that the index does not act as a constraint on the table and does not prevent identical rows from being inserted.
Unique constraints mean that the index prevents any identical rows from being inserted.

--Does not re-order the actual table data
--Sometimes called a "heap table" for tables lacking clustered indexes because it points to the actual data pages that are essentially unordered and non-indexed.
--If no clustered index, non-clustered indexes point to the actual data in the table.
--If clustered index present, non-clustered index point to clustered index.
--Logical order of the index does not match the physical stored order of the rows on disk.
--Similar to an index in the back of a book.  The actual data is stored in the pages of the book but the index reorders and stores a pointer to each data value.

BEST PRACTICES FOR NON-CLUSTERED INDEXES
-Add nonclustered indexes for queries that return smaller result sets.  Large results will have to read more table pages anyway so they will not benefit as much from a non-clustered index.
--Add to columns used in WHERE clauses that return exact matches.
--If a clustered index is not used on these columns, add an index for collections of distinct values that are commonly queried such as a first and last name column group.
--Add for all columns grouped together for a given query that is expensive or very common on a large data table. 
--Add to foreign-key columns where joins are common that are not covered by the clustered index.

--Lage amounts of selects on a table  = create a clustered index on the primary key of the table.  Then create nonclusted indexes for all other columns used in selects and searches.  Put nonclustered indexes on foreign key/primary key columns that are used in joins.

--Indexes are a lot of "trial and error" depending on your database design, SQL queries, and database size.
*/

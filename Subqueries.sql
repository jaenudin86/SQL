/*
SUBQUERIES
For each of these questions use a subquery, even if you can do it in a join.
*/
USE CommunityAssist
--1.  Return the personKey, donation date and the donation amount for the highest donation.

--My approach is uses the operator '=' with the subquery.
SELECT PersonKey, DonationDate, DonationAmount
FROM Donation
WHERE DonationAmount = 
	(SELECT MAX(DonationAmount)
	FROM Donation)


--2.  List the first names and last names of every person who is an employee.
-- MY NOTES:
--This statement uses the following tables: Person, Employee
SELECT PersonFirstName 'First Name', PersonLastName 'Last Name'
FROM Person p
WHERE p.PersonKey
IN (SELECT	e.PersonKey
	FROM Employee e
	WHERE e.PersonKey = p.PersonKey)
ORDER BY p.PersonKey

--3.  Get the names of all the services that have never been offered.
-- MY NOTES:
--This statement uses the following tables: CommunityService, ServiceGrant
--If I'm understanding the task correctly, this is the same task as number 8 in Assignment 4. 
--The only difference is that this tasks requires the use of a subquery (instead of a join).
--FOR STEVE: Are my above-referenced assumptions about this task correct?

SELECT cs.ServiceName
FROM CommunityService cs
WHERE cs.ServiceKey
NOT IN (SELECT sg.ServiceKey
	FROM ServiceGrant sg)
ORDER BY cs.ServiceName


--4.  Get the names of each employee who was involved in a grant review.
--MY NOTES: This task uses the following tables: Employee, GrantReview, Person
SELECT p.PersonFirstName, p.PersonLastName
FROM Person p
WHERE p.PersonKey
IN (SELECT e.PersonKey
	FROM Employee e
	WHERE e.EmployeeKey
	IN (SELECT gr.EmployeeKey
		FROM GrantReview gr))
ORDER BY p.PersonLastName
--ANSWER:  There happens to be only ONE employee in the GrantReview table (EmployeeKey 5)
--so the result is that one employee, Jessie Conner

/*
5.  
This is hard, but useful and can only be done with a subquery.  
Get the total number of grants, the count of grants denied and the counts of grants reduced.
What is the percent denied and the percent reduced?  You can do this in one query.
*/
-- MY NOTES:This task uses the following tables: ServiceGrant
SELECT COUNT(GrantKey) 'Total Number of Grants',
	(SELECT COUNT(GrantKey) FROM ServiceGrant WHERE GrantApprovalStatus = 'denied') 'Total Number of Grants Denied', 
	(SELECT COUNT(GrantKey) FROM ServiceGrant WHERE GrantApprovalStatus = 'reduced') 'Total Number of Grants Reduced',
	cast(Cast((Select count(GrantKey) From ServiceGrant where GrantApprovalStatus='denied')as decimal(5,2))
	/cast(count(GrantKey)as Decimal(5,2)) * 100 as Decimal(5,2)) as [Percent Denied],
	cast(Cast((Select count(GrantKey) From ServiceGrant where GrantApprovalStatus='reduced')as decimal(5,2))
	/cast(count(GrantKey)as Decimal(5,2)) * 100 as Decimal(5,2)) as [Percent Reduced]
FROM ServiceGrant

/*
6.
This is also hard.  It is a correlated subquery.  
We want to find those grants with an allocated amount greater than the average.
But we don't what to compare apples to oranges.  
So we only want Rental amounts compared with rental amounts, food with food etc.
Look at the example in the blog.
*/
SELECT ServiceKey,
	(SELECT ServiceName FROM CommunityService cs WHERE cs.ServiceKey = sg.ServiceKey) 'Service Name', 
	GrantAllocation, 
	(SELECT AVG(GrantAllocation) FROM ServiceGrant sg1 WHERE sg.ServiceKey = sg1.ServiceKey) 'Average allocated amount'
FROM ServiceGrant sg
WHERE GrantAllocation >
	(SELECT AVG(GrantAllocation)
	FROM ServiceGrant sg1
	WHERE sg.ServiceKey = sg1.ServiceKey)

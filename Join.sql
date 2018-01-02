/*
JOINS
*/
USE CommunityAssist

SELECT * 
FROM Employee

SELECT *
FROM Person
--1.  Return the first name, last name, hire date, status and monthly salary for each employee.
SELECT PersonFirstName 'First Name', 
	PersonLastName 'Last Name', 
	EmployeeHireDate 'Hire Date', 
	EmployeeStatus 'Status', 
	EmployeeMonthlySalary 'Monthly Salary'
FROM Employee e JOIN Person p
ON e.PersonKey = p.PersonKey

--2.  Return the first name, last name, hire date, status, title and monthly salary for each employee.
SELECT PersonFirstName 'First Name', 
	PersonLastName 'Last Name', 
	EmployeeHireDate 'Hire Date', 
	EmployeeStatus 'Status', 
	JobTitleName 'Job Title', 
	EmployeeMonthlySalary 'Monthly Salary'
FROM Person p JOIN
	(Employee e JOIN 
	(EmployeeJobTitle ejt JOIN JobTitle jt
	ON jt.JobTitleKey = ejt.JobTitleKey)
	ON e.EmployeeKey = ejt.EmployeeKey)
	ON p.PersonKey = e.PersonKey
--ANSWER:  This statement joins FOUR different tables:  Person, Employee, EmployeeJobTitle, and JobTitle.

--3.  Return the all the information for employee listed in 2 and then also return their address.
--MY NOTES:
--My approach concatenates the following columns from the PersonAddress table to create on Address column: Street, Apartment, City, State, Zip.
--I use the IIF function to check whether or not the Apartment column in the PersonAddress table has a value
--If it does, then the value is added to the concatenated string as Apt. + (Apartment) + ', '.
--If it doesn't, then ', ' is added to the concatenated string
--So, IIF(pa.Apartment IS NOT NULL, (' Apt.'+ Apartment + ', '), ', ')   is essentially IIF ( boolean_expression, true_value, false_value ) 
SELECT PersonFirstName 'First Name', 
	PersonLastName 'Last Name', 
	CONCAT(Street, (IIF(pa.Apartment IS NOT NULL, (' Apt.'+ Apartment + ', '), ', ')), City, ', ', State, ', ', Zip) 'Address',
	EmployeeHireDate 'Hire Date', 
	EmployeeStatus 'Status', 
	JobTitleName 'Job Title', 
	EmployeeMonthlySalary 'Monthly Salary'
FROM Person p JOIN
	(PersonAddress pa JOIN
	(Employee e JOIN
	(EmployeeJobTitle ejt JOIN JobTitle jt
	ON jt.JobTitleKey = ejt.JobTitleKey)
	ON e.EmployeeKey = ejt.EmployeeKey)
	ON pa.PersonKey = e.PersonKey)
	ON p.PersonKey = pa.PersonKey

--4.  Return the same as in 3, but set it up in the older syntax that uses the where clause rather than the join syntax.
SELECT PersonFirstName 'First Name', 
	PersonLastName 'Last Name', 
	CONCAT(Street, (IIF(pa.Apartment IS NOT NULL, (' Apt.'+ Apartment + ', '), ', ')), City, ', ', State, ', ', Zip) 'Address',
	EmployeeHireDate 'Hire Date', 
	EmployeeStatus 'Status', 
	JobTitleName 'Job Title', 
	EmployeeMonthlySalary 'Monthly Salary'
FROM Person p, PersonAddress pa,Employee e, EmployeeJobTitle ejt, JobTitle jt 
WHERE jt.JobTitleKey = ejt.JobTitleKey
	AND e.EmployeeKey = ejt.EmployeeKey
	AND pa.PersonKey = e.PersonKey
	AND p.PersonKey = pa.PersonKey

--5.  Return a cross join of employee and person. 
SELECT *
FROM Employee CROSS JOIN Person

--6.  Return the last name, first name and the service name and grant Allocation for all those who applied for school asssistance.
--MY NOTES:
--This uses the following tables: CommunityService, Person, ServiceGrant
SELECT PersonFirstName 'First Name', 
	PersonLastName 'Last Name',
	ServiceName 'Service Name',
	GrantAllocation 'Grant Allocation'
FROM Person p JOIN
	(ServiceGrant sg JOIN CommunityService cs
	ON sg.ServiceKey = cs.ServiceKey)
	ON p.PersonKey = sg.PersonKey

--7.  Get the names of the services and the total of all that has been granted for each service.
--MY NOTES:
--This uses the following tables: CommunityService, ServiceGrant
SELECT ServiceName 'Service Name', SUM(GrantAllocation) 'Total Amount Granted'
FROM CommunityService cs JOIN ServiceGrant sg
ON cs.ServiceKey = sg.ServiceKey
GROUP BY ServiceName

--8.  Return the name of all the services that have never been granted (ServiceGrant).

--This uses tables CommunityService and ServiceGrant
--The task is to find the ServiceNames PRESENT IN THE COMMUNITYSERVICE TABLE that were never used in the GrantApprovalStatus table.  
--The task is NOT to find ServiceNames in the ServiceGrant table that never had any other status other than denied (as was my understanding upon first reading).  This task would not be valid because all ServiceNames in the ServiceGrant table have statuses other than denied (e.g. approved, reduced).
SELECT ServiceName, GrantApprovalStatus
FROM CommunityService cs
LEFT JOIN ServiceGrant sg 
ON cs.ServiceKey = sg.ServiceKey
WHERE sg.ServiceKey IS NULL

--9.  Return the names of all the people who are not donors.

--This task uses the following tables:  Person, Donation
--The tasks is similar to task 8:  It is to find the names of all the people IN THE PERSON TABLE who do not have a personkey in the Donation table.
SELECT PersonLastName 'Last Name', PersonFirstName 'First Name'
FROM Person p
LEFT JOIN Donation d
ON p.PersonKey = d.PersonKey
WHERE d.PersonKey IS NULL

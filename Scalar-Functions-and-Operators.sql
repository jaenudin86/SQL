/*
ASSIGNMENT 2 - SCALAR FUNCTIONS
Alias all calculated columns
*/
USE CommunityAssist

--Practice
/*
SELECT PersonLastName, 
		7 AS 'Face Rating',
		Personpasskey * 3 AS 'New passkey'	
FROM Person
ORDER BY PersonLastName 

SELECT 2 + 3
*/

/*1.  
Use the table ServiceGrant.  
What is the difference between the grant amount and the actual amount alloted 
	when the grant allocation is less than the grant amount?
Show the grant amount, the allocation, and the difference.
*/
SELECT GrantAmount, GrantAllocation, (GrantAmount - GrantAllocation) AS 'Difference'
FROM ServiceGrant sg
WHERE sg.GrantAllocation < sg.GrantAmount

/*2.
Return all the people in the Person table as a single column formatted as Lastname, firstname, email.  
Example:  Anderson, Jay  JAnderson@gmail.com
*/
--I've found TWO ways to accomplish the task, each yielding exactly the same result.
--Option 1
SELECT PersonLastName + ' , ' + PersonFirstName + '   ' + PersonUsername AS 'Lastname, Firstname, Email'
FROM Person

--Option 2
SELECT CONCAT(PersonLastName, ', ', PersonFirstName, '  ', PersonUserName) AS 'Lastname, Firstname, Email'
FROM Person

/*3.
Return the personKeys of all donors.  
But only return each key once.
*/
SELECT DISTINCT PersonKey
FROM Person

/*4.
Use the date functions and concatenation to return the donation date in the format month/day/year.
Example: 9/8/2013
*/
--I've found FOUR ways to accomplish this task:
--Option 1:
--Clean, tight version using cast and varchar
SELECT CAST(MONTH(DonationDate) AS VARCHAR(2)) + '/' + CAST(DAY(DonationDate) AS VARCHAR(2)) + '/' + CAST(YEAR(DonationDate) AS VARCHAR(4))
FROM DONATION

--Option 2:
--Not so clean version using str and declaring the number of characters.  
--It's not as clean because you get an extra space in month and day, as in mm/dd/yyyy without the zeros:  e.g. (space)8/(space)9/2013
SELECT STR(MONTH(DonationDate),2) + '/' + STR(DAY(DonationDate),2) + '/' + STR(YEAR(DonationDate),4)
FROM Donation

--Option 3:
--I think this is the best and cleanest option.
--It turns everything into a string.
SELECT CONCAT(MONTH(DonationDate), '/', DAY(DonationDate), '/', YEAR(DonationDate))
FROM Donation

--Option 4:
--This uses the FORMAT function, which only works for numeric and date/time data types
--According to Microsoft documentation, the FORMAT function appeared first in SQL Server 2014
SELECT FORMAT(DonationDate, 'd', 'en-US')
FROM Donation

/*5.
Format the phone numbers in PersonContact to look like (206)555-1234
*/
--My approach concatenates the result of three nested functions:
--The LEFT takes the first three numbers of the phone number
--The SUBSTRING finds the middle three numbers of the phone number
--The RIGHT takes the last four number of the phone number.
SELECT CONCAT('(',LEFT(ContactInfo, 3), ')', SUBSTRING(ContactInfo,4,3), '-', RIGHT(ContactInfo, 4)) AS 'Contact Info'
FROM PersonContact

--Option2:
--Uses format
SELECT FORMAT(CONVERT(NUMERIC, ContactInfo), '(###)###-####')
FROM PersonContact

/*6.
Use the table ServiceGrant.  
Format the grantAmount and GrantAllocation so that they have $ signs, like $320.50
*/
--Here is my approach to just creating a string representation of the data, concatenating the $ sign.
SELECT CONCAT('$', GrantAmount) AS 'Grant Amount', CONCAT('$', GrantAllocation) AS 'Grant Allocation'
FROM ServiceGrant

--Option2
--Uses Format function and the standard numeric format string for currency 'C'
SELECT FORMAT(GrantAmount, 'C', 'en-us') AS 'Grant Amount', FORMAT(GrantAllocation, 'C', 'en-us') AS 'Grant Allocation'
FROM ServiceGrant

/*7.
Return the years in which employees were hired.
Only return one instance of each year.
*/
--My approach uses DISTINCT and YEAR functions
SELECT DISTINCT YEAR(EmployeeHireDate)
FROM Employee

/*8.
Return only the first word of each street address in PersonAddress.
*/

--This needs work.  For Western Towers, for instance, it will only return Towers.

SELECT *, SUBSTRING(Street, CHARINDEX(' ', Street)+1, (CHARINDEX(' ', Street)))
FROM PersonAddress


/*9.
In Employee return the EmployeeKey and Dependents substitute the word "none" for each null in dependents.
*/
SELECT EmployeeKey, EmployeeDependents = 'none' 
FROM Employee
WHERE EmployeeDependents IS NULL

/*10.
What is the difference between the date the Grant was requested and the date 
	it was reviewed in days for those grants conducted in September?
*/
SELECT GrantDate, GrantReviewDate, DATEDIFF(dd, GrantDate, GrantReviewDate) AS 'Number of days between Grant Date and Grant Review'
FROM ServiceGrant
WHERE DATENAME(mm,GrantDate) = 'September' AND DATENAME(mm, GrantReviewDate) = 'September'

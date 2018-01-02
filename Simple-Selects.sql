/*
SIMPLE SELECTS
*/

USE CommunityAssist

--1. Return all the records for the table CommunityService
SELECT *
FROM CommunityService

--2. Sort the CommunityService table alphabetically by the service name
SELECT *
FROM CommunityService
ORDER BY ServiceName 

--3. Order CommunityService by service maximum from largest to least
SELECT *
FROM CommunityService
ORDER BY ServiceMaximum DESC

--4. Return all the first names, last names and email from the Person table.
SELECT PersonFirstName, PersonLastName, PersonUsername
FROM Person

--5. Sort the Person table by LastName ascending and first name ascending (return the same columns as above).
SELECT PersonFirstName, PersonLastName, PersonUsername
FROM Person
ORDER BY PersonLastName, PersonFirstName 

--6. Return the same fields as in 4 and five but alias PersonFirstName as first name and PersonLastName as last name.
SELECT PersonFirstName AS 'First Name', PersonLastName AS 'Last Name', PersonUsername
FROM Person
ORDER BY PersonLastName, PersonFirstName 

--7. Return all the people with the last name of "Nelson."
SELECT PersonFirstName, PersonLastName, PersonUsername
FROM Person
WHERE PersonLastName = 'Nelson'
ORDER BY PersonLastName, PersonFirstName 

--8. From the donations table return all the donations with an amount more than $1000.
SELECT *
FROM Donation d
WHERE d.DonationAmount > 1000

--9. From the donations table return all the donations with an amount less than $75.
SELECT *
FROM Donation d
WHERE d.DonationAmount < 75

--10.Return only unique donors (use only the personkey).
SELECT DISTINCT PersonKey
FROM Donation d

--11.From the PersonAddress table return all the addresses NOT in Seattle
SELECT *
FROM PersonAddress
WHERE NOT City = 'Seattle'

--12.From the PersonAddress table return all the records with no apartment number (Null).
SELECT *
FROM PersonAddress
WHERE Apartment IS NULL

--13.From the PersonAddress table return all the records that have an apartment listed and live in Seattle.
SELECT *
FROM PersonAddress
WHERE Apartment IS NOT NULL AND City = 'Seattle'

--14.From the Person table list all the people who have "hotmail" in their email address.
SELECT *
FROM Person
WHERE PersonUsername LIKE '%hotmail%'


--15.From the PersonAddress table return all the people who live in the city of Bellevue or Redmond.
SELECT *
FROM PersonAddress
WHERE City = 'Bellevue' OR City = 'Redmond'

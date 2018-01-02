/*
ASSIGNMENT 3:
AGGREGATE FUNCTIONS
*/
USE CommunityAssist

--1. Get the count of all the unique donors. (Give the SQL and the count.)
SELECT DISTINCT COUNT(PersonUsername)
FROM Person
-- ANSWER: The count is 125

--2. What is the total of all donations (give the SQL and the count.)
SELECT SUM(DonationAmount) AS 'Total Donations'
FROM Donation
--ANSWER: 53960.17

--3. What is the average grant amount alloted? (Give the SQL and the average.)
SELECT AVG(GrantAmount) AS 'Average Grant Amount Alloted'
FROM ServiceGrant
--ANSWER: 322.9492

--4.  What is the biggest donation amount? (Give the SQL and the amount.)
SELECT MAX(DonationAmount)
FROM Donation
--ANSWER: 12150.55

--5.  What is the total donation amount for each month in 2013? (Just SQL)
SELECT SUM(DonationAmount) AS 'Total Donation Amount'
FROM Donation
WHERE YEAR(DonationDate) = '2013'
GROUP BY DATENAME(mm, DonationDate)

--6.  List all the donors (PersonKey) and the count of their donations (just SQL).
SELECT PersonKey, COUNT(DonationAmount) AS 'Donation Count'
FROM Donation
GROUP BY PersonKey

--7.  List all the donors who have given more than once and the total of their donations listed in descending order (just SQL).
SELECT PersonKey 'Donor', SUM(DonationAmount) 'Total Donation Amount', COUNT(DonationAmount) 'Number of Donations'
FROM Donation
GROUP BY PersonKey
HAVING COUNT(DonationAmount) > 1

--8.  Return the count of the grants and the totals alloted for each type of grant (ServiceKey) (SQL).
SELECT ServiceKey 'Type of Grant',COUNT(GrantKey)'Count of Grants', SUM(GrantAmount) 'Grand Total of Grants'
FROM ServiceGrant
GROUP BY ServiceKey

/*9.  
What is the total number of grant requests? What is the count grants denied?  What percent of grants are denied? 
(Just enter the numbers from the pervious queries).  Do as separate queries.
*/
/*
SELECT *
FROM ServiceGrant
*/
--Total number of grant requests
SELECT COUNT(GrantKey) 'Number of Grant Requests'
FROM ServiceGrant --ANSWER:89
--Count of grants denied
SELECT COUNT(GrantKey) 'Number of Denied Grant Requests'
FROM ServiceGrant
WHERE GrantApprovalStatus = 'denied' --ANSWER: 13
--Percent of grants denied
SELECT COUNT(GrantKey) 'Number of Grant Requests', CONCAT(ROUND((13.0/89.0)*100, 2), '%') 'Percent of Grants Requests Denied'
FROM ServiceGrant

--10. What is the average grant amount for each service (serviceKey) (SQL).
SELECT ServiceKey, ROUND(AVG(GrantAmount),2) 'Average Grant Amount'
FROM ServiceGrant
GROUP BY ServiceKey

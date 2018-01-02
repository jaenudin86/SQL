/*
CREATING FUNCTIONS
*/

/*
This assignment uses CommunityAssist.  These are all scalar functions.
*/
USE CommunityAssist
--MY NOTES:
/*
Here is the syntax for a user-defined scalar function:
GO
CREATE FUNCTION
RETURNS 
AS -- nothing to add here
BEGIN -- nothing to add here
	DECLARE...;
	SELECT
	FROM
	WHERE...;
	IF...SET...;
	RETURN
END; -- nothing to add here
GO
*/
/*
1.
Create a function that takes in the donation amount and a percentage and returns that percent of the donation amount.
Use the function in a query in which the donation amount is divided so that 85% goes to the charity cause and 15% goes to the organization.
Make it so the user can enter the percentage as either a whole number or a decimal.
*/
GO
IF OBJECT_ID('fnPercentDonation') IS NOT NULL -- If there is a function (as in, if there is an object with the function name)
DROP FUNCTION fnPercentDonation
GO
CREATE FUNCTION fnPercentDonation --It was orginally CREATE FUNCTION fnPercentDonation, but I've had to alter it multiple times.
(@userDonationAmount MONEY, @userDonationPercentage DECIMAL(5,2)) --parameters are VARCHAR an 
RETURNS MONEY 
AS
BEGIN
	DECLARE @donationPercent DECIMAL(10,2) --making the parameter type DECIMAL ensures that the return value only has two digits after the decimal.
	IF @userDonationPercentage <> FLOOR(@userDonationPercentage) -- the <> means 'not equal to'. FLOOR returns the largest integer less than or equal to the specified numeric expression. For example, FLOOR(123.45) is 123.  Using FLOOR means taht the @userDonationPercentage can be determined it is an integer or not.  If @userDonationPercentage is already 0.85, then it is not equal to the FLOOR, or 0 in this case.  This means that @userDonationPercentage is float.  Otherwise, if @userDonationPercentage is 85, then it is equal to the FLOOR, which is indeed 85. It's thus a whole number and must be divided by 100 to get the decimal reprsentation of the percentage 
		BEGIN
			SET @donationPercent = @userDonationAmount * @userDonationPercentage 
		END
		ELSE
		BEGIN
			SET @donationPercent = @userDonationAmount * (@userDonationPercentage/100) --make the @userDonationPercentage into a decimal before multiplying it against @userDonationAmount
		END  
	RETURN CAST(@donationPercent AS MONEY) --cast to money here, but because it was originally of type DECIMAL, it will only have 2 digits after the decimal
END;
GO --this GO at the end is necessary for the syntax of the function. It indicates the end of a batch of SQL statements.

--Test decimal numbers
SELECT DonationAmount, dbo.fnPercentDonation(DonationAmount, 0.85) 'Charity Donation', dbo.fnPercentDonation(DonationAmount, 0.15) 'Donation to Org'
FROM Donation

--Test whole numbers
SELECT DonationAmount, dbo.fnPercentDonation(DonationAmount, 85) 'Charity Donation', dbo.fnPercentDonation(DonationAmount, 15) 'Donation to Org'
FROM Donation


/*
2.
Create a function that takes in the grant amount requested and the amount actually allocated.  
The function should return a decimal percentage (allocation/request).  
Use the function in a query that compares it for each record and then use it in a query that returns the average percentage.
*/
GO
IF OBJECT_ID('fnPercentGrantRequest') IS NOT NULL
DROP FUNCTION fnPercentGrantRequest
GO
CREATE FUNCTION fnPercentGrantRequest
(@userGrantRequest MONEY, @userGrantAllocation MONEY)  
RETURNS FLOAT 
AS
BEGIN
	DECLARE @grantPercent FLOAT
	SET @grantPercent = CAST(((@userGrantAllocation/@userGrantRequest)*100) AS FLOAT)  
	RETURN @grantPercent  
END;
GO

/*2a.  Use the function in a query that compares it for each record: */

--Average grant allocation percentage for each grant requested.
SELECT PersonKey, ServiceKey, GrantAmount, GrantAllocation, 'Grant Request-to-Allocation Percentage' =  CAST(dbo.fnPercentGrantRequest(GrantAmount, GrantAllocation) AS VARCHAR) + '%'--CAST to VARCHAR in order to add the '%' to the end of the float number.
FROM ServiceGrant
ORDER BY PersonKey

--Average grant allocation percentage for each type of service.  
--FOR STEVE: I'm not sure if you wanted this too, so did it just in case and also for funsies :)
SELECT sg.ServiceKey,cs.ServiceName, 'Sum Grant' = SUM(GrantAllocation), 'Average Grant Allocation Percentage' = CAST(dbo.fnPercentGrantRequest(SUM(GrantAmount), SUM(GrantAllocation)) AS VARCHAR) + '%'
FROM ServiceGrant sg JOIN CommunityService cs
ON sg.ServiceKey = cs.ServiceKey
GROUP BY sg.ServiceKey, cs.ServiceName


/*2b.  ...then use it in a query that returns the average percentage. */

--Average grant allocation percentage for all services
SELECT 'Average Grant Allocation Percentage' = CAST(dbo.fnPercentGrantRequest(SUM(GrantAmount), SUM(GrantAllocation)) AS VARCHAR) + '%'
FROM ServiceGrant
--ANSWERl 87.28%

--Average grant allocation percentage for each type of service. 
--FOR STEVE: I'm not sure if you wanted this too, so did it just in case and also for funsies :)
SELECT sg.ServiceKey,cs.ServiceName, 'Average Grant Allocation Percentage' = CAST(dbo.fnPercentGrantRequest(SUM(GrantAmount), SUM(GrantAllocation)) AS VARCHAR) + '%'
FROM ServiceGrant sg JOIN CommunityService cs
ON sg.ServiceKey = cs.ServiceKey
GROUP BY sg.ServiceKey, cs.ServiceName


/*
3.
Create a function that takes the amount allotted for a grant and subtracts it from the ServiceMaximum and returns the difference.
*/

--MY NOTES:
--My approach to the task is to create an inline table-valued function with no parameters. 
--It uses the following tables: ServiceRequest, CommunityService
--  It returns six(6) columns: GrantDate, ServiceName, PersonKey, GrantAllocation, ServiceMaximum, and the difference between ServiceMaximum and GrantAllocation as 'What Remains'

--The function
GO
IF OBJECT_ID('fnGrantAvailable') IS NOT NULL
DROP FUNCTION fnGrantAvailable
GO
CREATE FUNCTION fnGrantAvailable()
RETURNS TABLE 
AS
RETURN
(
	SELECT sg.GrantDate,cs.ServiceName, sg.PersonKey, sg.GrantAllocation, cs.ServiceMaximum, 'What Remains' = (cs.ServiceMaximum - SUM(sg.GrantAllocation))
	FROM ServiceGrant sg 
	JOIN CommunityService cs
	ON sg.ServiceKey = cs.ServiceKey
	--WHERE sg.PersonKey = @xid
	GROUP BY sg.GrantDate,sg.PersonKey,cs.ServiceName, sg.GrantAllocation, cs.ServiceMaximum 
);
GO

--Select statement to test the function.
SELECT * FROM dbo.fnGrantAvailable()

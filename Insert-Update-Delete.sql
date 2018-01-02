/*
INSERT, UPDATE, DELETE
*/
USE CommunityAssist
/*
1.
Insert the following new donor. 
This will require inserts into several tables.  
You do not have to worry about the seed or hashed password for now.
Remember the tables have identities for keys.  
You cannot insert into an identity column, but you will need the value of the key as a foreign key to relate the records in the different tables.

Sara Wilson
1201 Washington Ave.
Seattle, WA  98001
Cell: 4345551243
Home:  2065550067
Email: swilson@nwenterprises.org
Plain password: saraPass
Donation: $1200
*/
SELECT *
FROM Person --has person key only
ORDER BY PersonLastName

SELECT *
FROM PersonAddress --has person key, person address key

SELECT *
FROM Donation --has person key, employee key, donation key

SELECT *
FROM Employee --has person key, employee key

SELECT *
FROM [dbo].[CommunityService]

GO
INSERT INTO [dbo].[Person] ([PersonFirstName], [PersonLastName], [PersonUsername], [PersonPlainPassword], [PersonEntryDate])
VALUES('Sara', 'Wilson', 'swilson@nwenterprises.org', 'saraPass', '09/26/2015')

GO
INSERT INTO [dbo].[PersonAddress] ([Street], [City], [State], [Zip], [PersonKey])
VALUES('1201 Washington Ave.', 'Seattle', 'WA', 98001, 129) 

GO
INSERT INTO [dbo].[Donation] ([DonationDate], [DonationAmount], [PersonKey])
VALUES (9/25/2015, 1200, 129)


/*
2.
Insert the following new Employee:

Barbara Nadar
Apt 121
3400 North Edison Street
Seattle, WA  98100
Cell:  5345559012
Email: bnadar@hotmail.com
HireDate: current date
Social Security Number:  518-22-1234
Dependents: 2
Status: PT
Monthly Salary: S2000
*/

GO
INSERT INTO [dbo].[Person] ([PersonFirstName], [PersonLastName], [PersonUsername], [PersonPlainPassword], [PersonEntryDate])
VALUES('Sara', 'Wilson', 'swilson@nwenterprises.org', 'saraPass', '09/26/2015')

GO
INSERT INTO [dbo].[PersonAddress] ([Street], [City], [State], [Zip], [PersonKey])
VALUES('1201 Washington Ave.', 'Seattle', 'WA', 98001, 129) 

GO
INSERT INTO [dbo].[Employee] ([EmployeeHireDate], [EmployeeSSNumber], [EmployeeDependents], [PersonKey], [EmployeeStatus],[EmployeeMonthlySalary])
VALUES('09/26/2015', '518221234', 2, 129, 'PT', 2000)

/*
Make the following updates:
*/

/*
3.
Change the address at PersonAddressKey 81 so that the street is "1000 South Eastern, Seattle, WA  98100"
*/
UPDATE [dbo].[PersonAddress]
SET [Street] = '1000 South Eastern', [City] = 'Seattle', [State] = 'WA', [Zip] = 98100
WHERE [PersonAddressKey] = 81

/*
4.
Update the address at PersonAddressKey 83 to read "221 Broadway, Seattle, WA  98100"
*/
UPDATE [dbo].[PersonAddress]
SET [Street] = '221 Broadway', [City] = 'Seattle', [State] = 'WA', [Zip] = 98100
WHERE [PersonAddressKey] = 83

/*
5.
Change the lifetime service maximum so that all are increased by 5%.
*/
UPDATE [dbo].[CommunityService]
SET [ServiceLifetimeMaximum] = ([ServiceLifetimeMaximum]* 0.05) + [ServiceLifetimeMaximum]


/*
Delete the following records
*/

/*
6.
Delete "holiday" from CommunityService
*/
DELETE FROM [dbo].[CommunityService]
WHERE [ServiceName] = 'holiday'

/*
7.
Delete "pager" and "Fax" from ContactType
*/
DELETE FROM [dbo].[ContactType]
WHERE [ContactTypeName] = 'pager' AND [ContactTypeName] = 'Fax'

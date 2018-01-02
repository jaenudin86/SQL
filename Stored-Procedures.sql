/*
STORED PROCEDURES
*/
/*
This task uses CommunityAssist.
First we will create a couple of simple stored procedures.
*/
USE CommunityAssist
/*
1.
Create a procedure that shows the name, email, address and contact numbers for a person.  
Pass in the personKey as a parameter.
*/

/*
--General stored procedure syntax:
GO
CREATE PROCEDURE name 
	@parameter,
	@parameter
AS
	SET
GO
*/

--IIF ( boolean_expression, true_value, false_value ) 
--This task uses the following tables: Person, PersonAddress, PersonContact
GO
IF OBJECT_ID('procPersonInfo') IS NOT NULL
DROP PROCEDURE procPersonInfo
GO 
CREATE PROCEDURE procPersonInfo
	@userPersonKey INT
AS
	SELECT p.PersonKey, 'Name' =  CONCAT(p.PersonFirstName, ' ', p.PersonLastName), p.PersonUsername, 'Address' = CONCAT(pa.Street, IIF(pa.Apartment IS NOT NULL, ' ' + pa.Apartment + ', ',', '), pa.City, ' ', pa.Zip), 'Contact numbers' = pc.ContactInfo
	FROM Person p JOIN
	(PersonAddress pa JOIN PersonContact pc ON pa.PersonKey = pc.PersonKey)
	ON p.PersonKey = pa.PersonKey
	WHERE p.PersonKey = @userPersonKey
GO

EXECUTE dbo.procPersonInfo @userPersonKey = 1
GO

/*
2.
Create a procedure that returns the total number granted and the total amount allocated for a particular service.
Enter the ServiceKey as a parameter.
*/
--This task uses the ServiceGrant table

--procedure
GO
IF OBJECT_ID('procServiceInfo') IS NOT NULL
DROP PROCEDURE procServiceInfo
GO 
CREATE PROCEDURE procServiceInfo
	@userServiceKey INT
AS
	SELECT ServiceKey, 'Total Number Granted' = COUNT(GrantKey), 'Total Amount Allocated' = SUM(GrantAllocation)
	FROM ServiceGrant
	WHERE ServiceKey = @userServiceKey
	GROUP BY ServiceKey
GO

--test the procedure
EXECUTE dbo.procServiceInfo @userServiceKey = 4
GO

/*
these are more complex stored procedures
*/
/*
3.
Create a procedure that inserts a new client (theirs, name, address and contact numbers, and lets them apply for a service grant.
(You do not have to insert into GrantReviewDate, GrantApprovalStatus, or GrantAllocation.)
-This stored procedure should check to see if the person already exists in the database.
-If they don't it should insert all the information.
-If they do it should only insert the grant request information. (don't forget to get the personKey for the person if they do exist.)
-It should use a transaction and a try catch
-if there is an y error in any of the inserts it should roll back all the transactions and print a message.
*/

--This task uses the following tables: Person, PersonAddress, PersonContact, ServiceGrant
GO
IF OBJECT_ID('procNewClient') IS NOT NULL
DROP PROCEDURE procNewClient
GO 
CREATE PROCEDURE procNewClient
	@userLast NVARCHAR(255),
	@userFirst NVARCHAR(255),
	@userStreet NVARCHAR(255),
	@userApartment NVARCHAR(255),
	@userCity NVARCHAR(255), 
	@userState NVARCHAR(2),
	@userZip NVARCHAR(10),
	@userContact NVARCHAR(255),

	@userGrantAmount MONEY, 
	@userGrantDate DATETIME,
	@userGrantNeedExplanation NVARCHAR(255)	
AS
DECLARE @PersonKey INT --Declare variable immediately so that it can be used anywhere in the code below.
IF EXISTS--Check to see if person exists
	(SELECT p.PersonKey
	FROM Person p JOIN
		(PersonAddress pa JOIN PersonContact pc 
		ON pa.PersonKey = pc.PersonKey)
	ON p.PersonKey = pa.PersonKey
	WHERE p.PersonLastName = @userLast
	AND p.PersonFirstName = @userFirst
	AND pc.ContactInfo = @userContact)
	BEGIN --Number 1
		PRINT 'Person exists'
		IF EXISTS --Check to see if grant exists (A check to see if person exists already accomplished in code above)
			(SELECT sg.GrantAmount, sg.GrantDate, sg.GrantNeedExplanation,
				(SELECT p.PersonKey FROM Person p JOIN
				(PersonAddress pa JOIN PersonContact pc 
				ON pa.PersonKey = pc.PersonKey)
				ON p.PersonKey = pa.PersonKey
				WHERE p.PersonLastName = @userLast
				AND p.PersonFirstName = @userFirst
				AND pc.ContactInfo = @userContact)
			FROM dbo.ServiceGrant sg JOIN dbo.Person p
			ON sg.PersonKey = p.PersonKey 
			WHERE GrantAmount = @userGrantAmount
			AND GrantDate = @userGrantDate
			AND GrantNeedExplanation = @userGrantNeedExplanation)
			BEGIN --Number 2
				PRINT 'Grant already in database'
				RETURN
			END --Number 2	
		ELSE --If person exists and grant request DOES NOT exist, insert grant request
			BEGIN --Number 3
			--Get @PersonKey value
				SELECT @PersonKey = p.PersonKey FROM Person p JOIN
					(PersonAddress pa JOIN PersonContact pc 
					ON pa.PersonKey = pc.PersonKey)
					ON p.PersonKey = pa.PersonKey
					WHERE p.PersonLastName = @userLast
					AND p.PersonFirstName = @userFirst
					AND pc.ContactInfo = @userContact	
					BEGIN TRY--Try to insert user grant request
						INSERT INTO ServiceGrant(GrantAmount, GrantDate, GrantNeedExplanation, PersonKey)
						VALUES(@userGrantAmount, @userGrantDate, @PersonKey, @userGrantNeedExplanation)
						PRINT 'The new grant request is now inserted successfully.'
					END TRY --End insert if successful.  If not successful, go to CATCH
					BEGIN CATCH --If the grant already exists, display a message stating so.
						PRINT 'This is the fail-safe for inserting a new grant reqeust when a person exists. Something went wrong.'
						END CATCH 
					RETURN
			END --Number 3
END --Number 1.  End of checking whether a person  and a grant exists, and end of inserting a grant if a person exists.
ELSE--If the person does NOT exist (as vetted by the code above), insert new person info AND new grant request
BEGIN TRAN --Start the transaction. A transaction must complete every line of code or it doesn't go through.
	BEGIN TRY
		SET @PersonKey=IDENT_CURRENT('Person')--Set @PersonKey to the next autonumber PersonKey in table Person
		--Insert user personal info
		INSERT INTO Person(PersonLastName,PersonFirstName)
		VALUES(@userLast, @userFirst)
		INSERT INTO PersonAddress(Street, Apartment, City, State, Zip, PersonKey)
		VALUES(@userStreet, @userApartment, @userCity, @userState, @userZip, @PersonKey)
		INSERT INTO PersonContact(ContactInfo, PersonKey)
		VALUES(@userContact, @PersonKey)
		--Print message
		PRINT 'New client profile created successfully'
		--Inset user grant request
		INSERT INTO ServiceGrant(GrantAmount, GrantDate, PersonKey, GrantNeedExplanation)
		VALUES(@userGrantAmount, @userGrantDate, @PersonKey, @userGrantNeedExplanation)
		--Print message
		PRINT 'New grant request submitted successfully'
		--Commit transaction
		COMMIT TRAN 
	END TRY
BEGIN CATCH
	ROLLBACK TRAN --If there is a problem with any of the transaction stuff above, get rid of all the insertions and restore the database to where it was before it the transaction began.
END CATCH
GO

--SAMPLE ENTRIES to test the stored procedure
EXEC dbo.procNewClient 
	@userLast = 'Souze',
	@userFirst = 'Kaiser',
	@userStreet = '321123 YourDad Street',
	@userApartment = '111',
	@userCity = 'Seattle', 
	@userState = 'WA',
	@userZip = '98101',
	@userContact ='2069999992',

	@userGrantAmount = 500, 
	@userGrantDate = '9/30/15',
	@userGrantNeedExplanation = 'My cat passed away, and I need to pay for his mummification' 
GO

EXEC dbo.procNewClient 
	@userLast = 'Holly',
	@userFirst = 'LittleBuddy',
	@userStreet = '999 TexasAintBad Street',
	@userApartment = '999',
	@userCity = 'Seattle', 
	@userState = 'WA',
	@userZip = '98101',
	@userContact ='2061111111',

	@userGrantAmount = 300, 
	@userGrantDate = '9/30/15',
	@userGrantNeedExplanation = 'My great uncle passed away a while ago, but I need to acquire his famous glasses from an antiques dealer' 
GO

EXEC dbo.procNewClient 
	@userLast = 'Estranja',
	@userFirst = 'Laganja',
	@userStreet = '333 RupaulDragRace Lane',
	@userApartment = '777',
	@userCity = 'Seattle', 
	@userState = 'WA',
	@userZip = '98101',
	@userContact ='2064204200',

	@userGrantAmount = 450, 
	@userGrantDate = '10/3/15',
	@userGrantNeedExplanation = 'I am a medicinal cannabis patient and I need three months worth of my prescription medicine, currently Acapulco Gold.' 
GO


EXEC dbo.procNewClient 
	@userLast = 'Stranger',
	@userFirst = 'Random',
	@userStreet = '222 TheWildWild Street',
	@userApartment = '101',
	@userCity = 'Seattle', 
	@userState = 'WA',
	@userZip = '98101',
	@userContact ='2061111111',

	@userGrantAmount = '1000', 
	@userGrantDate = '10/3/15',
	@userGrantNeedExplanation = 'I need money, because we all need money.'
GO

 --check that everything went through
 SELECT * 
 FROM Person --look to find the PersonKey for the new person = 130

 SELECT *
 FROM dbo.PersonAddress 
 --WHERE PersonKey = 132
 --WHERE PersonKey = 133
 WHERE PersonKey = 140

 SELECT *
 FROM PersonContact
 --WHERE PersonKey = 132
 --WHERE PersonKey = 133
  WHERE PersonKey = 140

 SELECT *
 FROM ServiceGrant
 WHERE PersonKey = 140
 --FOR STEVE:  The PersonKey in Person is off by 1.  PersonKey 52 is skipped for some reason, so the database shows PersonKey 51, then 53 and on from that.
 --This means that when I look up the PersonAddress info, I have to enter a PersonKey in the WHERE clause that is one less than what the PersonKey displays in Person
 --So, PersonKey 133 in Person is actually 132 in PersonAddress

/*
4.
The next stored procedure should let a person update their own name, email, address, and contact information.
Again, it should use transactions and error trapping and rollback if there is any error.
*/

GO
IF OBJECT_ID('procUpdateNewClient') IS NOT NULL
DROP PROCEDURE procUpdateNewClient
GO 
CREATE PROCEDURE procUpdateNewClient
	@userLastOld NVARCHAR(255),
	@userFirstOld NVARCHAR(255),
	@userLast NVARCHAR(255),
	@userFirst NVARCHAR(255),
	@userStreet NVARCHAR(255),
	@userApartment NVARCHAR(255),
	@userCity NVARCHAR(255), 
	@userState NVARCHAR(2),
	@userZip NVARCHAR(10),

	@userContactOld NVARCHAR(255),
	@userContact NVARCHAR(255),

	@userUsernameAsEmailOld NVARCHAR(50),
	@userUsernameAsEmail NVARCHAR(50)	
AS
DECLARE @PersonKey INT
IF EXISTS --Check to see if the OLD person and contact info exist
	(SELECT PersonFirstName, PersonLastName, PersonUsername
	FROM dbo.Person
	WHERE PersonFirstName = @userFirstOld
	AND PersonLastName = @userLastOld
	AND PersonUsername = @userUsernameAsEmailOld)
	BEGIN --Number 1.  This begans a huge statement block that ends right before the code that simply inserts the user information as a new record if all of the user information does not pass the various code statements in the statement block.
IF EXISTS --Check to see if the person and contact info exist
	(SELECT PersonFirstName, PersonLastName, PersonUsername
	FROM dbo.Person
	WHERE PersonFirstName = @userFirst
	AND PersonLastName = @userLast
	AND PersonUsername = @userUsernameAsEmail)
	BEGIN --Number 1A
	PRINT 'Person First, Last, Username exists. No updates needed'
	END --Number 1A
ELSE -- ELSE 1
BEGIN --Number 2
BEGIN TRAN --Update table Person.  If the user enters the same info as in in the record, this returns a message.	
	BEGIN TRY
		UPDATE dbo.Person
		SET PersonFirstName = @userFirst,
		PersonLastName = @userLast, 
		PersonUsername = @userUsernameAsEmail
		WHERE PersonFirstName = @userFirstOld
		AND PersonLastName = @userLastOld
		AND PersonUsername = @userUsernameAsEmailOld
		PRINT 'Person name and username info updated'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN 
		PRINT 'Something went wrong. Person name and username NOT updated'
	END CATCH
END --Number 2  --Stop ELSE 1
IF EXISTS(SELECT PersonKey
		FROM dbo.PersonAddress
		WHERE Street = @userStreet
		AND Apartment  = @userApartment
		AND City = @userCity
		AND State = @userState)
BEGIN --Number 4
PRINT 'Person new address is the SAME as the record in the database. No address update needed'
END --Number 4
ELSE --ELSE 2
	BEGIN --Number 5
	BEGIN TRAN 
	BEGIN TRY
		UPDATE dbo.PersonAddress 
		SET Street = @userStreet,
		Apartment  = @userApartment,
		State = @userState,
		City = @userCity,
		Zip = @userZip
		PRINT 'Person address updated'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN 
		PRINT 'Something went wrong. Person address NOT updated'
	END CATCH
	END --Number 5
--Stop ELSE 2
IF EXISTS
	(SELECT ContactInfo
	FROM dbo.PersonContact
	WHERE PersonKey 
		IN (SELECT pc.PersonKey 
					FROM PersonContact pc JOIN Person p
					ON p.PersonKey = pc.PersonKey
					WHERE p.PersonLastName = @userLast
					AND p.PersonFirstName = @userFirst
					AND pc.ContactInfo = @userContact))
	BEGIN --Number 1B	
	PRINT 'Person contact info exists. No updates needed'
	RETURN
	END --Number 1B
ELSE	--Update table ContactInfo --ELSE 3
BEGIN --Number 7 --Update table ContactInfo
BEGIN TRAN
	BEGIN TRY
		UPDATE dbo.PersonContact 
		SET ContactInfo = @userContact
		WHERE PersonKey 
		IN (SELECT p.PersonKey 
					FROM Person p JOIN PersonContact pc 					
					ON p.PersonKey = pc.PersonKey
					WHERE p.PersonLastName = @userLastOld
					AND p.PersonFirstName = @userFirstOld
					AND pc.ContactInfo = @userContactOld)
		PRINT 'Person contact info updated' 	
		COMMIT TRAN	
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN 
		PRINT 'Something went wrong.  Person contact info NOT updated'
	END CATCH
END --End Number 7
END --Number 1
ELSE --Otherwise, enter the information submitted as a new record.
BEGIN --Number 8
BEGIN TRAN
	BEGIN TRY
		SET @PersonKey=IDENT_CURRENT('Person')--Set @PersonKey to the next autonumber PersonKey in table Person
		INSERT INTO dbo.Person(PersonLastName,PersonFirstName, PersonUsername)
		VALUES(@userLast, @userFirst, @userUsernameAsEmail)
		INSERT INTO dbo.PersonAddress(Street, Apartment, City, State, Zip, PersonKey)
		VALUES(@userStreet, @userApartment, @userCity, @userState, @userZip, @PersonKey)
		INSERT INTO dbo.PersonContact(ContactInfo, PersonKey)
		VALUES(@userContact, @PersonKey)
		COMMIT TRAN 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN 
	END CATCH
END; --Number 8
GO
	--FOR STEVE:  Is there a reason why you included more stuff in the AND cluses of the UPDATE statement (were you trying to triple-safeguard again inserting info into the wrong  record?)  In other words, why wouldn't WHERE PersonKey = @PersonKey suffice?

--sample data to test stored procedure
EXEC dbo.procUpdateNewClient
	@userLastOld = 'Holly',
	@userFirstOld = 'LittleBuddy',
	@userLast = 'Holly',
	@userFirst = 'LittleBuddy',
	@userStreet = '999 TexasAintBad Street',
	@userApartment = '876',
	@userCity = 'Seattle', 
	@userState = 'WA',
	@userZip = '98101',

	@userContactOld = '2061111118',
	@userContact ='2061111118',

	@userUsernameAsEmailOld = 'tootles@hotmail.com'	,
	@userUsernameAsEmail = 'tootles@hotmail.com'		
GO

SELECT *
FROM Person

/*
CREATING AND ALTERING TABLES
*/

 /*
 For this task we will create a small database, add some tables and then do a few alterations.
 First create a new database called "MovieList"
 Now add these tables:

 
 COLUMN NAME		DATA TYPE				REQUIRED			KEY
 MOVIE
 MovieKey			int, Identity(1,1)		Yes					Primary Key
 MovieTitle			NVarchar(255)			Yes
 MovieStudio		NVarchar(255)			No

 ACTOR
 ActorKey			int, Identity(1,1)		Yes					Primary Key
 ActorName			NVarchar(255)			Yes

 GENRE
 GenreKey			int, Identity(1,1)		Yes					Primary Key
 GenrerName			NVarchar(255)			Yes

 MOVIEACTOR
 ActorKey			int						Yes					primary Key, foreign Key
 MovieKey			int						Yes					Primary Key, foreign Key

 MOVIEGENRE (keys for this table will be added by alter talbe commands)
 MovieKey			int						Yes
 GenreKey			int						Yes

 */

 CREATE DATABASE MovieList

 USE MovieList

 CREATE TABLE Movie (
 MovieKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
 MovieTitle NVARCHAR(255) NOT NULL,
 MovieStudio NVARCHAR(255)
 )

 CREATE TABLE Actor (
 ActorKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL ,
 ActorName  NVARCHAR(255) NOT NULL
 )

 CREATE TABLE Genre (
 GenreKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
 GenreName NVARCHAR(255)
 )

 CREATE TABLE MovieActor (
 ActorKey INT NOT NULL ,
 MovieKey INT  NOT NULL,
 CONSTRAINT PK_ActorMovieKey PRIMARY KEY(ActorKey, MovieKey), --concatenated primary key, meaning more than one primary key
 CONSTRAINT FK_ActorKey FOREIGN KEY (ActorKey) REFERENCES Actor(ActorKey),
 CONSTRAINT FK_MovieKey FOREIGN KEY (MovieKey) REFERENCES Movie(MovieKey)
 )

 CREATE TABLE MovieGenre (
 MovieKey INT NOT NULL,
 GenreKey INT NOT NULL
 )

 /*
Now do these alterations (all use "alter table"):
 */
 --1.  Add a column called "MovieYear" to the Movie table.  Give it a data type of Int.
 ALTER TABLE Movie
 ADD MovieYear INT

 --2.  Add a column "ActorCountry" to Actor. Give it a data type of NVARCHAR(255)
 ALTER TABLE Actor
 ADD ActorCountry NVARCHAR(255)

 --3.  Add a check constraint to MOVIE.   Set it so that the year must be between 1910 and 2050.
 ALTER TABLE Movie
 ADD MovieYear DATETIME CHECK (MovieYear > '1910' AND MovieYear < '2051') --This does two things: adds the column MovieYear and adds the check constraint.
--/*Here is just the check constraint*/ ADD CHECK (MovieYear > '1910' AND MovieYear < '2051')


 --4.  Add a primary key constraint to MovieGenre which creates a composite primary key containing both MovieKey and GenreKey.
 ALTER TABLE MovieGenre 
 ADD CONSTRAINT PK_MovieGenreKey PRIMARY KEY(MovieKey, GenreKey) --concatenated primary key, meaning more than one primary key

 --5.  Add a foreign key constraint to MovieGenre for MovieKey.
 ALTER TABLE MovieGenre 
 ADD CONSTRAINT FK_MovieKeyInMovieGenre FOREIGN KEY(MovieKey) REFERENCES Movie(MovieKey)
 
 --6.  Add a foreign key constraint to MovieGenre for GenreKey
 ALTER TABLE MovieGenre 
 ADD CONSTRAINT FK_GenreKeyInMovieGenre FOREIGN KEY (GenreKey) REFERENCES Genre(GenreKey)

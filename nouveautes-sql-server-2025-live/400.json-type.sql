CREATE DATABASE [Restaurants]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Restaurants', FILENAME = N'/var/opt/mssql/data/Restaurants.mdf' , SIZE = 262144KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Restaurants_log', FILENAME = N'/var/opt/mssql/data/Restaurants_log.ldf' , SIZE = 65536KB , FILEGROWTH = 65536KB )
 WITH LEDGER = OFF
GO
ALTER DATABASE [Restaurants] SET COMPATIBILITY_LEVEL = 170
ALTER DATABASE [Restaurants] SET RECOVERY SIMPLE 
GO

USE Restaurants;
GO

SELECT *
FROM OPENROWSET(BULK '/var/opt/mssql/backups/restaurants.json', SINGLE_CLOB) as j

SELECT r.*
FROM OPENROWSET(BULK '/var/opt/mssql/backups/restaurants.json', SINGLE_CLOB) as j
CROSS APPLY OPENJSON(j.BulkColumn) as r


CREATE TABLE dbo.restaurants (
	RestaurantId int NOT NULL PRIMARY KEY,
	Restaurant JSON NOT NULL
);
GO

INSERT INTO dbo.restaurants (RestaurantId, Restaurant)
SELECT r.[Key], r.Value
FROM OPENROWSET(BULK '/var/opt/mssql/backups/restaurants.json', SINGLE_CLOB) as j
CROSS APPLY OPENJSON(j.BulkColumn) as r

SELECT TOP 1 *
FROM dbo.restaurants;


CREATE TABLE dbo.restaurantsClob (
	RestaurantId int NOT NULL PRIMARY KEY,
	Restaurant NVARCHAR(MAX) NOT NULL
);
GO

INSERT INTO dbo.restaurantsClob
SELECT * FROM dbo.restaurants;
GO

INSERT INTO dbo.restaurantsClob (RestaurantId, Restaurant)
SELECT RestaurantId, CAST(Restaurant as NVARCHAR(MAX))
FROM dbo.restaurants;
GO

SET STATISTICS TIME, IO ON;
GO

-- LOB
SELECT TOP 10 JSON_VALUE(Restaurant , '$.name')
FROM dbo.restaurantsClob;

SELECT *
FROM dbo.restaurantsClob
WHERE JSON_VALUE(Restaurant , '$.name') = N'Wilken''S Fine Food'

-- Type
SELECT TOP 10 JSON_VALUE(Restaurant , '$.name')
FROM dbo.restaurants;

SELECT *
FROM dbo.restaurants
WHERE JSON_VALUE(Restaurant , '$.name') = N'Wilken''S Fine Food';

-- with index
CREATE JSON INDEX IXJ_RestaurantJson_Restaurant_Name
ON dbo.Restaurants (Restaurant)
FOR (N'$.name')
GO

SELECT TOP 10 JSON_VALUE(Restaurant , '$.name')
FROM dbo.restaurants;

SELECT *
FROM dbo.restaurants
WHERE JSON_VALUE(Restaurant , '$.name') = N'Wilken''S Fine Food';
GO

DROP INDEX IXJ_RestaurantJson_Restaurant_Name
ON dbo.Restaurants;


SELECT JSON_VALUE(Restaurant , '$.name')
FROM dbo.restaurants
WHERE JSON_VALUE(Restaurant , '$.name') = N'Wilken''S Fine Food';
GO

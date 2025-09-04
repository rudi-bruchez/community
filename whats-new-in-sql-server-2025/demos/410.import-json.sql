-- copy restaurants.json to D:/sqldata/backups:/var/opt/mssql/backups
SET STATISTICS TIME ON;

USE PachadataTraining;
GO

DROP TABLE IF EXISTS dbo.RestaurantJson;
DROP TABLE IF EXISTS dbo.RestaurantClob;
GO
CREATE TABLE dbo.RestaurantJson (
    RestaurantId smallint NOT NULL CONSTRAINT pk_RestaurantJson PRIMARY KEY,
    JsonInfo JSON NOT NULL
);
CREATE TABLE dbo.RestaurantClob (
    RestaurantId smallint NOT NULL CONSTRAINT pk_RestaurantClob PRIMARY KEY,
    JsonInfo NVARCHAR(MAX) COLLATE Latin1_General_BIN2 NOT NULL
);
GO

INSERT INTO dbo.RestaurantJson (RestaurantId, JsonInfo)
SELECT j.[key], j.value
FROM OPENROWSET(BULK '/var/opt/mssql/backups/restaurants.json', SINGLE_CLOB) o
CROSS APPLY OPENJSON(o.BulkColumn) j;

INSERT INTO dbo.RestaurantClob (RestaurantId, JsonInfo)
SELECT RestaurantId, CAST(JsonInfo AS NVARCHAR(MAX)) FROM dbo.RestaurantJson;
-- Error 257 : Implicit conversion from data type json to nvarchar(max) is not allowed. 
-- Use the CONVERT function to run this query.
GO

SELECT TOP 10 *
FROM dbo.RestaurantJson;
SELECT TOP 10 *
FROM dbo.RestaurantClob;
GO

SELECT COUNT(*)
FROM dbo.RestaurantJson
WHERE JsonInfo LIKE '%Chutney Kitchen%';

SELECT COUNT(*)
FROM dbo.RestaurantClob
WHERE JsonInfo LIKE '%Chutney Kitchen%';

SELECT COUNT(*)
FROM dbo.RestaurantClob
WHERE JSON_VALUE(JsonInfo, '$.name') = 'Chutney Kitchen'

SELECT COUNT(*)
FROM dbo.RestaurantJson
WHERE JSON_VALUE(JsonInfo, '$.name') = 'Chutney Kitchen'


-- DROP INDEX IXJ_RestaurantJson_JsonInfo_Name ON dbo.RestaurantJson
--CREATE OR ALTER JSON INDEX IXJ_RestaurantJson_JsonInfo_Name
CREATE JSON INDEX IXJ_RestaurantJson_JsonInfo_Name
ON dbo.RestaurantJson (JsonInfo)
FOR (N'$.name')
WITH (FILLFACTOR = 90);

SELECT COUNT(*)
FROM dbo.RestaurantJson
WHERE JSON_VALUE(JsonInfo, '$.name') = 'Chutney Kitchen'

-- WITH ARRAY WRAPPER
SELECT JSON_QUERY(j.JsonInfo, '$.grades[*].date')
FROM dbo.RestaurantJson j
WHERE j.RestaurantId = 1;

SELECT JSON_QUERY(j.JsonInfo, '$.grades[*].date' WITH ARRAY WRAPPER)
FROM dbo.RestaurantJson j
WHERE j.RestaurantId = 1;
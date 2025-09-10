-- Demo: Standard vs Developer Edition Features
-- This script checks the SQL Server edition and demonstrates features that may differ between editions.
-- It creates a temporary table and adds a primary key constraint with ONLINE option, which may be edition-specific.
SELECT SERVERPROPERTY('edition');
GO

SELECT TOP (5) *
INTO #t
FROM sys.messages;
GO

ALTER TABLE #t
ADD CONSTRAINT Pk_t
PRIMARY KEY (Id)
WITH (ONLINE = ON);
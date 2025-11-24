USE PachadataTraining;
GO

DECLARE @cols varchar(max) = '<complaint-id>, <attendee-id>, <attendee-name>, <attendee#email>, <course-id>, <course-title>, 
                              <trainer#name>, <date>, <order>, <complaint-type>, <complaint#details>, <severity-level>, 
                              <status>, <resolution-notes>, <resolved-by>, <resolved-date>, <ip-address>';

-- 1. Using SSMS (manual method)
-- CTRL+H -> replace by `\n`

-- 2. Using STRING_SPLIT (SQL Server 2016+)
SELECT *
FROM STRING_SPLIT(@cols, ',') cols

-- 3. Using REGEXP_SPLIT (SQL Server 2025+)
SELECT value AS column_name
FROM REGEXP_SPLIT_TO_TABLE(@cols, ',');
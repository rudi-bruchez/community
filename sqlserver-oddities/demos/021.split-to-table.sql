USE PachadataTraining;
GO

DECLARE @cols varchar(max) = '<complaint-id>, <attendee-id>, <attendee-name>, <attendee#email>, <course-id>, <course-title>, <trainer#name>, <date>, <order>, <complaint-type>, <complaint#details>, <severity-level>, <status>, <resolution-notes>, <resolved-by>, <resolved-date>, <ip-address>';

SELECT LEN(@cols)

/*
SELECT *
FROM REGEXP_SPLIT_TO_TABLE(@cols, '>, <') t
-- Currently, 'REGEXP_SPLIT_TO_TABLE' function does not support NVARCHAR(max)/VARCHAR(max) inputs.
*/

SELECT *
FROM REGEXP_SPLIT_TO_TABLE(CAST(@cols as VARCHAR(1000)), '>, <') t

SELECT *
FROM REGEXP_MATCHES(CAST(@cols as VARCHAR(1000)), '(?:<).*?(?:>)') t

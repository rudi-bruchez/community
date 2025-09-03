USE PachadataTraining;
GO

SELECT *
FROM Contact.Contact c1
CROSS JOIN Contact.Contact c2
OPTION (USE HINT('ABORT_QUERY_EXECUTION'));
GO

USE [master]
GO
ALTER DATABASE [PachadataTraining] SET QUERY_STORE = ON
ALTER DATABASE [PachadataTraining] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO

USE PachadataTraining;
GO

SELECT *
FROM Contact.Contact c1
CROSS JOIN Contact.Contact c2;

SELECT 
    qsq.query_id,
    qsq.last_execution_time,
    qsqt.query_sql_text
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qsqt
    ON qsq.query_text_id = qsqt.query_text_id
WHERE
    qsqt.query_sql_text LIKE '%CROSS JOIN Contact.Contact c2%'
    AND qsqt.query_sql_text NOT LIKE N'%query_store%'
OPTION (RECOMPILE, MAXDOP 1);

EXECUTE sys.sp_query_store_set_hints
    @query_id = 4,
    @query_hints = N'OPTION (USE HINT(''ABORT_QUERY_EXECUTION''))';


SELECT *
FROM sys.query_store_query_hints
WHERE query_id = 4;

EXECUTE sys.sp_query_store_clear_hints @query_id = 4;
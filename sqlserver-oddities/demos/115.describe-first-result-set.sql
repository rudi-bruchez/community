DECLARE @col NVARCHAR(128) 

SET @col = 'whatever';
SET @col = 'date';
SET @col = 'order';

SELECT * FROM sys.dm_exec_describe_first_result_set(CONCAT('CREATE TABLE ', @col ,' (id int)'), NULL, 0);
-- sys.dm_exec_describe_first_result_set(@tsql, @params, @include_browse_information)
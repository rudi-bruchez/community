USE master;
GO

CREATE OR ALTER PROCEDURE sp_getOptimizedLockingXEvent
AS
BEGIN
    SET NOCOUNT ON;

	SELECT *, cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Lock Memory (KB)';

	SELECT 
		TRIM(instance_name) as [mode],
		cntr_value as [requests]
	FROM sys.dm_os_performance_counters
	WHERE counter_name = N'Lock Requests/sec'
	AND instance_name IN (
		N'Xact',
		N'HoBT',
		N'RID',
		N'Key',
		N'Page',
		N'Object'
	)
	ORDER BY [mode];

	SELECT *, pages_kb
	FROM sys.dm_os_memory_clerks
	WHERE type = 'CACHESTORE_LOCKMGR';

	SELECT name, pages_kb, virtual_memory_reserved_kb, virtual_memory_committed_kb
	FROM sys.dm_os_memory_clerks
	WHERE type = N'OBJECTSTORE_LOCK_MANAGER';
END;
GO
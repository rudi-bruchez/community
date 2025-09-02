USE PachadataTraining;
GO

-- Query the current database's state and configuration options
SELECT 
    name, 
    compatibility_level, 
    is_read_committed_snapshot_on, 
    is_accelerated_database_recovery_on,
    data_compaction_desc,
    is_proactive_statistics_refresh_on,
    is_optimized_locking_on
FROM sys.databases
WHERE database_id = DB_ID();
GO

SELECT DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') as IsOptimizedLockingOn;
GO

-- Count the number of contacts whose phone number starts with 04, 05, 06, or 07
SELECT COUNT(*) 
FROM Contact.Contact
WHERE Phone LIKE '0[4567]%';

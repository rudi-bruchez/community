USE Master;
GO

ALTER DATABASE [PachadataTraining] SET COMPATIBILITY_LEVEL = 170 -- no need :) Why ?

ALTER DATABASE [PachadataTraining] SET ACCELERATED_DATABASE_RECOVERY = ON
WITH ROLLBACK IMMEDIATE;

ALTER DATABASE [PachadataTraining] SET OPTIMIZED_LOCKING = ON
WITH ROLLBACK IMMEDIATE;
GO

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

-- Create a new Extended Events session named 'OptimizedLocking' to track lock acquisitions 
EXEC dbo.sp_create_OptimizedLocking_xevent @@SPID

BEGIN TRAN;

-- Update the LastName of the contact whose Phone is '533535534' 
-- in the Contact.Contact table
-- There is one row with that phone number, but no index on the column
UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE Phone LIKE '0[4567]%';

EXEC sp_lock2 @@SPID;

-- lock memory
SELECT name, pages_kb, virtual_memory_reserved_kb, virtual_memory_committed_kb
FROM sys.dm_os_memory_clerks
WHERE type = N'OBJECTSTORE_LOCK_MANAGER'
AND name NOT LIKE '%DAC%';

ROLLBACK

-- Query the histogram data collected by the 'OptimizedLocking' Extended Events session
EXEC sp_getOptimizedLockingXEvent;
GO

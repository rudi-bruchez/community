-- WARNING : set manually the current session_id in xevent session !

USE Master;
GO

-- 120 = SQL Server 2014
ALTER DATABASE [PachadataTraining] SET COMPATIBILITY_LEVEL = 120

ALTER DATABASE [PachadataTraining] SET ACCELERATED_DATABASE_RECOVERY = ON
WITH ROLLBACK IMMEDIATE;

ALTER DATABASE [PachadataTraining] SET OPTIMIZED_LOCKING = ON
WITH ROLLBACK IMMEDIATE;
GO

-- Create a new Extended Events session named 'OptimizedLocking' to track lock acquisitions 
-- for current session_id (! set manually the session_id !)
-- If an Extended Events session named 'OptimizedLocking' exists, drop it to avoid conflicts
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'OptimizedLocking')
BEGIN
    DROP EVENT SESSION [OptimizedLocking] ON SERVER 
END;

CREATE EVENT SESSION [OptimizedLocking] ON SERVER 
ADD EVENT sqlserver.lock_acquired(
    SET collect_resource_description=(1)
    WHERE ([sqlserver].[session_id]=(86)))
ADD TARGET package0.histogram (
    SET filtering_event_name='sqlserver.lock_acquired',
    slots=16,
    source=N'mode',
    source_type=0
);
GO

ALTER EVENT SESSION [OptimizedLocking] ON SERVER STATE = START;
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

BEGIN TRAN;

-- Update the LastName of the contact whose Phone is '533535534' 
-- in the Contact.Contact table
-- There is one row with that phone number, but no index on the column
UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE Phone LIKE '0[4567]%';

EXEC sp_lock2 @@SPID;

ROLLBACK

-- Query the histogram data collected by the 'laq' Extended Events session
EXEC sp_getOptimizedLockingXEvent;
GO

ALTER EVENT SESSION [OptimizedLocking] ON SERVER 
STATE = STOP;

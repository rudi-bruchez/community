DECLARE @laq bit = 1;

-- 120 = SQL Server 2014
ALTER DATABASE [PachadataTraining] SET COMPATIBILITY_LEVEL = 120

IF @laq = 1
BEGIN
    -- set Optimized locking ON
    ALTER DATABASE [PachadataTraining] SET READ_COMMITTED_SNAPSHOT ON
    WITH ROLLBACK IMMEDIATE;

    ALTER DATABASE [PachadataTraining] SET ACCELERATED_DATABASE_RECOVERY = ON
    WITH ROLLBACK IMMEDIATE;

    ALTER DATABASE [PachadataTraining] SET OPTIMIZED_LOCKING = ON
    WITH ROLLBACK IMMEDIATE;
END ELSE BEGIN
    -- set Optimized locking OFF
    ALTER DATABASE [PachadataTraining] SET READ_COMMITTED_SNAPSHOT OFF
    WITH ROLLBACK IMMEDIATE;

    ALTER DATABASE [PachadataTraining] SET OPTIMIZED_LOCKING = OFF
    WITH ROLLBACK IMMEDIATE;

    ALTER DATABASE [PachadataTraining] SET ACCELERATED_DATABASE_RECOVERY = OFF
    WITH ROLLBACK IMMEDIATE;

END;
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

UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE Phone LIKE '08%';

UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE Phone LIKE '07%';

-- ROLLBACK

EXEC sp_lock2 60


DBCC OPENTRAN
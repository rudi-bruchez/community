USE Master;
GO

ALTER DATABASE [PachadataFormation] SET COMPATIBILITY_LEVEL = 170 -- no need :) Why ?

ALTER DATABASE [PachadataFormation] SET ACCELERATED_DATABASE_RECOVERY = ON
WITH ROLLBACK IMMEDIATE;

ALTER DATABASE [PachadataFormation] SET OPTIMIZED_LOCKING = ON
WITH ROLLBACK IMMEDIATE;
GO

USE PachadataFormation;
GO

SELECT 
    name, 
    compatibility_level, 
    is_read_committed_snapshot_on, 
    is_accelerated_database_recovery_on,
    --data_compaction_desc,
    --is_proactive_statistics_refresh_on,
    is_optimized_locking_on
FROM sys.databases
WHERE database_id = DB_ID();
GO

BEGIN TRAN;

-- There is one row with that phone number, but no index on the column
UPDATE Contact.Contact
SET Nom = 'Bergman'
WHERE Telephone LIKE '0[4567]%';

EXEC sp_lock2 @@SPID;

-- Get current transaction ID
SELECT CURRENT_TRANSACTION_ID();

-- View locks including TID locks (SQL Server 2025 with optimized locking)
SELECT *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
  AND resource_type IN ('PAGE','RID','KEY','XACT');


ROLLBACK


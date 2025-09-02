-- Activate LAQ
USE Master;
GO

-- original state (SQL Server 2014)
ALTER DATABASE [PachadataTraining] SET COMPATIBILITY_LEVEL = 120
GO

-- ALTER DATABASE [PachadataTraining] SET READ_COMMITTED_SNAPSHOT ON
-- WITH ROLLBACK AFTER 60;
-- GO

ALTER DATABASE [PachadataTraining] SET ACCELERATED_DATABASE_RECOVERY = ON
WITH ROLLBACK AFTER 60;
GO

ALTER DATABASE [PachadataTraining] SET OPTIMIZED_LOCKING = ON
WITH ROLLBACK AFTER 60;
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


IF EXISTS (SELECT * FROM sys.server_event_sessions 
           WHERE name = 'laq')
BEGIN
    DROP EVENT SESSION [laq] ON SERVER 
END;

CREATE EVENT SESSION [laq] ON SERVER 
ADD EVENT sqlserver.lock_acquired(
    SET collect_resource_description=(1)
    WHERE ([sqlserver].[session_id]=(87)))
ADD TARGET package0.histogram(
    SET filtering_event_name='sqlserver.lock_acquired',
    slots=16,
    source=N'mode',
    source_type=0
    )
;


ALTER EVENT SESSION [laq] ON SERVER STATE = START;
GO

BEGIN TRAN;

UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE Phone = '533535534';

ROLLBACK

;WITH t AS (
    SELECT 
        CAST(target_data AS XML) AS xml_data
    FROM sys.dm_xe_sessions s 
    JOIN sys.dm_xe_session_targets t 
        ON s.address = t.event_session_address
    WHERE s.name = 'laq' 
    AND t.target_name = 'histogram'
),
h AS (
    SELECT 
        x.value('(value)[1]', 'VARCHAR(50)') as lock_mode,
        x.value('@count', 'bigint') as [count]
    FROM t
    CROSS APPLY xml_data.nodes('//Slot') AS slots(x)
),
map_values AS (
    SELECT
        map_key,
        map_value
    FROM sys.dm_xe_map_values
    WHERE name = 'lock_mode' -- Important: Filter by the correct map name
)
SELECT 
    --h.lock_mode,
    mv.map_value AS lock_mode,
    h.[count]
FROM h
LEFT JOIN map_values mv ON h.lock_mode = mv.map_key
ORDER BY [count] DESC;


ALTER EVENT SESSION [laq] ON SERVER 
STATE = STOP;

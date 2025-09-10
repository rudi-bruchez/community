USE master;
GO

CREATE OR ALTER PROCEDURE sp_getOptimizedLockingXEvent
AS
BEGIN
    SET NOCOUNT ON;

    -- Query the histogram data collected by the 'laq' Extended Events session
    ;WITH t AS (
        SELECT
            CAST(target_data AS XML) AS xml_data
        FROM sys.dm_xe_sessions s
    JOIN sys.dm_xe_session_targets t
        ON s.address = t.event_session_address
    WHERE s.name = 'OptimizedLocking'
    AND t.target_name = 'histogram'
    ),
    h AS (
        -- Extract lock mode and count from the XML histogram data
        SELECT
            x.value('(value)[1]', 'VARCHAR(50)') as lock_mode,
            x.value('@count', 'bigint') as [count]
        FROM t
        CROSS APPLY xml_data.nodes('//Slot') AS slots(x)
    ),
    map_values AS (
        -- Get the mapping between lock mode keys and their human-readable values
        SELECT
            map_key,
            map_value
        FROM sys.dm_xe_map_values
        WHERE name = 'lock_mode' -- Only include lock_mode mappings
    )
    -- Display the lock mode and count, sorted by count descending
    SELECT
        --h.lock_mode,
        mv.map_value AS lock_mode,
        h.[count]
    FROM h
    LEFT JOIN map_values mv ON h.lock_mode = mv.map_key
    ORDER BY [count] DESC;

    ALTER EVENT SESSION [OptimizedLocking] ON SERVER 
    STATE = STOP;

END

USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_create_OptimizedLocking_xevent
    @sessionId int,
    @start bit = 1
AS BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM sys.server_event_sessions 
               WHERE name = 'OptimizedLocking')
    BEGIN
        DROP EVENT SESSION [OptimizedLocking] ON SERVER;
    END;

    DECLARE @sql NVARCHAR(MAX) = CONCAT(N'
        CREATE EVENT SESSION [OptimizedLocking] ON SERVER 
        ADD EVENT sqlserver.lock_acquired(
            SET collect_resource_description=(1)
            WHERE ([sqlserver].[session_id]=(', @sessionId, N')))
        ADD TARGET package0.histogram (
            SET filtering_event_name=''sqlserver.lock_acquired'',
            slots=16,
            source=N''mode'',
            source_type=0
        );');

    IF @start = 1
    BEGIN
        ALTER EVENT SESSION [OptimizedLocking] ON SERVER STATE = START;
    END;
END
GO

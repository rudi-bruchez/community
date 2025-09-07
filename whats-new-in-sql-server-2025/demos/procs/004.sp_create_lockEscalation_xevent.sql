USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_create_lockEscalation_xevent
    @sessionId int,
    @start bit = 1
AS BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM sys.server_event_sessions 
               WHERE name = 'LockEscalation')
    BEGIN
        DROP EVENT SESSION [LockEscalation] ON SERVER;
    END;

    DECLARE @sql NVARCHAR(MAX) = CONCAT(N'
        CREATE EVENT SESSION [lock_escalation] ON SERVER 
        ADD EVENT sqlserver.lock_escalation(
            WHERE ([sqlserver].[session_id]=(', @sessionId, N')))
        ADD TARGET package0.ring_buffer
        WITH (STARTUP_STATE=OFF);');

    IF @start = 1
    BEGIN
        ALTER EVENT SESSION [LockEscalation] ON SERVER STATE = START;
    END;
END
GO

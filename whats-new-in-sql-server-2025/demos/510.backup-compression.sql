SELECT value
FROM sys.configurations
WHERE name = 'backup compression algorithm';
GO

BACKUP DATABASE [PachadataTraining] TO  DISK = N'/var/opt/mssql/backups/Pacha.bak' 
    WITH NOFORMAT, NOINIT,  
    NAME = N'PachadataTraining', SKIP, NOREWIND, NOUNLOAD, 
    COMPRESSION (ALGORITHM = ZSTD),
    STATS = 10
GO

EXECUTE sp_configure 'backup compression algorithm', 3;

RECONFIGURE;
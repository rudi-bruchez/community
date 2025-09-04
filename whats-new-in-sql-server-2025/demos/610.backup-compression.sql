SELECT value
FROM sys.configurations
WHERE name = 'backup compression algorithm';
GO

-- without compression
BACKUP DATABASE [PachadataTraining] TO  DISK = N'/var/opt/mssql/backups/Pacha_nocompress.bak' 
    WITH FORMAT, INIT, NAME = N'PachadataTraining',
    COMPRESSION (ALGORITHM = ZSTD),
    STATS = 10

-- with MS_XPRESS compression
BACKUP DATABASE [PachadataTraining] TO  DISK = N'/var/opt/mssql/backups/Pacha_MS_XPRESS.bak' 
    WITH FORMAT, INIT, NAME = N'PachadataTraining',
    COMPRESSION,
    STATS = 10

-- with ZSTD compression
BACKUP DATABASE [PachadataTraining] TO  DISK = N'/var/opt/mssql/backups/Pacha_ZSTD.bak' 
    WITH FORMAT, INIT, NAME = N'PachadataTraining',
    COMPRESSION (ALGORITHM = ZSTD),
    STATS = 10
GO

-- set it globally
EXECUTE sp_configure 'backup compression algorithm', 3;
RECONFIGURE;
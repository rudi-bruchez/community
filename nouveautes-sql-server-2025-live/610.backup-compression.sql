SELECT value
FROM sys.configurations
WHERE name = 'backup compression algorithm';
GO

-- sans compression
BACKUP DATABASE [PachadataFormation] TO  DISK = N'/var/opt/mssql/backups/Pacha_nocompress.bak' 
    WITH FORMAT, INIT, NAME = N'PachadataFormation',
    STATS = 10

-- with MS_XPRESS compression
BACKUP DATABASE [PachadataFormation] TO  DISK = N'/var/opt/mssql/backups/Pacha_MS_XPRESS.bak' 
    WITH FORMAT, INIT, NAME = N'PachadataFormation',
    COMPRESSION,
    STATS = 10

-- with ZSTD compression
BACKUP DATABASE [PachadataFormation] TO  DISK = N'/var/opt/mssql/backups/Pacha_ZSTD.bak' 
    WITH FORMAT, INIT, NAME = N'PachadataFormation',
    COMPRESSION (ALGORITHM = ZSTD),
    STATS = 10
GO

-- set it globally
EXECUTE sp_configure 'backup compression algorithm', 3;
RECONFIGURE;
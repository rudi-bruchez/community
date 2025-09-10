SELECT value
FROM sys.configurations
WHERE name = 'backup compression algorithm';
GO

<<<<<<< HEAD
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
=======
BACKUP DATABASE [PachadataTraining] TO  DISK = N'/var/tmp/PachaNoCompression.bak' 
    WITH FORMAT, INIT,  
    NAME = N'PachadataTraining', SKIP, NOREWIND, NOUNLOAD, 
    NO_COMPRESSION
GO

BACKUP DATABASE [PachadataTraining] TO  DISK = N'/var/tmp/PachaMsXpress.bak' 
    WITH FORMAT, INIT,  
    NAME = N'PachadataTraining', SKIP, NOREWIND, NOUNLOAD, 
    COMPRESSION
GO

BACKUP DATABASE [PachadataTraining] TO  DISK = N'/var/tmp/PachaZstd.bak' 
    WITH FORMAT, INIT,  
    NAME = N'PachadataTraining', SKIP, NOREWIND, NOUNLOAD, 
    COMPRESSION (ALGORITHM = ZSTD)
GO

EXECUTE sp_configure 'backup compression algorithm', 3;

>>>>>>> 8db4294772e45469de7b735a602ddc669ad7f357
RECONFIGURE;
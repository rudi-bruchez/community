SELECT value
FROM sys.configurations
WHERE name = 'backup compression algorithm';
GO

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

RECONFIGURE;
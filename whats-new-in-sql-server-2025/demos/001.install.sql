-- Demo: SQL Server 2025 Installation Script
-- This script restores the demo database from a backup file.
-- It sets the compatibility level and enables preview features required for the demos.
-- Run this script first to prepare the environment for all subsequent demos.
USE [master]

RESTORE DATABASE [PachadataTraining] 
FROM  DISK = N'/var/opt/mssql/backups/PachaDataTraining.bak' WITH  FILE = 1,  
    MOVE N'PachaDataFormation' TO N'/var/opt/mssql/data/PachaDataTraining.mdf',  
    MOVE N'PachaDataFormation_log' TO N'/var/opt/mssql/data/PachaDataTraining.LDF',  
    NOUNLOAD,  STATS = 5
GO

ALTER DATABASE [PachadataTraining] SET COMPATIBILITY_LEVEL = 170;
GO
USE [PachadataTraining]
GO

ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

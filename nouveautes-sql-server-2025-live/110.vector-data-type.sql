CREATE DATABASE [VectorDemo]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'VectorDemo', FILENAME = N'/var/opt/mssql/data/VectorDemo.mdf' , SIZE = 262144KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'VectorDemo_log', FILENAME = N'/var/opt/mssql/data/VectorDemo_log.ldf' , SIZE = 65536KB , FILEGROWTH = 65536KB )
 WITH LEDGER = OFF
GO
ALTER DATABASE [VectorDemo] SET COMPATIBILITY_LEVEL = 170
ALTER DATABASE [VectorDemo] SET RECOVERY SIMPLE 
ALTER DATABASE [VectorDemo] SET DELAYED_DURABILITY = FORCED 
GO


USE [VectorDemo];

CREATE TABLE ProductCatalog (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255),
    Description NVARCHAR(MAX),
    -- NEW in SQL Server 2025: Vector data type
    DescriptionEmbedding VECTOR(1536)  -- OpenAI ada-002 dimensions
    -- https://openai.com/index/new-and-improved-embedding-model/
);

INSERT INTO ProductCatalog (Name, Description, DescriptionEmbedding) VALUES 
('Gaming Laptop Pro', 'High-performance laptop with RTX 4080, perfect for gaming and streaming', 
 VECTOR('[0.123, 0.456, 0.789, ...]')), -- Truncated for presentation
('Business Ultrabook', 'Lightweight professional laptop for office productivity and presentations',
 VECTOR('[0.234, 0.567, 0.890, ...]')),
('Creative Workstation', 'Powerful desktop for video editing, 3D rendering, and creative work',
 VECTOR('[0.345, 0.678, 0.901, ...]'));
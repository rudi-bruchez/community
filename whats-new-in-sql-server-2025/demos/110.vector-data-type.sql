--USE PachadataTraining;

CREATE DATABASE VectorDemo;
GO

USE [VectorDemo]; -- Pre-created database

-- Step 1: Create table with vector column
CREATE TABLE ProductCatalog (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255),
    Description NVARCHAR(MAX),
    -- NEW in SQL Server 2025: Vector data type
    DescriptionEmbedding VECTOR(1536)  -- OpenAI ada-002 dimensions
    -- https://openai.com/index/new-and-improved-embedding-model/
);

-- Insert sample data (embeddings pre-generated for demo)
INSERT INTO ProductCatalog (Name, Description, DescriptionEmbedding) VALUES 
('Gaming Laptop Pro', 'High-performance laptop with RTX 4080, perfect for gaming and streaming', 
 VECTOR('[0.123, 0.456, 0.789, ...]')), -- Truncated for presentation
('Business Ultrabook', 'Lightweight professional laptop for office productivity and presentations',
 VECTOR('[0.234, 0.567, 0.890, ...]')),
('Creative Workstation', 'Powerful desktop for video editing, 3D rendering, and creative work',
 VECTOR('[0.345, 0.678, 0.901, ...]'));
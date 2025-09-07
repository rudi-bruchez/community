-- Demo: Vector Content Operations and Data Type Conversions
-- This script demonstrates how to query and inspect vector data in SQL Server 2025.
-- It shows how to check vector column properties, perform conversions, and work with JSON and VECTOR types.
USE VectorDemo;
GO

SELECT TOP 10 *
FROM dbo.verses v
WHERE v.verse_embedding IS NOT NULL;

SELECT TOP 10
	v.verse_embedding,
	--LEN(v.verse_embedding),
	DATALENGTH(v.verse_embedding)
FROM dbo.verses v
WHERE v.verse_embedding IS NOT NULL;

SELECT 1544 / 4;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'verses'
AND COLUMN_NAME = 'verse_embedding';

SELECT name, max_length, vector_base_type_desc, vector_dimensions
FROM sys.columns
WHERE object_id = OBJECT_ID('verses')
AND name = 'verse_embedding';

DECLARE @v VECTOR(3) = '[1.0, 2.0, 3.0]';
SET @v = JSON_ARRAY(1.0, 2.0, 3.0)

DECLARE @json JSON = '[0.1, 0.2, 0.3]';
DECLARE @vector VECTOR(3) = CAST(@json AS VECTOR(3));

SELECT @v, @json, @vector;
GO
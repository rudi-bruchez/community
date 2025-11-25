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
-- https://learn.microsoft.com/fr-fr/sql/t-sql/data-types/float-and-real-transact-sql

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'verses'
AND COLUMN_NAME = 'verse_embedding';

SELECT name, max_length, vector_base_type_desc, vector_dimensions
FROM sys.columns
WHERE object_id = OBJECT_ID('verses')
AND name = 'verse_embedding';

SELECT TOP 1 *,
	VECTORPROPERTY([verse_embedding], 'dimensions') as [dimensions],
	VECTORPROPERTY([verse_embedding], 'BaseType') as [base type], -- always float (32 bit) for now,
	VECTOR_NORMALIZE ([verse_embedding], 'norm2' ) as [normalisé]
FROM [dbo].[verses];
GO

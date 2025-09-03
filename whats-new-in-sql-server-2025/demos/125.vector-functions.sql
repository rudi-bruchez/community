USE [VectorDemo];
GO

SELECT TOP 1 *,
	VECTORPROPERTY([verse_embedding], 'dimensions') as [dimensions],
	VECTORPROPERTY([verse_embedding], 'BaseType') as [base type], -- always float (32 bit) for now,
	VECTOR_NORMALIZE ([verse_embedding], 'norm2' )
FROM [dbo].[verses];
GO

ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

DECLARE @v as VECTOR(384);

SELECT @v = [verse_embedding]
FROM [dbo].[verses] v1
WHERE v1.verse = 'And tyrannizing was the lady''s look,';

-- you cannot search without an index ...
SELECT
  v.verse,
  r.distance
FROM
  VECTOR_SEARCH(
    TABLE = [dbo].[verses] AS v,
    COLUMN = [verse_embedding],
    SIMILAR_TO = @v,
    METRIC = 'cosine',
    TOP_N = 10
  ) AS r
ORDER BY
  r.distance;
GO

CREATE VECTOR INDEX IX_verses_verse_embedding 
ON dbo.verses(verse_embedding)
WITH (
    METRIC = 'cosine',     -- Similarity metric
    TYPE = 'DiskANN',
    MAXDOP = 1
);
GO

DECLARE @v as VECTOR(384);

SELECT @v = VECTOR_NORMALIZE ([verse_embedding], 'norm2' )
FROM [dbo].[verses] v1
WHERE v1.verse = 'And tyrannizing was the lady''s look,';

-- you cannot search without an index ...
SELECT
  v.verse,
  r.distance
FROM
  VECTOR_SEARCH(
    TABLE = [dbo].[verses] AS v,
    COLUMN = [verse_embedding],
    SIMILAR_TO = @v,
    METRIC = 'cosine',
    TOP_N = 10
  ) AS r
ORDER BY
  r.distance;
GO

-- Semantic search using VECTOR_DISTANCE
DECLARE @v as VECTOR(384);

SELECT @v = VECTOR_NORMALIZE ([verse_embedding], 'norm2' )
FROM [dbo].[verses] v1
WHERE v1.verse = 'And tyrannizing was the lady''s look,';

SELECT TOP 10
    *,
    -- Cosine similarity - closer to 0 means more similar
    VECTOR_DISTANCE('cosine', verse_embedding, @v) as Similarity
FROM [dbo].[verses] AS v
ORDER BY Similarity ASC;
  
--SELECT AI_GENERATE_EMBEDDING(N'Pink Floyd music style' USE MODEL Ada2Embeddings);
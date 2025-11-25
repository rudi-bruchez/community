USE [VectorDemo];
GO

SELECT TOP 10 * FROM verses;

ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = OFF;
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

DECLARE @v as VECTOR(384);

SELECT @v = [verse_embedding]
FROM [dbo].[verses] v1
WHERE v1.verse = 'And tyrannizing was the lady''s look,';

SELECT
  v.verse_embedding,
  r.distance,
  v.verse
FROM
  VECTOR_SEARCH(
    TABLE = [dbo].[verses] AS v,
    COLUMN = [verse_embedding],
    SIMILAR_TO = @v,
    METRIC = 'cosine',
    TOP_N = 10
  ) AS r
WHERE v.verse <> 'BOOK I.'
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

-- Semantic search using VECTOR_DISTANCE
DECLARE @v as VECTOR(384);

SELECT @v = [verse_embedding]
FROM [dbo].[verses] v1
WHERE v1.verse = 'And tyrannizing was the lady''s look,';

SELECT TOP 10
    *,
    -- Cosine similarity - closer to 0 means more similar
    VECTOR_DISTANCE('cosine', verse_embedding, @v) as Similarity
FROM [dbo].[verses] AS v
ORDER BY Similarity ASC;

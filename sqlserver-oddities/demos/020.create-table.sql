USE PachadataTraining;
GO

-- all carets : SHIFT+ALT + S
-- next matching caret : SHIFT+ALT + ;
-- comment / uncomment
DECLARE @cols varchar(max) = '<complaint-id>, <attendee-id>, <attendee-name>, <attendee#email>, <course-id>, <course-title>, <trainer#name>, <date>, <order>, <complaint-type>, <complaint#details>, <severity-level>, <status>, <resolution-notes>, <resolved-by>, <resolved-date>, <ip-address>';

/*
SELECT *
FROM STRING_SPLIT(@cols, '>, <') cols
-- Procedure expects parameter 'separator' of type 'nchar(1)/nvarchar(1)'.
*/

/*
-- le niveau de compatibilité doit être défini sur 160 pour pouvoir utiliser les mots clés LEADING, TRAILING ou BOTH.
*/

;WITH cte AS (
    SELECT
        cols.ordinal,
        TRANSLATE(
            TRIM(' <>' FROM cols.value)
            , '-#', '__')
        AS col
    FROM STRING_SPLIT(@cols, ',', 1) cols
)
, cte2 AS (
    SELECT 
        ordinal, 
        col,
        rs.column_ordinal as to_change
    FROM cte
    OUTER APPLY sys.dm_exec_describe_first_result_set(CONCAT('CREATE TABLE ', col ,' (id int)'), NULL, 0) rs
    WHERE NULLIF(rs.column_ordinal, 1) IS NULL
    -- sinon quotename
)
, cte3 AS (
    SELECT ordinal,
        CONCAT(CHOOSE(to_change, 'complaint_'), col) as col
    FROM cte2
)
, cte4 AS (
    SELECT 
        DISTINCT -- ORDER BY items must appear in the select list if SELECT DISTINCT is specified.
        --FIRST_VALUE(CONCAT_WS(' ', col, v.t, ',')) OVER (PARTITION BY col ORDER BY pref) as col,
        FIRST_VALUE(CONCAT_WS(' ', col, v.t)) OVER (PARTITION BY col ORDER BY pref) as col,
        c.ordinal
    FROM cte3 c
    LEFT JOIN (VALUES('.*_(id|type|level|order)$','INT', 1),('.*_(name|email|title|notes|details)$','VARCHAR (50)', 1), ('.*date$','DATE', 1), ('.*','VARCHAR (50)', 9)) v(s, t, pref) 
        ON REGEXP_LIKE(c.col, v.s)
)
SELECT 
    CONCAT('CREATE TABLE dbo complaint'
    TRIM(', ' + CHAR(13) FROM STRING_AGG(col, ', ' + CHAR(13)) WITHIN GROUP (ORDER BY ordinal))
    --TRIM(', ' + CHAR(13) FROM STRING_AGG(col, ', ' + CHAR(13)) WITHIN GROUP (ORDER BY ordinal)) -- non regex ?
FROM cte4;
--ORDER BY c.ordinal;

/*
enable_ordinal
Expression int ou bit pour activer ou désactiver la colonne de sortie ordinal. 
Si enable_ordinal est omis, NULL, ou a une valeur de 0, la colonne ordinal est désactivée.
*/


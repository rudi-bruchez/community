
-- =====================================================================
-- Script d'analyse de performances - Regex vs LIKE dans SQL Server 2025
-- Comparaison des performances et de l'efficacité
-- =====================================================================

USE pachadatatraining;
GO

-- Activer les statistiques pour mesurer les performances
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS PROFILE ON;

-- =====================================================================
-- Test 1: Recherche de motifs simples
-- =====================================================================

PRINT '=== Test 1: Recherche de motifs simples ===';
PRINT 'Recherche d''emails avec des domaines spécifiques';

-- Mesure avec LIKE
DECLARE @start_time1 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Resultats_LIKE
FROM Contact.Contact
WHERE Email LIKE '%@gmail.%' 
   OR Email LIKE '%@yahoo.%' 
   OR Email LIKE '%@hotmail.%'
   OR Email LIKE '%@outlook.%';

DECLARE @end_time1 DATETIME2 = SYSDATETIME();
DECLARE @duration1 INT = DATEDIFF(MICROSECOND, @start_time1, @end_time1);

PRINT 'Durée LIKE: ' + CAST(@duration1 AS VARCHAR(20)) + ' microsecondes';

-- Mesure avec REGEXP_LIKE
DECLARE @start_time2 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Resultats_REGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Email, '@(gmail|yahoo|hotmail|outlook)\.');

DECLARE @end_time2 DATETIME2 = SYSDATETIME();
DECLARE @duration2 INT = DATEDIFF(MICROSECOND, @start_time2, @end_time2);

PRINT 'Durée REGEXP_LIKE: ' + CAST(@duration2 AS VARCHAR(20)) + ' microsecondes';
PRINT 'Facteur de performance: ' + CAST(CAST(@duration2 AS FLOAT) / @duration1 AS VARCHAR(10));

-- =====================================================================
-- Test 2: Validation complexe de formats
-- =====================================================================

PRINT '=== Test 2: Validation de formats complexes ===';
PRINT 'Validation de numéros de téléphone français';

-- Test LIKE (approximatif)
DECLARE @start_time3 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Validation_LIKE_Approximative
FROM Contact.Contact
WHERE Phone LIKE '0[1-9]%' 
  AND LEN(REPLACE(REPLACE(REPLACE(REPLACE(Phone, ' ', ''), '-', ''), '.', ''), '+', '')) = 10;

DECLARE @end_time3 DATETIME2 = SYSDATETIME();
DECLARE @duration3 INT = DATEDIFF(MICROSECOND, @start_time3, @end_time3);

PRINT 'Durée validation approximative LIKE: ' + CAST(@duration3 AS VARCHAR(20)) + ' microsecondes';

-- Test REGEXP_LIKE (précis)
DECLARE @start_time4 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Validation_REGEXP_Precise
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^(\+33|0033|0)[1-9]([0-9]{8}|([0-9]{2}[\s\.-]){3}[0-9]{2})$');

DECLARE @end_time4 DATETIME2 = SYSDATETIME();
DECLARE @duration4 INT = DATEDIFF(MICROSECOND, @start_time4, @end_time4);

PRINT 'Durée validation précise REGEXP_LIKE: ' + CAST(@duration4 AS VARCHAR(20)) + ' microsecondes';
PRINT 'Facteur de performance: ' + CAST(CAST(@duration4 AS FLOAT) / @duration3 AS VARCHAR(10));

-- =====================================================================
-- Test 3: Extraction et transformation
-- =====================================================================

PRINT '=== Test 3: Extraction et transformation de données ===';
PRINT 'Extraction du domaine des emails';

-- Approche traditionnelle avec SUBSTRING et CHARINDEX
DECLARE @start_time5 DATETIME2 = SYSDATETIME();

SELECT 
    ContactId,
    SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) as Domaine_Traditionnel
FROM Contact.Contact
WHERE Email IS NOT NULL AND CHARINDEX('@', Email) > 0;

DECLARE @end_time5 DATETIME2 = SYSDATETIME();
DECLARE @duration5 INT = DATEDIFF(MICROSECOND, @start_time5, @end_time5);

PRINT 'Durée extraction traditionnelle: ' + CAST(@duration5 AS VARCHAR(20)) + ' microsecondes';

-- Approche REGEXP_SUBSTR
DECLARE @start_time6 DATETIME2 = SYSDATETIME();

SELECT 
    ContactId,
    REGEXP_SUBSTR(Email, '@(.+)$', 1, 1, '', 1) as Domaine_REGEXP
FROM Contact.Contact
WHERE Email IS NOT NULL;

DECLARE @end_time6 DATETIME2 = SYSDATETIME();
DECLARE @duration6 INT = DATEDIFF(MICROSECOND, @start_time6, @end_time6);

PRINT 'Durée extraction REGEXP_SUBSTR: ' + CAST(@duration6 AS VARCHAR(20)) + ' microsecondes';
PRINT 'Facteur de performance: ' + CAST(CAST(@duration6 AS FLOAT) / @duration5 AS VARCHAR(10));

-- =====================================================================
-- Test 4: Analyse de complexité avec index
-- =====================================================================

PRINT '=== Test 4: Impact des index sur les performances ===';

-- Créer un index sur la colonne Email pour les tests
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Contact_Email' AND object_id = OBJECT_ID('Contact.Contact'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Contact_Email ON Contact.Contact (Email);
    PRINT 'Index créé sur la colonne Email';
END

-- Test avec prédicat SARGable (LIKE avec préfixe)
DECLARE @start_time7 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Resultats_LIKE_Sargable
FROM Contact.Contact
WHERE Email LIKE 'admin@%';

DECLARE @end_time7 DATETIME2 = SYSDATETIME();
DECLARE @duration7 INT = DATEDIFF(MICROSECOND, @start_time7, @end_time7);

PRINT 'Durée LIKE SARGable avec index: ' + CAST(@duration7 AS VARCHAR(20)) + ' microsecondes';

-- Test REGEXP_LIKE (peut utiliser l'index selon le motif)
DECLARE @start_time8 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Resultats_REGEXP_Index
FROM Contact.Contact
WHERE REGEXP_LIKE(Email, '^admin@');

DECLARE @end_time8 DATETIME2 = SYSDATETIME();
DECLARE @duration8 INT = DATEDIFF(MICROSECOND, @start_time8, @end_time8);

PRINT 'Durée REGEXP_LIKE avec motif indexable: ' + CAST(@duration8 AS VARCHAR(20)) + ' microsecondes';
PRINT 'Facteur de performance: ' + CAST(CAST(@duration8 AS FLOAT) / @duration7 AS VARCHAR(10));

-- =====================================================================
-- Test 5: Analyse des plans d'exécution
-- =====================================================================

PRINT '=== Test 5: Analyse des plans d''exécution ===';

-- Activer les plans d'exécution détaillés
SET SHOWPLAN_ALL ON;

PRINT 'Plan d''exécution pour LIKE:';
SELECT COUNT(*) FROM Contact.Contact WHERE Email LIKE '%@company.%';

PRINT 'Plan d''exécution pour REGEXP_LIKE:';
SELECT COUNT(*) FROM Contact.Contact WHERE REGEXP_LIKE(Email, '@company\.');

SET SHOWPLAN_ALL OFF;

-- =====================================================================
-- Test 6: Test de charge avec gros volumes
-- =====================================================================

PRINT '=== Test 6: Test de charge ===';

-- Créer une table temporaire avec plus de données pour le test de charge
IF OBJECT_ID('tempdb..#ContactsTest') IS NOT NULL DROP TABLE #ContactsTest;

CREATE TABLE #ContactsTest (
    ContactId INT IDENTITY(1,1),
    Email VARCHAR(150),
    Phone VARCHAR(15)
);

-- Insérer des données de test (multiplication des données existantes)
INSERT INTO #ContactsTest (Email, Phone)
SELECT 
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY ContactId) % 5 = 0 THEN REPLACE(Email, '@', CAST(ROW_NUMBER() OVER (ORDER BY ContactId) AS VARCHAR(10)) + '@')
        ELSE Email
    END,
    Phone
FROM Contact.Contact c1
CROSS JOIN (SELECT TOP 10 ContactId FROM Contact.Contact) c2
WHERE c1.Email IS NOT NULL;

PRINT 'Données de test créées: ' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ' lignes';

-- Test de performance sur gros volume avec LIKE
DECLARE @start_time9 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Resultats_LIKE_Volume
FROM #ContactsTest
WHERE Email LIKE '%@gmail.%' 
   OR Email LIKE '%@yahoo.%' 
   OR Email LIKE '%@company.%';

DECLARE @end_time9 DATETIME2 = SYSDATETIME();
DECLARE @duration9 INT = DATEDIFF(MICROSECOND, @start_time9, @end_time9);

PRINT 'Durée LIKE sur gros volume: ' + CAST(@duration9 AS VARCHAR(20)) + ' microsecondes';

-- Test de performance sur gros volume avec REGEXP_LIKE
DECLARE @start_time10 DATETIME2 = SYSDATETIME();

SELECT COUNT(*) as Resultats_REGEXP_Volume
FROM #ContactsTest
WHERE REGEXP_LIKE(Email, '@(gmail|yahoo|company)\.');

DECLARE @end_time10 DATETIME2 = SYSDATETIME();
DECLARE @duration10 INT = DATEDIFF(MICROSECOND, @start_time10, @end_time10);

PRINT 'Durée REGEXP_LIKE sur gros volume: ' + CAST(@duration10 AS VARCHAR(20)) + ' microsecondes';
PRINT 'Facteur de performance gros volume: ' + CAST(CAST(@duration10 AS FLOAT) / @duration9 AS VARCHAR(10));

-- Nettoyage
DROP TABLE #ContactsTest;

-- =====================================================================
-- Rapport de synthèse des performances
-- =====================================================================

PRINT '=== Rapport de synthèse ===';
PRINT 'Les tests montrent que:';
PRINT '1. REGEXP_LIKE offre plus de flexibilité pour des motifs complexes';
PRINT '2. LIKE peut être plus rapide pour des recherches simples avec index';
PRINT '3. REGEXP_LIKE permet une validation précise impossible avec LIKE';
PRINT '4. L''impact sur les performances dépend de la complexité du motif';
PRINT '5. Les nouveaux opérateurs regex sont SARGables dans certains cas';

-- Désactiver les statistiques
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
SET STATISTICS PROFILE OFF;

GO


-- =====================================================================
-- Script de démonstration des nouvelles fonctions regex dans SQL Server 2025
-- Base de données : pachadatatraining
-- Table : Contact.Contact
-- =====================================================================

USE pachadatatraining;
GO

-- Vérifier et définir le niveau de compatibilité 170 (SQL Server 2025)
IF (SELECT compatibility_level FROM sys.databases WHERE name = 'pachadatatraining') < 170
BEGIN
    ALTER DATABASE pachadatatraining SET COMPATIBILITY_LEVEL = 170;
    PRINT 'Niveau de compatibilité mis à jour vers 170 (SQL Server 2025)';
END
GO

-- =====================================================================
-- SECTION 1: REGEXP_LIKE - Validation et détection de motifs
-- =====================================================================

PRINT '=== REGEXP_LIKE - Exemples de validation ===';

-- 1.1 Validation d'emails
SELECT 
    ContactId,
    Email,
    CASE 
        WHEN REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') = 1 
        THEN 'Email valide'
        ELSE 'Email non valide'
    END AS ValidationEmail
FROM Contact.Contact
WHERE Email IS NOT NULL
ORDER BY ContactId;

-- 1.2 Validation de numéros de téléphone français
SELECT 
    ContactId,
    Phone,
    CASE 
        WHEN REGEXP_LIKE(Phone, '^(\+33|0)[1-9]([0-9]{8})$') = 1 
        THEN 'Téléphone français valide'
        WHEN REGEXP_LIKE(Phone, '^[0-9]{2}[\s\.-][0-9]{2}[\s\.-][0-9]{2}[\s\.-][0-9]{2}[\s\.-][0-9]{2}$') = 1
        THEN 'Format français avec séparateurs'
        ELSE 'Format non reconnu'
    END AS ValidationTelephone
FROM Contact.Contact
WHERE Phone IS NOT NULL;

-- 1.3 Détection de noms avec caractères spéciaux
SELECT 
    ContactId,
    FirstName,
    LastName
FROM Contact.Contact
WHERE REGEXP_LIKE(FirstName, '[^A-Za-zÀ-ÿ\s\-\'']') = 1
   OR REGEXP_LIKE(LastName, '[^A-Za-zÀ-ÿ\s\-\'']') = 1;

-- =====================================================================
-- SECTION 2: REGEXP_COUNT - Comptage d'occurrences
-- =====================================================================

PRINT '=== REGEXP_COUNT - Comptage d''occurrences ===';

-- 2.1 Compter les chiffres dans les noms
SELECT 
    ContactId,
    FirstName,
    LastName,
    REGEXP_COUNT(FirstName, '[0-9]') AS ChiffresPrenom,
    REGEXP_COUNT(LastName, '[0-9]') AS ChiffresNom
FROM Contact.Contact
WHERE REGEXP_COUNT(FirstName, '[0-9]') > 0 
   OR REGEXP_COUNT(LastName, '[0-9]') > 0;

-- 2.2 Analyser la complexité des mots de passe (si colonne existe)
-- Simulation avec Email pour la démonstration
SELECT 
    ContactId,
    Email,
    REGEXP_COUNT(Email, '[A-Z]') AS MajusculeCount,
    REGEXP_COUNT(Email, '[a-z]') AS MinusculeCount,
    REGEXP_COUNT(Email, '[0-9]') AS ChiffreCount,
    REGEXP_COUNT(Email, '[^A-Za-z0-9@.]') AS SpecialCharCount
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- =====================================================================
-- SECTION 3: REGEXP_INSTR - Position des correspondances
-- =====================================================================

PRINT '=== REGEXP_INSTR - Position des correspondances ===';

-- 3.1 Trouver la position du domaine dans l'email
SELECT 
    ContactId,
    Email,
    REGEXP_INSTR(Email, '@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') AS PositionDomaine,
    REGEXP_INSTR(Email, '@') AS PositionArobase
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- 3.2 Position des espaces dans les noms complets
SELECT 
    ContactId,
    CONCAT(FirstName, ' ', LastName) AS NomComplet,
    REGEXP_INSTR(CONCAT(FirstName, ' ', LastName), '\s') AS PremierEspace,
    REGEXP_INSTR(CONCAT(FirstName, ' ', LastName), '\s', 1, 2) AS DeuxiemeEspace
FROM Contact.Contact
WHERE FirstName IS NOT NULL AND LastName IS NOT NULL;

-- =====================================================================
-- SECTION 4: REGEXP_REPLACE - Remplacement avec expressions régulières
-- =====================================================================

PRINT '=== REGEXP_REPLACE - Remplacement avec regex ===';

-- 4.1 Normaliser les numéros de téléphone
SELECT 
    ContactId,
    Phone AS TelephoneOriginal,
    REGEXP_REPLACE(Phone, '[\s\.-]', '') AS TelephoneNormalise,
    REGEXP_REPLACE(Phone, '^(\+33|0033)', '0') AS TelephoneFrancais
FROM Contact.Contact
WHERE Phone IS NOT NULL;

-- 4.2 Masquer une partie des emails pour la confidentialité
SELECT 
    ContactId,
    Email AS EmailOriginal,
    REGEXP_REPLACE(Email, '^([^@]{1,2})[^@]*(@.*)$', '$1***$2') AS EmailMasque
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- 4.3 Nettoyer les noms en supprimant les caractères non désirés
SELECT 
    ContactId,
    FirstName AS PrenomOriginal,
    REGEXP_REPLACE(FirstName, '[^A-Za-zÀ-ÿ\s\-\'']', '') AS PrenomNettoye,
    LastName AS NomOriginal,
    REGEXP_REPLACE(LastName, '[^A-Za-zÀ-ÿ\s\-\'']', '') AS NomNettoye
FROM Contact.Contact
WHERE FirstName IS NOT NULL OR LastName IS NOT NULL;

-- =====================================================================
-- SECTION 5: REGEXP_SUBSTR - Extraction de sous-chaînes
-- =====================================================================

PRINT '=== REGEXP_SUBSTR - Extraction de sous-chaînes ===';

-- 5.1 Extraire le nom d'utilisateur et le domaine de l'email
SELECT 
    ContactId,
    Email,
    REGEXP_SUBSTR(Email, '^[^@]+') AS NomUtilisateur,
    REGEXP_SUBSTR(Email, '@(.+)$', 1, 1, '', 1) AS Domaine
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- 5.2 Extraire les codes postaux depuis les fax (exemple)
SELECT 
    ContactId,
    Fax,
    REGEXP_SUBSTR(Fax, '[0-9]{5}') AS CodePostalExtrait
FROM Contact.Contact
WHERE Fax IS NOT NULL 
  AND REGEXP_LIKE(Fax, '[0-9]{5}') = 1;

-- =====================================================================
-- SECTION 6: REGEXP_MATCHES - Correspondances détaillées
-- =====================================================================

PRINT '=== REGEXP_MATCHES - Correspondances détaillées ===';

-- 6.1 Analyser les composants d'un email
SELECT 
    c.ContactId,
    c.Email,
    m.match_value,
    m.match_ordinal
FROM Contact.Contact c
CROSS APPLY REGEXP_MATCHES(c.Email, '([^@]+)@([^.]+)\.(.+)') m
WHERE c.Email IS NOT NULL;

-- 6.2 Extraire tous les mots d'un nom complet
SELECT 
    c.ContactId,
    CONCAT(c.FirstName, ' ', c.LastName) as NomComplet,
    m.match_value as Mot,
    m.match_ordinal as Position
FROM Contact.Contact c
CROSS APPLY REGEXP_MATCHES(CONCAT(c.FirstName, ' ', c.LastName), '[A-Za-zÀ-ÿ]+') m
WHERE c.FirstName IS NOT NULL AND c.LastName IS NOT NULL;

-- =====================================================================
-- SECTION 7: REGEXP_SPLIT_TO_TABLE - Division en table
-- =====================================================================

PRINT '=== REGEXP_SPLIT_TO_TABLE - Division en table ===';

-- 7.1 Séparer les noms composés
SELECT 
    c.ContactId,
    c.FirstName,
    s.value as PartiePrenom,
    s.ordinal as Ordre
FROM Contact.Contact c
CROSS APPLY REGEXP_SPLIT_TO_TABLE(c.FirstName, '[\s\-]') s
WHERE c.FirstName IS NOT NULL 
  AND REGEXP_LIKE(c.FirstName, '[\s\-]') = 1;

-- 7.2 Analyser les domaines d'email par segments
SELECT 
    c.ContactId,
    c.Email,
    REGEXP_SUBSTR(c.Email, '@(.+)$', 1, 1, '', 1) as DomaineComplet,
    s.value as SegmentDomaine,
    s.ordinal as Niveau
FROM Contact.Contact c
CROSS APPLY REGEXP_SPLIT_TO_TABLE(REGEXP_SUBSTR(c.Email, '@(.+)$', 1, 1, '', 1), '\.') s
WHERE c.Email IS NOT NULL;

-- =====================================================================
-- SECTION 8: Comparaison de performances REGEXP vs LIKE
-- =====================================================================

PRINT '=== Tests de performance REGEXP vs LIKE ===';

-- 8.1 Test de performance : recherche d'emails
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Test avec LIKE
SELECT COUNT(*) as ResultatsLIKE
FROM Contact.Contact
WHERE Email LIKE '%@gmail.%' 
   OR Email LIKE '%@yahoo.%' 
   OR Email LIKE '%@hotmail.%';

-- Test avec REGEXP_LIKE
SELECT COUNT(*) as ResultatsREGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Email, '@(gmail|yahoo|hotmail)\.');

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- 8.2 Test de complexité : validation format téléphone
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Approche LIKE (limitée)
SELECT COUNT(*) as ValidationLIKE
FROM Contact.Contact
WHERE Phone LIKE '01%' 
   OR Phone LIKE '02%' 
   OR Phone LIKE '03%';

-- Approche REGEXP_LIKE (complète)
SELECT COUNT(*) as ValidationREGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^(\+33|0)[1-9][0-9]{8}$');

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- =====================================================================
-- SECTION 9: Requêtes d'analyse avancées
-- =====================================================================

-- 9.1 Rapport de qualité des données
WITH QualiteData AS (
    SELECT 
        ContactId,
        FirstName,
        LastName,
        Email,
        Phone,
        CASE WHEN REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') = 1 
             THEN 1 ELSE 0 END as EmailValide,
        CASE WHEN REGEXP_LIKE(Phone, '^(\+33|0)[1-9][0-9]{8}$') = 1 
             THEN 1 ELSE 0 END as TelephoneValide,
        CASE WHEN REGEXP_LIKE(FirstName, '^[A-Za-zÀ-ÿ\s\-\''.]+$') = 1 
             THEN 1 ELSE 0 END as PrenomValide,
        CASE WHEN REGEXP_LIKE(LastName, '^[A-Za-zÀ-ÿ\s\-\''.]+$') = 1 
             THEN 1 ELSE 0 END as NomValide
    FROM Contact.Contact
    WHERE Email IS NOT NULL OR Phone IS NOT NULL
)
SELECT 
    COUNT(*) as TotalContacts,
    SUM(EmailValide) as EmailsValides,
    SUM(TelephoneValide) as TelephonesValides,
    SUM(PrenomValide) as PrenomsValides,
    SUM(NomValide) as NomsValides,
    CAST(AVG(CAST(EmailValide AS FLOAT)) * 100 AS DECIMAL(5,2)) as PourcentageEmailsValides,
    CAST(AVG(CAST(TelephoneValide AS FLOAT)) * 100 AS DECIMAL(5,2)) as PourcentageTelephonesValides
FROM QualiteData;

-- 9.2 Analyse des domaines d'email les plus fréquents
SELECT 
    REGEXP_SUBSTR(Email, '@([^.]+)', 1, 1, '', 1) as Fournisseur,
    COUNT(*) as NombreUtilisateurs,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Contact.Contact WHERE Email IS NOT NULL) AS DECIMAL(5,2)) as Pourcentage
FROM Contact.Contact
WHERE Email IS NOT NULL
GROUP BY REGEXP_SUBSTR(Email, '@([^.]+)', 1, 1, '', 1)
ORDER BY COUNT(*) DESC;

GO

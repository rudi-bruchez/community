-- =====================================================================
-- Demonstration script for new regex functions in SQL Server 2025
-- Database: pachadatatraining
-- Table: Contact.Contact
-- test it at : https://regex101.com/ (use Golang flavor)
-- =====================================================================

-- Set compatibility level 170 (SQL Server 2025)
ALTER DATABASE PachadataTraining SET COMPATIBILITY_LEVEL = 170;
GO
USE PachadataTraining
GO

-- =====================================================================
--             REGEXP_LIKE - Searching for patterns
-- =====================================================================

-- Email validation
SELECT
    ContactId,
    Email,
    CASE
        WHEN REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$')
        THEN 'Email valid'
        ELSE 'Email invalid'
    END AS ValidationEmail
FROM Contact.Contact
WHERE Email IS NOT NULL
ORDER BY ContactId;

-- Validation of French phone numbers
SELECT
    ContactId,
    Phone,
    CASE
        WHEN REGEXP_LIKE(Phone, '^(\+33|0)[1-9]([0-9]{8})$')
            THEN 'Valid French phone number'
        WHEN REGEXP_LIKE(Phone, '^[0-9]{2}[\s\.-][0-9]{2}[\s\.-][0-9]{2}[\s\.-][0-9]{2}[\s\.-][0-9]{2}$')
            THEN 'French format with separators'
        ELSE 'Unrecognized format'
    END AS PhoneValidation
FROM Contact.Contact
WHERE Phone IS NOT NULL;

-- Detect names with special characters
SELECT 
    ContactId,
    FirstName,
    LastName
FROM Contact.Contact
WHERE REGEXP_LIKE(LastName, '[^A-Za-zÀ-ÿ\s\-\'']')
--WHERE REGEXP_LIKE(LastName, '^Ama', 'i')
-- manually setting selectivity
-- OPTION (USE HINT ('ASSUME_FIXED_MIN_SELECTIVITY_FOR_REGEXP'));

-- where does it come from? Who knows
SELECT COUNT(*)
FROM Contact.Contact;

-- =====================================================================
--             REGEXP_COUNT - Counting occurrences
-- =====================================================================

-- Analyze emails
SELECT
    ContactId,
    Email,
    REGEXP_COUNT(Email, '[A-Z]') AS UpperCaseCount,
    REGEXP_COUNT(Email, '[a-z]') AS LowerCaseCount,
    REGEXP_COUNT(Email, '[0-9]') AS DigitCount,
    REGEXP_COUNT(Email, '[^A-Za-z0-9@.]') AS SpecialCharCount
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- =====================================================================
--             REGEXP_INSTR - Match positions
-- =====================================================================

-- Find the position of the domain in the email
SELECT 
    ContactId,
    Email,
    REGEXP_INSTR(Email, '[^@][A-Za-z0-9.-]+\.[A-Za-z]{2,}$') AS PositionDomain,
    REGEXP_INSTR(Email, '@') AS PositionAt
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- Position of spaces in full names
SELECT 
    ContactId,
    CONCAT(FirstName, ' ', LastName) AS NomComplet,
    REGEXP_INSTR(CONCAT(FirstName, ' ', LastName), '\s') AS FirstSpace,
    REGEXP_INSTR(CONCAT(FirstName, ' ', LastName), '\s', 1, 2) AS SecondSpace
FROM Contact.Contact
WHERE FirstName IS NOT NULL AND LastName IS NOT NULL;

-- =====================================================================
--            REGEXP_REPLACE - Replacement with regular expressions
-- =====================================================================

-- Mask part of emails for privacy
SELECT 
    ContactId,
    Email AS OriginalEmail,
    REGEXP_REPLACE(Email, '^([^@]{1,2})[^@]*(@.*)$', '\1***\2') AS MaskedEmail
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- =====================================================================
--             REGEXP_SUBSTR - Substring extraction
-- =====================================================================

-- Extract username and domain from email
SELECT
    ContactId,
    Email,
    REGEXP_SUBSTR(Email, '^[^@]+') AS UserName,
    REGEXP_SUBSTR(Email, '@(.+)$', 1, 1, '', 1) AS Domain
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- =====================================================================
--             REGEXP_MATCHES - Detailed matches
-- =====================================================================

SELECT *
FROM REGEXP_MATCHES('A thing of beauty is a joy for ever:
  Its loveliness increases; it will never
  Pass into nothingness; but still will keep
  A bower quiet for us, and a sleep
  Full of sweet dreams, and health, and quiet breathing.', '[A-Za-zÀ-ÿ]+') m


-- =====================================================================
--             REGEXP_SPLIT_TO_TABLE - Split into table
-- =====================================================================

-- Split compound first names
SELECT TOP 20
    c.ContactId,
    c.FirstName,
    s.value as FirstNamePart,
    s.ordinal as [Order]
FROM Contact.Contact c
CROSS APPLY REGEXP_SPLIT_TO_TABLE(c.FirstName, '[\s\-]') s
WHERE c.FirstName IS NOT NULL 
  AND REGEXP_LIKE(c.FirstName, '[\s\-]');

-- Analyze email domains by segments
SELECT
    c.ContactId,
    c.Email,
    REGEXP_SUBSTR(c.Email, '@(.+)$', 1, 1, '', 1) as FullDomain,
    s.value as DomainSegment,
    s.ordinal as Level
FROM Contact.Contact c
CROSS APPLY REGEXP_SPLIT_TO_TABLE(REGEXP_SUBSTR(c.Email, '@(.+)$', 1, 1, '', 1), '\.') s
WHERE c.Email IS NOT NULL;

-- =====================================================================
--             REGEXP vs LIKE performance comparison
-- =====================================================================

-- Performance test: email search
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Test with LIKE
SELECT COUNT(*) as ResultatsLIKE
FROM Contact.Contact
WHERE Email LIKE '%@solarpanel.%' 
   OR Email LIKE '%@spycamera.%' 
   OR Email LIKE '%@hotmail.%';

-- Test with REGEXP_LIKE
SELECT COUNT(*) as ResultatsREGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Email, '@(solarpanel|spycamera|hotmail)\.');

-- Complexity test: phone format validation

-- LIKE approach (limited)
SELECT COUNT(*) as ValidationLIKE
FROM Contact.Contact
WHERE Phone LIKE '01%' 
   OR Phone LIKE '02%' 
   OR Phone LIKE '03%';

-- REGEXP_LIKE approach (complete)
SELECT COUNT(*) as ValidationREGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^(\+33|0)[1-9][0-9]{8}$');

-- SARGability

CREATE INDEX ix_Contact_Phone ON Contact.Contact (Phone)
-- WITH (DROP_EXISTING = ON);
GO

-- TODO : check the density vector
SELECT COUNT(*) as ValidationREGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^(\+33|0)[1-9][0-9]{8}$');
GO

SELECT *
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^(\+33|0)[1-9][0-9]{8}$');
GO

SELECT COUNT(*) as ValidationREGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^[1-9][0-9]{8}$');

SELECT COUNT(*) as ValidationREGEXP
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^06[0-9]{6}$');

-- row goal ?
SELECT TOP 10 LastName, Phone
FROM Contact.Contact
WHERE REGEXP_LIKE(Phone, '^(\+33|0)[1-9][0-9]{8}$');
GO


-- =====================================================================
--             Advanced analysis queries
-- =====================================================================

-- Data quality report
WITH QualiteData AS (
    SELECT 
        ContactId,
        FirstName,
        LastName,
        Email,
        Phone,
        CASE WHEN REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
             THEN 1 ELSE 0 END as ValidEmail,
        CASE WHEN REGEXP_LIKE(Phone, '^(\+33|0)[1-9][0-9]{8}$')
             THEN 1 ELSE 0 END as ValidPhone,
       CASE WHEN REGEXP_LIKE(FirstName, '^[A-Za-zÀ-ÿ\s\-\''.]+$')
           THEN 1 ELSE 0 END as ValidFirstName,
       CASE WHEN REGEXP_LIKE(LastName, '^[A-Za-zÀ-ÿ\s\-\''.]+$')
           THEN 1 ELSE 0 END as ValidLastName
    FROM Contact.Contact
    WHERE Email IS NOT NULL OR Phone IS NOT NULL
)
SELECT 
    COUNT(*) as TotalContacts,
    SUM(ValidEmail) as ValidEmails,
    SUM(ValidPhone) as ValidPhones,
    SUM(ValidFirstName) as ValidFirstNames,
    SUM(ValidLastName) as ValidLastNames,
    CAST(AVG(CAST(ValidEmail AS FLOAT)) * 100 AS DECIMAL(5,2)) as PercentageValidEmails,
    CAST(AVG(CAST(ValidPhone AS FLOAT)) * 100 AS DECIMAL(5,2)) as PercentageValidPhones
FROM QualiteData;

-- Analysis of most frequent email domains
SELECT 
    REGEXP_SUBSTR(Email, '@([^.]+)', 1, 1, '', 1) as Provider,
    COUNT(*) as UserCount,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Contact.Contact WHERE Email IS NOT NULL) AS DECIMAL(5,2)) as Percentage
FROM Contact.Contact
WHERE Email IS NOT NULL
GROUP BY REGEXP_SUBSTR(Email, '@([^.]+)', 1, 1, '', 1)
ORDER BY COUNT(*) DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
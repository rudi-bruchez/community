USE PachadataTraining;
GO

SET STATISTICS TIME ON;
GO

SELECT 
    ContactId,
    Email,
    CASE
        WHEN REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$')
        THEN 'Email valid'
        ELSE 'Email invalid'
    END AS ValidationEmail
FROM Contact.Contact
WHERE Email IS NOT NULL;

-- simpler, less accurate
SELECT 
    ContactId,
    Email,
    CASE
        WHEN REGEXP_LIKE(Email, '^[^\s@]+@[^\s@]+\.[^\s@]{2,}$')
        THEN 'Email valid'
        ELSE 'Email invalid'
    END AS ValidationEmail
FROM Contact.Contact
WHERE Email IS NOT NULL;

SELECT 
    ContactId,
    Email,
    CASE
        WHEN REGEXP_LIKE(Email, '^[A-Za-z0-9][A-Za-z0-9._%+-]{0,63}@[A-Za-z0-9][A-Za-z0-9.-]{0,62}\.[A-Za-z]{2,6}$')
        THEN 'Email valid'
        ELSE 'Email invalid'
    END AS ValidationEmail
FROM Contact.Contact
WHERE Email IS NOT NULL;

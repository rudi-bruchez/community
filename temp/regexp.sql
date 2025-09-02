ALTER DATABASE pachadatatraining SET COMPATIBILITY_LEVEL = 170;

-- Email validation
SELECT 
    ContactId,
    Email,
    CASE 
        WHEN REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
        THEN 'Email valid'
        ELSE 'Email invalid'
    END AS ValidationEmail
FROM Contact.Contact
WHERE Email IS NOT NULL
ORDER BY ContactId;

SELECT 
    ContactId,
    Phone,
    CASE 
        WHEN REGEXP_LIKE(Phone, '^(\\+33|0)[1-9]([0-9]{8})$') 
        THEN 'Téléphone français valide'
        WHEN REGEXP_LIKE(Phone, '^[0-9]{2}[\\s\\.-][0-9]{2}[\\s\\.-][0-9]{2}[\\s\\.-][0-9]{2}[\\s\\.-][0-9]{2}$')
        THEN 'Format français avec séparateurs'
        ELSE 'Format non reconnu'
    END AS ValidationTelephone
FROM Contact.Contact
WHERE Phone IS NOT NULL;
USE PachadataTraining;
GO

BEGIN TRAN;

UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE Phone LIKE '08%';

-- ROLLBACK

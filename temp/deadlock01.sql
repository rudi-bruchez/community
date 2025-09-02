USE PachadataTraining;

IF EXISTS(SELECT 1 FROM sys.databases WHERE database_id = DB_ID() AND is_optimized_locking_on = 0)
BEGIN
    RAISERROR('Optimized Locking is OFF.', 10, 1) WITH NOWAIT;
END ELSE
BEGIN
    RAISERROR('Optimized Locking is ON.', 10, 1) WITH NOWAIT;
END;

BEGIN TRANSACTION;

UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE LastName = 'Simon';

UPDATE Contact.Company
SET name = 'Fish Fosh'
WHERE Name = 'Bamboo Flooring';

ROLLBACK;

USE PachadataTraining;
GO

-- with an index
--CREATE INDEX ix_Contact_Phone ON Contact.Contact (Phone);

-- Create a new Extended Events session named 'OptimizedLocking' to track lock acquisitions 
EXEC dbo.sp_create_OptimizedLocking_xevent @@SPID
GO

--SET LOCK_TIMEOUT 10;

BEGIN TRAN;

-- Update the LastName of the contact whose Phone is '533535534' 
-- in the Contact.Contact table
-- There is one row with that phone number, but no index on the column
UPDATE Contact.Contact
SET LastName = 'Bergman'
WHERE Phone = '0763945448';
--WHERE Phone LIKE '0[4567]%';

EXEC sp_lock2 @@SPID;

-- lock memory
SELECT name, pages_kb, virtual_memory_reserved_kb, virtual_memory_committed_kb
FROM sys.dm_os_memory_clerks
WHERE type = N'OBJECTSTORE_LOCK_MANAGER'
AND name NOT LIKE '%DAC%';

ROLLBACK

-- Query the histogram data collected by the 'OptimizedLocking' Extended Events session
EXEC sp_getOptimizedLockingXEvent
GO


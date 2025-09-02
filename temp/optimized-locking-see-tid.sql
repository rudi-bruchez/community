DBCC TRACEON (3604);

-- Find the page containing your data
DBCC IND('PachadataTraining', 'Contact.Contact', 1);

-- Examine the page content (replace with actual file_id and page_id)
DBCC PAGE('PachadataTraining', 1, 680, 3);

-- Get current transaction ID
SELECT CURRENT_TRANSACTION_ID();

-- View locks including TID locks (SQL Server 2025 with optimized locking)
SELECT *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
  AND resource_type IN ('PAGE','RID','KEY','XACT');

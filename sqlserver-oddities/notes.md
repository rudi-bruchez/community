# SQL Server oddities

* EXEC sp\_lock @@SPID, --> 2 spid
* ALTER DATABASE \[PachadataTraining] SET READ\_COMMITTED\_SNAPSHOT ON
  WITH ROLLBACK AFTER 60;
* read dirty page

# LINENO

sp_helptext proc_name

Out of habit I place LINENO 0 directly after BEGIN in my stored procedures. This resets the line number - to zero, in this case.

```sql
BEGIN CATCH
  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  DECLARE @ErrorState INT;

  SELECT 
     @ErrorMessage = ERROR_MESSAGE() + ' occurred at Line_Number: ' + CAST(ERROR_LINE() AS VARCHAR(50)),
     @ErrorSeverity = ERROR_SEVERITY(),
     @ErrorState = ERROR_STATE();

  RAISERROR (@ErrorMessage, -- Message text.
     @ErrorSeverity, -- Severity.
     @ErrorState -- State.
  );

END CATCH
```

## some references

* [SET NOEXEC](https://learn.microsoft.com/en-us/sql/t-sql/statements/set-noexec-transact-sql)
* [FOR BROWSE](https://stackoverflow.com/questions/10951907/what-is-the-tsql-for-browse-option-used-for)


MULTIPLE CARETS IN SSMS -- pour changer la taille du varchar
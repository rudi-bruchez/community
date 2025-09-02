* EXEC sp\_lock @@SPID, --> 2 spid
* ALTER DATABASE \[PachadataTraining] SET READ\_COMMITTED\_SNAPSHOT ON
  WITH ROLLBACK AFTER 60;
* read dirty page

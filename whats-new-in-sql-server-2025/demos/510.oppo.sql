USE PachadataTraining;
GO

-- OPPO requires compatibility level 170 (default in SQL Server 2025)
ALTER DATABASE PachadataTraining SET COMPATIBILITY_LEVEL = 170;

-- OPPO is enabled by default, but can be controlled explicitly
ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = ON;
GO

/*
DROP INDEX ix_Contact_LastName  ON Contact.Contact;
DROP INDEX ix_Contact_FirstName ON Contact.Contact;
DROP INDEX ix_Contact_Email     ON Contact.Contact;
*/

CREATE INDEX ix_Contact_LastName  ON Contact.Contact (LastName);
CREATE INDEX ix_Contact_FirstName ON Contact.Contact (FirstName);
CREATE INDEX ix_Contact_Email     ON Contact.Contact (Email);
GO

CREATE OR ALTER PROCEDURE Contact.GetContactOppo
	@LastName  varchar(50) = NULL,
	@FirstName varchar(50) = NULL,
	@Email     varchar(50) = NULL
AS BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Contact.Contact
	WHERE (LastName  = @LastName  OR @LastName  IS NULL)
	AND   (FirstName = @FirstName OR @FirstName IS NULL)
	AND   (Email     = @Email     OR @Email     IS NULL)
	OPTION (USE HINT('DISABLE_OPTIONAL_PARAMETER_OPTIMIZATION'));
	--OPTION (RECOMPILE);

END;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

SET STATISTICS IO ON;
GO

PRINT '@LastName = ''Simon'''
EXEC Contact.GetContactOppo @LastName = 'Simon';
GO
PRINT '@FirstName = ''C�leste'''
EXEC Contact.GetContactOppo @FirstName = 'C�leste';
GO
PRINT '@Email = ''z.lopez@socialsurveys.com'''
EXEC Contact.GetContactOppo @Email = 'z.lopez@socialsurveys.com';
GO

SET STATISTICS IO OFF;
GO

-- Plan cache
SELECT
    deqp.plan_handle,
    deqp.cacheobjtype,
    deqp.objtype,
    deqp.size_in_bytes,
    dest.text AS query_text,
    deqp.usecounts,
    deqp.parent_plan_handle,
    dest.objectid AS stored_procedure_id,
    DB_NAME(dest.dbid) AS database_name,
    OBJECT_NAME(dest.objectid, dest.dbid) AS stored_procedure_name,
    qp.query_plan
FROM sys.dm_exec_cached_plans AS deqp
CROSS APPLY sys.dm_exec_sql_text(deqp.plan_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(deqp.plan_handle) AS qp
WHERE
    dest.objectid = OBJECT_ID('Contact.GetContactOppo')
    AND dest.dbid = DB_ID('PachadataTraining')
OPTION (RECOMPILE);

-- View all plan variants for a procedure
SELECT 
    cp.usecounts,
    cp.size_in_bytes,
    cp.objtype,
    cp.cacheobjtype,
    st.text,
    qp.query_plan,
    -- Extract QueryVariantID from the plan if available
    qp.query_plan.value('(//PLAN[1]/@QueryVariantID)[1]', 'int') AS QueryVariantID
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE st.text LIKE '%PLAN PER VALUE%' -- OPPO plans include this marker
    AND (st.objectid = OBJECT_ID('Contact.GetContactOppo'));
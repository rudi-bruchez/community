# Walkthrough

* Start with [010.start.sql](./010.start.sql)
* how to save time?
* notice there are reserved kewords: `date`, `order`
* QUESTION: is `date` a reserved keyword?
  * ANSWER: yes and no, it's a "future reserved keyword"
  * [reserved keywoards](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/reserved-keywords-transact-sql)
  * `date` is mentionned in the list of "ODBC reserved keywords", does it work with ODBC?
  * try with PowerShell and ODBC: [100.date.ps1](./100.date.ps1)
* QUESTION: what about `order`?
  * `CREATE TABLE #t (order int);`
* QUESTION: why the delimeters are `[]`?
  * ANSWER: because it's the SQL Server way, but you normally can use the SQL standard double quotes `""`, but ...
  * [SET QUOTED_IDENTIFIER](https://learn.microsoft.com/en-us/sql/t-sql/statements/set-quoted-identifier-transact-sql)
* QUESTION: how could we know if a column name is a reserved keyword?
  * ANSWER: [sys.dm_exec_describe_first_result_set](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-describe-first-result-set-transact-sql)
  * [example](./115.describe-first-result-set.sql)
  * so we could use this knowledge in our code to automatically escape reserved keywords
* QUESTION: yes, but how could we parse the list of colunms from the string?
  * three ways:
    * use SSMS
    * use STRING_SPLIT
    * use REGEXP_SPLIT in SQL Server 2025
      * yes but "Currently, 'REGEXP_SPLIT_TO_TABLE' function does not support NVARCHAR(max)/VARCHAR(max) inputs."
* QUESTION: OK, but now, how to remove the spaces and `<` and `>` characters?
  * `LTRIM` and `REPLACE` ??
  * Why not TRIM only?
  * In SQL Server 2022, TRIM has been enhanced to support multiple characters.
  * [TRIM ( [ LEADING | TRAILING | BOTH ] [characters FROM ] string )](https://learn.microsoft.com/en-us/sql/t-sql/functions/trim-transact-sql)
* QUESTION: yes but we still have some unwanted characters...
  * - and #. Is it important to remove them?
  * use `TRANSLATE` to replace multiple characters at once
  * [TRANSLATE ( inputString, characters, translations )](https://learn.microsoft.com/en-us/sql/t-sql/functions/translate-transact-sql)
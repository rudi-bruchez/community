# SQL Server Oddities

In this session, **you** will do all the work.

You receive a mail from a colleague asking you to add a new table in the PachadataTraining database.

[Here is the email](./demos/010.email.txt)

She gave you a list of columns. Will you create the table manually by copying and pasting each column separately ?

If you want to do something a bit more clever, how could you do it?

+ Using Sql Server Management Studio features.
+ or maybe, using SQL Server features.

To find some solutions, here is the list of columns she gave you :

```
<complaint_id>, <attendee_id>, <attendee_name>, <attendee_email>, <course_id>, <course_title>, <trainer_name>, <date>, <order>, <complaint_type>, <complaint_details>, <severity_level>, <status>, <resolution_notes>, <resolved_by>, <resolved_date>, <ip_address>
```

Are there some issues to solve in that list?

+ You see that she added brackets to each column name
+ There is a column named `date`, isn't it a reserved keyword in SQL Server?
+ There is a column named `order`, it is definitely a reserved keyword in the SQL language.

[TODO] look at the documentation for identifiers

How to split the columns :

+ using SSMS
+ using T-SQL
+ using new features of SQL Server 2025


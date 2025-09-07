--CREATE TABLE t1 (id int) -- null ou pas par défaut ?
CREATE TABLE t1 (id int not null)

CREATE TABLE t2 (id INT IDENTITY(1, 1))

/*
ALTER TABLE SWITCH statement failed because column 'id' does not have 

the same nullability attribute in tables 'PachadataTraining.dbo.t1' and 'PachadataTraining.dbo.t2'.
*/

INSERT INTO t1 VALUES (1)

ALTER TABLE t1 SWITCH TO t2

INSERT INTO t2 DEFAULT VALUES;


DROP TABLE t1;
DROP TABLE t2;

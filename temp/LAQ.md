# LAQ (lock after qualification) in SQL Server 2025

The new **Lock After Qualification (LAQ)** feature in SQL Server 2025 is designed to improve concurrency and reduce blocking during data manipulation operations by deferring locking until a row has been qualified for update based on query predicates.[^1][^2][^5]

## Core Principle

LAQ works by first scanning rows and evaluating query predicates (conditions such as WHERE clauses) on the most recent committed version of each row, without taking any locks initially. Only after a row passes the predicate is an exclusive (X) row lock acquired, and the lock is released immediately after the row is updated, instead of being held until the transaction commits. This strategy sharply reduces lock contention and unblocks concurrent transactions modifying different rows.[^2][^4][^5][^9][^1]

## How LAQ Works Step By Step

- The engine scans table rows and checks if they match the query predicate, reading the latest committed version without touching row locks.[^4][^1][^2]
- If a row doesn't qualify, no locks are taken, and the engine moves to the next row.[^1][^2]
- If a row qualifies, the system tries to obtain an exclusive lock only at that moment to update the row.[^5][^2][^1]
- If another transaction modifies the row between predicate evaluation and lock acquisition, the predicate is rechecked before updating. If the row was changed so that it no longer qualifies, the update is not performed.[^5][^1]
- In certain rare scenarios, if the query plan or statement type does not support LAQ (e.g. statements using OUTPUT clauses, variable assignment, or conflicting locking hints), the engine will fall back to traditional locking.[^1]


## Use Requirements and Limitations

- LAQ relies on **Read Committed Snapshot Isolation (RCSI)** being enabled at the database level.[^2][^4][^1]
- LAQ doesn’t operate if conflicting locking hints are used, or if the transaction isolation level is stricter than Read Committed.[^1]
- Tables with columnstore indexes or DML statements using certain patterns (variable assignment, OUTPUT, or multiple index scans/seeks) do not use LAQ.[^1]
- If repeated query restarts (due to row changes between evaluation and lock) exceed built-in thresholds, LAQ may be automatically disabled until conditions improve.[^5][^1]


## Example

Suppose two sessions run simultaneous UPDATE statements:

- Session 1: `UPDATE t1 SET b = b + 10 WHERE a = 1;`
- Session 2: `UPDATE t1 SET b = b + 10 WHERE a = 2;`

With LAQ, neither session is blocked by the other, as locks are only placed after rows qualify and are released right after update. In legacy behavior, one session would block the other due to preemptive locking.[^5][^1]

## Benefits

- **Concurrency** is greatly improved, especially in high-write environments.[^7][^1]
- **Lock memory usage** is minimized, as update and exclusive locks are held for shorter periods and only as needed.[^4][^2]
- **Blocking** between transactions updating different rows is dramatically reduced.[^9][^5][^1]

For environments running workloads with high update contention and RCSI enabled, LAQ in SQL Server 2025 offers a robust solution to improve throughput, reduce wait times, and optimize memory utilization.[^2][^4][^1]
<span style="display:none">[^10][^3][^6][^8]</span>

<div style="text-align: center">⁂</div>

[^1]: https://learn.microsoft.com/en-us/sql/relational-databases/performance/optimized-locking?view=sql-server-ver17

[^2]: https://www.dbi-services.com/blog/sql-server-2025-optimized-locking/

[^3]: https://learn.microsoft.com/fr-fr/sql/relational-databases/performance/optimized-locking?view=sql-server-ver17

[^4]: https://www.linkedin.com/pulse/sql-server-2025-optimized-lockinga-game-changer-michael-fuller-zipce

[^5]: https://www.linkedin.com/pulse/optimized-locking-sql-server-2025-premises-danny-ravid-sdhhf

[^6]: https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-ver17

[^7]: https://www.mssqltips.com/sqlservertip/8290/sql-server-2025-new-features/

[^8]: https://www.geopits.com/blog/whats-new-in-sql-server-2025.html

[^9]: https://blog.devart.com/whats-new-in-sql-server-2025.html

[^10]: https://www.coeo.com/2025/01/a-basic-overview-of-locks-in-sql-server/

LAQ interacts closely with **READ COMMITTED snapshot isolation (RCSI)**, and its effectiveness is fundamentally tied to RCSI being enabled for the database.[1][2]

## How LAQ Leverages RCSI

- With **RCSI enabled**, SQL Server performs predicate evaluation for DML statements (UPDATE, DELETE) on the most recent committed version of each row, *without acquiring row locks before qualification*.[2][1]
- LAQ then acquires an **exclusive (X) lock** only after a row qualifies for update, and this lock is released immediately following the update, rather than being held for the life of the transaction.[1]
- This approach is possible because **RCSI uses row versioning**, allowing the engine to confidently examine the committed state of each row at the start of the statement, without risking dirty reads or lost updates.[2][1]

## Impact on Blocking and Concurrency

- **Blocking between concurrent writers is greatly reduced**: Since locks are taken only when strictly necessary and for very short durations, concurrent updates on different rows rarely block one another.[1]
- **Readers under RCSI are never blocked by writers**; only writers may briefly block each other if two attempt to update the same qualified row at the same time, but this is much less frequent than with legacy locking.[2][1]

## Behavior Changes and Limitations

- **Query behavior may differ**: Because LAQ with RCSI bases predicate evaluation on the last committed version rather than the current in-transaction version, outcomes in concurrent transactions can differ from traditional READ COMMITTED. Strict execution order cannot be guaranteed without stricter isolation levels.[1]
- **Rows may be skipped**: If a row is changed between predicate evaluation and lock acquisition, LAQ will not update it unless it still qualifies, which could differ from legacy blocking—some updates may be missed in edge cases.[1]
- LAQ benefits **require RCSI**; without RCSI, LAQ does not apply and traditional locking remains in effect.[2][1]

## Recommendations

- Enable **RCSI** to fully benefit from LAQ and optimized locking in SQL Server 2025.[1]
- For workloads requiring strict transaction ordering, consider higher isolation levels such as REPEATABLE READ or SERIALIZABLE, as LAQ with RCSI favors concurrency over strict ordering.[2][1]

In summary, LAQ exploits the optimistic reads offered by RCSI to minimize lock contention and maximize concurrency, but also subtly changes transactional semantics, especially in highly concurrent environments.[2][1]

[1] https://learn.microsoft.com/en-us/sql/relational-databases/performance/optimized-locking?view=sql-server-ver17
[2] https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-ver17
[3] https://www.sql.kiwi/2014/05/data-modifications-under-rcsi/
[4] https://www.pachadata.com/docs/howtos/performances/rcsi/
[5] https://gohigh.substack.com/p/avoid-read-write-blocking-with-read
[6] https://www.brentozar.com/archive/2013/01/implementing-snapshot-or-read-committed-snapshot-isolation-in-sql-server-a-guide/
[7] https://www.youtube.com/watch?v=jb6NWVwR8RM
[8] https://www.youtube.com/watch?v=QvO0uxqu1GM
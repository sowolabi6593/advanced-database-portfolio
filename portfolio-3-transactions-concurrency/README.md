# Portfolio 3 — Transactions and Concurrency

Demonstrates ACID behaviour on NaijaMart: atomic order placement, rollback on
payment failure, savepoints, and isolation-level experiments.

- `transactions.sql` — commit / rollback / savepoint scripts
- `concurrency_demo.sql` — two-session lost-update and locking experiments
- `isolation_notes.md` — READ COMMITTED vs REPEATABLE READ vs SERIALIZABLE
- `evidence/` — captured outputs (dirty-read test, serialization failure, etc.)

# Isolation levels — findings on NaijaMart

| Level | Dirty read | Non-repeatable read | Phantom | Observed behaviour |
|---|---|---|---|---|
| READ COMMITTED (PG default) | No | Yes | Yes | Experiment A lost update reproduced |
| REPEATABLE READ | No | No | PG blocks phantoms | snapshot fixed at first statement |
| SERIALIZABLE | No | No | No | abort with SQLSTATE 40001, retry needed |

## Why the conditional UPDATE was chosen
`UPDATE ... WHERE stock_qty >= qty` keeps the read-modify-write inside one
statement so PostgreSQL takes the row lock for the whole check — preventing the
lost update without raising the isolation level. `SELECT ... FOR UPDATE` is the
fallback when the check needs multiple statements (e.g. pricing rules).

## Deadlock note
Concurrent order-placement transactions that touch several products lock rows in
arbitrary order; I order updates by `product_id ASC` in the application path to
keep lock ordering consistent and avoid deadlocks — confirmed with
`pg_locks`/`deadlock_timeout` testing.

# Portfolio 2 — Query Processing and Optimisation

Analytical SQL against the NaijaMart schema, with before/after indexing evidence.

- `queries.sql` — six reporting queries (joins, aggregation, window functions)
- `indexes.sql` — indexes added after baseline EXPLAIN
- `evidence/explain_before.txt` / `explain_after.txt` — captured plans
- `analysis.md` — performance analysis

## Reproduce
psql -f ../portfolio-1-database-design/schema.sql
psql -f generate_data.sql   -- ~50k orders synthetic
psql -f queries.sql

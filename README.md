# Advanced Database Systems Portfolio — NaijaMart E-commerce Platform

MIT 8103 Advanced Database Systems — First Semester Continuous Assessment (September Cohort 2026)
Author: Stanley Owolabi (s.owolabi6593@miva.edu.ng)

## Case study
**NaijaMart** is a simulated Nigerian e-commerce marketplace connecting SME sellers to
customers nationwide. The database supports customers, sellers, products, orders,
payments, deliveries and product reviews. Key operations: register customers, list
products, place orders (with stock reservation), process payments and track deliveries.

## Repository map
| Folder | Portfolio activity |
|---|---|
| `portfolio-1-database-design/` | Case study, ER model, relational schema, normalisation |
| `portfolio-2-query-optimisation/` | Analytical SQL, execution plans, indexing evidence |
| `portfolio-3-transactions-concurrency/` | Transaction + isolation / concurrency experiments |
| `portfolio-4-nosql/` | MongoDB document model + implementation of the same case study |
| `portfolio-5-distributed-cloud/` | Replica-set / sharding design and consistency discussion |

## How to run
- Relational work: PostgreSQL 15+ (`psql -f schema.sql`, then `psql -f queries.sql`)
- NoSQL work: MongoDB 6+ (`mongosh naijamart < seed.js`)
- Distributed demo: `docker compose up` in `portfolio-5-distributed-cloud/` (optional)

All outputs in `*/evidence/` were captured locally and are also summarised in each
folder's README.

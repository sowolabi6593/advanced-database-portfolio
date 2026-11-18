# NaijaMart distributed database design

## Topology
- **Primary + 2 secondaries** (MongoDB replica set) across two regions
  (Lagos-primary, Abuja-secondary) — automatic failover, read scale-out.
- PostgreSQL equivalent: streaming replication + Patroni for failover; the
  portfolio demo uses the MongoDB replica set for direct comparison with
  Portfolio 4.

## Sharding plan (for when one replica set is not enough)
- Shard `orders` on a **hashed `customer_id`** key — order history is always
  customer-scoped, so a customer shard-key keeps each query single-shard.
- `products` stays unsharded (40k docs fit anywhere) and is broadcast-joined.
- Avoided range sharding on `placed_at` — hot shard on the latest range.

## CAP discussion
- Payments/orders path favours **CP**: writes go to the primary only
  (`writeConcern:"majority"` + `readConcern:"linearizable"` for balance checks)
  so a partition can't accept conflicting payments.
- Catalog browsing favours **AP**: product reads served from secondaries with
  `readPreference:"secondaryPreferred"` — a seller price update may lag a few
  seconds for browsers, which is acceptable.

## Cloud notes
- On MongoDB Atlas this is an M30 multi-region cluster (2+1 electable nodes).
- Equivalent managed options evaluated: Amazon Aurora (PostgreSQL) with read
  replicas — rejected here because Portfolio 4 already committed to documents.
- Backup: continuous cloud snapshots + point-in-time restore (RPO ~minutes).

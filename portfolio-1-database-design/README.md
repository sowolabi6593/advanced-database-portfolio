# Portfolio 1 — Database Design and Modelling

## Selected organisation: NaijaMart (e-commerce marketplace)
NaijaMart is a simulated Nigerian online marketplace. SME sellers list products;
customers browse, order and pay; logistics partners deliver.

- **Users:** customers, sellers, warehouse staff, support agents, finance
- **Major data:** customers, sellers, products, categories, orders, order items,
  payments, shipments/deliveries, reviews
- **Key operations:** register customer, onboard seller, list product, place order
  (stock check + reservation), capture payment, update delivery status, post review

## Artefacts
- `case_study.md` — full case-study description
- `naijamart-er.mmd` — ER diagram (Mermaid source); `naijamart-er.svg` — rendered diagram
- `schema.sql` — relational schema (PostgreSQL): tables, keys, constraints
- `normalisation.md` — normalisation walk-through to 3NF/BCNF

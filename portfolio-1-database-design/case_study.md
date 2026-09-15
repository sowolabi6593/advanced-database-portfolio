# Case Study — NaijaMart E-commerce Platform

NaijaMart is a mid-sized e-commerce marketplace operating in Lagos, Abuja and Port
Harcourt. It does not hold all stock itself: independent sellers list products and
NaijaMart processes the order, payment and delivery coordination, taking a
commission on each sale.

## Business rules
1. A customer may place many orders; each order belongs to exactly one customer.
2. An order contains one or more order items; each item references one product and
   captures the unit price *at purchase time* (prices change).
3. Each product is sold by exactly one seller and belongs to one category.
4. A payment belongs to one order; an order may have several payment attempts
   (e.g. failed card then transfer).
5. A shipment delivers one order to one delivery address; status moves
   PENDING → IN_TRANSIT → DELIVERED (or FAILED).
6. A customer may review a product only once, and only for delivered orders
   (enforced in application; FK allows the check).
7. Stock is decremented on order placement inside the same transaction to avoid
   overselling (see Portfolio 3).

## Volumes assumed for design
~120k customers, 2.5k sellers, 40k products, ~3k orders/day peak. Hot paths:
product search, order placement, order-history lookup, seller sales reports.

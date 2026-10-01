# Views & Query Optimisation

## Reusable Views

The project includes reusable analytical views for:

- Monthly sales
- Customer performance
- Product performance
- Warehouse operations
- Sales channel performance
- Business KPI summary

These views reduce repeated SQL logic and provide reusable
datasets for reporting and dashboarding.

## Indexes

Indexes were created for frequently used:

- Customer joins
- Order-date filtering
- Order-to-order-item joins
- Product joins
- Return-status filtering

## Query Optimisation

Query performance was investigated using:

- EXPLAIN
- EXPLAIN ANALYZE
- Execution time
- Query plans
- Index scan vs sequential scan
- Table size
- Index size
- Index usage statistics

## Important Findings

To be completed using the actual PostgreSQL execution plans.

## Index Trade-offs

Indexes can improve selective queries but also consume storage
and introduce overhead when data is inserted or updated.

Indexes should therefore be created based on actual query
patterns rather than added to every column.

## Optimisation Results

To be completed after comparing execution plans.
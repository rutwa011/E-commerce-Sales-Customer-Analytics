\# Data Quality Validation



\## Objective



Validate the completeness, consistency and relational integrity of the e-commerce dataset before conducting business analysis.



\## Tables Validated



| Table       | Expected Row Count |

| ----------- | -----------------: |

| customers   |             25,000 |

| products    |              1,175 |

| orders      |            138,116 |

| order\_items |            397,569 |



\## Validation Areas



\* Table row counts

\* Primary-key uniqueness

\* Missing identifiers

\* Foreign-key integrity

\* Missing values

\* Invalid numeric values

\* Date ranges and future dates

\* Order status and return status distributions

\* Quantity, price and discount validation

\* Gross sales and profit reconciliation

\* Order-level and item-level sales reconciliation



\## Key Observations



\* Customer, product and order identifiers were checked for uniqueness.

\* Referential integrity was checked between orders and customers, and between order items and orders and products.

\* Sales calculations were checked against their underlying quantities and prices.

\* Order-level and item-level sales were compared to identify potential reconciliation differences.



\## Return Status Handling



The `return\_status` column contains NULL values for orders that were not returned. These values were interpreted as "Not Returned" for reporting rather than automatically classified as data-quality errors.



\## Data Quality Principles



Potential anomalies should be investigated before being corrected or removed. NULL values may represent valid business states, and differences between order-level and item-level totals may arise from different calculation rules.



\## Conclusion



Data quality checks establish a foundation for more reliable analysis. Any unresolved anomalies or reconciliation differences should be documented before being used for business decisions.




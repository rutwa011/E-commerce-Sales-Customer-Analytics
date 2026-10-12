# E-commerce Sales & Customer Analytics with PostgreSQL

## Project Overview

An end-to-end SQL analytics project exploring e-commerce sales, customer behaviour, product performance and operational metrics using PostgreSQL.

The project demonstrates relational data modelling, data quality validation, business-focused analysis, advanced SQL techniques, reusable analytical views and query performance evaluation.

The dataset contains **138,116 orders across 2021–2025**, supported by customer, product and order-item tables.

## Business Objectives

The analysis addresses questions such as:

* How do revenue, profit and order volume change over time?
* Which sales channels and customer segments generate the most revenue?
* Which product categories contribute most to revenue and profit?
* Do the highest-revenue products also have the highest profit margins?
* How do customer spending patterns vary?
* What does the available delivery and returns data reveal about operations?
* How can SQL views and indexes support repeatable analysis?

## Dataset and Data Model

The project uses four core relational tables:

| Table         | Purpose                                             |
| ------------- | --------------------------------------------------- |
| `customers`   | Customer profiles and segmentation                  |
| `products`    | Product catalogue, categories, brands and costs     |
| `orders`      | Order-level sales and operational information       |
| `order_items` | Product-level quantities, revenue, costs and profit |

Primary keys and foreign keys connect the tables and support consistent joins.

The original dataset does not contain historical stock-on-hand records. Inventory metrics requiring stock quantities should not be interpreted as actual historical inventory unless a separate, clearly documented inventory dataset is added.

## Tools and Technologies

* PostgreSQL
* SQL
* pgAdmin
* Git and GitHub

## SQL Skills Demonstrated

* Filtering, sorting and aggregation
* `GROUP BY` and `HAVING`
* Inner and left joins
* `CASE` expressions and conditional aggregation
* Common Table Expressions (CTEs)
* Subqueries
* Window functions
* `ROW_NUMBER`, `RANK`, `DENSE_RANK` and `NTILE`
* `LAG` and `LEAD`
* Rolling averages and cumulative metrics
* Percentiles using `PERCENTILE_CONT`
* Revenue contribution and Pareto analysis
* Views and indexes
* Query plan inspection using `EXPLAIN ANALYZE`

## Analysis Areas

### 1. Data Quality: Validated table counts, key uniqueness, missing values, referential integrity, numeric ranges, date ranges and consistency between order-level and item-level sales.

### 2. Sales and Revenue: Calculated revenue, profit, average order value, annual performance, monthly trends, channel performance and profitability.

### 3. Product Performance: Compared category revenue, units sold, product profit, margins and high-revenue products.

### 4. Customer Analytics: Compared customer segments and explored customer spending, purchase patterns, rankings and value distribution.

### 5. Operations and Returns: Reviewed delivery times, recorded late-delivery statuses, return counts and return rates.

### 6. Advanced SQL: Used CTEs, ranking functions, window functions, rolling calculations, percentiles and Pareto-style analysis to answer more complex business questions.

### 7. Query Optimization: Created reusable views and evaluated index usage and query plans. Performance conclusions should be based on observed PostgreSQL execution plans rather than assumed improvements.

## Key Findings

The analysis produced the following results:

| KPI                   |          Result |
| --------------------- | --------------: |
| Total orders          |         138,116 |
| Net sales             | $177,134,263.74 |
| Profit                |  $76,146,395.76 |
| Average order value   |       $1,282.50 |
| Derived profit margin |          42.99% |
| Returned orders       |           9,462 |
| Order return rate     |           6.85% |

### Revenue Trends

Annual revenue remained within approximately $35.1 million to $35.7 million between 2021 and 2025. Annual order volume was also relatively stable, ranging from 27,554 to 27,768 orders.

### Sales Channels

The Mobile App generated the highest revenue at approximately $70.83 million, followed by the Website at approximately $61.85 million.

Average order values and profit margins were relatively similar across the four channels.

### Customer Segments

The Consumer segment generated approximately $97.20 million in revenue, the largest amount among the four customer segments. Premium customers ranked second at approximately $44.27 million.

### Product Categories

Electronics generated the highest category revenue at approximately $41.15 million and the highest category profit at approximately $14.10 million. Its derived margin was 34.28%, lower than several smaller categories.

### Delivery and Returns

The displayed warehouse results showed average delivery times between 4.47 and 4.66 days. No orders were labelled `Late` in the returned warehouse results, so this finding should be validated against actual and estimated delivery dates.

The overall recorded return rate was 6.85%.

More detailed findings and caveats are documented in `docs/business_insights.md`.

## Repository Structure

```text
sql/        Database setup, validation and analytical SQL
docs/       Business findings and technical documentation
images/     Project diagrams and selected screenshots
results/    Selected query outputs, where appropriate
data/       Local data files and generated data
```


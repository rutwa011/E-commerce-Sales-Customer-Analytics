-- ============================================================
-- E-COMMERCE SALES, CUSTOMER & OPERATIONS ANALYTICS
-- QUERY OPTIMIZATION
-- ============================================================

--index orders by customers
CREATE INDEX IF NOT EXISTS idx_orders_customer_id
ON orders(customer_id);

--indesx orders by date
CREATE INDEX IF NOT EXISTS idx_orders_order_date
ON orders(order_date);

--indesx order items by order
CREATE INDEX IF NOT EXISTS idx_order_items_order_id
ON order_items(order_id);

--index order itemsby products
CREATE INDEX IF NOT EXISTS idx_order_items_product_id
ON order_items(product_id);

--index return status
CREATE INDEX IF NOT EXISTS idx_orders_return_status
ON orders(return_status);

--checking the indexes
SELECT indexname, tablename, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

--using explain analyze
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'CUST00001';

--comparing before and after indexing
--first temporarily testing without the customer table
DROP INDEX IF EXISTS idx_orders_customer_id;

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'CUST00001';

CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'CUST00001';

--Testing a date-based query
EXPLAIN ANALYZE
SELECT
    order_date,
    SUM(net_sales) AS revenue
FROM orders
WHERE order_date >= DATE '2025-01-01'
  AND order_date < DATE '2026-01-01'
GROUP BY order_date
ORDER BY order_date;

--testing a join
EXPLAIN ANALYZE
SELECT
    c.region,
    SUM(o.net_sales) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.region;

--checking table sizes
SELECT relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

--Check index sizes
SELECT
    indexrelname AS index_name,
    relname AS table_name,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_catalog.pg_statio_user_indexes
ORDER BY
    pg_relation_size(indexrelid) DESC;

--Check for unused indexes
SELECT schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS index_scans

FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan;

--adding a composite index
CREATE INDEX IF NOT EXISTS idx_orders_warehouse_date
ON orders(warehouse, order_date);

EXPLAIN ANALYZE
SELECT warehouse, order_date,
    SUM(net_sales) AS revenue
FROM orders
WHERE warehouse = 'Warehouse A'
  AND order_date >= DATE '2025-01-01'
  AND order_date < DATE '2026-01-01'
GROUP BY
    warehouse,
    order_date
ORDER BY order_date;

--creating a summary view for the portfolio
CREATE OR REPLACE VIEW vw_business_kpi_summary AS
SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(net_sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(net_sales), 2) AS average_order_value,
    ROUND(100.0 * COUNT(*) FILTER (WHERE return_status = 'Returned') / NULLIF(COUNT(*), 0), 2) AS return_rate,
    ROUND(100.0 * COUNT(*) FILTER (WHERE delivery_days > estimated_delivery_days) /
        NULLIF(COUNT(*) FILTER (WHERE delivery_days IS NOT NULL AND estimated_delivery_days IS NOT NULL), 0), 2) AS late_delivery_rate
FROM orders;

SELECT *
FROM vw_business_kpi_summary;

SELECT
    schemaname,
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

SELECT *
FROM vw_monthly_sales
LIMIT 10;

SELECT *
FROM vw_customer_summary
LIMIT 10;

SELECT *
FROM vw_product_performance
LIMIT 10;

SELECT *
FROM vw_operations_performance
LIMIT 10;

SELECT *
FROM vw_channel_performance
LIMIT 10;

SELECT *
FROM vw_business_kpi_summary;
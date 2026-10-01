-- ============================================================
-- E-COMMERCE SALES, CUSTOMER & OPERATIONS ANALYTICS
-- REUSABLE ANALYTICAL VIEWS
-- ============================================================

-- Business Purpose:
-- Create reusable views for common reporting and analysis.
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT DATE_TRUNC('month', order_date)::DATE AS month,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(SUM(profit) / NULLIF(SUM(net_sales), 0) * 100, 2) AS profit_margin_percentage
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

SELECT *
FROM vw_monthly_sales
ORDER BY month;

SELECT *
FROM vw_monthly_sales;

--Creating a customer summary view
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT c.customer_id, c.customer_name, c.customer_segment, c.region,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.net_sales), 2) AS total_revenue,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(AVG(o.net_sales), 2) AS average_order_value,
    COUNT(*) FILTER (WHERE o.return_status = 'Returned') AS returned_orders

FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.region;

SELECT *
FROM vw_customer_summary
ORDER BY total_revenue DESC
LIMIT 20;

--Creating a product performance view
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT p.product_id, p.product_name, p.product_category, p.product_subcategory, p.brand, p.supplier,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS orders_containing_product,
    ROUND(SUM(oi.net_sales), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit,
    ROUND(100.0 * SUM(oi.profit) / NULLIF(SUM(oi.net_sales), 0), 2) AS profit_margin_percentage

FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.product_category,
    p.product_subcategory,
    p.brand,
    p.supplier;

SELECT *
FROM vw_product_performance
ORDER BY revenue DESC
LIMIT 20;

--Creating an operations performance view
CREATE OR REPLACE VIEW vw_operations_performance AS
SELECT warehouse,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_days),2) AS avg_delivery_days,
    ROUND(AVG(delivery_days - estimated_delivery_days), 2) AS avg_delivery_variance,

    COUNT(*) FILTER (WHERE delivery_days > estimated_delivery_days) AS late_orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE delivery_days > estimated_delivery_days) / NULLIF(COUNT(*), 0), 2) AS late_delivery_rate,

    COUNT(*) FILTER (WHERE return_status = 'Returned') AS returned_orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE return_status = 'Returned') / NULLIF(COUNT(*), 0), 2) AS return_rate,

    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM orders
WHERE delivery_days IS NOT NULl AND estimated_delivery_days IS NOT NULL
GROUP BY warehouse;

SELECT *
FROM vw_operations_performance
ORDER BY late_delivery_rate DESC;

--Creating a channel performance views
CREATE OR REPLACE VIEW vw_channel_performance AS
SELECT sales_channel,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(profit),2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(net_sales), 0), 2) AS profit_margin_percentage,
    ROUND(AVG(net_sales), 2) AS average_order_value,
    ROUND(100.0 * COUNT(*) FILTER (WHERE return_status = 'Returned')/ NULLIF(COUNT(*), 0), 2) AS return_rate

FROM orders
GROUP BY sales_channel;

SELECT *
FROM vw_channel_performance
ORDER BY revenue DESC;
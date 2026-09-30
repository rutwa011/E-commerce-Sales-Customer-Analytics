-- ============================================================
-- E-COMMERCE SALES, CUSTOMER & OPERATIONS ANALYTICS
-- ADVANCED SQL BUSINESS ANALYSIS
-- ============================================================

-- Objective:
-- Combine sales, customer, product, and operations data
-- using advanced SQL techniques to answer complex
-- business questions.

-- QUESTION 1: Who is the highest-revenue customer in each region?
WITH customer_revenue AS (
    SELECT
        c.region, c.customer_id, c.customer_name,
        SUM(o.net_sales) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.region, c.customer_id, c.customer_name
),

ranked_customers AS (
    SELECT region, customer_id, customer_name, revenue,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

SELECT region, customer_id, customer_name,
    ROUND(revenue, 2) AS revenue
FROM ranked_customers
WHERE revenue_rank = 1
ORDER BY region;

--QUESTION 2: Which product generates the most revenue within each category?
WITH product_sales AS (
    SELECT p.product_category, p.product_id, p.product_name,
        SUM(oi.net_sales) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_category, p.product_id, p.product_name
),

ranked_products AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY revenue DESC) AS product_rank
    FROM product_sales
)

SELECT product_category, product_id, product_name,
    ROUND(revenue, 2) AS revenue
FROM ranked_products
WHERE product_rank = 1
ORDER BY revenue DESC;

-- Calculating Monthly revenue with previous and next month
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(net_sales) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS previous_month_revenue,
    ROUND(
        LEAD(revenue) OVER (
            ORDER BY month
        ),
        2
    ) AS next_month_revenue

FROM monthly_sales
ORDER BY month;

--QUESTION 3: Which months experienced declining revenue compared with the previous month?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(net_sales) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_comparison AS (
    SELECT month, revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_sales
)

SELECT month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(100.0 * (revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0),2) AS growth_percentage

FROM revenue_comparison

WHERE revenue < previous_month_revenue

ORDER BY month;

--QUESTION 4: What is the rolling 3-month average revenue?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(net_sales) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT month,
    ROUND(revenue, 2) AS revenue,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3_month_avg
FROM monthly_sales
ORDER BY month;

-- QUESTION 5: How does revenue accumulate over time?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(net_sales) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month),2) AS cumulative_revenue

FROM monthly_sales

ORDER BY month;

--QUESTION 6: How did each month perform compared with the same month last year?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(net_sales) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),

yoy_comparison AS (
    SELECT month, revenue,
        LAG(revenue, 12) OVER (ORDER BY month) AS previous_year_revenue
    FROM monthly_sales
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_year_revenue, 2) AS previous_year_revenue,
    ROUND(100.0 * (revenue - previous_year_revenue) / NULLIF(previous_year_revenue, 0), 2) AS yoy_growth_percentage

FROM yoy_comparison

ORDER BY month;

--QUESTION 7: How can customers be grouped according to total spending?
WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(net_sales) AS total_spend
    FROM orders
    GROUP BY customer_id
)

SELECT customer_id,
    ROUND(total_spend, 2) AS total_spend,
    NTILE(4) OVER (
        ORDER BY total_spend DESC
    ) AS spending_quartile

FROM customer_spend
ORDER BY total_spend DESC;

-- QUESTION 8: What are the median, 75th-percentile, and 90th-percentile customer spending levels?
WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(net_sales) AS total_spend
    FROM orders
    GROUP BY customer_id
)

SELECT
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_spend)::NUMERIC, 2) AS median_customer_spend,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_spend)::NUMERIC, 2) AS percentile_75_spend,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_spend)::NUMERIC, 2) AS percentile_90_spend

FROM customer_spend;

--What are the most frequently purchased product by each customer
WITH customer_product_sales AS (
    SELECT o.customer_id, oi.product_id, p.product_name,
        SUM(oi.quantity) AS units_purchased
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY o.customer_id, oi.product_id, p.product_name
),

ranked_products AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY units_purchased DESC) AS product_rank
    FROM customer_product_sales
)

SELECT customer_id, product_id, product_name, units_purchased
FROM ranked_products
WHERE product_rank = 1;

--QUESTION 9: Which customers have broad product-category engagement?
SELECT o.customer_id,
    COUNT(DISTINCT p.product_category) AS categories_purchased,
    ROUND(SUM(oi.net_sales),2) AS total_spend
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.product_category) >= 5
ORDER BY categories_purchased DESC, total_spend DESC;

--QUESTION 10: What category does each customer spend the most on?
WITH category_spend AS (
    SELECT o.customer_id, p.product_category,
        SUM(oi.net_sales) AS category_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        o.customer_id,
        p.product_category
),

ranked_categories AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY category_revenue DESC) AS category_rank
    FROM category_spend
)

SELECT customer_id, product_category,
    ROUND(category_revenue, 2) AS category_spend
FROM ranked_categories
WHERE category_rank = 1;

--QUESTION 11: How does customer order value change from their first to second purchase?
WITH ranked_orders AS (
    SELECT customer_id, order_id, order_date, net_sales,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS purchase_number
    FROM orders
),

customer_purchase_values AS (
    SELECT customer_id,
        MAX(
            CASE
                WHEN purchase_number = 1
                THEN net_sales
            END
        ) AS first_order_value,

        MAX(
            CASE
                WHEN purchase_number = 2
                THEN net_sales
            END
        ) AS second_order_value
    FROM ranked_orders
    GROUP BY customer_id
)

SELECT customer_id,
    ROUND(first_order_value, 2) AS first_order_value,
    ROUND(second_order_value, 2) AS second_order_value,
    ROUND(second_order_value - first_order_value, 2) AS change_in_order_value

FROM customer_purchase_values
WHERE second_order_value IS NOT NULL
ORDER BY change_in_order_value DESC;

--QUESTION 12: Which products have stronger recent sales than their historical monthly average?
WITH reference_date AS (
    SELECT MAX(order_date) AS max_order_date
    FROM orders
),

monthly_product_sales AS (
    SELECT oi.product_id,
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity) AS units_sold
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY oi.product_id,
        DATE_TRUNC('month', o.order_date)
),

product_metrics AS (
    SELECT m.product_id,
        AVG(m.units_sold)
            AS historical_avg_monthly_units,
        AVG(m.units_sold) FILTER (WHERE m.month > DATE_TRUNC('month', r.max_order_date)- INTERVAL '3 months') AS recent_avg_monthly_units

    FROM monthly_product_sales m
    CROSS JOIN reference_date r
    GROUP BY m.product_id
)

SELECT pm.product_id, p.product_name,
    ROUND(pm.historical_avg_monthly_units, 2) AS historical_avg_units,
    ROUND(pm.recent_avg_monthly_units, 2) AS recent_avg_units,
    ROUND(100.0 * (pm.recent_avg_monthly_units - pm.historical_avg_monthly_units) / NULLIF (pm.historical_avg_monthly_units, 0), 2) AS demand_change_percentage

FROM product_metrics pm
JOIN products p
    ON pm.product_id = p.product_id
WHERE pm.recent_avg_monthly_units > pm.historical_avg_monthly_units
ORDER BY demand_change_percentage DESC;

--QUESTION 13: Which product categories generate the most revenue from each customer segment?
WITH segment_category_sales AS (
    SELECT c.customer_segment, p.product_category,
        SUM(oi.net_sales) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        c.customer_segment,
        p.product_category
),
ranked_categories AS (
    SELECT *,
        RANK() OVER (PARTITION BY customer_segment ORDER BY revenue DESC) AS category_rank
    FROM segment_category_sales
)

SELECT customer_segment, product_category,
    ROUND(revenue, 2) AS revenue
FROM ranked_categories
WHERE category_rank = 1;

--QUESTION 14: Which valuable customers experienced frequent late deliveries?
WITH customer_metrics AS (
    SELECT c.customer_id, c.customer_name,
        SUM(o.net_sales) AS lifetime_revenue,
        COUNT(*) AS total_orders,
        COUNT(*) FILTER (
            WHERE o.delivery_days > o.estimated_delivery_days) AS late_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.delivery_days IS NOT NULL
      AND o.estimated_delivery_days IS NOT NULL
    GROUP BY c.customer_id, c.customer_name
),

customer_analysis AS (
    SELECT *,
        100.0 * late_orders/ NULLIF(total_orders, 0) AS late_delivery_rate,
        NTILE(4) OVER (ORDER BY lifetime_revenue DESC) AS value_quartile
    FROM customer_metrics
)

SELECT
    customer_id, customer_name,
    ROUND(lifetime_revenue, 2) AS lifetime_revenue,
    total_orders,
    ROUND(late_delivery_rate, 2) AS late_delivery_rate

FROM customer_analysis
WHERE value_quartile = 1 AND late_delivery_rate > 20
ORDER BY lifetime_revenue DESC;

--QUESTION 15: Which channel performs best across revenue, profit, and returns?
WITH channel_metrics AS (
    SELECT sales_channel, 
        SUM(net_sales) AS revenue,
        SUM(profit) AS profit,
        100.0 * COUNT(*) FILTER (WHERE return_status = 'Returned') / NULLIF(COUNT(*), 0) AS return_rate
    FROM orders
    GROUP BY sales_channel
),

channel_ranks AS (
    SELECT *,
        RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY profit DESC) AS profit_rank,
        RANK() OVER (ORDER BY return_rate) AS return_rank
    FROM channel_metrics
)

SELECT sales_channel,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit,
    ROUND(return_rate, 2) AS return_rate,
    revenue_rank, profit_rank, return_rank,
    revenue_rank + profit_rank + return_rank AS combined_performance_score

FROM channel_ranks
ORDER BY combined_performance_score;

--QUESTION 16: Which high-volume products may require attention because of return exposure?
SELECT p.product_id, p.product_name,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS orders_containing_product,
    COUNT(DISTINCT o.order_id) FILTER (WHERE o.return_status = 'Returned') AS returned_orders,
    ROUND(100.0 * COUNT(DISTINCT o.order_id) FILTER (WHERE o.return_status = 'Returned') / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS return_rate

FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >= 500
ORDER BY return_rate DESC;
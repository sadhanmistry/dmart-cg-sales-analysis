-- ============================================================
--  DMart Chhattisgarh — IN STORE SALES ANALYSIS  
--  FY 2025-26  |  6 Stores  |  13 Categories  |  205 Products


-- ============================================================
-- STEP 1 — DATABASE CREATION
-- ============================================================

CREATE DATABASE IF NOT EXISTS dmart_cg_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE dmart_cg_db;


-- ============================================================
-- STEP 2 — DATA IMPORT
-- ============================================================

-- Here, I have imported datasets/Tables through python (pandas)



-- ============================================================
-- STEP 3 — DATA TYPE CORRECTIONS
-- ============================================================


-- After pandas import, all columns default to TEXT / DOUBLE.
-- We have to Run these ALTER statements to set correct types.
-- ============================================================

DESC dim_stores;
-- ── dim_stores ──────────────────────────────────────────────
ALTER TABLE dim_stores
    MODIFY COLUMN store_id      VARCHAR(10)  NOT NULL,
    MODIFY COLUMN store_name    VARCHAR(100) NOT NULL,
    MODIFY COLUMN city          VARCHAR(50)  NOT NULL,
    MODIFY COLUMN locality      VARCHAR(100),
    MODIFY COLUMN pincode       VARCHAR(10),
    MODIFY COLUMN tier          VARCHAR(10),
    MODIFY COLUMN opening_year  SMALLINT,
    MODIFY COLUMN area_sqft     INT,
    MODIFY COLUMN staff_count   INT,
    MODIFY COLUMN manager_name  VARCHAR(100),
    MODIFY COLUMN state         VARCHAR(50);

DESC dim_stores;


-- ============================================================

DESC dim_products;
-- ── dim_products ────────────────────────────────────────────
ALTER TABLE dim_products
    MODIFY COLUMN product_id       VARCHAR(10)   NOT NULL,
    MODIFY COLUMN product_name     VARCHAR(150)  NOT NULL,
    MODIFY COLUMN brand            VARCHAR(80),
    MODIFY COLUMN category         VARCHAR(80),
    MODIFY COLUMN sub_category     VARCHAR(80),
    MODIFY COLUMN mrp              DECIMAL(10,2),
    MODIFY COLUMN cost_price       DECIMAL(10,2),
    MODIFY COLUMN gst_pct          TINYINT,
    MODIFY COLUMN unit             VARCHAR(20),
    MODIFY COLUMN selling_price    DECIMAL(10,2),
    MODIFY COLUMN is_private_label TINYINT(1)    DEFAULT 0;

DESC dim_products;


-- ============================================================

DESC fact_sales;
-- ── fact_sales ──────────────────────────────────────────────
ALTER TABLE fact_sales
    MODIFY COLUMN sale_id        VARCHAR(14)   NOT NULL,
    MODIFY COLUMN sale_date      DATE          NOT NULL,
    MODIFY COLUMN sale_time      TIME          NOT NULL,
    MODIFY COLUMN store_id       VARCHAR(10)   NOT NULL,
    MODIFY COLUMN payment_method VARCHAR(20),
    MODIFY COLUMN total_items    SMALLINT,
    MODIFY COLUMN bill_subtotal  DECIMAL(12,2),
    MODIFY COLUMN bill_discount  DECIMAL(10,2),
    MODIFY COLUMN bill_gst       DECIMAL(10,2),
    MODIFY COLUMN bill_net_amount DECIMAL(12,2),
    MODIFY COLUMN is_weekend     TINYINT(1)    DEFAULT 0,
    MODIFY COLUMN event_tag      VARCHAR(40);

DESC fact_sales;


-- ============================================================

DESC fact_sale_items;
-- ── fact_sale_items ─────────────────────────────────────────
ALTER TABLE fact_sale_items
    MODIFY COLUMN item_id            VARCHAR(15)   NOT NULL,
    MODIFY COLUMN sale_id            VARCHAR(14)   NOT NULL,
    MODIFY COLUMN product_id         VARCHAR(10)   NOT NULL,
    MODIFY COLUMN quantity           TINYINT,
    MODIFY COLUMN unit_selling_price DECIMAL(10,2),
    MODIFY COLUMN line_discount      DECIMAL(10,2),
    MODIFY COLUMN line_base_amount   DECIMAL(12,2),
    MODIFY COLUMN line_gst_amount    DECIMAL(10,2),
    MODIFY COLUMN line_net_amount    DECIMAL(12,2),
    MODIFY COLUMN line_cogs          DECIMAL(12,2),
    MODIFY COLUMN line_margin        DECIMAL(12,2);

DESC fact_sale_items;


-- ============================================================


-- ============================================================
-- STEP 4 — VERIFYING
-- ============================================================

-- Verify types after alteration
DESCRIBE dim_stores;
DESCRIBE dim_products;
DESCRIBE fact_sales;
DESCRIBE fact_sale_items;


-- ============================================================
-- STEP 5 — BUILD DATA MODELELING
-- ============================================================


-- STEP 5.1 — ADDING PRIMARY KEY
ALTER TABLE dim_stores      ADD PRIMARY KEY (store_id);
ALTER TABLE dim_products    ADD PRIMARY KEY (product_id);
ALTER TABLE fact_sales      ADD PRIMARY KEY (sale_id);
ALTER TABLE fact_sale_items ADD PRIMARY KEY (item_id);

-- STEP 5.2 — ADDING FOREIGN KEY
-- fact_sales → dim_stores
ALTER TABLE fact_sales
    ADD CONSTRAINT fk_sales_store
    FOREIGN KEY (store_id)
    REFERENCES dim_stores(store_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- fact_sale_items → fact_sales
ALTER TABLE fact_sale_items
    ADD CONSTRAINT fk_items_sale
    FOREIGN KEY (sale_id)
    REFERENCES fact_sales(sale_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- fact_sale_items → dim_products
ALTER TABLE fact_sale_items
    ADD CONSTRAINT fk_items_product
    FOREIGN KEY (product_id)
    REFERENCES dim_products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- ============================================================

-- STEP 5.3 — ADDING INDEXES for query performance
CREATE INDEX idx_sales_date     ON fact_sales(sale_date);
CREATE INDEX idx_sales_store    ON fact_sales(store_id);
CREATE INDEX idx_items_product  ON fact_sale_items(product_id);
CREATE INDEX idx_items_sale     ON fact_sale_items(sale_id);
CREATE INDEX idx_prod_category  ON dim_products(category);

-- ============================================================

-- STEP 5.4 — VERIFYING FOREIGN KEY RELATIONSHIPS
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'dmart_cg_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL;


-- ============================================================
-- STEP 6 — DATA QUALITY CHECKS
-- ============================================================

-- STEP 6.1 - Check row counts
SELECT 'dim_stores'       AS table_name, COUNT(*) AS row_count FROM dim_stores
UNION ALL
SELECT 'dim_products',                   COUNT(*)              FROM dim_products
UNION ALL
SELECT 'fact_sales',                     COUNT(*)              FROM fact_sales
UNION ALL
SELECT 'fact_sale_items',                COUNT(*)              FROM fact_sale_items;

-- STEP 6.2 - Check for NULL values in key columns
SELECT
    SUM(CASE WHEN sale_id         IS NULL THEN 1 ELSE 0 END) AS null_sale_id,
    SUM(CASE WHEN sale_date       IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN store_id        IS NULL THEN 1 ELSE 0 END) AS null_store,
    SUM(CASE WHEN bill_net_amount IS NULL THEN 1 ELSE 0 END) AS null_amount
FROM fact_sales;

-- STEP 6.3 - Verify date range covers full FY 2025-26
SELECT
    MIN(sale_date) AS fy_start,
    MAX(sale_date) AS fy_end,
    COUNT(DISTINCT sale_date) AS total_days
FROM fact_sales;

-- STEP 6.4 - Check all 6 stores have sales
SELECT store_id, COUNT(*) AS bills
FROM fact_sales
GROUP BY store_id
ORDER BY store_id;

-- STEP. 6.5 - Check orphan items (items without a matching sale)
SELECT COUNT(*) AS orphan_items
FROM fact_sale_items fi
LEFT JOIN fact_sales fs ON fi.sale_id = fs.sale_id
WHERE fs.sale_id IS NULL;



-- ================================================================
--  STEP 7 — BUSINESS QUERIES/PROBLEMS & INSIGHTS
-- ================================================================

-- ── Q1. Total overall revenue ────────────────────────────────
-- Business question: What is our total revenue for FY 2025-26?
SELECT
    ROUND(SUM(bill_net_amount), 2)  AS total_revenue,
    ROUND(SUM(bill_subtotal), 2)    AS gross_revenue,
    ROUND(SUM(bill_discount), 2)    AS total_discount_given,
    ROUND(SUM(bill_gst), 2)         AS total_gst_collected
FROM fact_sales;


-- ── Q2. Total revenue by store (with full store details) ─────
-- Business question: Which store is the highest performer?
SELECT
    ds.store_id,
    ds.store_name,
    ds.city,
    ds.tier,
    ds.manager_name,
    COUNT(fs.sale_id)                AS total_bills,
    ROUND(SUM(fs.bill_net_amount), 2) AS total_revenue,
    ROUND(AVG(fs.bill_net_amount), 2) AS avg_bill_value
FROM dim_stores ds
JOIN fact_sales fs ON ds.store_id = fs.store_id
GROUP BY
    ds.store_id, ds.store_name, ds.city,
    ds.tier, ds.manager_name
ORDER BY total_revenue DESC;


-- ── Q3. Revenue by payment method ────────────────────────────
-- Business question: Which payment mode do customers prefer?
SELECT
    payment_method,
    COUNT(*)                          AS transaction_count,
    ROUND(SUM(bill_net_amount), 2)    AS total_revenue,
    ROUND(AVG(bill_net_amount), 2)    AS avg_bill_value,
    ROUND(100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER(), 2)      AS pct_of_transactions
FROM fact_sales
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- ── Q4. Weekend vs Weekday performance ───────────────────────
-- Business question: How much do weekends boost sales?
SELECT
    CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(sale_id)                    AS total_bills,
    ROUND(SUM(bill_net_amount), 2)    AS total_revenue,
    ROUND(AVG(bill_net_amount), 2)    AS avg_bill_value,
    ROUND(AVG(total_items), 2)        AS avg_basket_size
FROM fact_sales
GROUP BY is_weekend
ORDER BY is_weekend DESC;


-- ── Q5. Revenue by event / festival season ───────────────────
-- Business question: Which festival drives the most sales?
SELECT
    event_tag,
    COUNT(sale_id)                    AS total_bills,
    ROUND(SUM(bill_net_amount), 2)    AS total_revenue,
    ROUND(AVG(bill_net_amount), 2)    AS avg_bill_value
FROM fact_sales
GROUP BY event_tag
ORDER BY total_revenue DESC;


-- ── Q6. Monthly revenue trend ────────────────────────────────
-- Business question: How does revenue trend month over month?
SELECT
    YEAR(sale_date)                   AS sale_year,
    MONTH(sale_date)                  AS sale_month,
    DATE_FORMAT(sale_date, '%b %Y')   AS month_label,
    COUNT(sale_id)                    AS total_bills,
    ROUND(SUM(bill_net_amount), 2)    AS total_revenue
FROM fact_sales
GROUP BY
    YEAR(sale_date), MONTH(sale_date),
    DATE_FORMAT(sale_date, '%b %Y')
ORDER BY sale_year, sale_month;


-- ── Q7. Top 10 best-selling products by quantity ─────────────
-- Business question: What are our fastest-moving SKUs?
SELECT
    dp.product_id,
    dp.product_name,
    dp.brand,
    dp.category,
    dp.sub_category,
    SUM(fi.quantity)                  AS total_qty_sold,
    ROUND(SUM(fi.line_net_amount), 2) AS total_revenue
FROM dim_products dp
JOIN fact_sale_items fi ON dp.product_id = fi.product_id
GROUP BY
    dp.product_id, dp.product_name,
    dp.brand, dp.category, dp.sub_category
ORDER BY total_qty_sold DESC
LIMIT 10;


-- ── Q8. Revenue by product category ─────────────────────────
-- Business question: Which category contributes most to revenue?
SELECT
    dp.category,
    COUNT(DISTINCT fi.sale_id)        AS total_bills,
    SUM(fi.quantity)                  AS total_qty_sold,
    ROUND(SUM(fi.line_net_amount), 2) AS total_revenue,
    ROUND(AVG(fi.line_net_amount), 2) AS avg_line_value
FROM dim_products dp
JOIN fact_sale_items fi ON dp.product_id = fi.product_id
GROUP BY dp.category
ORDER BY total_revenue DESC;


-- ── Q9. Total discount given by store ───────────────────────
-- Business question: Which store gives out the most discounts?
SELECT
    ds.store_name,
    ds.city,
    ROUND(SUM(fs.bill_discount), 2)   AS total_discount,
    ROUND(SUM(fs.bill_net_amount), 2) AS total_revenue,
    ROUND(100.0 * SUM(fs.bill_discount) /
          SUM(fs.bill_subtotal), 2)   AS discount_rate_pct
FROM dim_stores ds
JOIN fact_sales fs ON ds.store_id = fs.store_id
GROUP BY ds.store_name, ds.city
ORDER BY total_discount DESC;


-- ── Q10. Daily sales count — busiest single days ─────────────
-- Business question: What were our top 10 busiest days?
SELECT
    sale_date,
    DAYNAME(sale_date)                AS day_name,
    event_tag,
    COUNT(sale_id)                    AS total_bills,
    ROUND(SUM(bill_net_amount), 2)    AS total_revenue
FROM fact_sales
GROUP BY sale_date, DAYNAME(sale_date), event_tag
ORDER BY total_bills DESC
LIMIT 10;



-- ── Q11. Revenue per store per month (pivot-style) ───────────
-- Business question: Monthly store-wise revenue heatmap data
SELECT
    ds.store_name,
    DATE_FORMAT(fs.sale_date, '%b %Y')  AS month_label,
    MONTH(fs.sale_date)                 AS month_num,
    ROUND(SUM(fs.bill_net_amount), 2)   AS revenue
FROM dim_stores ds
JOIN fact_sales fs ON ds.store_id = fs.store_id
GROUP BY ds.store_name, month_label, month_num
ORDER BY ds.store_name, month_num;


-- ── Q12. Top 5 products per category by revenue ──────────────
-- Business question: Best product in each category?
SELECT
    category, product_name, brand, total_revenue
FROM (
    SELECT
        dp.category,
        dp.product_name,
        dp.brand,
        ROUND(SUM(fi.line_net_amount), 2)   AS total_revenue,
        RANK() OVER (
            PARTITION BY dp.category
            ORDER BY SUM(fi.line_net_amount) DESC
        ) AS rnk
    FROM dim_products dp
    JOIN fact_sale_items fi ON dp.product_id = fi.product_id
    GROUP BY dp.category, dp.product_name, dp.brand
) ranked
WHERE rnk <= 5
ORDER BY category, rnk;


-- ── Q13. Gross margin analysis by category ───────────────────
-- Business question: Which category is most profitable?
SELECT
    dp.category,
    ROUND(SUM(fi.line_net_amount), 2)  AS revenue,
    ROUND(SUM(fi.line_cogs), 2)        AS cost_of_goods,
    ROUND(SUM(fi.line_margin), 2)      AS gross_margin,
    ROUND(100.0 * SUM(fi.line_margin) /
          SUM(fi.line_net_amount), 2)  AS margin_pct
FROM dim_products dp
JOIN fact_sale_items fi ON dp.product_id = fi.product_id
GROUP BY dp.category
ORDER BY gross_margin DESC;


-- ── Q14. Revenue contribution % by store ────────────────────
-- Business question: What % of total revenue does each store own?
SELECT
    ds.store_name,
    ds.city,
    ROUND(SUM(fs.bill_net_amount), 2)   AS store_revenue,
    ROUND(100.0 * SUM(fs.bill_net_amount) /
          SUM(SUM(fs.bill_net_amount)) OVER (), 2) AS revenue_share_pct
FROM dim_stores ds
JOIN fact_sales fs ON ds.store_id = fs.store_id
GROUP BY ds.store_name, ds.city
ORDER BY store_revenue DESC;


-- ── Q15. Average basket size and value by store ──────────────
-- Business question: Which store has the most engaged shoppers?
SELECT
    ds.store_name,
    ds.city,
    ds.tier,
    COUNT(fs.sale_id)                   AS total_transactions,
    ROUND(AVG(fs.total_items), 2)       AS avg_items_per_bill,
    ROUND(AVG(fs.bill_net_amount), 2)   AS avg_bill_value,
    ROUND(MIN(fs.bill_net_amount), 2)   AS min_bill,
    ROUND(MAX(fs.bill_net_amount), 2)   AS max_bill
FROM dim_stores ds
JOIN fact_sales fs ON ds.store_id = fs.store_id
GROUP BY ds.store_name, ds.city, ds.tier
ORDER BY avg_bill_value DESC;


-- ── Q16. Quarter-wise revenue (Financial Year Q1–Q4) ─────────
-- Business question: Which financial quarter performs best?
SELECT
    CASE
        WHEN MONTH(sale_date) IN (4,5,6)   THEN 'Q1 (Apr-Jun)'
        WHEN MONTH(sale_date) IN (7,8,9)   THEN 'Q2 (Jul-Sep)'
        WHEN MONTH(sale_date) IN (10,11,12) THEN 'Q3 (Oct-Dec)'
        ELSE                                     'Q4 (Jan-Mar)'
    END AS fy_quarter,
    COUNT(sale_id)                      AS total_bills,
    ROUND(SUM(bill_net_amount), 2)      AS total_revenue,
    ROUND(AVG(bill_net_amount), 2)      AS avg_bill_value
FROM fact_sales
GROUP BY fy_quarter
ORDER BY MIN(MONTH(sale_date));


-- ── Q17. GST collected by product category ───────────────────
-- Business question: GST liability breakdown for tax filing
SELECT
    dp.category,
    dp.gst_pct                          AS gst_rate,
    SUM(fi.quantity)                    AS total_units_sold,
    ROUND(SUM(fi.line_base_amount), 2)  AS taxable_value,
    ROUND(SUM(fi.line_gst_amount), 2)   AS gst_collected
FROM dim_products dp
JOIN fact_sale_items fi ON dp.product_id = fi.product_id
GROUP BY dp.category, dp.gst_pct
ORDER BY gst_collected DESC;


-- ── Q18. Brand-level sales performance ───────────────────────
-- Business question: Which brand generates the most revenue?
SELECT
    dp.brand,
    COUNT(DISTINCT fi.sale_id)          AS bills_containing_brand,
    SUM(fi.quantity)                    AS total_units,
    ROUND(SUM(fi.line_net_amount), 2)   AS total_revenue,
    ROUND(SUM(fi.line_margin), 2)       AS total_margin
FROM dim_products dp
JOIN fact_sale_items fi ON dp.product_id = fi.product_id
GROUP BY dp.brand
ORDER BY total_revenue DESC
LIMIT 20;


-- ── Q19. Hour-of-day sales pattern ───────────────────────────
-- Business question: What time of day is peak shopping hour?
SELECT
    HOUR(sale_time)                     AS hour_of_day,
    COUNT(sale_id)                      AS total_bills,
    ROUND(SUM(bill_net_amount), 2)      AS total_revenue,
    ROUND(AVG(bill_net_amount), 2)      AS avg_bill_value
FROM fact_sales
GROUP BY HOUR(sale_time)
ORDER BY hour_of_day;


-- ── Q20. Day-of-week revenue breakdown ───────────────────────
-- Business question: Revenue pattern across all 7 days
SELECT
    DAYNAME(sale_date)                  AS day_name,
    DAYOFWEEK(sale_date)                AS day_num,
    COUNT(sale_id)                      AS total_bills,
    ROUND(SUM(bill_net_amount), 2)      AS total_revenue,
    ROUND(AVG(bill_net_amount), 2)      AS avg_bill_value
FROM fact_sales
GROUP BY DAYNAME(sale_date), DAYOFWEEK(sale_date)
ORDER BY day_num;


-- ── Q21. Products never sold (inventory dead stock) ──────────
-- Business question: Which products have zero sales?
SELECT
    dp.product_id,
    dp.product_name,
    dp.brand,
    dp.category,
    dp.mrp
FROM dim_products dp
LEFT JOIN fact_sale_items fi ON dp.product_id = fi.product_id
WHERE fi.product_id IS NULL;


-- ── Q22. Store performance vs company average ────────────────
-- Business question: Which stores are above/below average revenue?
SELECT
    ds.store_name,
    ds.city,
    ROUND(SUM(fs.bill_net_amount), 2)              AS store_revenue,
    ROUND(AVG(SUM(fs.bill_net_amount)) OVER (), 2) AS company_avg_revenue,
    ROUND(SUM(fs.bill_net_amount) -
          AVG(SUM(fs.bill_net_amount)) OVER (), 2) AS vs_avg,
    CASE
        WHEN SUM(fs.bill_net_amount) > AVG(SUM(fs.bill_net_amount)) OVER ()
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance_flag
FROM dim_stores ds
JOIN fact_sales fs ON ds.store_id = fs.store_id
GROUP BY ds.store_name, ds.city
ORDER BY store_revenue DESC;


-- ── Q23. Private label vs national brand revenue split ────────
-- Business question: How are D-Mart own brands performing vs national brands?
SELECT
    CASE WHEN dp.is_private_label = 1 THEN 'D-Mart Private Label'
         ELSE 'National Brand' END        AS brand_type,
    COUNT(DISTINCT dp.product_id)         AS num_products,
    SUM(fi.quantity)                      AS total_units,
    ROUND(SUM(fi.line_net_amount), 2)     AS total_revenue,
    ROUND(SUM(fi.line_margin), 2)         AS total_margin,
    ROUND(100.0 * SUM(fi.line_margin) /
          SUM(fi.line_net_amount), 2)     AS margin_pct
FROM dim_products dp
JOIN fact_sale_items fi ON dp.product_id = fi.product_id
GROUP BY dp.is_private_label
ORDER BY total_revenue DESC;


-- ── Q24. Monthly revenue growth rate (MoM%) ──────────────────
-- Business question: Is revenue growing or declining month over month?
WITH monthly AS (
    SELECT
        YEAR(sale_date)                     AS yr,
        MONTH(sale_date)                    AS mn,
        DATE_FORMAT(sale_date, '%b %Y')     AS month_label,
        ROUND(SUM(bill_net_amount), 2)      AS revenue
    FROM fact_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date),
             DATE_FORMAT(sale_date, '%b %Y')
)
SELECT
    month_label,
    revenue,
    LAG(revenue) OVER (ORDER BY yr, mn)     AS prev_month_revenue,
    ROUND(100.0 * (revenue -
        LAG(revenue) OVER (ORDER BY yr, mn)) /
        NULLIF(LAG(revenue) OVER (ORDER BY yr, mn), 0), 2) AS mom_growth_pct
FROM monthly
ORDER BY yr, mn;


-- ── Q25. Diwali vs non-Diwali revenue comparison ─────────────
-- Business question: Quantify the Diwali spike impact
SELECT
    CASE WHEN event_tag = 'Diwali' THEN 'Diwali Period'
         ELSE 'Rest of Year' END            AS period,
    COUNT(DISTINCT sale_date)               AS num_days,
    COUNT(sale_id)                          AS total_bills,
    ROUND(SUM(bill_net_amount), 2)          AS total_revenue,
    ROUND(AVG(bill_net_amount), 2)          AS avg_bill_value,
    ROUND(SUM(bill_net_amount) /
          COUNT(DISTINCT sale_date), 2)     AS avg_daily_revenue
FROM fact_sales
GROUP BY
    CASE WHEN event_tag = 'Diwali' THEN 'Diwali Period'
         ELSE 'Rest of Year' END
ORDER BY total_revenue DESC;



--    ─────────────  END OF SQL PART  ─────────────


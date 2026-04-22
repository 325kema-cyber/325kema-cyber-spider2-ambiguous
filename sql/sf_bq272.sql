-- Question ID: sf_bq272
-- This file contains all SQL interpretations for this question.

-- ============================================================================
-- SQL Query 1
-- Interpretation 1:
-- ============================================================================
WITH monthly_product_profit AS (
    SELECT
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM') AS month,
        p."name" AS product_name,
        SUM(oi."sale_price") - SUM(p."cost") AS profit
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON oi."product_id" = p."id"
    WHERE oi."status" NOT IN ('Cancelled', 'Returned')
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) >= '2019-01-01'
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) < '2022-09-01'
    GROUP BY
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM'),
        p."name"
),
ranked_products AS (
    SELECT
        month,
        product_name,
        profit,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY profit DESC, product_name
        ) AS product_rank
    FROM monthly_product_profit
)
SELECT
    month,
    product_name,
    profit
FROM ranked_products
WHERE product_rank <= 3
ORDER BY month, product_rank;

-- ============================================================================
-- SQL Query 2
-- Interpretation 2:
-- ============================================================================
WITH monthly_product_profit AS (
    SELECT
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM') AS month,
        p."id" AS product_id,
        p."name" AS product_name,
        SUM(oi."sale_price") - SUM(p."cost") AS profit
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON oi."product_id" = p."id"
    WHERE oi."status" NOT IN ('Cancelled', 'Returned')
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) >= '2019-01-01'
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) < '2022-09-01'
    GROUP BY
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM'),
        p."id",
        p."name"
),
ranked_products AS (
    SELECT
        month,
        product_id,
        product_name,
        profit,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY profit DESC, product_id
        ) AS product_rank
    FROM monthly_product_profit
)
SELECT
    month,
    product_id,
    product_name,
    profit,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY month, product_rank;

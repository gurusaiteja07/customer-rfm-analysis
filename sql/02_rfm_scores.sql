CREATE OR REPLACE VIEW rfm_scores AS

WITH reference_date AS (
    SELECT MAX(invoice_date) + INTERVAL '1 day' AS ref_date
    FROM clean_transactions
),

customer_metrics AS (
    SELECT
        CustomerID,

        -- RECENCY: how many days since last purchase?
        DATEDIFF('day', MAX(invoice_date),
                 (SELECT ref_date FROM reference_date))    AS recency_days,

        -- FREQUENCY: how many unique orders did they place?
        COUNT(DISTINCT InvoiceNo)                          AS frequency,

        -- MONETARY: total amount they spent?
        ROUND(SUM(line_revenue), 2)                        AS monetary
    FROM clean_transactions
    GROUP BY CustomerID
),

rfm_ranked AS (
    SELECT
        CustomerID,
        recency_days,
        frequency,
        monetary,

        -- NTILE(5): split customers into 5 equal buckets
        -- For recency: LOWER days = MORE recent = BETTER → reverse the order
        NTILE(5) OVER (ORDER BY recency_days DESC)   AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)       AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)        AS m_score
    FROM customer_metrics
)

SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    -- Combined RFM score as a string, e.g. '555' = champion
    CONCAT(r_score, f_score, m_score)                AS rfm_combined,
    -- Average score for quick sorting
    ROUND((r_score + f_score + m_score) / 3.0, 2)   AS rfm_avg
FROM rfm_ranked;
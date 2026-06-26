CREATE OR REPLACE VIEW customer_segments AS

SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_avg,

    CASE
        -- Champions: bought recently, buy often, spend a lot
        WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4
            THEN 'Champion'

        -- Loyal customers: buy very often
        WHEN f_score >= 4 AND r_score >= 3
            THEN 'Loyal Customer'

        -- Potential loyalists: recent customers with average frequency
        WHEN r_score >= 4 AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalist'

        -- At risk: used to buy often, haven't come back
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'

        -- Can't lose them: big spenders going quiet
        WHEN r_score <= 2 AND m_score >= 4
            THEN "Can't Lose Them"

        -- Hibernating: low scores all around, haven't bought in a long time
        WHEN r_score <= 2 AND f_score <= 2
            THEN 'Hibernating'

        -- New customers: bought very recently but only once
        WHEN r_score = 5 AND f_score = 1
            THEN 'New Customer'

        ELSE 'Needs Attention'
    END AS segment

FROM rfm_scores;


-- INSIGHT QUERY 1: How many customers are in each segment?
SELECT
    segment,
    COUNT(*)                        AS customer_count,
    ROUND(AVG(monetary), 2)         AS avg_spend,
    ROUND(AVG(recency_days), 0)     AS avg_days_since_purchase
FROM customer_segments
GROUP BY segment
ORDER BY customer_count DESC;


-- INSIGHT QUERY 2: Month-over-month revenue (bonus window function)
SELECT
    DATE_TRUNC('month', invoice_date)    AS month,
    ROUND(SUM(line_revenue), 2)          AS monthly_revenue,
    ROUND(SUM(SUM(line_revenue)) OVER (
        ORDER BY DATE_TRUNC('month', invoice_date)
    ), 2)                                AS running_total
FROM clean_transactions
GROUP BY 1
ORDER BY 1;
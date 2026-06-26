CREATE OR REPLACE VIEW clean_transactions AS

WITH remove_nulls AS (
    -- Drop rows with no customer ID (can't attribute to anyone)
    SELECT *
    FROM raw_transactions
    WHERE CustomerID IS NOT NULL
      AND CustomerID != ''
),

remove_returns AS (
    -- Negative quantity = a return. Remove these.
    -- Also remove cancelled invoices (InvoiceNo starts with 'C')
    SELECT *
    FROM remove_nulls
    WHERE Quantity > 0
      AND UnitPrice > 0
      AND InvoiceNo NOT LIKE 'C%'
),

add_revenue AS (
    -- Calculate line-item revenue
    SELECT
        CustomerID,
        InvoiceNo,
        InvoiceDate::DATE          AS invoice_date,
        Quantity * UnitPrice        AS line_revenue
    FROM remove_returns
)

SELECT * FROM add_revenue;
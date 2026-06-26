# run_analysis.py
import duckdb

con = duckdb.connect("rfm.duckdb")

print("\n--- Segment Summary ---")
result = con.execute("""
    SELECT
        segment,
        COUNT(*)                    AS customers,
        ROUND(AVG(monetary), 2)     AS avg_spend,
        ROUND(AVG(recency_days), 0) AS avg_days_ago
    FROM customer_segments
    GROUP BY segment
    ORDER BY customers DESC
""").fetchdf()

print(result.to_string(index=False))
con.close()
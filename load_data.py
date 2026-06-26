import duckdb
import pandas as pd

con = duckdb.connect("rfm.duckdb")

df = pd.read_excel("data/online_retail.xlsx", dtype={"CustomerID": str})

con.execute("""
    CREATE OR REPLACE TABLE raw_transactions AS
    SELECT * FROM df
""")

print(f"Loaded {con.execute('SELECT COUNT(*) FROM raw_transactions').fetchone()[0]:,} rows")
con.close()
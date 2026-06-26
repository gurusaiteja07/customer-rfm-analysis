# generate_sample_data.py
import duckdb
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

random.seed(42)
np.random.seed(42)

n = 5000
customers = [f"C{str(i).zfill(4)}" for i in range(1, 201)]
start_date = datetime(2010, 12, 1)

rows = []
for _ in range(n):
    invoice_date = start_date + timedelta(days=random.randint(0, 365))
    rows.append({
        "InvoiceNo":   f"INV{random.randint(100000, 999999)}",
        "CustomerID":  random.choice(customers + [None] * 30),
        "InvoiceDate": invoice_date,
        "Quantity":    random.choice([-1, -2] * 5 + list(range(1, 20))),
        "UnitPrice":   round(random.uniform(0.5, 50.0), 2),
    })

df = pd.DataFrame(rows)

con = duckdb.connect("rfm.duckdb")
con.execute("CREATE OR REPLACE TABLE raw_transactions AS SELECT * FROM df")
print(f"Generated {len(df):,} sample rows for CI")
con.close()
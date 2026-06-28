# Customer RFM Segmentation — SQL Analytics Project

![Language](https://img.shields.io/badge/language-SQL-blue)
![Database](https://img.shields.io/badge/database-DuckDB-yellow)
![Python](https://img.shields.io/badge/python-3.11-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

End-to-end customer segmentation model built entirely in SQL on 541,909 real e-commerce transactions. Uses RFM (Recency, Frequency, Monetary) analysis with window functions to classify customers into actionable business segments.

---

## What is RFM Analysis?

RFM is a proven marketing model used by e-commerce and retail companies to identify their most and least valuable customers based on three behavioural signals:

| Signal | Question it answers | How it is measured |
|---|---|---|
| **Recency** | How recently did the customer buy? | Days since last purchase |
| **Frequency** | How often do they buy? | Number of unique orders |
| **Monetary** | How much do they spend? | Total revenue generated |

Each customer receives a score from 1 to 5 on each signal using SQL `NTILE(5)` window functions. These scores are then combined to classify customers into segments like Champions, At Risk, and Hibernating.

---

## Key Findings

> Analysis performed on the UCI Online Retail dataset (Dec 2010 — Dec 2011)

- **4,338 unique customers** identified across 8 behavioural segments
- **Champions (top 8%)** drove approximately **34% of total revenue** — the classic 80/20 pattern
- **1,200+ customers** classified as At Risk — frequent buyers who have gone quiet, strong candidates for a re-engagement campaign
- **Revenue dipped 22% in November** despite high order volume, driven by a spike in returns and cancelled orders
- Average days since last purchase for Hibernating customers: **298 days** — effectively lost without intervention

---

## Segments Defined

| Segment | R score | F score | M score | Business meaning |
|---|---|---|---|---|
| Champion | 5 | ≥ 4 | ≥ 4 | Best customers. Reward them. |
| Loyal Customer | ≥ 3 | ≥ 4 | any | Buy often. Upsell opportunities. |
| Potential Loyalist | ≥ 4 | 2–3 | any | Recent but not yet committed. Nurture. |
| New Customer | 5 | 1 | any | Just arrived. Onboard well. |
| At Risk | ≤ 2 | ≥ 3 | any | Used to buy often. Win them back. |
| Can't Lose Them | ≤ 2 | any | ≥ 4 | Big spenders going quiet. Act fast. |
| Hibernating | ≤ 2 | ≤ 2 | any | Low engagement. Low priority. |
| Needs Attention | other | other | other | Mid-range customers slipping away. |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| **DuckDB** | Local analytical SQL database — fast, serverless, no setup |
| **Python 3.11** | Load Excel file into DuckDB, print results |
| **pandas** | Read Excel file |
| **openpyxl** | Excel (.xlsx) parsing engine used by pandas |
| **SQL** | All cleaning, scoring, and segmentation logic |

---

## Project Structure

```
rfm-analysis/
│
├── .gitignore                   # Excludes data files and .duckdb from git
├── LICENSE                      # MIT license
├── README.md                    # This file
├── requirements.txt             # Python dependencies
│
├── load_data.py                 # Reads Excel file → loads into DuckDB
├── run_analysis.py              # Prints segment summary after pipeline runs
├── generate_sample_data.py      # Generates fake data for testing (no real file needed)
│
├── sql/
│   ├── 01_clean.sql             # CTE pipeline: remove nulls, returns, cancellations
│   ├── 02_rfm_scores.sql        # Calculate recency, frequency, monetary + NTILE scoring
│   └── 03_segments.sql          # CASE WHEN segmentation rules + insight queries
│
└── data/                        # NOT committed to git (see .gitignore)
    └── online_retail.xlsx       # Raw dataset — download manually (instructions below)
```

### What each file does

**`load_data.py`**
Reads the raw Excel file using pandas and writes it as a table called `raw_transactions` into a local DuckDB database file (`rfm.duckdb`). Run this once before anything else.

**`sql/01_clean.sql`**
A chain of three CTEs that progressively clean the raw data:
- `remove_nulls` — drops rows with no CustomerID
- `remove_returns` — filters out negative quantities and cancelled invoices (prefix `C`)
- `add_revenue` — computes line-item revenue as `Quantity × UnitPrice`

Output is saved as a view called `clean_transactions`.

**`sql/02_rfm_scores.sql`**
Aggregates clean transactions per customer to calculate raw RFM metrics, then applies `NTILE(5)` window functions to convert raw numbers into scores 1–5. Recency ordering is reversed (lower days = higher score) since buying recently is better.

Output is saved as a view called `rfm_scores`.

**`sql/03_segments.sql`**
Uses `CASE WHEN` logic to map RFM score combinations to named segments. Also contains two bonus insight queries — segment summary statistics and a month-over-month revenue running total using window functions.

Output is saved as a view called `customer_segments`.

**`run_analysis.py`**
Connects to the DuckDB file and prints the final segment summary table to the terminal. Used to verify the pipeline ran correctly.

**`generate_sample_data.py`**
Creates synthetic but realistic transaction data (5,000 rows, 200 customers) directly in DuckDB. Used when you do not have the real dataset handy — useful for testing your SQL logic.

---

## Setup and Installation

### Prerequisites

- Python 3.9 or higher
- pip
- Git

### Step 1 — Clone the repository

```bash
git clone https://github.com/yourusername/rfm-analysis.git
cd rfm-analysis
```

### Step 2 — Install dependencies

```bash
pip install -r requirements.txt
```

This installs three libraries: `duckdb`, `pandas`, and `openpyxl`.

### Step 3 — Download the dataset

The UCI Online Retail dataset is publicly available for free. Download it here:

```
https://archive.ics.uci.edu/ml/machine-learning-databases/00352/Online%20Retail.xlsx
```

Create a `data/` folder in the project root and place the downloaded file inside it:

```bash
mkdir data
# then move the downloaded file into data/
```

Your folder should now contain `data/online_retail.xlsx`.

> The `data/` folder is listed in `.gitignore` and will never be committed to GitHub.

### Step 4 — Load data into DuckDB

```bash
python load_data.py
```

Expected output:
```
Loaded 541,909 rows into raw_transactions
```

This creates a file called `rfm.duckdb` in your project root. This is your local database.

### Step 5 — Run the SQL pipeline

Run each SQL file in order:

```bash
duckdb rfm.duckdb < sql/01_clean.sql
duckdb rfm.duckdb < sql/02_rfm_scores.sql
duckdb rfm.duckdb < sql/03_segments.sql
```

### Step 6 — View results

```bash
python run_analysis.py
```

Expected output:
```
--- Customer Segment Summary ---
segment               customers   avg_spend   avg_days_ago
Champion                    347     1842.30             18
Loyal Customer              612      934.50             42
Potential Loyalist          489      412.80             15
New Customer                203      198.40              9
At Risk                    1247      623.10            312
Can't Lose Them             198     2103.60            298
Hibernating                 891      112.40            301
Needs Attention             351      287.90            145
```

---

## Running Without the Real Dataset

If you want to test the SQL logic without downloading the Excel file, use the sample data generator:

```bash
python generate_sample_data.py
duckdb rfm.duckdb < sql/01_clean.sql
duckdb rfm.duckdb < sql/02_rfm_scores.sql
duckdb rfm.duckdb < sql/03_segments.sql
python run_analysis.py
```

This generates 5,000 synthetic rows across 200 fictional customers and runs the full pipeline on them.

---

## SQL Concepts Demonstrated

| Concept | Where used | File |
|---|---|---|
| Common Table Expressions (CTEs) | Multi-step data cleaning pipeline | `01_clean.sql` |
| `NTILE(5)` window function | Bucketing customers into score quintiles | `02_rfm_scores.sql` |
| `OVER (ORDER BY ...)` | Defining window for each score | `02_rfm_scores.sql` |
| `DATEDIFF` | Calculating days since last purchase | `02_rfm_scores.sql` |
| `DATE_TRUNC` | Grouping transactions by month | `03_segments.sql` |
| `CASE WHEN` | Mapping scores to segment labels | `03_segments.sql` |
| Running total with `SUM() OVER` | Month-over-month cumulative revenue | `03_segments.sql` |
| `CONCAT` | Combining R, F, M scores into single string | `02_rfm_scores.sql` |
| Views | Saving intermediate results for reuse | all `.sql` files |

---

## Dataset Information

| Property | Value |
|---|---|
| Source | UCI Machine Learning Repository |
| Name | Online Retail Data Set |
| Rows | 541,909 transactions |
| Period | December 2010 — December 2011 |
| Geography | United Kingdom (primarily) |
| Link | https://archive.ics.uci.edu/ml/datasets/online+retail |

**Column descriptions:**

| Column | Type | Description |
|---|---|---|
| InvoiceNo | string | Unique invoice number. Prefix 'C' = cancellation |
| StockCode | string | Product code |
| Description | string | Product name |
| Quantity | integer | Units purchased. Negative = return |
| InvoiceDate | datetime | Date and time of transaction |
| UnitPrice | float | Price per unit in GBP |
| CustomerID | string | Unique customer identifier. Can be null |
| Country | string | Country of the customer |

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

The dataset is sourced from the UCI Machine Learning Repository and is publicly available for research and educational use.

---


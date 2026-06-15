# DMart Chhattisgarh — In-Store Sales Analysis
### FY 2025-26 | End-to-End Data Analytics Project

[![Power BI Dashboard](https://img.shields.io/badge/Power%20BI-Live%20Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://app.powerbi.com/links/a4c6PZvtWd?ctid=b8437072-63f3-4313-bdcf-374815276305&pbi_source=linkShare)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Python](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Pandas](https://img.shields.io/badge/Pandas-Data%20Loading-150458?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)

---

## Project Overview

A complete end-to-end retail analytics project simulating real DMart store operations across **6 locations in Chhattisgarh** for the full financial year **April 2025 – March 2026**.

The project covers the full data pipeline — synthetic data generation, Python-based loading into MySQL, SQL-based analysis with 20 business questions, and a 4-page interactive Power BI dashboard with live slicers.

---

## Dashboard Preview

### Page 1 — Executive Summary
![Executive Summary](dashboard/P-1_Executive_Summary.png)

### Page 2 — Store Analysis
![Store Analysis](dashboard/P-2_Store_Analysis.png)

### Page 3 — Product Analysis
![Product Analysis](dashboard/P-3_Product_Analysis.png)

### Page 4 — Seasonality Analysis
![Seasonality Analysis](dashboard/P-4_Seasonality_Analysis.png)

> **Live Dashboard:** [Click here to view the interactive Power BI report](https://app.powerbi.com/links/a4c6PZvtWd?ctid=b8437072-63f3-4313-bdcf-374815276305&pbi_source=linkShare)

---

## Key Business Insights

| Metric | Value |
|---|---|
| Total Revenue | Rs.180.15 Crores |
| Total Transactions | 8,82,037 |
| Avg Basket Value | Rs.2,042 |
| Gross Margin % | 12.3% |
| Top Store | Bhilai Katulbod — Rs.34.15 Cr |
| Top Category | Grocery — Rs.53.33 Cr (29.6%) |
| Diwali Spike | Rs.173.3L/day — 4.7x normal average |
| UPI Adoption | 40.1% of all transactions |
| Most Efficient Store | Rajnandgaon — Rs.13,210 per sq ft |

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Generation | Python (NumPy, Pandas) |
| Data Loading | Python + SQLAlchemy + PyMySQL |
| Data Storage | MySQL 8.0 |
| Data Analysis | MySQL (20 business queries) |
| Visualization | Microsoft Power BI Desktop |
| Publishing | Power BI Service (Fabric) |

---

## Repository Structure

```
dmart-cg-sales-analysis/
│
├── data/
│   ├── dim_stores.csv
│   ├── dim_products.csv
│   ├── fact_sales.csv
│   └── fact_sale_items.csv
│
├── notebooks/
│   └── Data_Loading.ipynb          ← Python CSV → MySQL pipeline
│
├── sql/
│   └── dmart_analysis.sql          ← DB setup + data modeling + 20 queries
│
├── dashboard/
│   ├── P-1_Executive_Summary.png
│   ├── P-2_Store_Analysis.png
│   ├── P-3_Product_Analysis.png
│   └── P-4_Seasonality_Analysis.png
│
└── README.md
```

---

## Database Schema (Star Schema)

```
dim_stores      ←──┐
dim_products    ←──┤── fact_sale_items ──→ fact_sales ──→ dim_stores
                   │
                   └── (product_id FK)     (sale_id FK)   (store_id FK)
```

**4 Tables:**
- `dim_stores` — 6 store locations with city, tier, area, manager
- `dim_products` — 205 SKUs across 13 categories with MRP, cost, GST
- `fact_sales` — 8,82,037 bill-level records with payment method, discount, GST
- `fact_sale_items` — 58,33,867 line-item records with quantity, margin, COGS

---

## How to Run

### Step 1 — Clone the repository
```bash
git clone https://github.com/sadhanmistry/dmart-cg-sales-analysis.git
cd dmart-cg-sales-analysis
```

### Step 2 — Install Python dependencies
```bash
pip install pandas sqlalchemy pymysql jupyter
```

### Step 3 — Create the MySQL database
```sql
CREATE DATABASE dmart_cg_db CHARACTER SET utf8mb4;
```

### Step 4 — Load data using the notebook
Open `notebooks/Data_Loading.ipynb` and update the connection string:
```python
engine = create_engine("mysql+pymysql://root:YOUR_PASSWORD@localhost/dmart_cg_db")
```
Run all cells — loads all 4 tables automatically.

### Step 5 — Run SQL analysis
Open `sql/dmart_analysis.sql` in MySQL Workbench and execute:
- Part 3 first — data type corrections
- Part 4 — primary & foreign keys
- Part 5 — data quality checks
- Part 6 — all 20 business questions

### Step 6 — View the Dashboard
[Click here for the live Power BI report](https://app.powerbi.com/links/a4c6PZvtWd?ctid=b8437072-63f3-4313-bdcf-374815276305&pbi_source=linkShare)

---

## Data Details

| Table | Rows | Columns | Description |
|---|---|---|---|
| dim_stores | 6 | 11 | Store master — city, tier, area, manager |
| dim_products | 205 | 11 | Product master — brand, category, MRP, cost |
| fact_sales | 8,82,037 | 12 | Bill-level transactions |
| fact_sale_items | 58,33,867 | 11 | Line-item details |

**Stores covered:** Raipur (Civil Lines, Ring Road) · Bhilai (Katulbod, Charoda) · Durg (Katulbod) · Rajnandgaon (Lakholi)

**Product categories:** Grocery · Dairy · Snacks · Beverages · Personal Care · Home Care · Baby Care · Health & Hygiene · Home & Kitchen · Apparel · Footwear · Electronics · Stationery

**Seasonality built-in:**
- Diwali (Oct 20 – Nov 10): 3× transaction volume spike
- Weekend uplift: 50–60% higher volume than weekdays
- Festival tags: Navratri, Chhath Puja, Holi, Year End, Independence Day

---

## Note: 
fact_sales.csv & fact_sale_items.csv are 75 MB & 493 MB. GitHub has a 25MB file limit. 
" fact_sales.csv & fact_sale_items.csv is available at 

fact_sales:- [Google Drive link]:- https://drive.google.com/file/d/11TTjJiwB1TjDDSend_geSlSHHB0qpSVC/view?usp=drive_link

fact_sale_items:- [Google Drive link]:- https://drive.google.com/file/d/11tlX273LAvXyjhuTmwMFNbBDNxP4UDZn/view?usp=drive_link

due to GitHub 25MB file size limit."

---

## Author

**Sadhan Mistry**
Data Analyst | Python · MySQL · Power BI

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/sadhanmistry/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat&logo=github)](https://github.com/sadhanmistry)

---

*This project uses synthetic data modelled after real retail patterns. No actual DMart data was used.*

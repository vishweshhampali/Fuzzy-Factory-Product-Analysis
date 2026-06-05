import duckdb
import os

DB_PATH = r"D:\MAVEN_PROJECT\dbt_maven\maven.duckdb"
OUT_DIR = r"D:\MAVEN_PROJECT\powerbi_parquet"

os.makedirs(OUT_DIR, exist_ok=True)

con = duckdb.connect(DB_PATH, read_only=True)

marts = [
    "mart_channel_performance",
    "mart_channel_roi",
    "mart_cohort_retention",
    "mart_conversion_funnel",
    "mart_crosssell",
    "mart_funnel_trend",
    "mart_page_leak",
    "mart_refund_rates",
    "mart_revenue_trend",
    "mart_user_intent",
    "mart_user_segments",
]

print("Exporting marts to parquet...\n")
for mart in marts:
    try:
        out_path = os.path.join(OUT_DIR, f"{mart}.parquet")
        con.execute(f"COPY {mart} TO '{out_path}' (FORMAT PARQUET)")
        rows = con.execute(f"SELECT COUNT(*) FROM {mart}").fetchone()[0]
        print(f"  ✅ {mart} — {rows:,} rows → {mart}.parquet")
    except Exception as e:
        print(f"  ❌ {mart} — {e}")

con.close()
print(f"\nDone. Files saved to: {OUT_DIR}")
print("In Power BI: Get Data → Parquet → select each file from that folder.")
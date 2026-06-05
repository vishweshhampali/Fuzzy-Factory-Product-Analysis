import duckdb

con = duckdb.connect(r'D:\\MAVEN_PROJECT\dbt_maven\maven.duckdb')

tables = [
    'website_sessions',
    'website_pageviews',
    'orders',
    'order_items',
    'order_item_refunds',
    'products'
]

for table in tables:
    con.execute(f"""
        CREATE TABLE IF NOT EXISTS {table} AS 
        SELECT * FROM read_csv_auto(
            'D:/MAVEN_PROJECT/Maven+Fuzzy+Factory/{table}.csv', 
            header=true
        )
    """)
    count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    print(f"✅ {table}: {count:,} rows loaded")

con.close()
print("\n🎉 Done! Raw tables are in maven.duckdb")
import duckdb

con = duckdb.connect(r'D:\MAVEN_PROJECT\dbt_maven\maven.duckdb')

print("\n" + "="*60)
print("Q1: IS REVENUE GROWING?")
print("="*60)
print(con.execute("""
    select 
        month,
        sessions,
        orders,
        revenue,
        gross_profit,
        round(avg(revenue) over (
            order by month rows between 2 preceding and current row
        ), 2) as revenue_3mo_avg
    from mart_revenue_trend
    where month is not null
    order by month
""").df().to_string(index=False))

print("\n" + "="*60)
print("Q2: WHICH CHANNEL WINS?")
print("="*60)
print(con.execute("""
    select 
        channel,
        campaign,
        device_type,
        sessions,
        orders,
        cvr_pct,
        revenue
    from mart_channel_performance
    order by sessions desc
    limit 15
""").df().to_string(index=False))

print("\n" + "="*60)
print("Q3: WHERE DO WE LOSE USERS?")
print("="*60)
print(con.execute("""
    select
        sum(saw_home)         as home,
        sum(saw_products)     as products,
        sum(saw_product_page) as product_page,
        sum(saw_cart)         as cart,
        sum(saw_shipping)     as shipping,
        sum(saw_billing)      as billing,
        sum(converted)        as orders
    from mart_conversion_funnel
""").df().to_string(index=False))

con.close()
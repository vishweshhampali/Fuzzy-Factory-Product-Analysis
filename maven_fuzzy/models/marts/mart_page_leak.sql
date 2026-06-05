with product_pages as (
    select
        s.session_id,
        s.utm_source,
        s.device_type,
        max(case when p.pageview_url in (
            '/the-original-mr-fuzzy',
            '/the-forever-love-bear',
            '/the-birthday-sugar-panda',
            '/the-hudson-river-mini-bear')
            then 1 else 0 end)                                    as saw_product_page,
        max(case when p.pageview_url = '/cart'
            then 1 else 0 end)                                    as reached_cart,
        max(case when p.pageview_url = '/thank-you-for-your-order'
            then 1 else 0 end)                                    as converted,
        max(o.price_usd)                                          as order_value
    from {{ ref('stg_sessions') }} s
    left join {{ ref('stg_pageviews') }} p
        on s.session_id = p.session_id
    left join {{ ref('stg_orders') }} o
        on s.session_id = o.session_id
    group by 1, 2, 3
)

select
    utm_source,
    device_type,
    count(distinct session_id)                                    as total_sessions,
    sum(saw_product_page)                                         as saw_product_page,
    sum(reached_cart)                                             as reached_cart,
    sum(saw_product_page) - sum(reached_cart)                     as dropped_at_product,
    round((sum(saw_product_page) - sum(reached_cart)) * 100.0
        / nullif(sum(saw_product_page), 0), 2)                    as drop_rate_pct,
    round(avg(order_value), 2)                                    as avg_order_value,
    round((sum(saw_product_page) - sum(reached_cart))
        * 0.10 * avg(order_value), 2)                             as revenue_if_10pct_recovered,
    round((sum(saw_product_page) - sum(reached_cart))
        * 0.05 * avg(order_value), 2)                             as revenue_if_5pct_recovered
from product_pages
group by 1, 2
order by dropped_at_product desc
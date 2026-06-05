with session_orders as (
    select
        s.session_id,
        s.utm_source,
        s.utm_campaign,
        s.utm_content,
        s.device_type,
        o.order_id,
        o.price_usd,
        o.cogs_usd
    from {{ ref('stg_sessions') }} s
    left join {{ ref('stg_orders') }} o
        on s.session_id = o.session_id
)

select
    utm_source,
    utm_campaign,
    device_type,
    count(distinct session_id)                                    as sessions,
    count(distinct order_id)                                      as orders,
    round(count(distinct order_id) * 100.0
        / nullif(count(distinct session_id), 0), 2)               as cvr_pct,
    round(sum(price_usd), 2)                                      as total_revenue,
    round(sum(price_usd)
        / nullif(count(distinct session_id), 0), 2)               as revenue_per_session,
    round(sum(price_usd - cogs_usd), 2)                           as gross_profit,
    round(sum(price_usd - cogs_usd)
        / nullif(count(distinct session_id), 0), 2)               as gross_profit_per_session
from session_orders
group by 1, 2, 3
order by revenue_per_session desc
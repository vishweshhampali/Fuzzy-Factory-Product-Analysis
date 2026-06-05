with session_orders as (
    select
        s.session_id,
        s.user_id,
        s.is_repeat_session,
        s.utm_source,
        s.device_type,
        o.order_id,
        o.price_usd
    from {{ ref('stg_sessions') }} s
    left join {{ ref('stg_orders') }} o
        on s.session_id = o.session_id
)

select
    is_repeat_session,
    count(distinct user_id)                                        as unique_users,
    count(*)                                                       as total_sessions,
    count(distinct order_id)                                       as total_orders,
    round(count(distinct order_id) * 100.0 / count(*), 2)         as cvr_pct,
    round(sum(price_usd), 2)                                       as total_revenue,
    round(sum(price_usd) / nullif(count(*), 0), 2)                as revenue_per_session,
    device_type,
    utm_source
from session_orders
group by is_repeat_session, device_type, utm_source
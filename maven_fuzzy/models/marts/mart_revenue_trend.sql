select
    date_trunc('month', o.created_at)  as month,
    count(distinct s.session_id)        as sessions,
    count(distinct o.order_id)          as orders,
    round(sum(o.price_usd), 2)          as revenue,
    round(sum(o.cogs_usd), 2)           as cogs,
    round(sum(o.price_usd - o.cogs_usd), 2) as gross_profit
from {{ ref('stg_sessions') }} s
left join {{ ref('stg_orders') }} o
    on s.session_id = o.session_id
group by 1
order by 1
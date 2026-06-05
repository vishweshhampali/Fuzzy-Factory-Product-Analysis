select
    utm_source                              as channel,
    utm_campaign                            as campaign,
    device_type,
    count(distinct s.session_id)            as sessions,
    count(distinct o.order_id)              as orders,
    round(count(distinct o.order_id) * 100.0 
          / count(distinct s.session_id), 2) as cvr_pct,
    round(sum(o.price_usd), 2)             as revenue
from {{ ref('stg_sessions') }} s
left join {{ ref('stg_orders') }} o
    on s.session_id = o.session_id
group by 1, 2, 3
order by sessions desc
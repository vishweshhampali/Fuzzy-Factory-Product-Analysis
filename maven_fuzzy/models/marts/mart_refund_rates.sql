select
    p.product_name,
    count(distinct oi.order_item_id)                                    as total_items_sold,
    count(distinct r.order_item_id)                                     as total_refunds,
    round(count(distinct r.order_item_id) * 100.0
          / nullif(count(distinct oi.order_item_id), 0), 2)             as refund_rate_pct,
    round(sum(oi.price_usd), 2)                                         as gross_revenue,
    round(sum(r.refund_amount_usd), 2)                                  as total_refunded,
    round(sum(oi.price_usd) - sum(coalesce(r.refund_amount_usd, 0)), 2) as net_revenue
from {{ ref('stg_order_items') }} oi
left join {{ ref('stg_products') }} p
    on oi.product_id = p.product_id
left join {{ ref('stg_refunds') }} r
    on oi.order_item_id = r.order_item_id
group by p.product_name
order by refund_rate_pct desc
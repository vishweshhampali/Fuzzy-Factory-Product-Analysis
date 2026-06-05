select
    p.product_name                                                       as entry_product,
    count(distinct oi.order_id)                                         as total_orders,
    count(distinct case when o.items_purchased > 1
                   then oi.order_id end)                                as multi_item_orders,
    round(count(distinct case when o.items_purchased > 1
                then oi.order_id end) * 100.0
          / nullif(count(distinct oi.order_id), 0), 2)                  as crosssell_rate_pct,
    round(avg(o.price_usd), 2)                                          as avg_order_value
from {{ ref('stg_order_items') }} oi
left join {{ ref('stg_products') }} p
    on oi.product_id = p.product_id
left join {{ ref('stg_orders') }} o
    on oi.order_id = o.order_id
group by p.product_name
order by crosssell_rate_pct desc
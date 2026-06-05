with funnel as (
    select
        date_trunc('month', s.created_at)                         as month,
        s.session_id,
        s.utm_source,
        s.device_type,
        max(case when p.pageview_url = '/home' then 1 else 0 end)
            as saw_home,
        max(case when p.pageview_url = '/lander-1' then 1 else 0 end)
            as saw_lander,
        max(case when p.pageview_url in (
            '/the-original-mr-fuzzy',
            '/the-forever-love-bear',
            '/the-birthday-sugar-panda',
            '/the-hudson-river-mini-bear')
            then 1 else 0 end)                                    as saw_product_page,
        max(case when p.pageview_url = '/cart' then 1 else 0 end)
            as saw_cart,
        max(case when p.pageview_url = '/shipping' then 1 else 0 end)
            as saw_shipping,
        max(case when p.pageview_url = '/billing'
            or p.pageview_url = '/billing-2' then 1 else 0 end)
            as saw_billing,
        max(case when p.pageview_url = '/thank-you-for-your-order'
            then 1 else 0 end)                                    as converted
    from {{ ref('stg_sessions') }} s
    left join {{ ref('stg_pageviews') }} p
        on s.session_id = p.session_id
    group by 1, 2, 3, 4
)

select
    month,
    count(distinct session_id)                                    as sessions,
    sum(saw_product_page)                                         as reached_product,
    sum(saw_cart)                                                 as reached_cart,
    sum(saw_shipping)                                             as reached_shipping,
    sum(saw_billing)                                              as reached_billing,
    sum(converted)                                                as converted,
    round(sum(converted) * 100.0
        / nullif(count(distinct session_id), 0), 2)               as overall_cvr_pct,
    round(sum(saw_product_page) * 100.0
        / nullif(count(distinct session_id), 0), 2)               as landing_to_product_pct,
    round(sum(saw_cart) * 100.0
        / nullif(sum(saw_product_page), 0), 2)                    as product_to_cart_pct,
    round(sum(converted) * 100.0
        / nullif(sum(saw_cart), 0), 2)                            as cart_to_order_pct
from funnel
group by 1
order by 1
with funnel_flags as (
    select
        session_id,
        max(case when pageview_url in ('/home', '/lander-1', '/lander-2',
            '/lander-3', '/lander-4', '/lander-5') then 1 else 0 end) as saw_lander,
        max(case when pageview_url = '/products'
            then 1 else 0 end)                                         as saw_products,
        max(case when pageview_url in ('/the-original-mr-fuzzy',
            '/the-forever-love-bear', '/the-birthday-sugar-panda',
            '/the-hudson-river-mini-bear') then 1 else 0 end)          as saw_product_page,
        max(case when pageview_url = '/cart'
            then 1 else 0 end)                                         as saw_cart,
        max(case when pageview_url = '/shipping'
            then 1 else 0 end)                                         as saw_shipping,
        max(case when pageview_url in ('/billing', '/billing-2')
            then 1 else 0 end)                                         as saw_billing,
        max(case when pageview_url = '/thank-you-for-your-order'
            then 1 else 0 end)                                         as converted
    from {{ ref('stg_pageviews') }}
    group by session_id
),

session_intent as (
    select
        f.session_id,
        s.user_id,
        s.is_repeat_session,
        s.device_type,
        s.utm_source,
        f.saw_lander,
        f.saw_products,
        f.saw_product_page,
        f.saw_cart,
        f.saw_shipping,
        f.saw_billing,
        f.converted,
        case
            when f.converted = 1                        then '7_converted'
            when f.saw_billing = 1                      then '6_abandoned_billing'
            when f.saw_shipping = 1                     then '5_abandoned_shipping'
            when f.saw_cart = 1                         then '4_abandoned_cart'
            when f.saw_product_page = 1                 then '3_abandoned_product_page'
            when f.saw_products = 1                     then '2_abandoned_products'
            else                                             '1_bounced'
        end as intent_stage
    from funnel_flags f
    left join {{ ref('stg_sessions') }} s
        on f.session_id = s.session_id
)

select
    intent_stage,
    count(*)                                                       as total_sessions,
    count(distinct user_id)                                        as unique_users,
    sum(is_repeat_session)                                         as repeat_sessions,
    round(sum(is_repeat_session) * 100.0 / count(*), 2)           as repeat_pct,
    device_type,
    utm_source
from session_intent
group by intent_stage, device_type, utm_source
order by intent_stage, device_type, utm_source
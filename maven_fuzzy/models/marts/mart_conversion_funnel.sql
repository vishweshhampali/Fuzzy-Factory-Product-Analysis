select
    s.session_id,
    s.utm_source,
    s.utm_campaign,
    s.device_type,
    max(case when p.pageview_url = '/home'             then 1 else 0 end) as saw_home,
    max(case when p.pageview_url like '/lander%' 
             or p.pageview_url = '/home'               then 1 else 0 end) as saw_lander,
    max(case when p.pageview_url = '/products'         then 1 else 0 end) as saw_products,
    max(case when p.pageview_url in (
                '/the-original-mr-fuzzy',
                '/the-forever-love-bear',
                '/the-birthday-sugar-panda',
                '/the-hudson-river-mini-bear')          then 1 else 0 end) as saw_product_page,
    max(case when p.pageview_url = '/cart'             then 1 else 0 end) as saw_cart,
    max(case when p.pageview_url = '/shipping'         then 1 else 0 end) as saw_shipping,
    max(case when p.pageview_url in ('/billing', '/billing-2') 
                                                       then 1 else 0 end) as saw_billing,
    max(case when p.pageview_url = '/thank-you-for-your-order' 
                                                       then 1 else 0 end) as converted
from {{ ref('stg_sessions') }} s
left join {{ ref('stg_pageviews') }} p
    on s.session_id = p.session_id
group by 1, 2, 3, 4
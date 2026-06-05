select
    website_pageview_id as pageview_id,
    created_at,
    website_session_id  as session_id,
    pageview_url
from {{ source('main', 'website_pageviews') }}
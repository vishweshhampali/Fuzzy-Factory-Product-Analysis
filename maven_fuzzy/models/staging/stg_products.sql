select
    product_id,
    created_at,
    product_name
from {{ source('main', 'products') }}
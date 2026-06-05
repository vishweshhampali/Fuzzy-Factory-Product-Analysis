select
    order_item_refund_id as refund_id,
    created_at,
    order_item_id,
    order_id,
    refund_amount_usd
from {{ source('main', 'order_item_refunds') }}
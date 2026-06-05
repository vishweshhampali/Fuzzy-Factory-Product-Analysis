with first_visit as (
    select
        user_id,
        date_trunc('month', min(created_at)) as cohort_month
    from {{ ref('stg_sessions') }}
    group by 1
),

user_activity as (
    select
        s.user_id,
        fv.cohort_month,
        date_trunc('month', s.created_at)                          as activity_month,
        datediff('month', fv.cohort_month,
                 date_trunc('month', s.created_at))                as months_since_first
    from {{ ref('stg_sessions') }} s
    inner join first_visit fv on s.user_id = fv.user_id
)

select
    cohort_month,
    months_since_first,
    count(distinct user_id)   as active_users
from user_activity
group by 1, 2
order by 1, 2
{{
  config(
    materialized='incremental',
    unique_key=['organization_id', 'invoice_date'],
    on_schema_change='fail'
  )
}}

-- Daily balance changes by org
-- Just sum up invoice amounts per day, that's the balance change
with daily_amounts as (
    select
        organization_id,
        invoice_date,
        sum(amount_usd) as daily_balance_usd
    from {{ ref('stg_invoices') }}
    {% if is_incremental() %}
        where invoice_date >= (select max(invoice_date) - interval 1 day from {{ this }})
    {% endif %}
    group by organization_id, invoice_date
)

select
    organization_id,
    invoice_date,
    daily_balance_usd,
    lag(daily_balance_usd, 1) over (partition by organization_id order by invoice_date) as prev_day_balance,
    
    -- calculate % change, handle zeros properly
    case
        when daily_balance_usd > 0 and lag(daily_balance_usd, 1) over (partition by organization_id order by invoice_date) > 0
        then cast((daily_balance_usd - lag(daily_balance_usd, 1) over (partition by organization_id order by invoice_date)) 
             / lag(daily_balance_usd, 1) over (partition by organization_id order by invoice_date) * 100 as Decimal64(2))
        
        when daily_balance_usd = 0 and lag(daily_balance_usd, 1) over (partition by organization_id order by invoice_date) > 0
        then cast(-100.0 as Decimal64(2))
        
        when daily_balance_usd > 0 and lag(daily_balance_usd, 1) over (partition by organization_id order by invoice_date) = 0
        then cast(100.0 as Decimal64(2))
        
        when daily_balance_usd = 0 and lag(daily_balance_usd, 1) over (partition by organization_id order by invoice_date) = 0
        then cast(0.0 as Decimal64(2))
        
        else null
    end as balance_change_pct,
    
    {{ audit_columns() }}
    
from daily_amounts
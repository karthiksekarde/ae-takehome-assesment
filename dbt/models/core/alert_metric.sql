{{
  config(
    materialized='incremental',
    unique_key=['organization_id', 'invoice_date'],
    on_schema_change='fail'
  )
}}

SELECT 
    organization_id,
    invoice_date,
    daily_balance_usd,
    prev_day_balance,
    balance_change_pct,
    
    -- Audit columns
    {{ audit_columns() }}
    
FROM {{ ref('fact_balance') }}
WHERE ABS(balance_change_pct) > 50
  {% if is_incremental() %}
    -- Only new days: process today and yesterday (for comparison)
    AND invoice_date >= today() - INTERVAL 1 DAY
  {% else %}
    -- Initial load: process all historical data
    -- No date filter for initial load to capture all historical anomalies
  {% endif %}

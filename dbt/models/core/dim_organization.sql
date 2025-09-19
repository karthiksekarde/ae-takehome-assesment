SELECT 
    org.organization_id,
    org.first_payment_date,
    org.last_payment_date,
    org.legal_entity_country_code,
    org.count_total_contracts_active,
    org.created_date,
    
    -- Simple enrichments
    COUNT(inv.invoice_id) as total_invoices,
    SUM(inv.amount_usd) as total_invoice_amount_usd,
    
    -- Business categorization
    CASE 
        WHEN SUM(inv.amount_usd) >= 100000 THEN 'high_value'
        WHEN SUM(inv.amount_usd) >= 10000 THEN 'medium_value'
        ELSE 'low_value'
    END as customer_segment,
    
    -- Organization age and activity metrics
    dateDiff('day', org.first_payment_date, today()) as org_age_days,
    dateDiff('day', org.last_payment_date, today()) as days_since_last_payment,
    
    -- Business activity status
    CASE 
        WHEN org.last_payment_date IS NULL THEN 'no_payments'
        WHEN dateDiff('day', org.last_payment_date, today()) <= 30 THEN 'active'
        WHEN dateDiff('day', org.last_payment_date, today()) <= 90 THEN 'dormant'
        WHEN dateDiff('day', org.last_payment_date, today()) <= 365 THEN 'inactive'
        ELSE 'churned'
    END as business_status,
    
    -- Audit columns
    {{ audit_columns() }}

FROM {{ ref('stg_organizations') }} org
LEFT JOIN {{ ref('stg_invoices') }} inv 
    ON org.organization_id = inv.organization_id
GROUP BY 
    org.organization_id,
    org.first_payment_date,
    org.last_payment_date,
    org.legal_entity_country_code,
    org.count_total_contracts_active,
    org.created_date

SELECT 
    ORGANIZATION_ID as organization_id,
    
    -- Clean and cast date fields - use parseDateTimeBestEffortOrNull for robust parsing
    CASE 
        WHEN FIRST_PAYMENT_DATE = '1900-01-01' OR FIRST_PAYMENT_DATE = '' THEN NULL 
        ELSE toDate(parseDateTimeBestEffortOrNull(FIRST_PAYMENT_DATE))
    END as first_payment_date,
    CASE 
        WHEN LAST_PAYMENT_DATE = '1900-01-01' OR LAST_PAYMENT_DATE = '' THEN NULL 
        ELSE toDate(parseDateTimeBestEffortOrNull(LAST_PAYMENT_DATE))
    END as last_payment_date,
    
    -- Clean other fields
    LEGAL_ENTITY_COUNTRY_CODE as legal_entity_country_code,
    COALESCE(CAST(COUNT_TOTAL_CONTRACTS_ACTIVE AS UInt32), 0) as count_total_contracts_active,
    -- Use parseDateTimeBestEffortOrNull for robust timestamp parsing
    parseDateTimeBestEffortOrNull(CREATED_DATE) as created_date,
    
    -- Data quality flag for conditions NOT filtered by WHERE clause
    CASE 
        WHEN LEGAL_ENTITY_COUNTRY_CODE IS NULL THEN 'missing_country'
        -- add more data quality flags here
        ELSE 'valid'
    END as data_quality_flag
    
FROM {{ source('raw_data', 'organizations_raw') }}
WHERE ORGANIZATION_ID IS NOT NULL

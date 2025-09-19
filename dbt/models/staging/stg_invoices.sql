SELECT 
    INVOICE_ID as invoice_id,
    PARENT_INVOICE_ID as parent_invoice_id,
    ORGANIZATION_ID as organization_id,
    TYPE as type,
    STATUS as status,
    UPPER(TRIM(CURRENCY)) as invoice_currency,
    UPPER(TRIM(PAYMENT_CURRENCY)) as payment_currency,
    
    -- Original amounts and FX rates (cast from String with larger precision)
    -- Make refunded amounts negative for proper balance calculation
    CASE 
        WHEN STATUS = 'refunded' THEN -CAST(COALESCE(AMOUNT, '0') AS Decimal128(2))
        ELSE CAST(COALESCE(AMOUNT, '0') AS Decimal128(2))
    END as invoice_amount,
    CAST(PAYMENT_AMOUNT AS Nullable(Decimal128(2))) as payment_amount,
    CAST(FX_RATE AS Nullable(Decimal128(8))) as fx_rate,
    CAST(FX_RATE_PAYMENT AS Nullable(Decimal128(8))) as fx_rate_payment,
    
    -- Calculate standardized USD amount for balance calculations
    -- Based on data analysis: AMOUNT and PAYMENT_AMOUNT are often the same
    -- FX_RATE seems to be the rate FROM invoice currency TO USD
    -- FX_RATE_PAYMENT seems to be the rate FROM payment currency TO USD
    CASE 
        -- If invoice currency is USD, use invoice amount (already handles refunded negative)
        WHEN UPPER(TRIM(CURRENCY)) = 'USD' AND AMOUNT IS NOT NULL THEN 
            CASE 
                WHEN STATUS = 'refunded' THEN -CAST(AMOUNT AS Decimal128(2))
                ELSE CAST(AMOUNT AS Decimal128(2))
            END
        -- If payment currency is USD, payment_amount should be the USD equivalent
        WHEN UPPER(TRIM(PAYMENT_CURRENCY)) = 'USD' AND PAYMENT_AMOUNT IS NOT NULL THEN 
            CASE 
                WHEN STATUS = 'refunded' THEN -CAST(PAYMENT_AMOUNT AS Decimal128(2))
                ELSE CAST(PAYMENT_AMOUNT AS Decimal128(2))
            END
        -- If neither is USD, convert invoice amount using FX rate to USD
        WHEN CAST(FX_RATE AS Decimal128(8)) > 0 AND UPPER(TRIM(CURRENCY)) != 'USD' AND AMOUNT IS NOT NULL THEN 
            CASE 
                WHEN STATUS = 'refunded' THEN -(CAST(AMOUNT AS Decimal128(8)) / CAST(FX_RATE AS Decimal128(8)))
                ELSE CAST(AMOUNT AS Decimal128(8)) / CAST(FX_RATE AS Decimal128(8))
            END
        -- Default fallback - handle NULL values
        WHEN AMOUNT IS NOT NULL THEN 
            CASE 
                WHEN STATUS = 'refunded' THEN -CAST(AMOUNT AS Decimal128(2))
                ELSE CAST(AMOUNT AS Decimal128(2))
            END
        ELSE 0
    END as amount_usd,
    
    -- Proper date/timestamp casting - use parseDateTimeBestEffortOrNull for robust parsing
    parseDateTimeBestEffortOrNull(CREATED_AT) as created_at,
    toDate(parseDateTimeBestEffortOrNull(CREATED_AT)) as invoice_date,
    
    -- Invoice hierarchy flags
    CASE 
        WHEN parent_invoice_id IS NULL OR parent_invoice_id = '' THEN 'parent'
        ELSE 'child'
    END as invoice_hierarchy,
    
    -- Data quality flag for conditions NOT filtered by WHERE clause
    CASE 
        WHEN CURRENCY IS NULL THEN 'missing_currency'
        WHEN FX_RATE IS NULL OR CAST(FX_RATE AS Decimal64(8)) <= 0 THEN 'invalid_fx_rate'
        WHEN PAYMENT_CURRENCY IS NULL AND PAYMENT_AMOUNT IS NOT NULL THEN 'missing_payment_currency'
        ELSE 'valid'
    END as data_quality_flag
    
FROM {{ source('raw_data', 'invoices_raw') }}
WHERE STATUS IN ('credited', 'refunded')
  AND INVOICE_ID IS NOT NULL 
  AND ORGANIZATION_ID IS NOT NULL 
  AND AMOUNT IS NOT NULL
  AND CREATED_AT IS NOT NULL

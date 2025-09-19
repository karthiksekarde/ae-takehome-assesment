{% macro audit_columns() %}
    now() as dbt_updated_at,
    '{{ invocation_id }}' as dbt_run_id,
    '{{ this }}' as dbt_model_name
{% endmacro %}

{% macro source_audit_columns() %}
    now() as loaded_at,
    '{{ invocation_id }}' as load_run_id,
    MD5(CONCAT_WS('|', 
        CAST(organization_id as String),
        CAST(created_date as String)
    )) as source_hash
{% endmacro %}

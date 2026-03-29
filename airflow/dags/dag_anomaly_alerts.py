from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'data-platform',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def check_balance_anomalies():
    import clickhouse_connect
    
    client = clickhouse_connect.get_client(
        host='deel-data-warehouse', 
        port=8123, 
        user='default', 
        password='password'
    )
    
    # get today's anomalies
    query = """
    SELECT 
        organization_id,
        invoice_date,
        daily_balance_usd,
        prev_day_balance,
        balance_change_pct
    FROM deel_analytics_deel_analytics_core.alert_metric
    WHERE invoice_date >= '2024-04-20'  -- Test with recent historical data
    ORDER BY ABS(balance_change_pct) DESC
    LIMIT 10
    """
    
    result = client.query(query)
    anomalies = result.result_rows
    
    if anomalies:
        print(f"Found {len(anomalies)} balance anomalies today:")
        for row in anomalies:
            org_id, date, balance_usd, prev_balance, change_pct = row
            print(f"Org {org_id}: {change_pct:.1f}% change on {date} (${prev_balance:,.0f} -> ${balance_usd:,.0f})")
    else:
        print("No balance anomalies today")
    
    return len(anomalies)

dag = DAG(
    'balance_anomaly_detection',
    default_args=default_args,
    description='Check for balance anomalies > 50%',
    schedule_interval='0 10 * * *',  # 10am daily
    catchup=False,
)

check_anomalies = PythonOperator(
    task_id='check_balance_anomalies',
    python_callable=check_balance_anomalies,
    dag=dag,
)
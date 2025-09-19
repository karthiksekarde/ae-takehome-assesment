from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'data-platform',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'dbt_pipeline',
    default_args=default_args,
    description='Run DBT models',
    schedule_interval=None,
    catchup=False,
)

# compile models
dbt_compile = BashOperator(
    task_id='dbt_compile',
    bash_command='cd /usr/local/airflow/dbt && dbt compile --profiles-dir /usr/local/airflow',
    dag=dag,
)

# run models
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command='cd /usr/local/airflow/dbt && dbt run --profiles-dir /usr/local/airflow',
    dag=dag,
)

# test models
dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command='cd /usr/local/airflow/dbt && dbt test --profiles-dir /usr/local/airflow',
    dag=dag,
)

# trigger alerts
trigger_alerts = BashOperator(
    task_id='trigger_alerts',
    bash_command='airflow dags trigger balance_anomaly_detection',
    dag=dag,
)

dbt_compile >> dbt_run >> dbt_test >> trigger_alerts
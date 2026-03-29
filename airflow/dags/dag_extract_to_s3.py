from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'data-platform',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def upload_to_minio():
    import boto3
    from botocore.client import Config
    
    s3_client = boto3.client(
        's3',
        endpoint_url="http://deel-data-lake:9000",
        aws_access_key_id="MINIOADMIN",
        aws_secret_access_key="MINIOADMIN",
        config=Config(signature_version='s3v4'),
        region_name='us-east-1'
    )
    
    bucket_name = 'data-lake'
    
    # create bucket if needed
    try:
        s3_client.head_bucket(Bucket=bucket_name)
        print(f"Bucket {bucket_name} exists")
    except:
        try:
            s3_client.create_bucket(Bucket=bucket_name)
            print(f"Created bucket {bucket_name}")
        except Exception as e:
            print(f"Failed to create bucket: {e}")
    
    # Upload files from input-files directory
    s3_client.upload_file('/usr/local/airflow/input-files/organizations.csv', bucket_name, 'organizations.csv')
    s3_client.upload_file('/usr/local/airflow/input-files/invoices.csv', bucket_name, 'invoices.csv')
    print("Successfully uploaded files to MinIO")

def create_external_tables():
    import clickhouse_connect
    
    client = clickhouse_connect.get_client(
        host='deel-data-warehouse', 
        port=8123, 
        user='default', 
        password='password'
    )
    
    # create database
    client.command('CREATE DATABASE IF NOT EXISTS deel_analytics')
    
    # organizations table
    client.command('''
        CREATE TABLE IF NOT EXISTS deel_analytics.organizations_raw (
            ORGANIZATION_ID String,
            FIRST_PAYMENT_DATE Nullable(String),
            LAST_PAYMENT_DATE Nullable(String),
            LEGAL_ENTITY_COUNTRY_CODE Nullable(String),
            COUNT_TOTAL_CONTRACTS_ACTIVE Nullable(String),
            CREATED_DATE Nullable(String)
        ) ENGINE = S3('http://deel-data-lake:9000/data-lake/organizations.csv', 'MINIOADMIN', 'MINIOADMIN', 'CSVWithNames')
    ''')
    
    # invoices table
    client.command('''
        CREATE TABLE IF NOT EXISTS deel_analytics.invoices_raw (
            INVOICE_ID String,
            PARENT_INVOICE_ID Nullable(String),
            TRANSACTION_ID Nullable(String),
            ORGANIZATION_ID String,
            TYPE Nullable(String),
            STATUS String,
            CURRENCY String,
            PAYMENT_CURRENCY Nullable(String),
            PAYMENT_METHOD Nullable(String),
            AMOUNT String,
            PAYMENT_AMOUNT Nullable(String),
            FX_RATE Nullable(String),
            FX_RATE_PAYMENT Nullable(String),
            CREATED_AT String
        ) ENGINE = S3('http://deel-data-lake:9000/data-lake/invoices.csv', 'MINIOADMIN', 'MINIOADMIN', 'CSVWithNames')
    ''')

dag = DAG(
    'extract_data_to_s3',
    default_args=default_args,
    description='Upload CSVs to MinIO and create ClickHouse external tables',
    schedule_interval='@daily',
    catchup=False,
)

upload_task = PythonOperator(
    task_id='upload_to_minio',
    python_callable=upload_to_minio,
    dag=dag,
)

create_tables_task = PythonOperator(
    task_id='create_external_tables',
    python_callable=create_external_tables,
    dag=dag,
)

trigger_dbt = BashOperator(
    task_id='trigger_dbt_pipeline',
    bash_command='airflow dags trigger dbt_pipeline',
    dag=dag,
)

upload_task >> create_tables_task >> trigger_dbt

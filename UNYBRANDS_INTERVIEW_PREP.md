# Unybrands Senior Data Engineer Interview Prep Guide

## Interview Overview

**Format**: 90 minutes with Head of Data + CTO  
**Style**: Practical, collaborative, production-focused (not academic)  
**Goal**: Simulate real-world working environment

---

## Interview Structure & Time Allocation

| Section | Duration | Format | What They're Testing |
|---------|----------|--------|---------------------|
| **1. Architecture & Data Modeling** | 30-40 min | Whiteboarding (draw.io) | Design thinking, analytical architecture evolution |
| **2. Live Debugging** | 30 min | Code pairing (Airflow DAG) | Debugging process, Airflow best practices, production awareness |
| **3. Design Strategy** | 20 min | Discussion | CI/CD, DevOps, automation, past experience |

---

## Part 1: Architecture & Data Modeling (30-40 mins)

### What to Expect

**Scenario**: Business use case (Logistics, E-commerce, Commercial)  
**Task**: Design ERD → Evolve to analytical data architecture  
**Tool**: draw.io (they provide link or you screen-share)

### What They're Looking For

✅ **Business understanding**: Ask clarifying questions about use case  
✅ **Normalized design first**: Proper ERD (entities, relationships, cardinality)  
✅ **Evolution to analytics**: Transition from OLTP to OLAP thinking  
✅ **Tradeoff articulation**: Why dimensional model vs normalized vs denormalized  
✅ **Scalability awareness**: Partitioning, indexing, growth considerations  
✅ **Communication**: Think aloud, explain choices

### Likely Scenarios (E-commerce Focus)

Given unybrands is an e-commerce aggregator, expect scenarios like:

**Scenario 1: Order Management & Fulfillment**
- Entities: Customers, Orders, Products, Inventory, Warehouses, Shipments
- Analytics needs: Sales trends, inventory turnover, fulfillment speed

**Scenario 2: Multi-Brand Analytics**
- Entities: Brands, Products, SKUs, Sales Channels (Amazon, Shopify, etc.)
- Analytics needs: Brand performance, channel attribution, cross-sell

**Scenario 3: Supply Chain & Logistics**
- Entities: Suppliers, POs, Shipments, Warehouses, Stock Levels
- Analytics needs: Lead time, stockout prediction, supplier performance

### Step-by-Step Approach

#### Phase 1: Requirements Gathering (3-5 minutes)

**Questions to Ask**:
- "What are the key business processes we need to support?" (e.g., order-to-cash, procure-to-pay)
- "Who are the primary users of this data?" (analysts, ops teams, execs)
- "What are the critical metrics?" (GMV, COGS, inventory turns, fulfillment time)
- "Are there real-time requirements or is batch sufficient?" (order tracking vs daily reports)
- "What's the data volume?" (orders/day, SKUs, brands)
- "Are there any specific pain points with current systems?" (slow queries, data silos)

**Pro tip**: Frame questions around their business model: "As an e-commerce aggregator, are brands siloed or do you need cross-brand analytics?"

#### Phase 2: Operational ERD (5-7 minutes)

Draw a normalized ERD focusing on transactional system:

**Example: Order Management ERD**

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  Customer   │         │    Order    │         │   Product   │
├─────────────┤         ├─────────────┤         ├─────────────┤
│ customer_id │────┐    │ order_id    │    ┌────│ product_id  │
│ email       │    │    │ customer_id │────┘    │ sku         │
│ name        │    │    │ order_date  │         │ brand_id    │
│ created_at  │    │    │ status      │         │ category    │
└─────────────┘    │    │ total_amt   │         │ price       │
                   │    └─────────────┘         └─────────────┘
                   │           │                        │
                   │           │                        │
                   │    ┌──────▼──────────┐            │
                   │    │  Order_Items    │────────────┘
                   │    ├─────────────────┤
                   │    │ order_item_id   │
                   │    │ order_id        │
                   │    │ product_id      │
                   │    │ quantity        │
                   │    │ unit_price      │
                   │    └─────────────────┘
                   │
                   └────────────────────────┐
                                            │
                   ┌────────────────────────▼───┐
                   │      Address               │
                   ├────────────────────────────┤
                   │ address_id                 │
                   │ customer_id                │
                   │ type (billing/shipping)    │
                   │ street, city, zip          │
                   └────────────────────────────┘
```

**Key Points to Mention**:
- "Customer table holds master data, normalized to avoid duplication"
- "Order_Items is junction table (many-to-many between orders and products)"
- "1:N relationship: One customer, many orders"
- "Foreign keys enforce referential integrity"
- "This supports OLTP: fast writes, normalized to avoid update anomalies"

#### Phase 3: Analytical Architecture Evolution (15-20 minutes)

Now evolve to analytical warehouse design:

**Step 3a: Identify Analytical Patterns**

"For analytics, we need to optimize for reads, not writes. Let me design a dimensional model."

**Step 3b: Dimensional Model (Star Schema)**

```
                    ┌─────────────────┐
                    │   Dim_Customer  │
                    ├─────────────────┤
                    │ customer_key    │ (surrogate key)
                    │ customer_id     │ (natural key)
                    │ email, name     │
                    │ segment         │
                    │ lifetime_value  │
                    │ cohort_month    │
                    │ valid_from      │ (SCD Type 2)
                    │ valid_to        │
                    │ is_current      │
                    └─────────────────┘
                            │
                            │
┌─────────────┐    ┌────────▼─────────┐    ┌─────────────┐
│ Dim_Product │    │  Fact_Orders     │    │  Dim_Date   │
├─────────────┤    ├──────────────────┤    ├─────────────┤
│product_key  │◄───│ order_key        │───►│ date_key    │
│product_id   │    │ customer_key     │    │ date        │
│sku          │    │ product_key      │    │ year, qtr   │
│brand_id     │    │ date_key         │    │ month, week │
│brand_name   │    │ channel_key      │    │ day_of_week │
│category     │    │────────────      │    │ is_holiday  │
│cost         │    │ order_id         │    └─────────────┘
│list_price   │    │ quantity         │
└─────────────┘    │ unit_price       │    ┌─────────────┐
                   │ discount         │    │ Dim_Channel │
                   │ revenue          │    ├─────────────┤
                   │ cogs             │◄───│ channel_key │
                   │ gross_profit     │    │ channel_name│
                   │ order_status     │    │ platform    │
                   └──────────────────┘    │ commission% │
                                           └─────────────┘
```

**Key Points to Articulate**:

1. **Why Star Schema?**
   - "Star schema optimizes for analytics: fewer joins, easier for BI tools"
   - "Denormalized dimensions reduce query complexity"
   - "Pre-joined data vs 5-way joins in normalized model"

2. **Surrogate Keys**:
   - "Surrogate keys (customer_key) decouple warehouse from source system IDs"
   - "Enables SCD Type 2 for customer history tracking"
   - "Natural key (customer_id) preserved for lookups"

3. **Slowly Changing Dimensions (SCD Type 2)**:
   - "Customer segment changes over time (bronze → silver → gold customer)"
   - "SCD Type 2 preserves history: valid_from, valid_to, is_current flag"
   - "Fact table joins to customer state at order_date (point-in-time correctness)"

4. **Fact Table Grain**:
   - "Grain: One row per order line item"
   - "Could aggregate to order level, but line-item grain more flexible"
   - "Pre-calculated metrics (revenue, cogs, gross_profit) for query performance"

5. **Conformed Dimensions**:
   - "Dim_Date is conformed (shared across all fact tables)"
   - "Enables cross-fact analysis (orders vs shipments vs returns)"

#### Step 3c: Full Analytical Architecture (Final 10 mins)

Zoom out to end-to-end architecture:

```
┌──────────────────────────────────────────────────────────────┐
│                    DATA SOURCES                               │
├──────────────────────────────────────────────────────────────┤
│  Shopify API │ Amazon SP-API │ Internal DB │ 3PL Webhooks   │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                  INGESTION LAYER                              │
├──────────────────────────────────────────────────────────────┤
│  Airflow DAGs: API extractors, CDC (Debezium), File uploads  │
│  Raw data → S3 (Bronze Layer) - Parquet, partitioned by date │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│               DATA WAREHOUSE (Snowflake)                      │
├──────────────────────────────────────────────────────────────┤
│  ┌────────────┐   ┌────────────┐   ┌──────────────┐        │
│  │   Bronze   │──►│   Silver   │──►│     Gold     │        │
│  ├────────────┤   ├────────────┤   ├──────────────┤        │
│  │ Raw copies │   │ Cleaned    │   │ Dimensional  │        │
│  │ from S3    │   │ Conformed  │   │ Star schema  │        │
│  │ Partitioned│   │ Deduped    │   │ Aggregates   │        │
│  │ by source  │   │ SCD Type 2 │   │ Pre-joined   │        │
│  └────────────┘   └────────────┘   └──────────────┘        │
│                                                               │
│  Transformation: dbt (models, tests, docs)                   │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                   SERVING LAYER                               │
├──────────────────────────────────────────────────────────────┤
│  Looker/Tableau  │  Jupyter Notebooks  │  APIs (FastAPI)    │
│  Dashboards      │  Ad-hoc Analysis    │  Operational       │
└──────────────────────────────────────────────────────────────┘
```

**Key Talking Points**:

1. **Medallion Architecture**:
   - "Bronze: Immutable raw data, audit trail, enables reprocessing"
   - "Silver: Business-ready, standardized, single source of truth"
   - "Gold: Performance-optimized, denormalized for consumption"

2. **Technology Choices**:
   - "Airflow for orchestration (Python-based, flexible, industry standard)"
   - "S3 data lake: Cost-effective, scalable, integrates with everything"
   - "Snowflake: Elastic compute, separation of storage/compute, time travel"
   - "dbt: SQL transformations, testing, documentation, CI/CD friendly"

3. **Scalability Considerations**:
   - "S3 partitioned by date/brand for query performance (partition pruning)"
   - "Snowflake clustering on high-cardinality columns (order_date, customer_id)"
   - "Incremental dbt models (only process new/changed data)"
   - "Materialized views for aggregations (pre-compute metrics)"

4. **Data Quality**:
   - "dbt tests: unique keys, not null, foreign key relationships"
   - "Great Expectations: range checks, distribution validation"
   - "Reconciliation: Compare Silver totals to source systems"

### Common Pitfalls to Avoid

❌ **Jumping to implementation**: Don't start drawing before understanding requirements  
❌ **Over-engineering**: Don't design real-time Kafka if batch is sufficient  
❌ **Under-engineering**: Don't ignore scalability ("this won't work at 1M orders/day")  
❌ **Jargon without explanation**: Don't say "SCD Type 2" without explaining why  
❌ **No tradeoffs**: Don't present solution as "perfect"; discuss alternatives  

### Practice Exercises

**Exercise 1: E-commerce Order to Cash**
- Time yourself: 35 minutes
- Draw: Customer → Order → Product → Payment ERD
- Evolve: Dimensional model with Fact_Orders
- Add: Multi-brand complexity (brand_id in Product)

**Exercise 2: Inventory & Supply Chain**
- Time yourself: 35 minutes
- Draw: Supplier → PO → Warehouse → Stock ERD
- Evolve: Fact_Inventory_Snapshot (daily grain)
- Add: Stockout prediction analytics

**Exercise 3: Marketing Attribution**
- Time yourself: 35 minutes
- Draw: Campaign → Click → Conversion → Order
- Evolve: Multi-touch attribution fact table
- Add: Channel (Amazon, Google, Facebook) dimension

---

## Part 2: Live Debugging (30 mins)

### What to Expect

**Scenario**: Existing Airflow DAG with "production issues"  
**Format**: Code pairing (they share code, you debug)  
**Environment**: Your local Airflow (Docker or venv)  
**File**: They provide .py file → you drop in `/dags` folder → trigger → debug

### What They're Looking For

✅ **Systematic debugging**: Methodical approach, not random guessing  
✅ **Airflow knowledge**: Best practices (retries, idempotency, resource mgmt)  
✅ **Production thinking**: What breaks in production vs dev?  
✅ **Code quality**: PEP8, readability, maintainability  
✅ **Communication**: Explain your thought process

### Common Airflow Anti-Patterns (Likely Issues)

#### Issue 1: Non-Idempotent Tasks

**Bad Code**:
```python
@task
def load_data():
    # This fails on retry - duplicates data!
    df = extract_from_api()
    df.to_sql('orders', engine, if_exists='append')  # ❌ APPEND
```

**What to Say**:
> "This task is not idempotent. If it fails after writing partial data and Airflow retries, we'll have duplicates. Should use UPSERT or delete-then-insert pattern."

**Fixed Code**:
```python
@task
def load_data():
    df = extract_from_api()
    # Option 1: Upsert with primary key
    df.to_sql('orders_staging', engine, if_exists='replace')
    engine.execute("""
        MERGE INTO orders t
        USING orders_staging s ON t.order_id = s.order_id
        WHEN MATCHED THEN UPDATE SET ...
        WHEN NOT MATCHED THEN INSERT ...
    """)
    
    # Option 2: Delete date range first, then insert
    execution_date = context['ds']
    engine.execute(f"DELETE FROM orders WHERE order_date = '{execution_date}'")
    df.to_sql('orders', engine, if_exists='append')
```

#### Issue 2: No Retry Logic or Incorrect Retries

**Bad Code**:
```python
with DAG(
    dag_id='orders_pipeline',
    default_args={'owner': 'data_team'},  # ❌ No retries
    schedule_interval='@daily',
) as dag:
    extract = PythonOperator(...)
```

**What to Say**:
> "No retry configuration. API calls can have transient failures. Need exponential backoff to avoid overwhelming source."

**Fixed Code**:
```python
default_args = {
    'owner': 'data_team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,
    'max_retry_delay': timedelta(minutes=30),
    'execution_timeout': timedelta(hours=1),
}
```

#### Issue 3: Hardcoded Dates (Not Using Execution Context)

**Bad Code**:
```python
@task
def extract_orders():
    # ❌ Hardcoded date - can't backfill!
    start_date = '2025-01-01'
    end_date = '2025-01-06'
    return api.get_orders(start_date, end_date)
```

**What to Say**:
> "Hardcoded dates break backfilling and catchup. Airflow provides execution context with data_interval_start/end. This DAG can't reprocess historical dates."

**Fixed Code**:
```python
@task
def extract_orders(**context):
    # Use Airflow's execution context
    start_date = context['data_interval_start'].strftime('%Y-%m-%d')
    end_date = context['data_interval_end'].strftime('%Y-%m-%d')
    return api.get_orders(start_date, end_date)
```

#### Issue 4: Top-Heavy DAG (Runs on Every Parse)

**Bad Code**:
```python
import pandas as pd

# ❌ This runs on every DAG parse (every 30s!)
df = pd.read_csv('s3://bucket/huge_file.csv')  
valid_products = df['product_id'].tolist()

with DAG(...) as dag:
    task1 = PythonOperator(...)
```

**What to Say**:
> "This code runs on every scheduler parse cycle (every 30 seconds), not just during task execution. Scheduler will slow down, and we're making unnecessary S3 reads. Should move inside task function."

**Fixed Code**:
```python
@task
def validate_products():
    # Runs only when task executes
    df = pd.read_csv('s3://bucket/huge_file.csv')
    return df['product_id'].tolist()
```

#### Issue 5: Secrets in Code

**Bad Code**:
```python
@task
def extract_from_shopify():
    api_key = 'shpat_1234567890abcdef'  # ❌ Hardcoded secret
    shopify.set_credentials(api_key)
```

**What to Say**:
> "Secrets hardcoded in DAG file. If this goes to Git, it's a security breach. Should use Airflow Variables or Connections, or AWS Secrets Manager."

**Fixed Code**:
```python
from airflow.models import Variable
from airflow.hooks.base import BaseHook

@task
def extract_from_shopify():
    # Option 1: Airflow Variable
    api_key = Variable.get('shopify_api_key')
    
    # Option 2: Airflow Connection (better)
    conn = BaseHook.get_connection('shopify_conn')
    api_key = conn.password
    
    shopify.set_credentials(api_key)
```

#### Issue 6: No Error Handling

**Bad Code**:
```python
@task
def extract_orders():
    response = requests.get('https://api.example.com/orders')
    return response.json()  # ❌ What if 500 error? Non-JSON response?
```

**What to Say**:
> "No error handling. If API returns 500 or non-JSON, this crashes without useful error message. Should check status code, handle timeouts, parse errors gracefully."

**Fixed Code**:
```python
@task
def extract_orders():
    try:
        response = requests.get(
            'https://api.example.com/orders',
            timeout=30
        )
        response.raise_for_status()  # Raises for 4xx/5xx
        return response.json()
    except requests.exceptions.Timeout:
        raise AirflowException("API timeout after 30s")
    except requests.exceptions.HTTPError as e:
        raise AirflowException(f"API returned {e.response.status_code}")
    except ValueError as e:
        raise AirflowException(f"Invalid JSON response: {e}")
```

#### Issue 7: Task Dependencies Not Clear

**Bad Code**:
```python
with DAG(...) as dag:
    extract = PythonOperator(task_id='extract', ...)
    transform = PythonOperator(task_id='transform', ...)
    load = PythonOperator(task_id='load', ...)
    # ❌ No dependencies defined!
```

**What to Say**:
> "No task dependencies. All three tasks will run in parallel, causing load to fail because transform hasn't run yet. Need to define execution order."

**Fixed Code**:
```python
# Option 1: Bitshift operators
extract >> transform >> load

# Option 2: set_downstream
extract.set_downstream(transform)
transform.set_downstream(load)

# Option 3: TaskFlow API (cleaner)
@dag(...)
def orders_pipeline():
    data = extract()
    transformed = transform(data)
    load(transformed)
```

#### Issue 8: Resource Intensive (No Pools/Queues)

**Bad Code**:
```python
# 100 tasks all hitting same database
for i in range(100):
    PythonOperator(
        task_id=f'load_batch_{i}',
        python_callable=load_to_postgres,
    )
```

**What to Say**:
> "No resource management. 100 concurrent connections will overwhelm Postgres. Should use pools to limit concurrency, or batch multiple loads per task."

**Fixed Code**:
```python
# Option 1: Use pool (define in Airflow UI first)
for i in range(100):
    PythonOperator(
        task_id=f'load_batch_{i}',
        python_callable=load_to_postgres,
        pool='postgres_pool',  # Max 10 concurrent
    )

# Option 2: Batch processing (better)
@task
def load_all_batches():
    # Process all 100 batches in one task with controlled parallelism
    with ThreadPoolExecutor(max_workers=5) as executor:
        executor.map(load_to_postgres, range(100))
```

### Debugging Process (What to Verbalize)

1. **Read DAG structure first**:
   > "Let me understand the DAG structure: schedule, tasks, dependencies"

2. **Check default_args**:
   > "Looking at retries, timeouts, execution_timeout—these are critical for production"

3. **Scan for anti-patterns**:
   > "Checking for hardcoded dates, secrets in code, top-heavy DAG logic"

4. **Review task logic**:
   > "This task does X, Y, Z—is it idempotent? What happens on retry?"

5. **Look at error handling**:
   > "Are API calls wrapped in try/except? Timeout configured?"

6. **Test mentally**:
   > "If this task fails halfway and retries, what happens? Duplicates? Data loss?"

7. **Check resource usage**:
   > "Are we creating too many DB connections? Should use a pool?"

### Practice Exercises

**Exercise 1: Review & Fix**

Take any Airflow DAG from GitHub (search "airflow dags examples"), identify 5 issues in 15 minutes:
- Idempotency issues?
- Retry configuration?
- Hardcoded values?
- Error handling?
- Resource management?

**Exercise 2: Write Idempotent Task**

Write a task that loads daily order data to Postgres. Ensure it's idempotent (can rerun safely). Time: 10 minutes.

**Exercise 3: Debug Logs**

Practice reading Airflow logs. Know what to look for:
- Task start/end timestamps
- Exception stack traces
- Retry attempts
- Resource exhaustion (OOM, timeout)

---

## Part 3: Design Strategy (20 mins)

### What to Expect

**Format**: Discussion, not whiteboarding  
**Topics**: DevOps, CI/CD, automation, past experiences  
**Depth**: They want to understand your production maturity

### What They're Looking For

✅ **CI/CD experience**: How do you deploy pipelines safely?  
✅ **Automation mindset**: "Automate the boring stuff"  
✅ **Data quality**: How do you prevent bad data reaching production?  
✅ **Monitoring & alerting**: How do you know when things break?  
✅ **Incident response**: How do you handle production issues?  
✅ **Past experience**: Real examples, not theory

### Key Topics & Your Answers

#### Topic 1: CI/CD for Data Pipelines

**Question**: "How do you deploy Airflow DAGs to production?"

**Strong Answer** (60 seconds):
> "We use GitHub Actions for CI/CD. On PR open, we run automated checks: syntax validation (Python linting), DAG integrity test (DAG can parse), and dbt model tests in dev environment. If tests pass, PR gets approved and merged to main. On merge, GitHub Actions deploys DAGs to S3 (for MWAA) or triggers sync to Airflow server. Deployment is blue-green where possible—new DAG version coexists with old, traffic switches after validation. We tag releases in Git for rollback capability."

**Key Points to Hit**:
- Automated testing (don't merge broken DAGs)
- Environment promotion (dev → staging → prod)
- Rollback strategy (Git tags, Airflow versioning)
- No manual file copies (everything through CI/CD)

---

#### Topic 2: Data Quality & Testing

**Question**: "How do you ensure data quality in your pipelines?"

**Strong Answer** (60 seconds):
> "Multi-layered approach. First, dbt tests on every model—unique keys, not null constraints, foreign key relationships, custom business logic tests. These run in CI/CD and block deployment if failed. Second, Great Expectations for runtime validation—range checks, distribution tests, anomaly detection. Third, reconciliation jobs that compare warehouse totals to source systems—if variance >0.1%, pipeline halts and alerts fire. Finally, monitoring via data freshness checks and volume anomaly detection. We treat data quality as code—tests are version-controlled, peer-reviewed, and continuously run."

**Key Points**:
- Testing at multiple layers (compile-time, runtime, post-load)
- Automated (not manual spot checks)
- Fail-fast (circuit breakers)
- Examples of actual tests (unique, not null, reconciliation)

---

#### Topic 3: Monitoring & Alerting

**Question**: "How do you monitor data pipelines?"

**Strong Answer** (60 seconds):
> "We monitor at three levels. Infrastructure: Airflow scheduler heartbeat, worker CPU/memory, database connections—alert if scheduler lag >5 minutes. Pipeline: DAG success rate (>99.5% target), task duration P95 (alert on 20% increase), SLA misses—all tracked in Datadog with Slack alerts. Data: Freshness (table hasn't updated in >2 hours), volume anomalies (50% row count drop), schema changes—these trigger PagerDuty for on-call. We avoid alert fatigue by tuning thresholds (statistical baselines, not static) and having clear runbooks for each alert."

**Key Points**:
- Three layers (infra, pipeline, data)
- Specific metrics (not vague "we monitor everything")
- Alerting channels (Slack, PagerDuty) with severity tiers
- Runbooks for common issues

---

#### Topic 4: Incident Response

**Question**: "Walk me through a production incident you handled."

**Strong Answer Template** (90 seconds):

> "Last quarter, our daily order pipeline failed at 6am—critical because exec dashboard needed data by 8am for board meeting. **Detection**: Freshness alert fired at 6:15am, on-call paged. **Diagnosis**: Checked Airflow logs, saw Snowflake timeout on COPY INTO—large file (2GB), network blip caused timeout. **Decision**: Reran task manually (cleared in Airflow UI), but failed again. Switched to manual Snowflake COPY (bypassed Airflow) to meet deadline. **Resolution**: Manual load worked, downstream tasks continued, dashboard updated by 7:30am. **Prevention**: Post-mortem identified root cause—undersized warehouse + insufficient timeout. Implemented three fixes: increased warehouse to Medium for large loads, added 30-min query timeout, and exponential backoff on retries. Haven't had that issue since."

**Structure (STAR)**:
- **Situation**: What was broken, why critical
- **Task**: Your role, time pressure
- **Action**: Diagnosis steps, decisions made
- **Result**: How resolved, prevention measures

---

#### Topic 5: Automation Philosophy

**Question**: "What's your approach to automating data workflows?"

**Strong Answer** (60 seconds):
> "I bias toward automation for repetitive, error-prone tasks. Examples: schema validation (automate, don't manually check), data quality tests (automate with dbt/GE), infrastructure provisioning (Terraform, not console clicks), alerting (automatic, not someone checking dashboards). I don't automate prematurely—if it's a one-off task, manual is fine. But if I do something twice, I script it; third time, I automate it fully. Key is making automation maintainable—clear code, good documentation, easy to debug when it breaks. Automation should reduce toil, not create a complex system that only one person understands."

**Key Points**:
- Specific examples (what you've automated)
- Pragmatic (don't over-automate)
- Maintainability matters
- "Automate the toil" mindset

---

#### Topic 6: Code Review & Collaboration

**Question**: "How do you ensure code quality on a team?"

**Strong Answer** (60 seconds):
> "Code review is mandatory—no direct commits to main. PRs require one approval from team member. We have a checklist: Is it idempotent? Are there tests? Is it documented? Secrets handled properly? We use automated linters (sqlfluff for SQL, black for Python) that run in CI—code doesn't merge if linting fails. For complex changes, we do pairing sessions—two people working together reduces bugs and spreads knowledge. We also have biweekly 'code review sessions' where we review interesting or problematic code as a team—learning opportunity, not blame session."

**Key Points**:
- Mandatory reviews (no solo commits)
- Automated checks (linting, tests)
- Checklist for common issues
- Pairing for complex work
- Team learning culture

---

#### Topic 7: Scalability Thinking

**Question**: "How do you design pipelines that scale?"

**Strong Answer** (60 seconds):
> "Start by understanding current and projected volume—orders/day today vs. 10× growth scenario. Design patterns: Incremental processing (don't full-refresh 1TB daily), partitioning (by date for pruning), parallel processing (Airflow dynamic tasks, Spark for large datasets), and idempotency (so we can safely rerun). Infrastructure: Use auto-scaling (Snowflake elastic warehouses, Airflow Celery workers), separate workloads (BI queries on different warehouse than ETL), and monitoring (track query performance trends to catch degradation early). Test at scale—backfill 90 days to validate pipeline can handle volume spikes."

**Key Points**:
- Incremental patterns (not full refresh everything)
- Parallelization where appropriate
- Infrastructure elasticity
- Testing at volume

---

### Common Questions & Crisp Answers

**Q: "How do you handle schema changes from upstream sources?"**  
A: "Proactive communication (source teams notify 48hr advance), defensive handling (Bronze layer accepts any schema, Silver validates), schema tests in CI/CD, and incident runbooks for unannounced changes. If CDC breaks, backfill gap and post-mortem."

**Q: "How do you backfill data without breaking production?"**  
A: "Separate backfill DAG (not production DAG), run off-hours, use smaller warehouse (cost optimization), parallelize by date range, validate on small sample first, communicate to stakeholders (dashboards may be incomplete during backfill)."

**Q: "What's your experience with dbt?"**  
A: "Built [X] dbt models in [Y] project. Use staging → intermediate → marts structure, incremental models for large tables, built-in tests (unique, not null, relationships), and auto-generated docs. dbt tests run in CI/CD pipeline—block deployment if fail."

**Q: "How do you handle PII/sensitive data?"**  
A: "Minimize collection (only capture what's needed), encrypt at rest (S3 AES-256, Snowflake), mask in non-prod (dynamic data masking in Snowflake), access controls (RBAC, column-level security), audit logging (who accessed what), and GDPR deletion workflows (propagate deletes across all layers)."

**Q: "Biggest mistake you've made with data pipelines?"**  
A: "Deployed non-idempotent task to production—reran on failure and duplicated data, inflated metrics by 30%. Caught in daily reconciliation check. Fixed by adding UPSERT logic, backfilled correct data, added idempotency tests to CI/CD. Lesson: Always design for retries, test rerun scenarios before production."

---

## Pre-Interview Setup Checklist

### Technical Setup (Do This 24 Hours Before)

#### Option A: Docker Compose (Recommended)

```bash
# 1. Download official Airflow docker-compose.yml
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.7.0/docker-compose.yaml'

# 2. Initialize Airflow
mkdir -p ./dags ./logs ./plugins ./config
echo -e "AIRFLOW_UID=$(id -u)" > .env

# 3. Start Airflow
docker-compose up airflow-init
docker-compose up -d

# 4. Verify (wait 2-3 minutes for services to start)
open http://localhost:8080  # User: airflow, Pass: airflow

# 5. Test DAG deployment
cat > ./dags/test_dag.py << 'EOF'
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    'test_dag',
    start_date=datetime(2025, 1, 1),
    schedule_interval=None,
    catchup=False
) as dag:
    test = BashOperator(task_id='test', bash_command='echo "Airflow works!"')
EOF

# 6. Refresh Airflow UI, verify test_dag appears
```

**Troubleshooting**:
- Port 8080 already in use: Change `docker-compose.yaml` line `"8080:8080"` to `"8081:8080"`
- Docker not starting: Increase Docker Desktop memory to 4GB minimum
- DAG not appearing: Check `./dags` folder path, restart scheduler: `docker-compose restart airflow-scheduler`

#### Option B: Local Python (If Docker Issues)

```bash
# 1. Create virtual environment
python3 -m venv airflow_venv
source airflow_venv/bin/activate

# 2. Install Airflow
export AIRFLOW_HOME=$(pwd)/airflow
pip install "apache-airflow==2.7.0" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.7.0/constraints-3.10.txt"

# 3. Initialize database
airflow db init

# 4. Create admin user
airflow users create \
    --username admin \
    --password admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com

# 5. Start services (two terminals)
# Terminal 1:
airflow webserver --port 8080

# Terminal 2:
airflow scheduler

# 6. Verify
open http://localhost:8080  # User: admin, Pass: admin
```

### Environment Verification

**Test These Before Interview**:

1. **Airflow UI loads**: `http://localhost:8080`
2. **Can trigger DAG**: Create test DAG, click "Trigger DAG", see it run
3. **Can view logs**: Click task → Logs → see output
4. **Can edit DAG**: Modify test_dag.py, refresh UI (may take 30-60s)
5. **IDE ready**: VS Code or PyCharm open, test_dag.py editable

### Tools/Links to Have Ready

- **draw.io**: https://app.diagrams.net/ (or download desktop app)
- **Airflow UI**: http://localhost:8080 (open, logged in)
- **IDE**: VS Code/PyCharm with `/dags` folder open
- **Terminal**: Ready to run `docker-compose restart airflow-scheduler` if needed
- **Browser tabs**: Airflow docs (https://airflow.apache.org/docs/), Python docs

### Materials to Have Open

- **This prep guide**: Quick reference during interview (have it open on second monitor if possible)
- **Blank notepad**: For jotting down requirements during architecture discussion
- **Water/coffee**: Stay hydrated and alert

---

## Day-of Strategy

### Time Management by Section

**Section 1: Architecture (40 min)**
- 0-5 min: Ask clarifying questions, understand requirements
- 5-15 min: Draw operational ERD, explain normalization
- 15-30 min: Evolve to dimensional model, explain star schema
- 30-40 min: Zoom out to full architecture, discuss tech choices

**Section 2: Debugging (30 min)**
- 0-5 min: Read entire DAG, understand structure
- 5-15 min: Identify issues systematically (retries, idempotency, etc.)
- 15-25 min: Fix issues, explain reasoning
- 25-30 min: Test in Airflow, show logs

**Section 3: Design Strategy (20 min)**
- Answer questions with real examples (STAR format)
- Be concise (60-90 sec per answer, not 5-min monologues)
- Ask clarifying questions if needed
- Relate to their business (e-commerce context)

### Communication Tips

**Do**:
✅ Think aloud: "Let me think about the entities we need..."  
✅ Ask questions: "Should I optimize for real-time or is batch okay?"  
✅ Admit unknowns: "I haven't used X in production, but here's how I'd approach it"  
✅ Draw parallels: "This is similar to a project where I..."  
✅ Show tradeoffs: "Option A is simpler, but Option B scales better"  

**Don't**:
❌ Silent thinking (they can't see your thought process)  
❌ Jump to solution (ask questions first)  
❌ Overconfident: "This is the only way" (no nuance)  
❌ Blame others: "My last team did it wrong" (shows poor collaboration)  
❌ Ramble: Keep answers focused (90 sec max per question)  

### If You Get Stuck

**Architecture section**:
> "Let me step back and make sure I understand the requirements. Can you clarify [specific aspect]?"

**Debugging section**:
> "I'm looking at [specific code section]. Let me trace through what happens on execution vs. retry."

**Strategy section**:
> "That's a great question. In my last role, we approached this by [example]. Is that the kind of approach you're asking about?"

### Confidence Boosters

- They want you to succeed (collaborative, not adversarial)
- They value process over perfection (thinking > final answer)
- It's okay to ask questions (shows you clarify requirements, like in real work)
- Your experience is valuable (you've built real pipelines)

---

## Final 24-Hour Checklist

### Technical (Do Today)

- [ ] Airflow running locally (Docker or venv)
- [ ] Test DAG deployed and runnable
- [ ] IDE open with `/dags` folder
- [ ] draw.io tested (can draw and share screen)
- [ ] Internet stable (test Zoom call with friend)

### Preparation (Do Today)

- [ ] Review this prep guide (focus on anti-patterns section)
- [ ] Practice 1 architecture scenario (time yourself: 35 min)
- [ ] Review 5 Airflow anti-patterns (idempotency, retries, etc.)
- [ ] Prepare 2 STAR stories (incidents, projects)
- [ ] Review unybrands business (e-commerce aggregator, multi-brand)

### Day-of (Do Tomorrow Morning)

- [ ] Light review (don't cram)
- [ ] Test Airflow one more time (start Docker, verify UI)
- [ ] Close unnecessary browser tabs (reduce distractions)
- [ ] Water/coffee ready
- [ ] Join 5 min early (test audio/video)

---

## Company Context: unybrands

**Business Model**: E-commerce brand aggregator (acquires and scales DTC brands)  
**Data needs**:
- Multi-brand analytics (compare performance across brands)
- E-commerce metrics (GMV, CAC, LTV, inventory turnover)
- Channel attribution (Amazon, Shopify, own site)
- Supply chain optimization (procurement, fulfillment)

**Likely pain points** (frame your answers around these):
- Data silos (each brand has different systems)
- Inconsistent metrics (revenue calculated differently per brand)
- Slow time-to-insight (manual reporting vs automated dashboards)
- Scalability (adding new brands shouldn't require re-architecting)

**Your value prop**:
> "I've built scalable data pipelines that consolidate multi-source data, standardize metrics, and enable self-service analytics—exactly what you need for multi-brand operations."

---

## Good Luck! 🚀

**Remember**:
- Think aloud (show your process)
- Ask questions (clarify requirements)
- Be practical (production-focused, not academic)
- Show experience (real examples, not theory)
- Stay calm (they want you to succeed)

**You've got this!** Your experience with data platforms, Airflow, and production systems will shine through. Be yourself, be thoughtful, and communicate clearly.

---

**Questions? Concerns?**

If you have setup issues or need clarification on any section, reach out to the interviewers early. They want you prepared and set up for success.


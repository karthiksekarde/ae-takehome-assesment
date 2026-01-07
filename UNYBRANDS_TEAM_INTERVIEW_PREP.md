# Unybrands Team Interview Prep: Data Foundations Strategy

## Interview Context

**Meeting With**:
- **Ayo** - Tableau Developer (BI/Analytics focus)
- **Maria** - Senior Product Manager (Product analytics, business impact)

**Your Position**: Senior Data Engineer with leadership mandate to establish data foundations

**Key Message**: "I'm here to build the platform that empowers you both to move faster, make better decisions, and scale with confidence."

---

## Your Value Proposition (30-Second Pitch)

> "In my 13 years building data platforms—most recently scaling a team from 2 to 13 at Immo Capital—I've learned that great data foundations aren't just about technology. They're about enabling people like you, Ayo, to build dashboards without waiting weeks for data, and you, Maria, to validate product hypotheses in hours, not days. I've built real-time pipelines processing millions of events, governed platforms with dbt and Snowflake, and most importantly, created self-service environments where analysts and PMs become autonomous. That's what I want to bring to unybrands—a foundation that scales with your multi-brand growth and turns data into your competitive advantage."

---

## Part 1: Understanding Your Needs (Questions to Ask)

### For Ayo (Tableau Developer)

**Current State Questions**:
1. "What's your biggest pain point with data access today?" (Likely: stale data, slow queries, unclear definitions)
2. "How long does it typically take from 'I need this data' to 'dashboard is live'?" (Baseline for improvement)
3. "Are you working directly with raw databases or is there a warehouse layer?" (Understand current architecture)
4. "What's your experience with data modeling—do you define metrics in Tableau or is there a semantic layer?" (Understand if they need governed definitions)
5. "What percentage of your time is spent on data wrangling vs actual visualization?" (Quantify inefficiency)

**Future State Questions**:
1. "If you could wave a magic wand, what would your ideal data platform look like?"
2. "What dashboards do stakeholders ask for most frequently?" (Identify common patterns to standardize)
3. "How do you currently handle multi-brand comparisons?" (Unybrands-specific challenge)

**Collaboration Questions**:
1. "How do you prefer to collaborate with data engineers—Slack, JIRA tickets, weekly syncs?"
2. "What documentation do you wish existed but doesn't?" (Data dictionary, lineage, definitions)

---

### For Maria (Senior Product Manager)

**Current State Questions**:
1. "What product questions can you answer quickly today vs. what requires custom analysis?" (Identify gaps)
2. "How do you currently measure product success—what are your North Star metrics?" (Understand their framework)
3. "What's the lag time between a product launch and having reliable data about its performance?" (Baseline for real-time needs)
4. "What decisions have you had to delay or make with incomplete data?" (Pain point identification)
5. "How do you currently track user behavior across brands/channels?" (Multi-brand complexity)

**Data-Driven Product Questions**:
1. "What experiments or A/B tests are you running? How do you analyze results?" (Experimentation maturity)
2. "What product hypotheses do you want to test but can't with current data?" (Unmet needs)
3. "How do stakeholders (CEO, CPO) typically consume product insights—dashboards, reports, Slack bots?" (Delivery preferences)

**Future Vision Questions**:
1. "If data were never a bottleneck, what would you build or test first?"
2. "What self-service capabilities would make you 10× more effective?"

---

## Part 2: Your Vision for Data Foundations at Unybrands

### The 3-Pillar Foundation

```
┌──────────────────────────────────────────────────────────────────┐
│                    UNYBRANDS DATA PLATFORM                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  PILLAR 1              PILLAR 2              PILLAR 3             │
│  Reliable              Self-Service          Actionable           │
│  Infrastructure        Analytics             Insights             │
│                                                                    │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
│  │ • Single     │     │ • Governed   │     │ • Real-time  │    │
│  │   source of  │     │   metrics    │     │   product    │    │
│  │   truth      │     │ • Self-serve │     │   analytics  │    │
│  │              │     │   dashboards │     │              │    │
│  │ • <1hr data  │     │ • Data       │     │ • Experiment │    │
│  │   freshness  │     │   catalog    │     │   framework  │    │
│  │              │     │              │     │              │    │
│  │ • 99.5%      │     │ • Pre-built  │     │ • Multi-brand│    │
│  │   pipeline   │     │   templates  │     │   benchmarks │    │
│  │   reliability│     │              │     │              │    │
│  └──────────────┘     └──────────────┘     └──────────────┘    │
│                                                                    │
│  ENABLES:              ENABLES:              ENABLES:             │
│  Trust in data         Ayo's autonomy        Maria's velocity     │
└──────────────────────────────────────────────────────────────────┘
```

---

### Pillar 1: Reliable Infrastructure (Foundation)

**What It Means**:
- Single source of truth for all business metrics (no more "which number is right?")
- Data arrives on time, every time (<1 hour batch, <15 min real-time)
- 99.5%+ pipeline reliability with automatic retries and alerting
- Clear data lineage from source → warehouse → dashboard

**How I'll Build It** (First 90 Days):

**Phase 1: Assessment & Quick Wins (Weeks 1-4)**
```
Week 1: Discovery
├── Interview 10 stakeholders (Ayo, Maria, finance, ops, brand managers)
├── Map current data sources (Shopify, Amazon SP-API, internal DBs, 3PLs)
├── Identify top 5 pain points (stale data? missing data? conflicting definitions?)
└── Document current architecture (where does data live today?)

Week 2: Quick Wins
├── Fix top 3 data quality issues (e.g., missing order timestamps, duplicate SKUs)
├── Create data freshness dashboard (how stale is each table?)
└── Set up basic alerting (pipeline failures, data delays)

Week 3-4: Foundation Setup
├── Deploy Snowflake (if not exists) or optimize existing warehouse
├── Set up Airflow/MWAA for orchestration
├── Implement Bronze layer (raw data landing zone in S3)
└── Begin dbt project structure (staging → marts)
```

**Key Deliverable for Ayo**:
> "Within 30 days, you'll have a data freshness dashboard showing when each table was last updated. No more guessing if data is stale."

**Key Deliverable for Maria**:
> "Within 30 days, I'll publish a data catalog documenting all key product metrics—definitions, sources, and owners. One source of truth."

---

### Pillar 2: Self-Service Analytics (Empowerment)

**What It Means**:
- Ayo can build dashboards without waiting for engineering (self-serve data models)
- Maria can answer "How many users converted yesterday?" without filing a ticket
- Governed metrics ensure everyone uses the same definitions (no "revenue" confusion)
- Pre-built dashboard templates for common use cases

**How I'll Enable This**:

**For Ayo (Tableau Developer)**:

**1. Governed Semantic Layer (dbt Metrics + Tableau)**
```sql
-- Example: dbt metric definition
metrics:
  - name: daily_active_users
    label: Daily Active Users (DAU)
    model: ref('fct_user_activity')
    calculation_method: count_distinct
    expression: user_id
    timestamp: activity_date
    dimensions:
      - brand
      - channel
      - user_segment
```

**Benefits for Ayo**:
- Metrics defined once in dbt, used everywhere (Tableau, Looker, SQL)
- No more "which SQL should I use for DAU?"
- Automatic aggregation logic (daily → weekly → monthly rollups)
- Version-controlled (see history of metric changes)

**2. Pre-Modeled Data Marts (Star Schema)**
```
Gold Layer (Optimized for Tableau):
├── fct_orders (grain: one row per order line)
│   ├── Pre-joined dimensions (no complex joins needed)
│   ├── Pre-calculated metrics (revenue, profit, discount%)
│   └── Clustered on order_date (fast date filters)
│
├── fct_user_activity (grain: user-day)
│   ├── Daily active users, sessions, page views
│   └── Pre-aggregated for dashboard performance
│
├── dim_product (slowly changing dimension)
│   ├── Product hierarchy (brand → category → SKU)
│   └── Current and historical attributes (price changes tracked)
│
└── dim_customer (slowly changing dimension)
    ├── Customer segment (Bronze → Silver → Gold)
    └── Lifetime value, cohort, acquisition channel
```

**What This Means for Ayo**:
> "Instead of writing complex SQL to join 5 tables, you'll connect Tableau to `fct_orders` and drag-and-drop. Queries will be 10× faster because data is pre-joined and clustered."

**3. Tableau Best Practices & Templates**

**Starter Dashboards I'll Build**:
- **Executive Dashboard**: Revenue, orders, GMV by brand (refreshes hourly)
- **Brand Performance**: Compare all brands side-by-side (normalized metrics)
- **Product Analytics**: Top SKUs, inventory turnover, out-of-stock rate
- **Customer Cohorts**: Retention curves, LTV by acquisition channel

**Collaboration Model with Ayo**:
- **Weekly Sync**: "What dashboards are you building? What data do you need?"
- **Office Hours**: 2 hours/week for ad-hoc data questions
- **Slack Channel**: `#data-requests` for quick answers (<30 min response SLA)
- **Quarterly Dashboard Review**: Deprecate unused, optimize slow queries

---

**For Maria (Product Manager)**:

**1. Product Analytics Self-Service**

**Funnel Analysis Template**:
```sql
-- Pre-built funnel model (Maria can customize in Tableau)
SELECT 
    cohort_date,
    brand,
    COUNT(DISTINCT CASE WHEN step = 'visit' THEN user_id END) as visitors,
    COUNT(DISTINCT CASE WHEN step = 'add_to_cart' THEN user_id END) as added_cart,
    COUNT(DISTINCT CASE WHEN step = 'checkout' THEN user_id END) as checkouts,
    COUNT(DISTINCT CASE WHEN step = 'purchase' THEN user_id END) as purchases,
    -- Conversion rates pre-calculated
    added_cart * 100.0 / NULLIF(visitors, 0) as visit_to_cart_rate,
    purchases * 100.0 / NULLIF(visitors, 0) as visit_to_purchase_rate
FROM fct_user_funnel
GROUP BY cohort_date, brand;
```

**What This Means for Maria**:
> "Instead of asking engineering to calculate funnel conversion rates, you'll have a live dashboard showing daily conversion by brand. Filter by date, segment, or channel—no code required."

**2. Experimentation Framework**

```python
# A/B Test Analysis Template (Jupyter Notebook)
def analyze_experiment(experiment_id):
    """
    Maria can run this notebook to analyze any A/B test
    - Calculates statistical significance
    - Shows conversion lift
    - Generates summary report
    """
    control = get_variant_metrics(experiment_id, 'control')
    treatment = get_variant_metrics(experiment_id, 'treatment')
    
    results = {
        'sample_size': {'control': len(control), 'treatment': len(treatment)},
        'conversion_rate': {
            'control': control['converted'].mean(),
            'treatment': treatment['converted'].mean()
        },
        'lift': calculate_lift(control, treatment),
        'p_value': ttest(control['converted'], treatment['converted']),
        'confidence': 'High' if p_value < 0.05 else 'Low'
    }
    
    return generate_report(results)
```

**What This Means for Maria**:
> "When you launch an A/B test, you'll get a Jupyter notebook template to analyze results yourself. No waiting for data science team. Results in minutes, not days."

**3. Product Metrics Dashboard (Real-Time)**

**North Star Metrics I'll Instrument**:
- **Activation**: % users who complete onboarding within 7 days
- **Engagement**: DAU/MAU ratio, sessions per user, time spent
- **Retention**: Day 1, Day 7, Day 30 cohort retention
- **Revenue**: ARPU, LTV, payback period
- **Growth**: New users by channel, viral coefficient

**Delivery**: Live Tableau dashboard, updates every 15 minutes

---

### Pillar 3: Actionable Insights (Business Impact)

**What It Means**:
- Data doesn't just sit in dashboards—it drives decisions
- Proactive alerts ("Your conversion rate dropped 20% today—investigate")
- Benchmarking across brands ("Brand X is 30% more profitable than Brand Y—why?")
- Predictive analytics (inventory stockout prediction, churn risk scoring)

**How I'll Deliver This**:

**1. Automated Insights & Alerts (For Maria)**

**Example: Daily Product Health Report (Slack Bot)**
```
🤖 Daily Product Report - Jan 6, 2025

📈 Highlights:
• DAU increased 12% vs yesterday (14.5K → 16.2K)
• Checkout conversion up 3% (4.2% → 4.3%)
• Revenue: $487K (+8% vs last Monday)

⚠️  Attention Needed:
• Brand "HomeGlow" conversion dropped 15% (investigate landing page?)
• iOS app crashes spiked 40% (talk to eng team?)
• 3 SKUs at <10% stock level (reorder: SKU-123, SKU-456, SKU-789)

🎯 This Week's Focus:
• New onboarding flow: 450 users enrolled, 62% completion rate
• Pricing experiment results ready (click link to analyze)
```

**How This Helps Maria**:
> "Every morning, you'll get a Slack summary of what matters. No more sifting through dashboards to find anomalies—the system tells you where to focus."

**2. Multi-Brand Benchmarking (For Leadership)**

**Brand Performance Scorecard**:
```sql
-- Compare all brands on key metrics
SELECT 
    brand,
    -- Efficiency metrics
    ROUND(revenue / marketing_spend, 2) as roas,
    ROUND(gross_profit_margin * 100, 1) as margin_pct,
    -- Growth metrics
    ROUND((mtd_revenue - mtd_revenue_ly) / mtd_revenue_ly * 100, 1) as revenue_growth_yoy,
    -- Operational metrics
    ROUND(avg_fulfillment_days, 1) as avg_ship_days,
    inventory_turnover_ratio,
    -- Customer metrics
    ROUND(customer_lifetime_value, 0) as ltv,
    ROUND(customer_acquisition_cost, 0) as cac,
    ROUND(ltv / cac, 2) as ltv_cac_ratio
FROM brand_scorecard
ORDER BY revenue DESC;
```

**Output**: Executive dashboard showing "Winners" and "Improvement Opportunities"

**3. Predictive Analytics (90-Day Roadmap)**

**Phase 1: Descriptive** (What happened?)
- Historical dashboards, trend analysis

**Phase 2: Diagnostic** (Why did it happen?)
- Automated root cause analysis (e.g., "Revenue dropped because Brand X had inventory issues")

**Phase 3: Predictive** (What will happen?)
- Inventory stockout prediction (30-day forecast)
- Customer churn prediction (high-risk customers for retention campaigns)
- Demand forecasting (how many units to order per SKU)

**Phase 4: Prescriptive** (What should we do?)
- Recommended actions (e.g., "Increase spend on Facebook for Brand Y—ROI is 4.2×")

---

## Part 3: Your Leadership Approach

### How You'll Work with the Team

**Ayo (Tableau Developer) - Your Analytics Partner**

**Relationship Model**:
```
You (Senior Data Engineer)          Ayo (Tableau Developer)
│                                    │
│ ✓ Build data models               │ ✓ Build dashboards
│ ✓ Define metrics (dbt)            │ ✓ Design visualizations
│ ✓ Optimize query performance      │ ✓ Train business users
│ ✓ Data quality & governance       │ ✓ Ad-hoc analysis
│                                    │
└────────── Collaborate ─────────────┘
        Weekly sync, shared backlog
```

**Your Commitments to Ayo**:
1. **No Blockers**: "If you need data, I'll get it to you within 48 hours (or explain why it takes longer)"
2. **Consultation**: "I'll review your Tableau workbooks for performance issues—let's keep dashboards <5 sec load time"
3. **Enablement**: "I'll teach you enough SQL/dbt so you can modify models yourself for simple changes"
4. **Recognition**: "When stakeholders praise dashboards, I'll make sure you get credit—you're the face of analytics"

**How You'll Collaborate**:
- **Weekly 1:1**: Review upcoming dashboards, discuss data needs
- **Quarterly Planning**: Align on analytics roadmap (what to build next)
- **On-Demand Pairing**: "Complex SQL query? Let's pair program for 30 min"

---

**Maria (Product Manager) - Your Business Partner**

**Relationship Model**:
```
You (Senior Data Engineer)          Maria (Product Manager)
│                                    │
│ ✓ Instrument product events       │ ✓ Define success metrics
│ ✓ Build product analytics         │ ✓ Run experiments
│ ✓ Enable self-service             │ ✓ Interpret data
│ ✓ Measure impact                  │ ✓ Drive product roadmap
│                                    │
└────────── Collaborate ─────────────┘
     Partner on product decisions
```

**Your Commitments to Maria**:
1. **Speed**: "You'll have product data within hours of launch, not weeks"
2. **Autonomy**: "You won't need to file tickets for basic analysis—self-service dashboards and notebooks"
3. **Insight**: "I'll proactively flag anomalies—you'll know about problems before stakeholders ask"
4. **Partnership**: "Your product roadmap informs my data roadmap—we align quarterly"

**How You'll Collaborate**:
- **Product Launches**: "I'll attend your product kickoffs to understand what to instrument"
- **Weekly Metrics Review**: "Let's review North Star metrics together—I'll explain what data shows"
- **Experiment Design**: "Before launching A/B tests, let's ensure tracking is set up correctly"
- **OKR Alignment**: "Your product OKRs become my data platform OKRs—we win together"

---

### Your Leadership Philosophy (Share This in Interview)

**1. Servant Leadership**
> "My job as a senior data engineer isn't to be the smartest person in the room—it's to make you both smarter and faster. I succeed when Ayo builds dashboards without me, and Maria validates product hypotheses in real-time."

**2. Bias Toward Action**
> "I've learned that perfect is the enemy of good. I'd rather ship a 'good enough' dashboard this week and iterate, than spend a month building the 'perfect' solution. Let's move fast and improve continuously."

**3. Transparent Communication**
> "If you ask for data and I can't deliver in 48 hours, I'll tell you why and what alternatives we have. No black box—I'll explain tradeoffs and let you decide priorities."

**4. Data Quality is Non-Negotiable**
> "A dashboard that shows wrong data is worse than no dashboard. I'll build automated tests, reconciliation checks, and alerts to ensure we catch issues before stakeholders do."

**5. Scale Through Systems, Not Heroics**
> "I don't want to be the bottleneck. I'll build self-service tools, documentation, and templates so you can move independently. The platform should work even when I'm on vacation."

---

## Part 4: 90-Day Roadmap (What They Can Expect)

### Month 1: Foundation & Quick Wins

**Week 1: Discovery**
- Interview Ayo, Maria, and 8 other stakeholders
- Map current data landscape (sources, tools, pain points)
- Identify top 5 quick wins

**Deliverable**: One-pager summarizing findings + 90-day roadmap

**Week 2-3: Infrastructure Setup**
- Deploy core platform (Airflow, Snowflake, dbt)
- Set up Bronze layer (raw data landing zone)
- Implement basic monitoring (data freshness, pipeline success rate)

**Deliverable**: Data platform health dashboard

**Week 4: Quick Wins**
- Fix top 3 data quality issues (e.g., missing timestamps, duplicates)
- Create data dictionary for 10 most-used tables
- Build first governed dbt mart (e.g., `fct_orders`)

**Deliverables for Ayo**: Data freshness dashboard  
**Deliverables for Maria**: Product metrics definition document

---

### Month 2: Self-Service Enablement

**Week 5-6: dbt Marts Development**
- Build core dimensional models (orders, products, customers, activity)
- Implement SCD Type 2 for customer/product history
- Add dbt tests (unique keys, not null, referential integrity)

**Deliverable**: 5 production-ready data marts

**Week 7: Tableau Optimization**
- Work with Ayo to migrate top 3 dashboards to new marts
- Optimize slow queries (clustering, materialized views)
- Create Tableau dashboard templates

**Deliverables for Ayo**: 
- 3 optimized dashboards (3× faster load times)
- Dashboard template library

**Week 8: Product Analytics**
- Build product event tracking (if not exists)
- Create user funnel model (visit → cart → checkout → purchase)
- Set up experimentation framework (A/B test analysis)

**Deliverables for Maria**:
- Product metrics dashboard (DAU, retention, conversion)
- A/B test analysis notebook

---

### Month 3: Advanced Analytics & Automation

**Week 9-10: Real-Time Pipelines**
- Set up event streaming (Kafka/MSK if needed)
- Build real-time aggregations (user activity, order volume)
- Reduce data latency from hours to <15 minutes

**Deliverable**: Real-time dashboards (15-min refresh)

**Week 11: Automated Insights**
- Build anomaly detection (alert if metrics drop >20%)
- Create daily Slack report (automated insights)
- Implement brand benchmarking scorecard

**Deliverables for Maria**: Daily product health report (Slack bot)  
**Deliverables for Leadership**: Multi-brand comparison dashboard

**Week 12: Documentation & Training**
- Complete data catalog (all tables documented)
- Host training sessions (SQL for PMs, dbt for analysts)
- Publish self-service guide ("How to answer common questions")

**Deliverable**: Data platform documentation site

---

### Success Metrics (How You'll Measure Impact)

**For Ayo (BI Efficiency)**:
- ⏱️ **Dashboard build time**: 3 days → <1 day (67% reduction)
- 🚀 **Query performance**: 30 sec → <5 sec (83% improvement)
- 📊 **Dashboard refresh rate**: Daily → Hourly (15× faster)
- 🔧 **Data requests to data eng**: 10/week → <2/week (80% reduction via self-service)

**For Maria (Product Velocity)**:
- ⚡ **Time to product insights**: 3 days → <4 hours (90% reduction)
- 🧪 **A/B test analysis time**: 1 day → 30 min (95% reduction)
- 📈 **Product metrics coverage**: 60% → 95% (more complete instrumentation)
- 🎯 **Self-service rate**: Maria can answer 80% of questions without filing tickets

**For Business (Overall Impact)**:
- ✅ **Data trust**: 70% → 95% (stakeholders trust dashboards)
- 🔄 **Pipeline reliability**: 90% → 99.5% (fewer data incidents)
- 💰 **Cost efficiency**: Optimize Snowflake spend (20% reduction)
- 🚀 **Time to insight**: 1 week → <1 day (7× faster)

---

## Part 5: Addressing Likely Concerns

### "How will you prioritize with limited resources?"

**Your Answer**:
> "Great question. I use the RICE framework: Reach × Impact × Confidence ÷ Effort. In the first month, I'll interview 10 stakeholders to understand pain points, then score each potential project. Example: If Ayo needs a specific dashboard that impacts 50 users daily (Reach), would save 2 hours/week (Impact), I'm 90% confident I can deliver (Confidence), and it takes 3 days (Effort)—that gets a RICE score of (50 × 2 × 0.9) / 3 = 30. I'll maintain a shared backlog with you both, review weekly, and re-prioritize as business needs shift. Transparency is key—if I have to say no to something, I'll explain why and what we're doing instead."

---

### "What if we disagree on priorities?"

**Your Answer**:
> "Healthy disagreement is good—it means we care. Here's how I handle it: First, I'll make sure I understand your 'why'—what business outcome are you trying to achieve? Often, there's a faster path to the same outcome. Second, if we still disagree, I'll escalate to our shared manager with data: 'Option A delivers X value in Y time, Option B delivers Z value in W time—what's more important given our OKRs?' Finally, I commit to the decision 100% once made, even if it wasn't my preference. I've learned that executing a 'good' decision quickly beats debating for the 'perfect' decision."

---

### "How technical do we need to be to work with you?"

**Your Answer (to Ayo)**:
> "Ayo, you already know SQL and Tableau—that's 80% of what you need. I'll teach you enough dbt so you can tweak models yourself (add a column, change a filter), but I'll handle the complex stuff (incremental models, performance tuning). If you ever get stuck, ping me on Slack—I commit to <30 min response time during work hours."

**Your Answer (to Maria)**:
> "Maria, you don't need to write code. I'll give you tools—dashboards, notebooks with pre-written analysis, Slack bots—that you can use without SQL. But if you want to learn SQL for ad-hoc queries, I'm happy to teach you the basics. Many great PMs I've worked with can write simple SELECT statements, and it makes them 10× faster."

---

### "What if something breaks in production?"

**Your Answer**:
> "When (not if) something breaks—because it will—here's my approach: First, I'll have monitoring and alerts in place so we catch issues before stakeholders do. Second, I'll build runbooks for common failures ('Dashboard stale? Check these 3 things'). Third, I'll be on-call during business hours—if you Slack me that a dashboard is wrong, I'll acknowledge within 15 minutes and triage. Fourth, every incident gets a blameless post-mortem: what happened, why, how we prevent it next time. I've handled midnight production fires at Immo Capital—I stay calm, communicate clearly, and fix fast."

---

## Part 6: Stories to Share (STAR Format)

### Story 1: Enabling Self-Service Analytics (For Ayo)

**Situation**: At Immo Capital, our BI team was drowning in ad-hoc SQL requests. Analysts spent 60% of time writing queries, 40% on analysis.

**Task**: My goal was to flip that ratio—make analysts self-sufficient so they spend 80% of time on insights.

**Action**: 
1. Built governed dbt marts with pre-joined dimensions (no complex SQL needed)
2. Created Tableau Accelerators—dashboard templates for common use cases
3. Defined metrics in dbt (one definition, used everywhere)
4. Hosted weekly "SQL Office Hours" for training

**Result**: 
- Ad-hoc data requests dropped 70% (10/week → 3/week)
- Dashboard build time reduced from 5 days to <1 day
- BI team satisfaction score increased from 6.5 → 9.2 (out of 10)
- Quote from analyst: "I can now answer questions in minutes that used to take days"

**Lesson**: Enablement beats heroics. Give people tools and training, and they'll amaze you.

---

### Story 2: Real-Time Product Analytics (For Maria)

**Situation**: At Immo Capital (B2C real estate), product team couldn't see user behavior in real-time. They'd launch features and wait 24 hours for data—too slow for rapid iteration.

**Task**: Build real-time product analytics to enable same-day iteration on product launches.

**Action**:
1. Implemented event streaming (Kafka) for user actions (clicks, pageviews, conversions)
2. Built Spark Streaming aggregations (15-minute windows)
3. Created real-time dashboard showing DAU, conversion funnel, feature adoption
4. Set up anomaly alerts (e.g., "Conversion rate dropped 20%—investigate!")

**Result**:
- Data latency reduced from 24 hours → <15 minutes (95× faster)
- Product team could iterate same-day based on user behavior
- Caught 3 critical bugs within hours of launch (previously took days to detect)
- PM quote: "This changed how we build products—we're data-informed, not data-dependent"

**Lesson**: Real-time data enables real-time decision-making. Worth the investment for product teams.

---

### Story 3: Multi-Brand Data Unification (Relevant to Unybrands)

**Situation**: At Idealo (B2C price comparison), we had 15 partner integrations, each with different data schemas. Analytics team struggled with "Which field is 'price'? Gross or net?"

**Task**: Create unified data model that standardized metrics across all partners.

**Action**:
1. Built staging layer (dbt) that normalized each partner's schema
2. Created canonical data model with clear definitions (documented in data dictionary)
3. Implemented data quality tests (price must be >0, product_id must match catalog)
4. Built reconciliation jobs (compare our totals to partner reports—flag >1% variance)

**Result**:
- Reduced "data doesn't match" incidents from 8/month → <1/month (87% reduction)
- Analytics team could compare across partners without custom SQL
- Data quality score improved from 78% → 96%
- CFO trusted dashboard numbers enough to present to board

**Lesson for Unybrands**: Multi-brand aggregation is complex, but standardization + governance = trust.

---

## Part 7: Questions to Ask Them (Show Strategic Thinking)

### For Ayo

1. **"What's the one dashboard you wish existed but doesn't?"**  
   (Shows you care about their needs, gets insight into gaps)

2. **"How do you currently handle version control for Tableau workbooks?"**  
   (Shows you think about best practices, governance)

3. **"What's your biggest data quality frustration?"**  
   (Shows you prioritize quality, want to solve pain points)

4. **"If you could learn one new skill this year, what would it be?"**  
   (Shows you care about their growth, mentorship mindset)

---

### For Maria

1. **"What product decision did you wish you had data for, but didn't?"**  
   (Shows you want to enable better decisions, identifies gaps)

2. **"How do you currently measure success for product launches?"**  
   (Shows you think in product terms, want to align metrics)

3. **"What's your ideal time-to-insight after launching a feature?"**  
   (Shows you understand velocity matters, sets expectations)

4. **"If data were never a bottleneck, what experiments would you run?"**  
   (Shows you think big, want to enable innovation)

---

### For Both (End of Interview)

1. **"What does success look like for me in the first 90 days?"**  
   (Shows you want clarity on expectations)

2. **"What's the one thing I should know about working at unybrands that isn't obvious from the outside?"**  
   (Shows cultural awareness, genuine curiosity)

3. **"How do you see the data team evolving over the next year?"**  
   (Shows you think long-term, want to align with vision)

4. **"What questions do you have for me that I haven't addressed?"**  
   (Shows confidence, openness, collaboration)

---

## Part 8: Your Closing Statement (2 Minutes)

> "Ayo, Maria—thank you for your time today. I'm excited about what we could build together at unybrands. Let me leave you with this: In my 13 years building data platforms, I've learned that the best data teams aren't just technically excellent—they're deeply embedded with the business. 
>
> **For you, Ayo**: I want to be the data engineer who makes your job easier, not harder. My success is measured by how rarely you need me—because you have the right data models, the right documentation, and the right tools to move independently. I'll be your partner, not your gatekeeper.
>
> **For you, Maria**: I want to be the data engineer who accelerates your product velocity. When you have a hypothesis to test, I want you to have data within hours. When you launch a feature, I want real-time insights so you can iterate same-day. Data should enable speed, not slow you down.
>
> **For unybrands**: I see the opportunity to build something truly differentiated. Most e-commerce aggregators struggle with multi-brand data complexity—inconsistent metrics, siloed insights, slow decision-making. I've solved this before at Idealo with 15 partners. I know how to standardize without losing flexibility, how to govern without bureaucracy, and how to scale without breaking.
>
> I'm confident I can establish the data foundations that turn unybrands' multi-brand portfolio into a competitive advantage. And I'm excited to do it alongside talented people like you.
>
> What questions can I answer?"

---

## Final Prep Checklist

### Day Before Interview

- [ ] Review this entire document (30 min)
- [ ] Practice your 30-second pitch out loud (5 min)
- [ ] Review your CV—be ready to expand on Immo Capital, Penta, Idealo experiences (10 min)
- [ ] Prepare 3 STAR stories (self-service analytics, real-time pipelines, multi-brand unification) (15 min)
- [ ] Research unybrands—what brands do they own? Recent news? (10 min)
- [ ] Prepare questions to ask them (write down 5-8 questions) (5 min)

### Morning of Interview

- [ ] Light review (don't cram—you know this)
- [ ] Test Zoom audio/video
- [ ] Have water/coffee ready
- [ ] Close unnecessary tabs (minimize distractions)
- [ ] Join 5 min early

### During Interview

- [ ] Start with energy and enthusiasm (they want someone excited to join)
- [ ] Listen actively—take notes on what they say
- [ ] Ask clarifying questions (shows you think before answering)
- [ ] Use STAR format for stories (keep under 90 sec each)
- [ ] Relate everything to their needs (Ayo's autonomy, Maria's velocity)
- [ ] Close strong with your 2-minute statement

---

## Remember: You're Interviewing Them Too

**Green Flags** (good culture):
- They're transparent about challenges (not painting perfect picture)
- They ask about your past experiences (want to learn from you)
- They're collaborative in tone (not adversarial)
- They're excited about data foundations (not treating it as afterthought)

**Yellow Flags** (proceed with caution):
- Vague about current data state (might be worse than they admit)
- Unrealistic expectations ("Can you fix everything in 30 days?")
- No mention of budget/resources (might be under-resourced)
- Dismissive of governance ("We just need dashboards fast")

**Red Flags** (consider carefully):
- Blame previous person ("Last data engineer was terrible")
- No clear ownership ("Everyone does data here")
- No strategy, just tactics ("We need 50 dashboards")
- Expect you to work miracles alone (no team, no budget)

---

## You've Got This! 🚀

**Why You'll Succeed**:

✅ **Experience**: 13 years, scaled teams, built real-time pipelines  
✅ **Relevance**: Immo Capital (B2C), Idealo (multi-partner), perfect fit for unybrands  
✅ **Leadership**: You've done this before—you know how to enable teams  
✅ **Passion**: Your CV shows you care about quality, governance, enablement  
✅ **Communication**: You can talk business (Maria) and technical (Ayo)  

**Your Competitive Edge**: You're not just a data engineer—you're a data platform leader who enables business impact.

**Final Thought**: 
> They're not just hiring a senior data engineer. They're hiring someone to lay foundations that will scale unybrands from 5 brands to 50. Show them you're that person—strategic vision, tactical execution, and genuine care for enabling your teammates.

**Good luck! You're going to crush this interview.** 💪


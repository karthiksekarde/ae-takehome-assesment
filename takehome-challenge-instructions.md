## AE Take Home Exercise (Data Platform team)

**Overview**

The goal of this take home assignment is to develop a simple data system that alerts an
operational team when a customer’s financial balance changes by more than 50%. We
don’t expect you to build a production-grade system, but rather a simple framework that we can
discuss during a technical interview. We recommend the assignment should be completed
within 3 days.

On the Data Platform team at Deel, we value three things above all else.
1) Simple code
2) Reliable outputs
3) Efficient use of compute

**Things to consider:**

- Many lines of code or a complex solution won’t impress us. Instead we are looking for a
solution that is simple, reliable, and efficient.

- It is not necessary to use DBT or Snowflake for this exercise, but it is also totally fine to
use those tools. Use whatever you want to get the job done.

- Note that we will ask technical questions about both DBT core and cloud databases, so
hands-on experience will be necessary.

- Finally, feel free to ChatGPT solutions or whatever your normal workflow is. You will be
expected to explain and dissect your code in an interview, so don’t submit anything that
you don’t understand.

**Raw Datasets (in csv format)**
- Organizations
- Invoices

**Desired Output**

A Github repository with the following outputs (feel free to commit additional supporting code,
but the below is what we will primarily evaluate).

1. Dimension table for organizations enriched with important information
2. Fact table at date / organization_id granularity
3. Tests to ensure data quality is accurate
4. A function that, when called, sends an alert message to your local console if a daily
financial account balance changes by more than 50% day over day. This should only
look at new days.
a. If you are familiar with the Slack API, feel free to send an alert message via Slack
instead. But not a requirement for this exercise.
b. Feel free to use a workflow tool like Airflow to do this or write from scratch in your
preferred language (ie Python, Javascript, etc)
c. Simplicity is preferred

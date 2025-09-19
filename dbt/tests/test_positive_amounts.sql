-- test that payment amounts are positive (after our filtering)
select *
from {{ ref('stg_invoices') }}
where payment_amount is not null and payment_amount <= 0

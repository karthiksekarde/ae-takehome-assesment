-- test that fact_balance has data
select count(*) as row_count
from {{ ref('fact_balance') }}
having count(*) = 0

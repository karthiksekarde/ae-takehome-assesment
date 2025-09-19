-- test that invoice status only has expected values
select *
from {{ ref('stg_invoices') }}
where status not in ('paid', 'skipped', 'cancelled', 'open', 'credited', 'pending', 'failed', 'processing', 'refunded', 'unpayable', 'awaiting_payment')

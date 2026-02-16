---> set Role
USE ROLE accountadmin;
---> set Warehouse
USE WAREHOUSE compute_wh;

CREATE OR REPLACE DATABASE raw;
CREATE OR REPLACE DATABASE analytics;
CREATE OR REPLACE SCHEMA raw.stripe;
CREATE OR REPLACE SCHEMA raw.jaffle_shop;


CREATE OR REPLACE TABLE raw.jaffle_shop.customers
(
id integer,
first_name varchar,
last_name varchar
);

CREATE OR REPLACE TABLE raw.jaffle_shop.orders
(
id integer,
user_id integer,
order_date date,
status varchar,
_etl_loaded_at timestamp_ltz default current_timestamp()
);

CREATE OR REPLACE TABLE raw.stripe.payments
(
id integer,
orderid integer,
paymentmethod varchar,
status varchar,
amount integer,
created date,
_batched_at timestamp_ltz default current_timestamp()
);

CREATE OR REPLACE STAGE raw.public.loading
URL = 'azure://wennandbt.blob.core.windows.net/jaffle-shop/'
credentials = (azure_sas_token = 'sp=rl&st=2026-02-16T02:07:06Z&se=2026-03-16T10:22:06Z&spr=https&sv=2024-11-04&sr=c&sig=YpNC0GgbLIIphIuQaxkyYOAmg4fpy1xRZr5qgISGlf8%3D')
file_format = (
type = CSV
field_delimiter = ','
skip_header = 1
);


COPY INTO raw.jaffle_shop.customers
(
id,
first_name,
last_name
)
from @raw.public.loading/customers/
files = ('jaffle_shop_customers.csv');

COPY INTO raw.jaffle_shop.orders
(
id,
user_id,
order_date,
status
)
from @raw.public.loading/orders/
files = ('jaffle_shop_orders.csv');

COPY INTO raw.stripe.payments
(
id,
orderid,
paymentmethod,
status,
amount,
created
)
from @raw.public.loading/payments/
files = ('stripe_payments.csv');


INSERT INTO raw.jaffle_shop.orders
(
id,
user_id,
order_date,
status
)
values
(100, 100, '2025-02-15', 'shipped'),
(101, 84,  '2025-02-15', 'shipped'),
(102, 42,  '2025-02-15', 'shipped'),
(103, 101, '2025-02-15', 'shipped'),
(104, 66,  '2025-02-15', 'shipped');


INSERT INTO raw.jaffle_shop.customers
(
id,
first_name,
last_name
)
values
(101, 'Michelle', 'B.'),
(102, 'Faith',    'L.');


INSERT INTO raw.stripe.payments
(
id,
orderid,
paymentmethod,
status,
amount,
created
)
values
(121, 100, 'bank_transfer', 'success', 1000, '2025-02-14'),
(122, 101, 'credit_card',   'fail',     400, '2025-02-14'),
(123, 102, 'credit_card',   'success', 1900, '2025-02-14'),
(124, 103, 'credit_card',   'success', 1000, '2025-02-15'),
(125, 104, 'coupon',        'success',  100, '2025-02-15');


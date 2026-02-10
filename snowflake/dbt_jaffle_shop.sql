create or replace warehouse transforming;
create or replace database analytics;
create or replace database raw;
create or replace schema raw.jaffle_shop;
create or replace schema raw.stripe;

create table raw.jaffle_shop.customers 
( id integer,
first_name varchar,
last_name varchar
);

create table raw.jaffle_shop.orders
( id integer,
user_id integer,
order_date date,
status varchar,
_etl_loaded_at timestamp_ltz default current_timestamp()
);

create table raw.stripe.payments 
( id integer,
orderid integer,
paymentmethod varchar,
status varchar,
amount integer,
created date,
_batched_at timestamp_ltz default current_timestamp()
);

create or replace stage raw.public.stg_dbt_tutorial
url = 'azure://wennandbt.blob.core.windows.net/aws-s3-demo-wennan/dbt-tutorial/'
credentials = (azure_sas_token = 'sp=rl&st=2026-02-08T04:15:57Z&se=2026-02-13T12:30:57Z&spr=https&sv=2024-11-04&sr=c&sig=3sw914wIOrSVG3IqnaHt68DsY3j2%2BotYR1MTApds0YE%3D')
file_format = (
type = 'CSV'
field_delimiter = ','
skip_header = 1
);

copy into raw.jaffle_shop.customers (id, first_name, last_name)
from @raw.public.stg_dbt_tutorial
files = ('jaffle_shop_customers.csv');

copy into raw.jaffle_shop.orders (id, user_id, order_date, status)
from @raw.public.stg_dbt_tutorial
files = ('jaffle_shop_orders.csv');

copy into raw.stripe.payments (id, orderid, paymentmethod, status, amount, created)
from @raw.public.stg_dbt_tutorial
files = ('stripe_payments.csv');


insert into raw.jaffle_shop.orders (id, user_id, order_date, status)
values
  (100, 100, '2025-02-15', 'shipped'),
  (101, 84,  '2025-02-15', 'shipped'),
  (102, 42,  '2025-02-15', 'shipped'),
  (103, 101, '2025-02-15', 'shipped'),
  (104, 66,  '2025-02-15', 'shipped');

insert into raw.jaffle_shop.customers (id, first_name, last_name)
values
  (101, 'Michelle', 'B.'),
  (102, 'Faith',    'L.');

insert into raw.stripe.payments (id, orderid, paymentmethod, status, amount, created)
values
  (121, 100, 'bank_transfer', 'success', 1000, '2025-02-14'),
  (122, 101, 'credit_card',   'fail',     400, '2025-02-14'),
  (123, 102, 'credit_card',   'success', 1900, '2025-02-14'),
  (124, 103, 'credit_card',   'success', 1000, '2025-02-15'),
  (125, 104, 'coupon',        'success',  100, '2025-02-15');




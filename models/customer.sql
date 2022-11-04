{{
  config(
    materialized='view'
  )
}}

-- Create Customers Table
with customer as (
    
    select * from {{ ref('stg_customers') }}
),
-- Create orders table
orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(order_id) as orders_count,
    from
        orders
    group by
        1
),
final as (
    select
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        customer_orders.first_order_date,
        customer_orders.last_order_date,
        coalesce(customer_orders.orders_count, 0) as orders_count
    from
        customer
        left join customer_orders using (customer_id)
)
select
    *
from
    final
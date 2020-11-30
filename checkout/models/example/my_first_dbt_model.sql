--I will use Dimension Snapshots to build a historised immutable table of users
--In DBT this file would live in the snapshots directory
--https://docs.getdbt.com/docs/building-a-dbt-project/snapshots/

{% snapshot users_hist %}

{{
    config(
      target_database='demo_db',
      target_schema='demo_db_stg',
      unique_key='id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('jaffle_shop', 'orders') }}

{% endsnapshot %}

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null

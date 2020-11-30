--I have used dimension snapshot to historize user postcode data
--This will run 15 minutes past midnight once every 24 hours
--Handles new columns as old rows are versioned off.
--https://docs.getdbt.com/docs/building-a-dbt-project/snapshots/
--I also have a macro that uses the custom schema name instead of appending the config schema name to
--avoid schema being called public_staging.


{% snapshot user_snapshot %}

{{
    config(
      target_database='checkout_db',
      target_schema='staging',
      unique_key='id',
      check_cols=['postcode'],
    )
}}

WITH users AS (
    select
     *
    from {{ source('users_extract', 'users') }}
    ),

    final AS (
    select * from users
    )

select * from final

{% endsnapshot %}

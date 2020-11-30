--This materialized incremental table will take the source pageview data once per hour
--The output will show the number of pageviews, by hour and user_id, with an additional postcode attribute
--This will be an incremental run once per hour
{{
    config(
        materialized='incremental',
        target_database='checkout_db',
        target_schema='staging',
    )
}}
--Take raw data
WITH page_views as (
    SELECT
        *
    FROM  {{ source('pageviews_extract', 'pageviews')}}
),
--Filter for latest postcodes for each user
postcode AS (
SELECT
        id
        , postcode as hist_postcode
    FROM {{  ref('user_snapshot')  }}
    WHERE dbt_valid_to IS NULL)
),
--Take page view data and aggregate up to the user_id, hour level
page_views_by_hour AS (

    SELECT
     user_id
     ,DATE_TRUNC('hour', pageview_datetime) as pageview_hour
     ,COUNT(*) as count_pageviews
    FROM page_views
    GROUP BY 1,2
),
--Join the aggregated fact table to the latest postcode for that day data
final AS (
    SELECT
        p.user_id
        , up.hist_postcode
        , p.pageview_hour
        , p.count_pageviews
    FROM page_views_by_hour p
    LEFT JOIN postcode up
    ON p.user_id = up.id
)

SELECT * FROM final

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where pageview_hour >= (select max(pageview_hour) from {{ this }})

{% endif %}



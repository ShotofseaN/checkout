--BI Tool/User facing view in the physical layer that will show a count of pageviews, by current postcode by hour

--Take the latest user postcode data
WITH latest_user_postcode AS (
    SELECT
        id
        , postcode
    FROM {{  ref('user_snapshot')  }}
    WHERE dbt_valid_to IS NULL),

--Join onto the pageviews incremental table
    page_views_by_user_hour AS (
    SELECT
        p.user_id
        , p.pageview_hour
        , p.count_pageviews
        , u.postcode
    FROM {{  ref('stg_pageviews_incremental')  }} p
    JOIN latest_user_postcode u
    ON p.user_id = u.id
    ),

--Aggregate up to the postcode, by hour level as user_id is not required in the final view
    pageviews_by_current_postcode AS (
    SELECT
        postcode
        , pageview_hour
        , SUM(count_pageviews) AS count_pageviews
    FROM page_views_by_user_hour
    GROUP BY 1,2
    )

    SELECT * FROM pageviews_by_current_postcode





--Take the incremental table of count of pageviews, by users, hist_postcodes and hour and aggregate up to histpostcode
-- and hour level

WITH pageviews_by_historical_postcode AS (
    SELECT
        hist_postcode
        , pageview_hour
        , SUM(count_pageviews) as count_pageviews
    FROM {{  ref('stg_pageviews_incremental')  }}
    GROUP BY 1,2
    )

    SELECT * FROM pageviews_by_historical_postcode

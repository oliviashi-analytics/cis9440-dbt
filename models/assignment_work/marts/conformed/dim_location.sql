WITH all_locations AS (
    SELECT
        borough,
        CAST(council_district AS STRING) AS council_district,
        CAST(zip AS STRING) AS zip
    FROM {{ ref('stg_nyc_311_dot') }}
    WHERE borough IS NOT NULL
       OR council_district IS NOT NULL
       OR zip IS NOT NULL

    UNION DISTINCT

    SELECT
        borough,
        CAST(council_district AS STRING) AS council_district,
        CAST(zip AS STRING) AS zip
    FROM {{ ref('stg_nyc_dob_job_filings') }}
    WHERE borough IS NOT NULL
       OR council_district IS NOT NULL
       OR zip IS NOT NULL
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'borough', 'council_district', 'zip'
    ]) }} AS location_key,
    borough,
    council_district,
    zip
FROM all_locations

UNION ALL

SELECT
    '-1' AS location_key,
    CAST(NULL AS STRING) AS borough,
    CAST(NULL AS STRING) AS council_district,
    CAST(NULL AS STRING) AS zip
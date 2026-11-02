WITH source AS (
    SELECT *
    FROM {{ source('raw', 'source_nyc_dob_job_apps') }}
),

cleaned AS (
    SELECT
        * EXCEPT (
            job_filing_number, borough, council_district, postcode, zip,
            filing_date, approved_date, current_status_date,
            first_permit_date, signoff_date
        ),

        TRIM(job_filing_number) AS job_filing_number,

        CASE UPPER(TRIM(borough))
            WHEN 'MANHATTAN' THEN 'Manhattan'
            WHEN 'BRONX' THEN 'Bronx'
            WHEN 'THE BRONX' THEN 'Bronx'
            WHEN 'BROOKLYN' THEN 'Brooklyn'
            WHEN 'QUEENS' THEN 'Queens'
            WHEN 'STATEN ISLAND' THEN 'Staten Island'
            ELSE 'UNKNOWN or CITYWIDE'
        END AS borough,

        NULLIF(TRIM(council_district), '') AS council_district,

        -- Use the job location's postcode for the shared location dimension.
        REGEXP_EXTRACT(TRIM(postcode), r'^(\d{5})(?:-\d{4})?$') AS zip,
        NULLIF(TRIM(zip), '') AS source_zip,

        SAFE_CAST(SUBSTR(TRIM(filing_date), 1, 10) AS DATE) AS filing_date,
        SAFE_CAST(SUBSTR(TRIM(approved_date), 1, 10) AS DATE) AS approved_date,
        SAFE_CAST(SUBSTR(TRIM(current_status_date), 1, 10) AS DATE) AS current_status_date,
        SAFE_CAST(SUBSTR(TRIM(first_permit_date), 1, 10) AS DATE) AS first_permit_date,
        SAFE_CAST(SUBSTR(TRIM(signoff_date), 1, 10) AS DATE) AS signoff_date

    FROM source
    WHERE NULLIF(TRIM(job_filing_number), '') IS NOT NULL
)

SELECT * FROM cleaned
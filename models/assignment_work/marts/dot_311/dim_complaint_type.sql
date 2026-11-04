WITH distinct_complaint_types AS (
    SELECT DISTINCT
        complaint_type,
        descriptor
    FROM {{ ref('stg_nyc_311_dot') }}
    WHERE complaint_type IS NOT NULL
),

enriched AS (
    SELECT
        complaint_type,
        descriptor,
        CASE
            WHEN LOWER(descriptor) LIKE '%sidewalk%' THEN 'sidewalk'
            WHEN LOWER(descriptor) LIKE '%street%'   THEN 'street'
            WHEN LOWER(descriptor) LIKE '%bike%'     THEN 'bike'
            WHEN LOWER(descriptor) LIKE '%highway%'  THEN 'highway'
            ELSE 'other'
        END AS complaint_category
    FROM distinct_complaint_types
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'complaint_type', 'descriptor'
    ]) }} AS complaint_type_key,
    complaint_type,
    descriptor,
    complaint_category
FROM enriched
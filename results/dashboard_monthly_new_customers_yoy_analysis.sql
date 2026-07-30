
WITH latest_year AS (
SELECT MAX(YEAR(created_at)) AS current_year
FROM customers
)
SELECT
    MONTH(created_at) AS month_number,
    MONTHNAME(created_at) AS month_name,
    COUNT(
        CASE
            WHEN YEAR(created_at) = ly.current_year
            THEN customer_id
        END
    ) AS current_year_new_customers,

    COUNT(
        CASE
            WHEN YEAR(created_at) = ly.current_year - 1
            THEN customer_id
        END
    ) AS previous_year_new_customers
FROM customers
CROSS JOIN latest_year ly
WHERE YEAR(created_at) IN (ly.current_year, ly.current_year - 1)
GROUP BY MONTH(created_at), MONTHNAME(created_at)
ORDER BY month_number;
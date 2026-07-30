USE banking_analytics_db;
WITH latest_year AS (
    SELECT MAX(YEAR(transaction_date)) AS current_year
    FROM transactions
)
SELECT
    MONTH(transaction_date) AS month_number,
    MONTHNAME(transaction_date) AS month_name,
    SUM(
        CASE
            WHEN YEAR(transaction_date) = ly.current_year
            THEN amount_usd
        END
    ) AS current_year_value,
    SUM(
        CASE
            WHEN YEAR(transaction_date) = ly.current_year - 1
            THEN amount_usd
        END
    ) AS previous_year_value
FROM transactions
CROSS JOIN latest_year ly
WHERE YEAR(transaction_date) IN (ly.current_year, ly.current_year - 1)
GROUP BY MONTH(transaction_date), MONTHNAME(transaction_date)
ORDER BY month_number;
    
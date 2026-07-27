-- ==========================================================
-- Business Problem 1: Top Spending Customers
-- ==========================================================

/*
Problem:
Identify customers with the highest total spending based on
their transaction history.

Business Context:
Understanding customer spending behavior helps relationship
managers identify high-value customers for premium banking
services, loyalty programs, and personalized product offerings.
*/

WITH customer_spending AS
(
    SELECT
        a.customer_id,
        COUNT(t.transaction_id) AS total_transactions,
        SUM(t.amount_usd) AS total_spending
    FROM accounts a
    JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY a.customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    cs.total_transactions,
    ROUND(cs.total_spending,2) AS total_spending,
    DENSE_RANK() OVER
    (
        ORDER BY cs.total_spending DESC
    ) AS spending_rank
FROM customer_spending cs
JOIN customers c
    ON cs.customer_id = c.customer_id
ORDER BY spending_rank;

/*
Insight:
Ranks customers based on their total transaction value,
helping the bank identify high-spending customers for
premium relationship management and targeted marketing.
*/

-- ==========================================================
-- Business Problem 2: Monthly Transaction Trend
-- ==========================================================

/*
Problem:
Analyze monthly transaction activity to understand customer
spending patterns over time.

Business Context:
Banks monitor transaction trends to identify seasonal spending
patterns, measure customer engagement, and support business
planning.
*/

SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount_usd),2) AS total_transaction_value,
    ROUND(AVG(amount_usd),2) AS average_transaction_value
FROM transactions
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY transaction_month;

/*
Insight:
Provides a monthly view of transaction volume and spending,
helping the bank identify growth trends and seasonal customer
activity.
*/
-- ==========================================================
-- Business Problem 3: Most Active Customers
-- ==========================================================

/*
Problem:
Identify customers with the highest transaction activity.

Business Context:
Customers who frequently transact are generally more engaged
with the bank. Understanding transaction frequency helps
identify loyal customers for premium services and targeted
marketing campaigns.
*/

WITH customer_activity AS
(
    SELECT
        a.customer_id,
        COUNT(t.transaction_id) AS total_transactions,
        ROUND(SUM(t.amount_usd),2) AS total_spending,
        ROUND(AVG(t.amount_usd),2) AS average_transaction_value
    FROM accounts a
    JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY a.customer_id
    HAVING COUNT(t.transaction_id) >= 20
)
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    ca.total_transactions,
    ca.total_spending,
    ca.average_transaction_value,
    DENSE_RANK() OVER(ORDER BY ca.total_transactions DESC) AS activity_rank
FROM customer_activity ca
JOIN customers c
    ON ca.customer_id = c.customer_id
ORDER BY activity_rank;
/*
Insight:
Highlights highly engaged customers based on transaction
frequency, supporting customer retention and loyalty programs.
*/

-- ==========================================================
-- Business Problem 4: Top Performing Merchants
-- ==========================================================

/*
Problem:
Identify merchants generating the highest transaction value.

Business Context:
Understanding merchant performance helps the bank identify
strategic merchant partnerships, negotiate commercial agreements,
and analyze customer spending preferences.
*/

WITH merchant_performance AS
(
    SELECT merchant_id, COUNT(transaction_id) AS total_transactions,
		ROUND(SUM(amount_usd),2) AS total_revenue,
        ROUND(AVG(amount_usd),2) AS average_transaction_value
    FROM transactions
    GROUP BY merchant_id
)
SELECT
    m.merchant_id, m.merchant_name, m.city, mp.total_transactions,
	mp.total_revenue, mp.average_transaction_value,
    DENSE_RANK() OVER( ORDER BY mp.total_revenue DESC) AS merchant_rank
FROM merchant_performance mp
JOIN merchants m
    ON mp.merchant_id = m.merchant_id
ORDER BY merchant_rank;

/*
Insight:
Ranks merchants by transaction revenue, helping the bank
identify high-performing merchant partners and customer
spending hotspots.
*/

-- ==========================================================
-- Business Problem 5: Customer Spending Segmentation
-- ==========================================================

/*
Problem:
Segment customers based on their total transaction spending.

Business Context:
Banks classify customers into different spending segments to
support personalized marketing campaigns, customer retention,
and premium banking initiatives.
*/

WITH customer_spending AS
(
    SELECT a.customer_id,
        ROUND(SUM(t.amount_usd),2) AS total_spending
    FROM accounts a
    JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY a.customer_id
)

SELECT
    CASE
        WHEN total_spending >= 50000 THEN 'High Spender'
        WHEN total_spending >= 20000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(total_spending),2) AS average_spending,
    ROUND(MIN(total_spending),2) AS minimum_spending,
    ROUND(MAX(total_spending),2) AS maximum_spending
FROM customer_spending
GROUP BY spending_segment
ORDER BY average_spending DESC;

/*
Insight:
Categorizes customers into spending segments, enabling the bank
to design targeted marketing strategies and personalized product
offerings for different customer groups.
*/


-- ==========================================================
-- Business Problem 6: Sudden Customer Spending Spikes
-- ==========================================================

/*
Problem:
Identify customers whose monthly spending has increased
significantly compared to the previous month.

Business Context:
Banks monitor sudden increases in customer spending to detect
changing financial behavior, identify premium banking
opportunities, and flag unusual spending patterns.
*/

WITH monthly_spending AS
(
    SELECT
        a.customer_id,
        DATE_FORMAT(t.transaction_date,'%Y-%m') AS transaction_month,
        ROUND(SUM(t.amount_usd),2) AS monthly_spending
    FROM accounts a
    JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY
        a.customer_id,
        DATE_FORMAT(t.transaction_date,'%Y-%m')
),
spending_growth AS
(
    SELECT customer_id, transaction_month, monthly_spending,
        LAG(monthly_spending)
        OVER ( PARTITION BY customer_id ORDER BY transaction_month) AS previous_month_spending
    FROM monthly_spending
)
SELECT
    customer_id,
    transaction_month,
    monthly_spending,
    previous_month_spending,
    ROUND(((monthly_spending - previous_month_spending)/ previous_month_spending) * 100, 2) 
	AS spending_growth_percentage
FROM spending_growth
WHERE previous_month_spending IS NOT NULL
ORDER BY spending_growth_percentage DESC;

/*
Insight:
Highlights customers whose spending increased sharply from
one month to the next, supporting proactive customer
engagement and behavioral monitoring.
*/

-- ==========================================================
-- Business Problem 7: Peak Transaction Hours
-- ==========================================================

/*
Problem:
Analyze transaction activity by hour of the day.

Business Context:
Banks monitor hourly transaction patterns to understand
customer behavior, optimize system capacity, and schedule
maintenance during low-traffic periods.
*/

SELECT
    HOUR(transaction_date) AS transaction_hour,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_usd),2) AS total_transaction_value,
    ROUND(AVG(amount_usd),2) AS average_transaction_value
FROM transactions
GROUP BY transaction_hour
ORDER BY total_transactions DESC;
/*
Insight:
Highlights peak transaction hours, helping the bank optimize
system performance and operational planning.
*/

-- ==========================================================
-- Business Problem 8: Detect Unusual Spending Activity
-- ==========================================================

/*
Problem:
Identify transactions that are significantly higher than a
customer's typical spending behavior.

Business Context:
Banks monitor transactions that deviate substantially from a
customer's historical spending pattern. These transactions
may require additional review to detect potential fraud or
unusual account activity.
*/

WITH customer_average AS
(
    SELECT a.customer_id, AVG(t.amount_usd) AS average_transaction_amount
    FROM accounts a
    JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY a.customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    t.transaction_id,
    t.amount_usd,
    ROUND(ca.average_transaction_amount,2) AS average_transaction_amount,
    ROUND(t.amount_usd / ca.average_transaction_amount,2
    ) AS spending_multiple
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN customer_average ca
    ON a.customer_id = ca.customer_id
JOIN customers c
    ON a.customer_id = c.customer_id
WHERE
    t.amount_usd >= ca.average_transaction_amount * 3
ORDER BY
    spending_multiple DESC,
    t.amount_usd DESC;

/*
Insight:
Flags transactions that are at least three times larger than a
customer's average transaction amount, helping identify
potentially unusual spending behavior for further review.
*/
-- ==========================================================
-- Business Problem 9: Detect Rapid Successive Transactions
-- ==========================================================

/*
Problem:
Identify customers performing multiple transactions within
a short period of time.

Business Context:
Banks continuously monitor rapid successive transactions as
they may indicate card testing, compromised accounts, or
other suspicious account activity requiring investigation.
*/

WITH customer_transactions AS
(
    SELECT 
		a.customer_id, t.transaction_id, t.transaction_date, t.amount_usd,
		LAG(t.transaction_date)
        OVER
        (
            PARTITION BY a.customer_id
            ORDER BY t.transaction_date
        ) AS previous_transaction_time,
        
        LAG(t.amount_usd)
        OVER
        (
            PARTITION BY a.customer_id
            ORDER BY t.transaction_date
        ) AS previous_transaction_amount
    FROM transactions t
    JOIN accounts a
	ON t.account_id = a.account_id
)
SELECT
    customer_id, transaction_id, transaction_date, previous_transaction_time, amount_usd, previous_transaction_amount,
	TIMESTAMPDIFF
    (
        MINUTE,
        previous_transaction_time,
        transaction_date
    ) AS minutes_between_transactions
FROM customer_transactions
WHERE
    previous_transaction_time IS NOT NULL
    AND TIMESTAMPDIFF
    (
        MINUTE,
        previous_transaction_time,
        transaction_date
    ) <= 5

ORDER BY
    customer_id,
    transaction_date;

/*
Insight:
Highlights customers performing transactions within five
minutes of their previous transaction, helping identify
potentially suspicious activity requiring further review.
*/

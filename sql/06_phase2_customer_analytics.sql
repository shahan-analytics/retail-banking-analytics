-- ==========================================================
-- Business Problem 1: Customer 360 Portfolio
-- ==========================================================

/*
Problem:
Build a 360-degree customer profile by combining customer,
account, card, and loan information.

Context:
Relationship managers need a consolidated view of each customer's
banking relationship to understand engagement and identify
cross-selling opportunities.
*/

WITH account_summary AS
(
    SELECT
        customer_id,
        COUNT(account_id) AS total_accounts,
        SUM(balance_usd) AS total_deposits
    FROM accounts
    GROUP BY customer_id
),
card_summary AS
(
    SELECT
        a.customer_id,
        COUNT(c.card_id) AS total_cards
    FROM cards c
    JOIN accounts a
        ON c.account_id = a.account_id
    GROUP BY a.customer_id
),
loan_summary AS
(
    SELECT
        customer_id,
        COUNT(loan_id) AS total_loans,
        SUM(loan_amount) AS total_loan_amount
    FROM loans
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    c.credit_score,
    COALESCE(a.total_accounts,0) AS total_accounts,
    ROUND(COALESCE(a.total_deposits,0),2) AS total_deposits,
    COALESCE(cd.total_cards,0) AS total_cards,
    COALESCE(l.total_loans,0) AS total_loans,
    ROUND(COALESCE(l.total_loan_amount,0),2) AS total_loan_amount,
    ROUND( COALESCE(a.total_deposits,0) + COALESCE(l.total_loan_amount,0), 2) AS relationship_value
FROM customers c
LEFT JOIN account_summary a
    ON c.customer_id = a.customer_id
LEFT JOIN card_summary cd
    ON c.customer_id = cd.customer_id
LEFT JOIN loan_summary l
    ON c.customer_id = l.customer_id
ORDER BY relationship_value DESC;

/*
Insight:
Provides a unified customer view combining deposits, loans,
cards, and accounts, helping identify the bank's most valuable
customers.
*/
-- ==========================================================
-- Business Problem 2: Top Customers by Deposits
-- ==========================================================

/*
Problem:
Identify customers with the highest total deposits.

Context:
Relationship managers use this report to identify high-value
customers for personalized banking services.
*/
USE banking_analytics_db;
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.city,
    ROUND(SUM(a.balance_usd),2) AS total_deposits,
    DENSE_RANK() OVER
    (
		ORDER BY SUM(a.balance_usd) DESC
    ) AS deposit_rank
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id, customer_name, c.city
ORDER BY deposit_rank;

/*
Insight:
Highlights the bank's highest-value deposit customers,
supporting wealth management and relationship banking initiatives.
*/

-- ==========================================================
-- Business Problem 3: Customers with Multiple Accounts
-- ==========================================================

/*
Problem:
Identify customers who own more than one bank account.

Context:
Customers maintaining multiple accounts are generally more
engaged with the bank and represent strong opportunities for
cross-selling and relationship banking.
*/

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.city,
    COUNT(a.account_id) AS total_accounts,
    ROUND(SUM(a.balance_usd),2) AS total_deposits
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id, customer_name, c.city
HAVING COUNT(a.account_id) > 1
ORDER BY total_accounts DESC, total_deposits DESC;

/*
Insight:
Highlights customers with multiple banking relationships,
helping identify highly engaged customers for targeted offers.
*/

-- ==========================================================
-- Business Problem 4: Customers Without Loans
-- ==========================================================

/*
Problem:
Identify customers who have bank accounts but have not taken
any loans.

Context:
These customers represent potential targets for loan marketing
campaigns and cross-selling initiatives.
*/

SELECT
	c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.city,
	ROUND(SUM(a.balance_usd),2) AS total_deposits,
	COUNT(a.account_id) AS total_accounts
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN loans l
    ON c.customer_id = l.customer_id
WHERE l.loan_id IS NULL
GROUP BY c.customer_id, customer_name, c.city
ORDER BY total_deposits DESC;

/*
Insight:
Identifies customers with active deposit relationships but no
loan products, making them ideal candidates for targeted loan
offers.
*/

-- ==========================================================
-- Business Problem 5: Monthly Customer Acquisition Trend
-- ==========================================================

/*
Problem:
Analyze monthly customer acquisition trends.

Context:
Tracking new customer registrations helps measure business growth,
marketing effectiveness, and seasonal acquisition patterns.
*/

SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS acquisition_month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY acquisition_month
ORDER BY acquisition_month;

/*
Insight:
Shows monthly customer acquisition trends, enabling the bank to
monitor growth and evaluate customer acquisition performance.
*/

-- ==========================================================
-- Business Problem 6: Cities with Highest Deposits
-- ==========================================================

/*
Problem:
Identify cities contributing the highest total deposits.

Context:
Regional managers use this report to evaluate market performance,
allocate resources, and identify high-value banking regions.
*/

SELECT
    c.city,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(a.account_id) AS total_accounts,
    ROUND(SUM(a.balance_usd),2) AS total_deposits,
    ROUND(AVG(a.balance_usd),2) AS average_account_balance,
    DENSE_RANK() OVER
    (
        ORDER BY SUM(a.balance_usd) DESC
    ) AS city_rank
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY c.city
ORDER BY city_rank;

/*
Insight:
Ranks cities based on total deposits while providing customer,
account, and average balance metrics to support regional
performance analysis.
*/

-- ==========================================================
-- Business Problem 7: Dormant Customers with High Balances
-- ==========================================================

/*
Problem:
Identify customers maintaining high deposit balances but who
have not performed any transactions in the last 90 days.

Business Context:
Banks lose revenue when valuable customers become inactive.
Relationship managers use this report to identify dormant
high-value customers and launch targeted engagement campaigns
before they move their funds to competing institutions.
*/
WITH account_summary AS
(
    SELECT
        customer_id,
        COUNT(account_id) AS total_accounts,
        SUM(balance_usd) AS total_deposits
    FROM accounts
    GROUP BY customer_id
),
transaction_summary AS
(
    SELECT
        a.customer_id,
        COUNT(t.transaction_id) AS total_transactions,
        MAX(t.transaction_date) AS last_transaction_date
    FROM accounts a
    LEFT JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY a.customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    s.total_accounts,
    ROUND(s.total_deposits,2) AS total_deposits,
    COALESCE(t.total_transactions,0) AS total_transactions,
    t.last_transaction_date,
    DATEDIFF(CURDATE(),t.last_transaction_date) AS inactive_days
FROM customers c
JOIN account_summary s
    ON c.customer_id = s.customer_id
LEFT JOIN transaction_summary t
    ON c.customer_id = t.customer_id
WHERE
    s.total_deposits >
    (
        SELECT AVG(total_deposits)
        FROM account_summary
    )
AND DATEDIFF(CURDATE(),t.last_transaction_date) >= 90
ORDER BY
    inactive_days DESC,
    total_deposits DESC;
/*
Insight:
Customers returned by this report maintain above-average
deposit balances but have not transacted for at least
90 days, making them ideal candidates for relationship
management and customer retention initiatives.
*/

-- ==========================================================

-- ==========================================================
-- Business Problem 8: Customer Deposit Concentration Analysis
-- ==========================================================

/*
Problem:
Analyze how customer deposits are distributed across the
customer base by calculating the cumulative share of deposits.

Business Context:
Retail banks monitor deposit concentration to understand
whether a small percentage of customers controls a large
portion of total deposits. High concentration increases
business risk if those customers leave the bank.
*/

WITH customer_deposits AS
(
    SELECT
		c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        SUM(a.balance_usd) AS total_deposits
    FROM customers c
    JOIN accounts a
        ON c.customer_id = a.customer_id
    GROUP BY
        c.customer_id,
        customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_deposits,2) AS total_deposits,
    DENSE_RANK() OVER
    (
        ORDER BY total_deposits DESC
    ) AS deposit_rank,
    ROUND(
        SUM(total_deposits)
        OVER
        (
            ORDER BY total_deposits DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ),2 ) AS cumulative_deposits,
	ROUND(
        (
            SUM(total_deposits)
            OVER
            (
                ORDER BY total_deposits DESC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            ) / SUM(total_deposits) OVER () ) * 100, 2) AS cumulative_percentage
FROM customer_deposits
ORDER BY deposit_rank;

/*
Insight:
Shows how quickly cumulative deposits increase as customers
are ranked by deposit value, helping identify whether a small
group of customers holds a significant proportion of the
bank's total deposits.
*/

-- ==========================================================
-- Business Problem 1: Savings vs Current Account Analysis
-- ==========================================================

/*
Problem:
Compare the performance of different account types based on
customer adoption and deposit contribution.

Business Context:
Banks analyze account portfolios to understand customer
preferences, evaluate product performance, and identify
which account types contribute the largest share of deposits.
*/
SELECT DISTINCT account_type 
FROM accounts;
USE banking_analytics_db;
SELECT
    account_type,
    COUNT(*) AS total_accounts,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(balance_usd),2) AS total_deposits,
    ROUND(AVG(balance_usd),2) AS average_account_balance,
    ROUND(MAX(balance_usd),2) AS highest_account_balance,
    ROUND(MIN(balance_usd),2) AS lowest_account_balance
FROM accounts
GROUP BY account_type
ORDER BY total_deposits DESC;

/*
Insight:
Provides a portfolio-level comparison of account types,
highlighting customer adoption, deposit contribution, and
balance characteristics to support product strategy.
*/

-- ==========================================================
-- Business Problem 2: Account Age Analysis
-- ==========================================================

/*
Problem:
Analyze account age to understand customer retention and
deposit behavior across different account age groups.

Business Context:
Banks monitor account longevity to measure customer loyalty,
identify mature relationships, and evaluate how deposits
grow over the customer lifecycle.
*/

SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, open_date, CURDATE()) < 1
            THEN 'Less than 1 Year'
        WHEN TIMESTAMPDIFF(YEAR, open_date, CURDATE()) BETWEEN 1 AND 3
            THEN '1 - 3 Years'
        WHEN TIMESTAMPDIFF(YEAR, open_date, CURDATE()) BETWEEN 4 AND 5
            THEN '4 - 5 Years'
        ELSE 'More than 5 Years'
    END AS account_age,
    COUNT(*) AS total_accounts,
    ROUND(SUM(balance_usd),2) AS total_deposits,
    ROUND(AVG(balance_usd),2) AS average_balance,
    ROUND(MAX(balance_usd),2) AS highest_balance,
    ROUND(MIN(balance_usd),2) AS lowest_balance
FROM accounts
GROUP BY account_age
ORDER BY total_deposits DESC;

/*
Insight:
Shows how deposits and account balances vary across different
account age groups, helping the bank understand customer
retention and long-term relationship value.
*/
DESCRIBE accounts;
SELECT * FROM accounts;

-- ==========================================================
-- Business Problem 3: High Balance, Low Activity Accounts
-- ==========================================================

/*
Problem:
Identify accounts maintaining high balances despite having
very few transactions.

Business Context:
Customers with large idle balances represent opportunities
for wealth management, investment products, and fixed deposit
campaigns. Banks monitor these accounts to improve customer
engagement and increase revenue.
*/

SELECT
    a.account_id,
    a.customer_id,
    a.account_type,
    ROUND(a.balance_usd,2) AS account_balance,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(COALESCE(SUM(t.amount_usd),0),2) AS total_transaction_value
FROM accounts a
LEFT JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY
    a.account_id,
    a.customer_id,
    a.account_type,
    a.balance_usd
HAVING
    a.balance_usd >= 10000
    AND COUNT(t.transaction_id) <= 10
ORDER BY
    a.balance_usd DESC,
    total_transactions ASC;

/*
Insight:
Highlights customers maintaining high account balances while
showing limited transaction activity, helping the bank target
them with wealth management and investment opportunities.
*/

-- ==========================================================
-- Business Problem 4: Customers Holding Multiple Account Types
-- ==========================================================

/*
Problem:
Identify customers who maintain multiple types of bank accounts.

Business Context:
Customers owning multiple account types generally have a
stronger relationship with the bank and are more likely to
adopt additional financial products. Identifying these
customers helps relationship managers prioritize cross-selling
and premium banking services.
*/

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(*) AS total_accounts,
    COUNT(DISTINCT a.account_type) AS account_types_owned,
    ROUND(SUM(a.balance_usd),2) AS total_balance
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    customer_name
HAVING
    COUNT(DISTINCT a.account_type) > 1
ORDER BY
    total_balance DESC;
/*
Insight:
Identifies customers maintaining multiple account types,
highlighting highly engaged customers who are strong
candidates for cross-selling and premium banking services.
*/

-- ==========================================================
-- Business Problem 4: Detect Accounts at Risk of Overdraft
-- ==========================================================

/*
Problem:
Identify accounts with very low balances and high transaction
activity.

Business Context:
Banks monitor accounts approaching minimum balance levels
while exhibiting frequent transaction activity. These
customers are more likely to experience overdrafts and may
benefit from overdraft protection or balance alerts.
*/

SELECT

    a.account_id,
    a.customer_id,
    a.account_type,
    ROUND(a.balance_usd,2) AS current_balance,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(AVG(t.amount_usd),2) AS average_transaction_amount
FROM accounts a
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY
    a.account_id,
    a.customer_id,
    a.account_type,
    a.balance_usd
HAVING
    balance_usd <= 1000
    AND COUNT(t.transaction_id) >= 20
ORDER BY
    current_balance ASC,
    total_transactions DESC;

/*
Insight:
Highlights highly active accounts with low balances,
supporting proactive overdraft prevention and customer
engagement initiatives.
*/


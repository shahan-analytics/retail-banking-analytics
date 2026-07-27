-- ==========================================================
-- Project : Retail Banking Analytics
-- Phase   : 1 - Business Overview
-- Database: banking_analytics_db
-- ==========================================================

USE banking_analytics_db;

-- ==========================================================
-- Business Problem 1: Overall Banking Portfolio
-- ==========================================================

/*
Problem:
Provide an executive-level snapshot of the bank's overall portfolio.

Context:
Management needs a quick overview of customers, accounts, loans,
cards, branches, merchants, and transactions before deeper analysis.
*/

SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM accounts) AS total_accounts,
    (SELECT COUNT(*) FROM cards) AS total_cards,
    (SELECT COUNT(*) FROM loans) AS total_loans,
    (SELECT COUNT(*) FROM branches) AS total_branches,
    (SELECT COUNT(*) FROM merchants) AS total_merchants,
    (SELECT COUNT(*) FROM transactions) AS total_transactions;

/*
Insight:
This query provides the core KPIs used to measure the bank's operational
scale and serves as the starting point for executive reporting.
*/

-- ==========================================================
-- Business Problem 2: Customer Distribution by City
-- ==========================================================

/*
Problem:
Identify the cities with the highest concentration of customers.

Context:
Understanding customer distribution helps the bank identify major markets,
allocate resources effectively, and plan regional expansion strategies.
*/

SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

/*
Insight:
Highlights the bank's strongest customer markets and supports
location-based business and marketing decisions.
*/

-- ==========================================================
-- Business Problem 3: Account Type Distribution
-- ==========================================================

/*
Problem:
Analyze the distribution of different account types.

Context:
Understanding product adoption helps management evaluate customer
preferences and identify opportunities for product growth.
*/

SELECT account_type, COUNT(*) AS total_accounts,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM accounts),2) AS percentage
FROM accounts
GROUP BY account_type
ORDER BY total_accounts DESC;

/*
Insight:
Shows which account products dominate the portfolio and how
customers are distributed across banking products.
*/

-- ==========================================================
-- Business Problem 4: Deposit Portfolio Overview
-- ==========================================================

/*
Problem:
Measure the overall deposit portfolio maintained by customers.

Context:
Deposit balances are a key indicator of the bank's liquidity and
overall financial strength.
*/

SELECT
    COUNT(*) AS total_accounts,
    ROUND(SUM(balance_usd),2) AS total_deposits,
    ROUND(AVG(balance_usd),2) AS average_balance,
    ROUND(MAX(balance_usd),2) AS highest_balance,
    ROUND(MIN(balance_usd),2) AS lowest_balance
FROM accounts;

/*
Insight:
Provides a high-level view of customer deposits and overall
account balance distribution.
*/

-- ==========================================================
-- Business Problem 5: Loan Portfolio Overview
-- ==========================================================

/*
Problem:
Evaluate the size and composition of the bank's loan portfolio.

Context:
Monitoring the loan portfolio helps management assess lending
activity and exposure.
*/

SELECT
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_loan_amount,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount,
    ROUND(AVG(interest_rate), 2) AS average_interest_rate
FROM loans;

/*
Insight:
Summarizes the bank's lending portfolio and key loan metrics.
*/
SELECT * FROM loans;

-- ==========================================================
-- Business Problem 6: Top Customers by Total Deposits
-- ==========================================================

/*
Problem:
Identify customers with the highest total deposits.

Context:
High-value customers contribute significantly to the bank's deposit base
and are often targeted for premium banking services.
*/

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    COUNT(a.account_id) AS total_accounts,
    ROUND(SUM(a.balance_usd),2) AS total_balance
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    customer_name,
    c.city
ORDER BY total_balance DESC
LIMIT 10;
/*
Insight:
Identifies the bank's highest-value customers based on total deposits.
*/

-- ==========================================================
-- Business Problem 7: Customers with Active Loans
-- ==========================================================

/*
Problem:
Identify customers who have borrowed from the bank.

Context:
Understanding the lending customer base helps evaluate product adoption
and customer engagement.
*/

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    COUNT(l.loan_id) AS total_loans,
    ROUND(SUM(l.loan_amount),2) AS total_borrowed
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    customer_name,
    c.city
ORDER BY total_borrowed DESC;

/*
Insight:
Highlights customers with the largest borrowing relationship.
*/

-- ==========================================================
-- Business Problem 8: Top Merchants by Transaction Volume
-- ==========================================================

/*
Problem:
Identify merchants processing the highest transaction volume.

Context:
High-volume merchants are strategically important and may require
dedicated partnership programs.
*/

SELECT
    m.merchant_name,
    m.city,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount_usd),2) AS total_transaction_value
FROM merchants m
JOIN transactions t
    ON m.merchant_id = t.merchant_id
GROUP BY
    m.merchant_name, m.city
ORDER BY total_transaction_value DESC
LIMIT 10;

/*
Insight:
Identifies the bank's most valuable merchant partners.
*/

-- ============================================
-- Data Validation
-- ============================================

USE banking_analytics_db;

-- Verify row counts
SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_accounts
FROM accounts;

SELECT COUNT(*) AS total_cards
FROM cards;

SELECT COUNT(*) AS total_merchants
FROM merchants;

SELECT COUNT(*) AS total_branches
FROM branches;

SELECT COUNT(*) AS total_loans
FROM loans;

SELECT COUNT(*) AS total_transactions
FROM transactions;

-- Referential Integrity Test

-- Accounts without a valid customer
SELECT COUNT(*) AS orphan_accounts
FROM accounts a
LEFT JOIN customers c
ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Cards without an account
SELECT COUNT(*) AS orphan_cards
FROM cards c
LEFT JOIN accounts a
ON c.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Transactions without an account
SELECT COUNT(*) AS orphan_transactions
FROM transactions t
LEFT JOIN accounts a
ON t.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Transactions without a merchant
SELECT COUNT(*) AS orphan_merchants
FROM transactions t
LEFT JOIN merchants m
ON t.merchant_id = m.merchant_id
WHERE m.merchant_id IS NULL;
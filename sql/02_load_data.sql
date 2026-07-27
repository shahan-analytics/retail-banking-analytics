-- ==========================================================
-- Project : Retail Banking Analytics
-- Database: retail_banking_db
-- Author  : Shahan
-- Purpose : Load CSV data into MySQL tables
-- ==========================================================

USE banking_analytics_db;
-- ==========================================================
-- Load Customers
-- ==========================================================
LOAD DATA LOCAL INFILE '/Users/saravanan/Documents/Retail Banking Analytics/csv/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    customer_id,
    first_name,
    last_name,
    email,
    city,
    credit_score,
    created_at
);

-- ==========================================================
-- Load Merchants
-- ==========================================================

LOAD DATA LOCAL INFILE '/Users/saravanan/Documents/Retail Banking Analytics/csv/merchants.csv'
INTO TABLE merchants
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    merchant_id,
    merchant_name,
    city
);

-- ==========================================================
-- Load Branches
-- ==========================================================

LOAD DATA LOCAL INFILE '/Users/saravanan/Documents/Retail Banking Analytics/csv/branches.csv'
INTO TABLE branches
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    branch_id,
    branch_name,
    manager_name,
    city,
    country
);

-- ==========================================================
-- Load Accounts
-- ==========================================================

LOAD DATA LOCAL INFILE '/Users/saravanan/Documents/Retail Banking Analytics/csv/accounts.csv'
INTO TABLE accounts
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    account_id,
    customer_id,
    account_type,
    balance_usd,
    open_date
);

-- ==========================================================
-- Load Cards
-- ==========================================================

LOAD DATA LOCAL INFILE '/Users/saravanan/Documents/Retail Banking Analytics/csv/cards.csv'
INTO TABLE cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    card_id,
    account_id,
    card_type,
    expiration_date
);

-- ==========================================================
-- Load Loans
-- ==========================================================

LOAD DATA LOCAL INFILE '/Users/saravanan/Documents/Retail Banking Analytics/csv/loans.csv'
INTO TABLE loans
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    loan_id,
    customer_id,
    loan_amount,
    interest_rate,
    start_date
);

-- ==========================================================
-- Load Transactions
-- ==========================================================
LOAD DATA LOCAL INFILE '/Users/saravanan/Documents/Retail Banking Analytics/csv/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    transaction_id,
    account_id,
    merchant_id,
    amount_usd,
    transaction_date
);
--  terminal: mysql --local-infile=1 -u root -p banking_analytics_db < "/Users/saravanan/Documents/Retail Banking Analytics/sql/02_load_data.sql"

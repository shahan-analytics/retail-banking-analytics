-- ===========================================
-- Project : Retail Banking Analytics
-- Database: retail_banking_db
-- Author  : shahan-analytics
-- ===========================================

-- ===========================================
-- Create Database
-- ===========================================

DROP DATABASE IF EXISTS banking_analytics_db;
CREATE DATABASE banking_analytics_db;
USE banking_analytics_db;

-- ===========================================
-- Customers
-- ===========================================
CREATE TABLE customers (
	customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    credit_score INT NOT NULL,
    created_at DATETIME NOT NULL
);

-- ===========================================
-- Accounts
-- ===========================================

CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance_usd DECIMAL(18,2) NOT NULL,
    open_date DATE NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- ===========================================
-- Cards
-- ===========================================

CREATE TABLE cards (
    card_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    card_type VARCHAR(20) NOT NULL,
    expiration_date DATE NOT NULL,
    FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);

-- ===========================================
-- Merchants
-- ===========================================
CREATE TABLE merchants (
    merchant_id VARCHAR(20) PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- ============================================
-- Branches
-- ============================================
CREATE TABLE branches (
    branch_id VARCHAR(20) PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    manager_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- ============================================
-- Loans
-- ============================================

CREATE TABLE loans (
    loan_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    loan_amount DECIMAL(18,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- =============================================
-- Transactions
-- =============================================

CREATE TABLE transactions (
    transaction_id VARCHAR(25) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    merchant_id VARCHAR(20) NOT NULL,
    amount_usd DECIMAL(18,2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    FOREIGN KEY (account_id)
        REFERENCES accounts(account_id),
    FOREIGN KEY (merchant_id)
        REFERENCES merchants(merchant_id)
);


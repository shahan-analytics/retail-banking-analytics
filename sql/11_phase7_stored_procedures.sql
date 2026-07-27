-- ==========================================================
-- Business Problem 1: Customer Financial Summary
-- ==========================================================

/*
Problem:
Create a stored procedure that returns a complete financial
summary for a customer.

Business Context:
Customer relationship managers frequently need a consolidated
view of a customer's entire banking relationship. Instead of
querying multiple tables individually, this stored procedure
returns a single financial summary for any customer.

Usage:
CALL GetCustomerFinancialSummary('CUSWMA3SKIR2ZEA');
*/

DELIMITER $$

CREATE PROCEDURE GetCustomerFinancialSummary
(
    IN p_customer_id VARCHAR(50)
)
BEGIN
WITH AccountSummary AS
(
    SELECT customer_id, COUNT(*) AS total_accounts, SUM(balance_usd) AS total_deposits
	FROM accounts
	GROUP BY customer_id
),
CardSummary AS
(
    SELECT a.customer_id, COUNT(c.card_id) AS total_cards
	FROM cards c
    JOIN accounts a
	ON c.account_id = a.account_id
	GROUP BY a.customer_id
),
LoanSummary AS
(
    SELECT customer_id, COUNT(*) AS total_loans, SUM(loan_amount) AS total_loan_amount
	FROM loans
	GROUP BY customer_id
),
TransactionSummary AS
(
    SELECT a.customer_id, COUNT(t.transaction_id) AS total_transactions, SUM(t.amount_usd) AS total_transaction_value, 
    AVG(t.amount_usd) AS average_transaction_value
	FROM transactions t
	JOIN accounts a
	ON t.account_id = a.account_id
	GROUP BY a.customer_id
)
SELECT c.customer_id,CONCAT(c.first_name,' ',c.last_name) AS customer_name,
	COALESCE(acc.total_accounts,0) AS total_accounts,
	ROUND(COALESCE(acc.total_deposits,0),2) AS total_deposits,
    COALESCE(card.total_cards,0) AS total_cards,
    COALESCE(loan.total_loans,0) AS total_loans,
    ROUND(COALESCE(loan.total_loan_amount,0),2) AS total_loan_amount,
    COALESCE(txn.total_transactions,0) AS total_transactions,
    ROUND(COALESCE(txn.total_transaction_value,0),2) AS total_transaction_value,
    ROUND(COALESCE(txn.average_transaction_value,0),2) AS average_transaction_value,
    ROUND(
        COALESCE(acc.total_deposits,0) -
        COALESCE(loan.total_loan_amount,0),
        2
    ) AS net_position
FROM customers c
LEFT JOIN AccountSummary acc
       ON c.customer_id = acc.customer_id
LEFT JOIN CardSummary card
       ON c.customer_id = card.customer_id
LEFT JOIN LoanSummary loan
       ON c.customer_id = loan.customer_id
LEFT JOIN TransactionSummary txn
       ON c.customer_id = txn.customer_id
WHERE
    c.customer_id = p_customer_id;
END $$
DELIMITER ;

-- ==========================================================
-- Example
-- ==========================================================
CALL GetCustomerFinancialSummary('CUSWMA3SKIR2ZEA');

-- ==========================================================
-- Business Problem 2: Customer Risk Score Generator
-- ==========================================================

/*
Problem:
Create a stored procedure that evaluates a customer's
financial profile and generates an overall risk score.

Business Context:
Banks assess customer risk using multiple financial
indicators rather than relying on a single metric. This
procedure assigns a score based on lending exposure,
transaction behaviour and credit quality, helping
relationship managers identify customers requiring
additional review.

Usage:
CALL GenerateCustomerRiskScore('CUSWMA3SKIR2ZEA');
*/

DELIMITER $$
CREATE PROCEDURE GenerateCustomerRiskScore
(
    IN p_customer_id VARCHAR(50)
)
BEGIN
    DECLARE v_credit_score INT DEFAULT 0;
    DECLARE v_total_deposits DECIMAL(18,2) DEFAULT 0;
    DECLARE v_total_loans DECIMAL(18,2) DEFAULT 0;
    DECLARE v_total_transactions INT DEFAULT 0;
    DECLARE v_avg_transaction DECIMAL(18,2) DEFAULT 0;

    DECLARE v_risk_score INT DEFAULT 0;
    DECLARE v_risk_level VARCHAR(20);
    SELECT credit_score INTO v_credit_score
	FROM customers
	WHERE customer_id = p_customer_id;
    
-- Total Deposits
    SELECT COALESCE(SUM(balance_usd),0)
    INTO v_total_deposits
	FROM accounts
	WHERE customer_id = p_customer_id;
    
-- Total Loans
    SELECT COALESCE(SUM(loan_amount),0)
    INTO v_total_loans
	FROM loans
	WHERE customer_id = p_customer_id;


-- Transaction Statistics 
    SELECT COUNT(t.transaction_id), COALESCE(AVG(t.amount_usd),0)
	INTO v_total_transactions, v_avg_transaction
    FROM transactions t 
    JOIN accounts a
        ON t.account_id = a.account_id
    WHERE a.customer_id = p_customer_id;

    IF v_credit_score < 650 THEN
        SET v_risk_score = v_risk_score + 40;
    END IF;
    IF v_total_loans > v_total_deposits THEN
        SET v_risk_score = v_risk_score + 30;
    END IF;
    IF v_total_transactions > 100 THEN
        SET v_risk_score = v_risk_score + 15;
    END IF;
    IF v_avg_transaction > 5000 THEN
        SET v_risk_score = v_risk_score + 15;
    END IF;
    IF v_risk_score >= 60 THEN
        SET v_risk_level = 'HIGH';
    ELSEIF v_risk_score >= 30 THEN
        SET v_risk_level = 'MEDIUM';
    ELSE
        SET v_risk_level = 'LOW';
    END IF;

    SELECT p_customer_id AS customer_id, v_credit_score AS credit_score,
		ROUND(v_total_deposits,2) AS total_deposits,
        ROUND(v_total_loans,2) AS total_loans,
        v_total_transactions AS total_transactions,
        ROUND(v_avg_transaction,2) AS average_transaction,
        v_risk_score AS risk_score,
        v_risk_level AS risk_level;
END $$
DELIMITER ;

-- ==========================================================
-- Example
-- ==========================================================

CALL GenerateCustomerRiskScore('CUSWMA3SKIR2ZEA');

-- ==========================================================
-- Business Problem 3: Daily Fraud Scanner
-- ==========================================================
-- Fraud Alert Table

CREATE TABLE fraud_alerts
(
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50),
    account_id VARCHAR(50),
    amount_usd DECIMAL(18,2),
    transaction_date DATETIME,
    customer_average DECIMAL(18,2),
    spending_multiple DECIMAL(10,2),
    risk_level VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
Problem:
Scan all historical transactions and identify transactions
that are unusually large compared to the customer's normal
spending behaviour.

Business Context:
Banks periodically run fraud scans on historical transaction
data to identify abnormal customer behaviour and generate
alerts for investigation.
*/

DELIMITER $$
CREATE PROCEDURE DailyFraudScanner()
BEGIN
    INSERT INTO fraud_alerts
    (
        transaction_id,
        account_id,
        amount_usd,
        transaction_date,
        customer_average,
        spending_multiple,
        risk_level
    )
    SELECT
        t.transaction_id, t.account_id, t.amount_usd, t.transaction_date, ca.avg_transaction,
		ROUND(t.amount_usd / ca.avg_transaction, 2) AS spending_multiple,
        CASE
            WHEN t.amount_usd >= ca.avg_transaction * 5 THEN 'HIGH'
            WHEN t.amount_usd >= ca.avg_transaction * 3 THEN 'MEDIUM'
            ELSE 'LOW'
        END
    FROM transactions t
    JOIN
    ( SELECT account_id, AVG(amount_usd) AS avg_transaction
        FROM transactions
        GROUP BY account_id
        HAVING COUNT(*) >= 5
    ) ca
    ON t.account_id = ca.account_id
    WHERE
        t.amount_usd >= ca.avg_transaction * 3;
END $$
DELIMITER ;
CALL DailyFraudScanner();
-- Every night at 2:00 AM, the bank wants to answer one question:
-- "Which transactions from today deserve investigation?"

-- ==========================================================
-- Example
-- ==========================================================
SELECT *
FROM fraud_alerts
ORDER BY spending_multiple DESC;
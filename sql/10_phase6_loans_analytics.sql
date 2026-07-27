-- ==========================================================
-- Business Problem 1: Largest Credit Exposure
-- ==========================================================

/*
Problem:
Identify customers with the highest total outstanding loan
exposure.

Business Context:
Banks continuously monitor customers with the largest total
loan exposure to manage concentration risk, prioritize credit
reviews, and ensure lending limits are not exceeded.
*/
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(l.loan_id) AS total_loans,
    ROUND(SUM(l.loan_amount),2) AS total_loan_exposure,
    ROUND(AVG(l.loan_amount),2) AS average_loan_amount,
    ROUND(MAX(l.loan_amount),2) AS largest_single_loan
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_loan_exposure DESC;
/*
Insight:
Highlights customers with the highest outstanding borrowing,
helping credit risk teams monitor concentration risk and
prioritize periodic loan portfolio reviews.
*/

-- ==========================================================
-- Business Problem 2: High Loan Exposure with Poor Credit Scores
-- ==========================================================

/*
Problem:
Identify customers with high loan exposure despite having
below-average credit scores.

Business Context:
Banks closely monitor borrowers with large outstanding loans
and weaker credit profiles, as these customers present higher
default risk and may require additional review or monitoring.
*/

SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.credit_score,
	COUNT(l.loan_id) AS total_loans,
	ROUND(SUM(l.loan_amount),2) AS total_loan_exposure,
    ROUND(AVG(l.interest_rate),2) AS average_interest_rate
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY c.customer_id, customer_name, c.credit_score
HAVING
    SUM(l.loan_amount) >= 50000
    AND c.credit_score < 650
ORDER BY
    total_loan_exposure DESC;
/*
Insight:
Identifies customers with significant borrowing despite lower
credit scores, enabling credit risk teams to prioritize
portfolio reviews and monitor potential default risk.
*/

-- ==========================================================
-- Business Problem 3: Customers with High Debt but Low Deposits
-- ==========================================================

/*
Problem:
Identify customers whose total outstanding loans exceed their
total account deposits.

Business Context:
Customers carrying significantly more debt than deposits may
present higher financial risk. Banks monitor these customers
to support proactive credit reviews and relationship
management.
*/

WITH CustomerDeposits AS
(
    SELECT customer_id, SUM(balance_usd) AS total_deposits
	FROM accounts
    GROUP BY customer_id
),
CustomerLoans AS
(
    SELECT
        customer_id,
        SUM(loan_amount) AS total_loans
    FROM loans
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    ROUND(cd.total_deposits,2) AS total_deposits,
    ROUND(cl.total_loans,2) AS total_loans,
    ROUND(cl.total_loans - cd.total_deposits,2) AS debt_gap
FROM customers c
JOIN CustomerDeposits cd
    ON c.customer_id = cd.customer_id
JOIN CustomerLoans cl
    ON c.customer_id = cl.customer_id
WHERE cl.total_loans > cd.total_deposits
ORDER BY debt_gap DESC;

/*
Insight:
Highlights customers whose debt exceeds their deposits,
supporting credit risk assessments and proactive financial
monitoring.
*/

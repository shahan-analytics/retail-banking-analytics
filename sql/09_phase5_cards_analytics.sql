SELECT * FROM banking_analytics_db.cards;
-- ==========================================================
-- Business Problem 1: Customers With Cards Expiring Soon
-- ==========================================================

/*
Problem:
Identify customers whose debit or credit cards are approaching
their expiration date.

Business Context:
Banks proactively contact customers with cards nearing
expiration to ensure timely renewal, prevent service
interruptions, and maintain a seamless customer experience.
*/

SELECT c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    cd.card_id, cd.card_type, cd.expiration_date,
	DATEDIFF(cd.expiration_date, CURDATE()) AS days_until_expiry
FROM cards cd
JOIN accounts a
    ON cd.account_id = a.account_id
JOIN customers c
    ON a.customer_id = c.customer_id
WHERE
    cd.expiration_date BETWEEN
        CURDATE()
        AND DATE_ADD(CURDATE(), INTERVAL 90 DAY)
ORDER BY
    days_until_expiry ASC;

/*
Insight:
Generates a renewal list of customers whose cards expire
within the next 90 days, enabling the bank to proactively
replace cards and minimize customer disruption.
*/

-- ==========================================================
-- Business Problem 2: High-Value Customers With Cards Expiring Soon
-- ==========================================================

/*
Problem:
Identify customers with high account balances whose cards
are expiring within the next 90 days.

Business Context:
Banks prioritize renewal of cards belonging to high-value
customers to maintain customer satisfaction and prevent
service disruptions.
*/

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    cd.card_id,
    cd.card_type,
    ROUND(a.balance_usd,2) AS account_balance,
    cd.expiration_date,
    DATEDIFF(cd.expiration_date,CURDATE()) AS days_until_expiry
FROM cards cd
JOIN accounts a
    ON cd.account_id = a.account_id
JOIN customers c
    ON a.customer_id = c.customer_id
WHERE
    cd.expiration_date BETWEEN
    CURDATE()
    AND DATE_ADD(CURDATE(),INTERVAL 90 DAY)
    AND a.balance_usd >= 10000
ORDER BY
    account_balance DESC,
    days_until_expiry ASC;

/*
Insight:
Identifies high-value customers whose cards require renewal,
allowing the bank to prioritize replacement and maintain
excellent customer service.
*/

-- ==========================================================
-- Business Problem 3: Customers Holding Multiple Cards
-- ==========================================================

/*
Problem:
Identify customers who own multiple bank cards.

Business Context:
Customers holding multiple cards typically have a stronger
relationship with the bank. They are valuable customers for
cross-selling premium cards, reward programs, and other
financial products.
*/

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(cd.card_id) AS total_cards,
    GROUP_CONCAT(DISTINCT cd.card_type
                 ORDER BY cd.card_type
                 SEPARATOR ', ') AS card_types
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN cards cd
    ON a.account_id = cd.account_id
GROUP BY
    c.customer_id,
    customer_name
HAVING
    COUNT(cd.card_id) > 1
ORDER BY
    total_cards DESC;
/*
Insight:
Identifies customers owning multiple cards, helping the bank
recognize highly engaged customers and prioritize them for
premium banking services and personalized offers.
*/

-- ==========================================================
-- Business Problem 4: Card Portfolio Distribution
-- ==========================================================

/*
Problem:
Analyze the bank's card portfolio by card type.

Business Context:
Banks monitor the distribution of issued cards to understand
product adoption, forecast renewal volumes, and support
future card issuance strategies.
*/

SELECT
    card_type,
    COUNT(*) AS total_cards,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cards), 2) AS portfolio_percentage
FROM cards
GROUP BY card_type
ORDER BY total_cards DESC;

/*
Insight:
Provides a portfolio-level view of card issuance by card type,
helping the bank understand product adoption and support
renewal planning.
*/
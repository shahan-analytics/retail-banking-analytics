CREATE INDEX idx_accounts_customer
ON accounts(customer_id);

CREATE INDEX idx_cards_account
ON cards(account_id);

CREATE INDEX idx_loans_customer
ON loans(customer_id);

CREATE INDEX idx_transactions_account
ON transactions(account_id);

CREATE INDEX idx_transactions_merchant
ON transactions(merchant_id);

CREATE INDEX idx_transactions_date
ON transactions(transaction_date);


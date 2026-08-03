### Dataset Information
The dataset used in this project is sourced from Kaggle:

- Synthetic Retail Banking Dataset  
  https://www.kaggle.com/datasets/akrambelha/synthetic-banking-dataset-csv-sql-sqlite  

Due to file size constraints, the complete dataset is not included in this repository.

---

### Data Description
This dataset simulates a real-world retail banking ecosystem and is structured as a **multi-table relational database** consisting of 7 interconnected entities.

The data models core banking operations including customers, accounts, transactions, lending, and merchant interactions, enabling end-to-end analytical workflows.

---

### Schema Overview

#### 1. Customers
Stores customer demographic and credit-related information.

- `customer_id` – Unique customer identifier  
- `first_name`, `last_name`  
- `email`, `city`  
- `credit_score` – Customer creditworthiness indicator  
- `created_at` – Customer onboarding date  

---

#### 2. Accounts
Represents bank accounts owned by customers.

- `account_id` – Unique account identifier  
- `customer_id` – Foreign key linking to customers  
- `account_type` – Checking / Savings  
- `balance_usd` – Current account balance  
- `open_date` – Account creation date  

---

#### 3. Loans
Captures customer loan information.

- `loan_id` – Unique loan identifier  
- `customer_id` – Linked customer  
- `loan_amount`  
- `interest_rate`  
- `start_date`  

---

#### 4. Cards
Represents debit and credit cards linked to accounts.

- `card_id` – Unique card identifier  
- `account_id` – Linked account  
- `card_type` – Debit / Credit  
- `expiration_date`  

---

#### 5. Transactions
Records financial activity across accounts.

- `transaction_id` – Unique transaction identifier  
- `account_id` – Linked account  
- `merchant_id` – Associated merchant  
- `amount_usd` – Transaction amount  
- `transaction_date` – Timestamp of transaction  

---

#### 6. Merchants
Contains merchant and vendor details.

- `merchant_id` – Unique merchant identifier  
- `merchant_name`  
- `city`  

---

#### 7. Branches
Represents banking branch operations.

- `branch_id` – Unique branch identifier  
- `branch_name`  
- `manager_name`  

---

### Key Relationships
- Customers → Accounts (1:N)  
- Customers → Loans (1:N)  
- Accounts → Transactions (1:N)  
- Accounts → Cards (1:N)  
- Transactions → Merchants (N:1)  

This relational design enables complex joins and cross-domain analysis across customer behavior, financial activity, and institutional operations.

---

### Usage
To reproduce this project:

1. Download the dataset from the provided Kaggle link  
2. Load the data into your SQL environment (Snowflake / PostgreSQL / MySQL)  
3. Use the scripts in the `/sql` directory to create tables and relationships  
4. Execute analytical queries to derive business insights  

---

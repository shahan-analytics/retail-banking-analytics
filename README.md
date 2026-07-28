## Retail Banking Analytics
SQL-driven analytics project simulating a retail banking environment, focused on uncovering customer behaviour, transaction patterns, and financial product performance through structured query design.

### Objective
To design and implement a structured analytical framework for retail banking data, enabling deep-dive analysis into customer activity, financial behaviour, and product utilisation using SQL.

### Business Context
Retail banks rely on data-driven insights to optimise customer engagement, manage financial risk, and improve product performance. 
This project replicates a real-world analytical environment where transactional and customer data are leveraged to support strategic decision-making across core banking functions.

### Data Source
The dataset used in this project is sourced from Kaggle:
- Synthetic Retail Banking Dataset  
  https://www.kaggle.com/datasets/akrambelha/synthetic-banking-dataset-csv-sql-sqlite
The dataset was ingested and transformed into a relational schema to support structured analytical workflows.

### Data Modeling
A relational schema was designed to normalize and structure the dataset into multiple interconnected tables representing customers, accounts, transactions, cards, and loans.
The entity relationships and table dependencies were modeled using Lucidchart to ensure referential integrity and efficient query performance.
The schema design follows normalized principles to minimize redundancy while enabling scalable analytical queries.

<img src="docs/schema.png" width="600">

### Data Architecture & Preparation
- Database schema design and normalisation
- Data ingestion and transformation from raw sources
- Data validation to ensure consistency and integrity
- Indexing strategies applied for query performance optimisation
  
### Analytical Framework
The project is structured into multiple analytical phases, each targeting a specific business domain within retail banking.

#### Phase 1: Business Overview
- Evaluated customer distribution across demographic and geographic dimensions  
- Analysed account composition by type, status, and lifecycle stage  
- Established baseline KPIs for overall banking activity
  
#### Phase 2: Customer Analytics
- Performed customer segmentation based on transactional behaviour and account activity  
- Identified high-value and high-engagement customer cohorts  
- Analysed behavioural patterns to support targeted decision-making
  
#### Phase 3: Transaction Analytics
- Assessed transaction volume and value distributions across channels  
- Identified dominant transaction categories and usage trends  
- Analysed temporal patterns to uncover peak activity periods
  
#### Phase 4: Account Analytics
- Evaluated account utilisation and balance distribution  
- Identified dormant and highly active accounts  
- Analysed relationships between account types and transaction behaviour  

#### Phase 5: Card Analytics
- Analysed card usage patterns across customer segments  
- Evaluated transaction frequency and spending behaviour for card holders  
- Identified key trends in card-based financial activity
  
#### Phase 6: Loan Analytics
- Analysed loan distribution across product categories  
- Evaluated repayment behaviour and outstanding balances  
- Identified potential indicators of credit risk
  
#### Phase 7: Stored Procedures
- Developed reusable SQL procedures for modular and scalable analysis  
- Automated repetitive analytical workflows  
- Improved maintainability and execution efficiency  

### Key Insights
- Customer deposits are concentrated among a small number of high-value customers.
- Behavioural transaction analysis identifies anomalous spending patterns for fraud detection.
- Dormant high-balance accounts present customer engagement opportunities.
- Low-balance, high-activity accounts indicate potential overdraft risk.
- Customers with loans exceeding deposits highlight elevated financial risk.
- Card expiry analysis supports proactive renewal planning.
- Customer financial summaries and risk scoring enable faster relationship and credit decisions.

### Repository Structure
- `sql/` - database setup, validation, indexing, and analytical queries  
- `dataset/` - dataset reference and sourcing information
- `docs/` - schema diagram and supporting visuals
- 'results/' -
  
### Skills Demonstrated
- Advanced SQL querying and optimisation  
- Data modelling and schema design  
- Analytical problem structuring  
- Behavioural and financial data analysis  
- Performance tuning using indexing  
- Modular query design using stored procedures  

### Tools & Technologies
SQL (MySQL) • Relational Database Systems • Data Modelling (Lucidchart) • Excel (Data Validation)

### Author
Shahan

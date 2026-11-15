-- =====================================================
-- Telco Customer Churn Analysis (MySQL)
-- Dataset: IBM Telco Customer Churn (Kaggle), 7043 rows
-- =====================================================

-- -----------------------------------------------------
-- STEP 1: Database and table setup
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS telco;
USE telco;

DROP TABLE IF EXISTS telco_churn;

CREATE TABLE telco_churn (
  customerID VARCHAR(50),
  gender VARCHAR(20),
  SeniorCitizen INT,
  Partner VARCHAR(10),
  Dependents VARCHAR(10),
  tenure INT,
  PhoneService VARCHAR(10),
  MultipleLines VARCHAR(30),
  InternetService VARCHAR(30),
  OnlineSecurity VARCHAR(30),
  OnlineBackup VARCHAR(30),
  DeviceProtection VARCHAR(30),
  TechSupport VARCHAR(30),
  StreamingTV VARCHAR(30),
  StreamingMovies VARCHAR(30),
  Contract VARCHAR(30),
  PaperlessBilling VARCHAR(10),
  PaymentMethod VARCHAR(50),
  MonthlyCharges DECIMAL(10,2),
  TotalCharges VARCHAR(20),   -- loaded as text first because some values are blank
  Churn VARCHAR(10)
);

-- -----------------------------------------------------
-- STEP 2: Load the CSV
-- Note: OPT_LOCAL_INFILE=1 must be set in the Workbench connection (Advanced tab)
-- Note: update the file path below to match your machine (use forward slashes)
-- -----------------------------------------------------
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/hp5cd/Downloads/WA_Fn-UseC_-Telco-Customer-Churn.csv'
INTO TABLE telco_churn
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_rows FROM telco_churn;   -- expected: 7043

-- -----------------------------------------------------
-- STEP 3: Data cleaning
-- -----------------------------------------------------

-- 3a) Windows line endings left a hidden \r character in the Churn column
UPDATE telco_churn
SET Churn = TRIM(REPLACE(Churn, '\r', ''));

-- Check: expected Yes = 1869, No = 5174
SELECT Churn, LENGTH(Churn) AS len, COUNT(*) AS cnt
FROM telco_churn
GROUP BY Churn;

-- 3b) Blank TotalCharges values belong to new customers (tenure = 0), so set them to 0
SELECT COUNT(*) AS blank_totalcharges
FROM telco_churn
WHERE TRIM(TotalCharges) = '';

SET SQL_SAFE_UPDATES = 0;

UPDATE telco_churn
SET TotalCharges = '0'
WHERE TRIM(TotalCharges) = '';

ALTER TABLE telco_churn MODIFY TotalCharges DECIMAL(10,2);

-- 3c) Duplicate check (expected: 0)
SELECT COUNT(*) - COUNT(DISTINCT customerID) AS duplicates
FROM telco_churn;

-- -----------------------------------------------------
-- STEP 4: Analysis
-- -----------------------------------------------------

-- Q1) Overall churn rate (about 26.54%)
SELECT ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate
FROM telco_churn;

-- Q2) Churn by contract type
SELECT Contract,
       COUNT(*) AS customers,
       SUM(Churn = 'Yes') AS churned,
       ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_pct
FROM telco_churn
GROUP BY Contract
ORDER BY churn_pct DESC;

-- Q3) Churn by tenure group
SELECT CASE WHEN tenure <= 12 THEN '1) 0-1 yr'
            WHEN tenure <= 36 THEN '2) 1-3 yr'
            ELSE '3) 3+ yr' END AS tenure_group,
       COUNT(*) AS customers,
       ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_pct
FROM telco_churn
GROUP BY tenure_group
ORDER BY tenure_group;

-- Q4) Churn by internet service type
SELECT InternetService,
       COUNT(*) AS customers,
       ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_pct
FROM telco_churn
GROUP BY InternetService
ORDER BY churn_pct DESC;

-- Q5) Fiber vs DSL: average monthly charge and share of customers without TechSupport
SELECT InternetService,
       ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge,
       ROUND(100 * SUM(TechSupport = 'No') / COUNT(*), 2) AS pct_without_techsupport
FROM telco_churn
WHERE InternetService <> 'No'
GROUP BY InternetService;

-- Q6) Churn by TechSupport
SELECT TechSupport,
       COUNT(*) AS customers,
       ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_pct
FROM telco_churn
GROUP BY TechSupport
ORDER BY churn_pct DESC;

-- Q7) High-risk segment (CTE)
-- Month-to-month contract + first-year customer + Fiber optic + no TechSupport
WITH high_risk AS (
  SELECT *
  FROM telco_churn
  WHERE Contract = 'Month-to-month'
    AND tenure <= 12
    AND InternetService = 'Fiber optic'
    AND TechSupport = 'No'
)
SELECT COUNT(*) AS customers,
       SUM(Churn = 'Yes') AS churned,
       ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_pct
FROM high_risk;

-- =====================================================
-- KEY FINDINGS
-- Overall churn: 26.54%
-- Month-to-month: 42.71% vs Two year: 2.83%
-- Tenure 0-1 yr: 47.44% vs 3+ yr: 11.93%
-- Fiber optic: 41.89% vs DSL: 18.96%
-- No TechSupport: 41.64% vs TechSupport: 15.17%
-- High-risk segment: 71.07% churn (833 customers, 592 churned)
-- =====================================================

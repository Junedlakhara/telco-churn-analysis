# Telco Customer Churn Analysis

SQL and Excel analysis of customer churn for a telecom company, built to find out **who is leaving, why, and what the company can do about it**.

## Problem Statement

A telecom company loses roughly 1 in 4 customers. The goal of this project is to identify the customer segments with the highest churn and recommend retention actions.

## Dataset

- **Source:** [IBM Telco Customer Churn (Kaggle)](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
- **Size:** 7,043 customers, 21 columns
- **Key columns:** tenure, Contract, InternetService, TechSupport, MonthlyCharges, TotalCharges, Churn

## Tools Used

- **MySQL** (MySQL Workbench) for data loading, cleaning and analysis
- **Excel** for pivot tables and charts

## Data Cleaning

- Loaded the CSV with `LOAD DATA LOCAL INFILE` and checked the row count (7,043).
- Removed a hidden carriage return (`\r`) in the `Churn` column caused by Windows line endings.
- 11 rows had blank `TotalCharges`. All were new customers (tenure = 0), so the blanks were replaced with 0 and the column converted to `DECIMAL`.
- Checked for duplicate customer IDs (none found).

## SQL Concepts Used

`GROUP BY`, `CASE WHEN`, conditional aggregation, CTE, `ROUND`, `COUNT` / `SUM` / `AVG`

## Key Findings

| Factor | Result |
|---|---|
| Overall churn rate | **26.54%** |
| Month-to-month contract | **42.71%** churn vs 2.83% for two-year contracts |
| Tenure 0-12 months | **47.44%** churn vs 11.93% for customers with 3+ years |
| Fiber optic internet | **41.89%** churn vs 18.96% for DSL |
| No TechSupport | **41.64%** churn vs 15.17% with TechSupport |

**Why do Fiber optic customers leave more?** They pay more (average monthly charge 91.50 vs 58.10 for DSL), and 72% of them have no TechSupport (vs 51% for DSL). The data suggests they pay a premium but do not get help when problems occur.

### High-Risk Segment

Customers who have **all four** traits (month-to-month contract, first-year customer, Fiber optic, no TechSupport):

- **833 customers** (about 12% of the base)
- **71.07% churn rate**, against 26.54% overall
- **592 of the 1,869** churned customers (about 32% of all churn) come from this one segment

## Recommendations

1. Offer discounts or perks to move month-to-month customers onto 1-year contracts. About 89% of all churned customers were on month-to-month plans.
2. Add a welcome programme for new customers (follow-up calls, onboarding offers) because the first year carries the highest risk.
3. Bundle free or discounted TechSupport for the first 3-6 months, especially for Fiber optic customers.
4. Target the 833 high-risk customers first with retention offers.

*Note: these findings show correlation, not proven causes. An A/B test of the retention offers would confirm what actually reduces churn.*

## Files

- `telco_churn_analysis.sql`: full SQL script (setup, cleaning, analysis)
- `telco_churn_pivots.xlsx`: Excel pivot tables and charts
- `screenshots/`: query results and charts

## How to Run

1. Download the dataset from Kaggle.
2. Open `telco_churn_analysis.sql` in MySQL Workbench.
3. Update the CSV file path in the `LOAD DATA` statement.
4. Run the script step by step.

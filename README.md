# used-car-price-prediction

A machine learning project that predicts used car prices from ~427,000 Craigslist 
vehicle listings, using SQL-based data cleaning and a comparison of regression models.

## Overview

This project cleans and models a large, messy real-world dataset of used car listings 
to predict price from features like manufacturer, model, vehicle age, odometer, and 
condition. The final tuned Random Forest model explains 91% of price variance 
(R²: 0.91) and reduces prediction error by roughly 70% compared to a naive baseline.

## Tech Stack

- **PostgreSQL** — data cleaning, filtering, and imputation
- **Python** — pandas, numpy, scikit-learn, XGBoost, scipy, seaborn, matplotlib
- **SQLAlchemy** — database connection
- **python-dotenv** — credential management

## Methodology

1. **Data Cleaning (SQL)** — Filtered implausible price, odometer, and year values, 
   excluded pre-1990 listings (different pricing market than daily-driver depreciation), 
   and imputed missing `cylinders`/`manufacturer` using mode lookups keyed on related 
   columns. Other categorical fields with no reliable predictor (`condition`, 
   `title_status`, `drive`, `transmission`) were preserved as an explicit `unknown` 
   category rather than guessed.

2. **Feature Engineering** — Derived `vehicle_age` from `year` for better interpretability; 
   target-encoded the high-cardinality `model` column rather than one-hot encoding it.

3. **Modeling** — Compared four approaches on a held-out test set: a naive mean baseline, 
   linear regression, random forest, and XGBoost. Each was evaluated with RMSE, MAE, and 
   R² to confirm real predictive value beyond guessing the average price.

4. **Hyperparameter Tuning** — Used `RandomizedSearchCV` to tune random forest and 
   XGBoost, widening search ranges where initial results suggested the model wanted 
   more capacity than originally allowed.

## Results

| Model                    | RMSE     | MAE     | R²    |
|----------------------------|----------|---------|-------|
| Naive mean baseline        | $14,778  | $11,514 | —     |
| Linear Regression          | $7,620   | $4,778  | 0.731 |
| Random Forest (untuned)    | $4,689   | $2,213  | 0.897 |
| XGBoost (untuned)          | $5,264   | $2,864  | 0.869 |
| **Random Forest (tuned)**  | **$4,404** | **$1,825** | **0.910** |
| XGBoost (tuned)            | $4,428   | $2,102  | 0.909 |

**Final model: Random Forest (tuned)** — selected over XGBoost for its slightly 
stronger performance and more consistent, reproducible results across runs.

## Key Findings

- **Model, vehicle age, and odometer** are the three strongest predictors, together 
  accounting for roughly 65% of the model's total feature importance, which is consistent with 
  real-world used car depreciation dynamics.
- **Missingness carries signal.** Several "unknown" category indicators (e.g. 
  `condition_unknown`) showed meaningful feature importance, validating the decision to 
  preserve missing data as its own category rather than imputing or dropping it.

## Limitations

- No data on accident history, exact trim level, or listing photo quality, which are known price 
  drivers not available in this dataset.
- No geographic/regional pricing signal.
- Reflects a 2021 snapshot; used car pricing shifts with broader market conditions 
  (e.g. supply chain disruptions, interest rates).
- Scoped to vehicles from 1990 onward; classic/collector cars follow different pricing 
  dynamics and were excluded (~1.7% of filtered data).

## Setup

```bash
pip install pandas sqlalchemy scikit-learn xgboost python-dotenv psycopg2-binary
```

Create a `.env` file with your database credentials:

```
DB_PASSWORD=your_password_here
```

Run the cleaning SQL against your PostgreSQL instance, then open `used_cars_notebook.ipynb`.
# Use a Statistical Model

## Purpose
Fits a statistical count regression model to identify key factors associated with hourly check-in volume and predict expected customer foot traffic for staffing decisions.

## When to Use
Activate when the user asks what factors predict hourly check-ins, requests a statistical regression model, or wants to model customer traffic volume based on day, hour, ratings, and service type.

## Required Inputs
- Outcome variable: `checkins` (overdispersed non-negative count)
- Predictor variables: `day`, `hour`, `stars`, `log_review_count`, `service_type`
- Dataset `data/yelp_analysis_data.rds`

## Files Used
- `R/skill_03_statistical_model.R`
- Saved model object: `data/nb_model.rds`
- Output visual asset: `output/skill_03_model_predictions.png`

## Method
Negative Binomial Regression (`MASS::glm.nb`) to handle severe overdispersion (variance >> mean) in count data. Model performance evaluated via McFadden's Pseudo R², RMSE, and MAE.

## Procedure
1. Check that outcome variance exceeds mean check-in volume (confirming overdispersion).
2. Fit Negative Binomial model predicting check-ins from shift day, shift hour, star rating, log review volume, and service type.
3. Compute Pseudo R², RMSE, and MAE.
4. Save fitted model object to `data/nb_model.rds`.
5. Return model summary table and predicted vs. actual plot.

## Validation
- Validate overdispersion: If outcome variance is less than or equal to mean, issue a warning that a standard Poisson model may suffice.
- Validate dataset complete cases before fitting.

## Output
- Model coefficient table (Incidence Rate Ratios, standard errors, p-values).
- Evaluation metrics (Pseudo R², RMSE, MAE).
- Predicted vs. actual check-in scatterplot.

## Interpretation
Peak dinner shifts (6 PM - 8 PM) and weekend days (Friday/Saturday) demonstrate the strongest positive association with hourly check-in volume. Each unit log-increase in review volume also significantly increases expected traffic.

## Limitation
Observational regression models identify statistical associations, not direct causal relationships. The model does not capture external factors such as local weather, sporting events, marketing promotions, or road construction.

# Time Series Forecast

## Purpose
Generates a 48-hour ahead shift traffic forecast for a selected restaurant location and converts predicted check-in volume into actionable staffing recommendations (e.g., Add 1 Staff, Add 2+ Staff).

## When to Use
Activate when the user asks for a future shift forecast, traffic predictions for next weekend, or specific hourly staffing requirements for a target location.

## Required Inputs
- Target location identifier (`business_id` or `name`)
- Fitted Negative Binomial model (`data/nb_model.rds`)
- Operational threshold (e.g., 75th percentile of historical check-in volume)

## Files Used
- `R/skill_04_time_series_forecast.R`
- `data/nb_model.rds`
- Output visual asset: `output/skill_04_staffing_forecast.png`

## Method
Predictive time-series horizon grid evaluation using the fitted Negative Binomial count model. Predicted hourly traffic is benchmarked against historical operational quantiles to generate shift alert rules.

## Procedure
1. Verify `data/nb_model.rds` and `data/yelp_analysis_data.rds` exist.
2. Select target location (or top volume location if unspecified).
3. Construct a 48-hour future shift horizon (Friday & Saturday hours 0-23).
4. Predict hourly check-in volume and assign staffing action labels based on historical 75th percentile thresholds.
5. Generate hourly forecast line plot with colored alert threshold indicators.

## Validation
- Validate model prerequisite: If `data/nb_model.rds` is missing, return error: *"VALIDATION ERROR: Fitted model object 'data/nb_model.rds' not found. Please run Skill 3 (R/skill_03_statistical_model.R) first."*
- Validate that the specified business exists in the dataset.

## Output
- 48-hour forecast schedule table with staffing action tags.
- Line plot visualization featuring the 75th percentile threshold line and color-coded shift alert points.

## Interpretation
Identifies specific peak hours (e.g., Friday 7 PM - 9 PM) where predicted foot traffic exceeds operational thresholds, advising the regional manager to add 1 to 2 additional shift workers to prevent service delays and negative reviews.

## Limitation
Forecasts assume normal operational conditions repeating historical day-of-week and hour-of-day patterns. Unscheduled local events, holidays, or sudden weather changes will cause actual traffic to deviate from model predictions.

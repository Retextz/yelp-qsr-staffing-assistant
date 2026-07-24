# Anomaly Detection

## Purpose
Identifies statistical traffic anomalies and ranks restaurant locations by operational shift volatility to flag shifts that experienced unexpected traffic spikes or drops.

## When to Use
Activate when the user asks which locations are acting strange, requests anomaly detection, asks for traffic outliers, or wants a shift volatility ranking across locations.

## Required Inputs
- Dataset `data/yelp_analysis_data.rds`
- Fitted model `data/nb_model.rds`
- Threshold rules: Standardized residual |std_res| > 3.0 or values exceeding 2.5x location IQR upper fence.

## Files Used
- `R/skill_06_anomaly_detection.R`
- `data/nb_model.rds`
- Output visual assets: `output/skill_06_anomaly_heatmap.png`, `output/skill_06_residual_scatter.png`

## Method
Dual-layer anomaly detection combining model-based standardized residual thresholding (|std_res| > 3.0) with location-specific contextual Interquartile Range (IQR) fence filtering. Computes shift volatility scores per business.

## Procedure
1. Verify model object `data/nb_model.rds` exists.
2. Compute predicted check-ins and model residuals for all shifts.
3. Apply statistical and contextual IQR anomaly flags.
4. Calculate shift volatility percentage per business location.
5. Render Day x Hour anomaly heatmap and residual scatterplot.

## Validation
- Validate model existence: If `data/nb_model.rds` is missing, return error: *"VALIDATION ERROR: Fitted model object 'data/nb_model.rds' not found. Please run Skill 3 first."*
- Validate minimum 10 total shifts per business location before computing volatility rank.

## Output
- Shift volatility ranking table (Top locations with highest % anomalous shifts).
- Anomaly rate heatmap across Day of Week and Hour of Day.
- Model residual scatterplot highlighting flagged anomaly shifts.

## Interpretation
Flags shifts where actual foot traffic significantly exceeded model expectations (e.g., Friday 10 PM traffic 3x higher than expected). High-volatility locations require flexible, on-call staffing agreements rather than fixed schedules.

## Limitation
Anomalies represent statistical outliers, not necessarily negative operational failures. A positive traffic anomaly may indicate a successful marketing promotion or local event rather than a staffing crisis.

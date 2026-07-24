# Explore Data

## Purpose
Helps a regional operations manager understand the overall baseline foot traffic (check-ins), customer star ratings, and data quality across all open food and restaurant locations before making operational changes.

## When to Use
Activate when the user requests a high-level overview, summary statistics, overall distributions of check-ins or ratings, or data quality/missingness checks across locations.

## Required Inputs
- Dataset `data/yelp_analysis_data.rds`
- Required variables: `business_id`, `checkins`, `stars`, `day`, `hour`, `service_type`

## Files Used
- `R/skill_01_explore_data.R`
- `data/yelp_analysis_data.rds`
- Output visual assets: `output/skill_01_checkins_by_day.png`, `output/skill_01_ratings_hist.png`

## Method
Univariate and bivariate exploratory data analysis: calculate mean, median, standard deviation, log-scale boxplot distributions by day of week, star rating histograms against a 4.0 benchmark, and missing-value counts.

## Procedure
1. Verify that `data/yelp_analysis_data.rds` exists and has ≥100 observations.
2. Confirm all required variables exist and contain valid numeric ranges (`stars` between 1.0 and 5.0, `checkins` ≥ 0).
3. Execute `R/skill_01_explore_data.R` using `Rscript`.
4. Return summary statistics table and generated distribution plots.
5. Provide practical interpretation and operational limitations.

## Validation
- Validate that the dataset file exists. If missing, return error: *"VALIDATION ERROR: Processed dataset 'data/yelp_analysis_data.rds' not found. Please run R/00_preprocess_yelp.R first."*
- Validate that the dataset contains at least 100 observations.

## Output
- Summary statistics table (mean, median, SD, min, max check-ins, mean star rating).
- Boxplot visualization of check-ins by day of week.
- Histogram of star ratings relative to the 4.0 quality benchmark.

## Interpretation
Explain baseline operational metrics in plain language (e.g., peak check-in volume occurs on weekends with Saturday averaging highest hourly volume; overall mean star rating across locations is ~3.7).

## Limitation
Yelp check-in counts are self-reported foot traffic proxies that depend on customer app engagement. They undercount total physical customer volume and may underrepresent demographics with lower smartphone usage.

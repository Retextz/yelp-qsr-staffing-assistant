# Compare Two Groups

## Purpose
Evaluates whether foot traffic (hourly check-ins) and customer star ratings significantly differ between Quick Service Restaurants (QSR) and Full Service Restaurants to inform tailored staffing models.

## When to Use
Activate when the user asks to compare two service categories, evaluate differences between quick service vs. full service restaurants, or perform two-group hypothesis testing.

## Required Inputs
- Dataset `data/yelp_analysis_data.rds`
- Grouping variable: `service_type` (must contain `Quick Service` and `Full Service`)
- Outcome variables: `checkins` (numeric count) and `stars` (numeric rating)

## Files Used
- `R/skill_02_compare_groups.R`
- `data/yelp_analysis_data.rds`
- Output visual asset: `output/skill_02_group_comparison.png`

## Method
Welch's two-sample t-test (unequal variances) for hourly check-in volume and business-level star ratings, supplemented with Cohen's d effect size calculations and 95% confidence intervals.

## Procedure
1. Check that `service_type` has exactly two comparison groups.
2. Confirm both groups have at least 30 observations.
3. Run `R/skill_02_compare_groups.R`.
4. Extract mean values, estimated mean differences, 95% CIs, p-values, and Cohen's d.
5. Return summary table, boxplot visualization, and plain-language operational advice.

## Validation
- Validate group sample sizes: If either comparison group has <30 observations, halt and return error: *"VALIDATION ERROR: Each comparison group must contain at least 30 observations for valid parametric inference."*
- Validate that outcome variables are numeric.

## Output
- Statistical comparison table (group means, difference estimate, 95% CI, p-value, Cohen's d).
- Group comparison boxplot visualization.

## Interpretation
Quick-service restaurants experience higher check-in volume per hour than full-service locations due to faster customer turnover. However, average star ratings remain comparable, proving that high volume does not inherently degrade customer satisfaction if operations are staffed appropriately.

## Limitation
Categories are derived from Yelp category tags, which may misclassify hybrid concepts (e.g., fast-casual dining). Statistical significance reflects population averages and does not replace location-specific shift planning.

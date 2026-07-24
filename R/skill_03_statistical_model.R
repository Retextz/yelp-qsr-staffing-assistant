# ============================================
# Skill 03: Use a Statistical Model
# File: R/skill_03_statistical_model.R
# ============================================

library(dplyr)
library(ggplot2)
library(readr)
library(MASS)
library(broom)

cat("Running Skill 03: Statistical Model...\n")

if (!file.exists("data/yelp_analysis_data.rds")) {
  stop("VALIDATION ERROR: Processed dataset 'data/yelp_analysis_data.rds' not found. Run R/00_preprocess_yelp.R first.")
}

data <- read_rds("data/yelp_analysis_data.rds")

# ---- Validation Check 3: Check Outcome Overdispersion ----
mean_y <- mean(data$checkins, na.rm = TRUE)
var_y <- var(data$checkins, na.rm = TRUE)

cat(sprintf("Outcome Mean: %.2f | Outcome Variance: %.2f\n", mean_y, var_y))

if (var_y <= mean_y) {
  cat("WARNING: Outcome is not overdispersed. Standard Poisson model may suffice.\n")
} else {
  cat("VALIDATION PASSED: Variance >> Mean confirms Negative Binomial regression is statistically appropriate over Poisson.\n")
}

# ---- Fit Negative Binomial Model ----
nb_model <- glm.nb(
  checkins ~ factor(day) + factor(hour) + stars + log_review_count + factor(service_type),
  data = data
)

summary_fit <- summary(nb_model)
print(summary_fit)

# ---- Model Fit Evaluation Metrics ----
null_model <- glm.nb(checkins ~ 1, data = data)
pseudo_r2 <- 1 - (as.numeric(logLik(nb_model)) / as.numeric(logLik(null_model)))

data$predicted_checkins <- predict(nb_model, newdata = data, type = "response")
rmse_val <- sqrt(mean((data$checkins - data$predicted_checkins)^2, na.rm = TRUE))
mae_val <- mean(abs(data$checkins - data$predicted_checkins), na.rm = TRUE)

cat(sprintf("\n=== MODEL EVALUATION ===\n"))
cat(sprintf("McFadden's Pseudo R²: %.4f\n", pseudo_r2))
cat(sprintf("Root Mean Squared Error (RMSE): %.2f check-ins/hour\n", rmse_val))
cat(sprintf("Mean Absolute Error (MAE): %.2f check-ins/hour\n", mae_val))

# ---- Save Fitted Model for Downstream Skills ----
saveRDS(nb_model, "data/nb_model.rds")

# ---- Visualization: Predicted vs Actual Checkins ----
p_model <- data %>%
  sample_n(min(5000, nrow(data))) %>%
  ggplot(aes(x = predicted_checkins, y = checkins)) +
  geom_point(alpha = 0.25, color = "#2B5C8F") +
  geom_abline(intercept = 0, slope = 1, color = "#D0021B", linetype = "dashed", linewidth = 1) +
  labs(title = "Negative Binomial Model: Predicted vs Actual Hourly Check-ins",
       subtitle = paste0("Pseudo R² = ", round(pseudo_r2, 3), " | RMSE = ", round(rmse_val, 2), " checkins/hr"),
       x = "Predicted Hourly Check-ins", y = "Actual Hourly Check-ins") +
  theme_minimal(base_size = 12)

ggsave("output/skill_03_model_predictions.png", p_model, width = 8, height = 5)

cat("Skill 03 executed successfully. Model saved to data/nb_model.rds and output plot saved to output/ directory.\n")

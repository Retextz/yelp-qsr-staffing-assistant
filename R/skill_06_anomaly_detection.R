# ============================================
# Skill 06: Anomaly Detection (Student Skill 3)
# File: R/skill_06_anomaly_detection.R
# ============================================

library(dplyr)
library(ggplot2)
library(readr)
library(MASS)

cat("Running Skill 06: Anomaly Detection & Volatility Scoring...\n")

if (!file.exists("data/yelp_analysis_data.rds") || !file.exists("data/nb_model.rds")) {
  stop("VALIDATION ERROR: Prerequisites missing. Run Skill 00 (Preprocessing) and Skill 03 (Model) first.")
}

data <- read_rds("data/yelp_analysis_data.rds")
nb_model <- read_rds("data/nb_model.rds")

# ---- Model Residual Anomaly Calculation ----
data$predicted_checkins <- predict(nb_model, newdata = data, type = "response")
data$residual <- data$checkins - data$predicted_checkins
data$std_residual <- scale(data$residual)[,1]

# Statistical anomaly (|std_residual| > 3)
data$anomaly_stat <- abs(data$std_residual) > 3.0

# Contextual IQR fence anomaly (per business location)
data <- data %>%
  group_by(business_id) %>%
  mutate(
    q1 = quantile(checkins, 0.25, na.rm = TRUE),
    q3 = quantile(checkins, 0.75, na.rm = TRUE),
    iqr = q3 - q1,
    upper_fence = q3 + 2.5 * iqr,
    anomaly_iqr = checkins > upper_fence
  ) %>%
  ungroup()

data$anomaly_combined <- data$anomaly_stat | data$anomaly_iqr

# ---- Anomaly Metrics ----
total_anomalies <- sum(data$anomaly_combined, na.rm = TRUE)
pct_anomalies <- 100 * mean(data$anomaly_combined, na.rm = TRUE)

cat(sprintf("\n=== ANOMALY DETECTION RESULTS ===\n"))
cat(sprintf("Total Anomalous Shifts Detected: %d (%.2f%% of all shifts)\n", total_anomalies, pct_anomalies))

# Top 10 Most Anomalous Locations (Volatility Rank)
anomaly_ranking <- data %>%
  group_by(business_id, name, city, service_type) %>%
  summarise(
    n_anomalies = sum(anomaly_combined, na.rm = TRUE),
    total_shifts = n(),
    volatility_score = round(100 * (sum(anomaly_combined, na.rm = TRUE) / n()), 2),
    avg_checkins = round(mean(checkins), 1),
    stars = mean(stars),
    .groups = "drop"
  ) %>%
  filter(total_shifts >= 10) %>%
  arrange(desc(volatility_score), desc(n_anomalies))

cat("\nTop 10 Locations by Shift Volatility Rank (% Anomalous Shifts):\n")
print(head(anomaly_ranking, 10))

# ---- Visualization 1: Anomaly Heatmap (Day x Hour) ----
p_heatmap <- data %>%
  group_by(day, hour) %>%
  summarise(anomaly_rate = mean(anomaly_combined, na.rm = TRUE) * 100, .groups = "drop") %>%
  ggplot(aes(x = hour, y = factor(day, levels = rev(c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))), fill = anomaly_rate)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#F7FBFF", high = "#D0021B") +
  labs(title = "Traffic Anomaly Rate Heatmap (% Unexpected Volume)",
       subtitle = "Clustering of statistical traffic spikes by Day of Week and Hour",
       x = "Hour of Day (0 - 23)", y = "Day of Week", fill = "Anomaly %") +
  theme_minimal(base_size = 11)

ggsave("output/skill_06_anomaly_heatmap.png", p_heatmap, width = 9, height = 5)

# ---- Visualization 2: Model Residual Scatter ----
p_resid <- data %>%
  sample_n(min(10000, nrow(data))) %>%
  ggplot(aes(x = predicted_checkins, y = residual, color = anomaly_combined)) +
  geom_point(alpha = 0.4, size = 1.2) +
  scale_color_manual(values = c("FALSE" = "#999999", "TRUE" = "#D0021B")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Model Residuals vs Predicted Traffic (Anomaly Identification)",
       subtitle = "Red points represent flagged traffic anomalies (|std_res| > 3 or > 2.5x IQR)",
       x = "Predicted Check-ins", y = "Residual (Actual - Predicted)", color = "Flagged Anomaly") +
  theme_minimal(base_size = 12)

ggsave("output/skill_06_residual_scatter.png", p_resid, width = 8, height = 5)

cat("Skill 06 executed successfully. Heatmap and residual scatter saved to output/ directory.\n")

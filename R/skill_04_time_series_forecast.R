# ============================================
# Skill 04: Time Series Forecast (Student Skill 1)
# File: R/skill_04_time_series_forecast.R
# ============================================

library(dplyr)
library(ggplot2)
library(readr)
library(MASS)

cat("Running Skill 04: Time Series Forecast & Staffing Alerts...\n")

if (!file.exists("data/yelp_analysis_data.rds") || !file.exists("data/nb_model.rds")) {
  stop("VALIDATION ERROR: Prerequisites missing. Run Skill 00 (Preprocessing) and Skill 03 (Model) first.")
}

data <- read_rds("data/yelp_analysis_data.rds")
nb_model <- read_rds("data/nb_model.rds")

# ---- Select High-Volume Target Location for Staffing Forecast ----
top_business <- data %>%
  group_by(business_id, name, city) %>%
  summarise(total_checkins = sum(checkins), n_shifts = n(), .groups = "drop") %>%
  filter(n_shifts >= 50) %>%
  arrange(desc(total_checkins)) %>%
  slice(1)

target_id <- top_business$business_id
target_name <- top_business$name

cat(sprintf("Generating 48-Hour Staffing Forecast for Location: '%s' (ID: %s)\n", target_name, target_id))

# ---- Build 48-Hour Ahead Horizon Grid (Next Friday + Saturday) ----
forecast_grid <- expand.grid(
  day = c("Friday", "Saturday"),
  hour = 0:23,
  stringsAsFactors = FALSE
)

target_info <- data %>% filter(business_id == target_id) %>% slice(1)

forecast_df <- forecast_grid %>%
  mutate(
    business_id = target_id,
    stars = target_info$stars,
    log_review_count = target_info$log_review_count,
    service_type = target_info$service_type,
    day = factor(day, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
  )

# Predict hourly traffic using Negative Binomial model
forecast_df$predicted_checkins <- predict(nb_model, newdata = forecast_df, type = "response")

# ---- Staffing Threshold Rule (75th Percentile Historical Threshold) ----
hist_threshold <- quantile(data$checkins, 0.75, na.rm = TRUE)

forecast_df <- forecast_df %>%
  mutate(
    staffing_recommendation = case_when(
      predicted_checkins >= hist_threshold * 1.5 ~ "Add 2+ Staff (Peak Alert 🔴)",
      predicted_checkins >= hist_threshold ~ "Add 1 Staff (Elevated 🟡)",
      TRUE ~ "Standard Staffing (Normal 🟢)"
    ),
    shift_label = paste0(substr(day, 1, 3), " ", sprintf("%02d:00", hour))
  )

# Explicitly use dplyr::select to avoid collision with MASS::select
print(head(forecast_df %>% dplyr::select(day, hour, predicted_checkins, staffing_recommendation), 10))

# ---- Visualization: Forecast Line Chart with Staffing Alert Threshold ----
p_forecast <- forecast_df %>%
  mutate(time_idx = 1:n()) %>%
  ggplot(aes(x = time_idx, y = predicted_checkins)) +
  geom_line(color = "#2B5C8F", linewidth = 1.2) +
  geom_point(aes(color = staffing_recommendation), size = 3) +
  geom_hline(yintercept = hist_threshold, linetype = "dashed", color = "#D0021B", linewidth = 1) +
  annotate("text", x = 2, y = hist_threshold + 0.5, label = paste0("75th Percentile Threshold (", round(hist_threshold, 1), " checkins)"), color = "#D0021B", hjust = 0) +
  scale_color_manual(values = c("Add 2+ Staff (Peak Alert 🔴)" = "#D0021B", 
                                "Add 1 Staff (Elevated 🟡)" = "#F5A623", 
                                "Standard Staffing (Normal 🟢)" = "#7ED321")) +
  scale_x_continuous(breaks = seq(1, 48, by = 4), labels = forecast_df$shift_label[seq(1, 48, by = 4)]) +
  labs(title = paste0("48-Hour Staffing Traffic Forecast: ", target_name),
       subtitle = "Model-based hourly predictions vs historical operational thresholds",
       x = "Shift Hour", y = "Predicted Check-in Volume", color = "Action") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("output/skill_04_staffing_forecast.png", p_forecast, width = 9, height = 5.5)

cat("Skill 04 executed successfully. Forecast plot saved to output/ directory.\n")

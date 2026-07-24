# ============================================
# Skill 01: Explore Data
# File: R/skill_01_explore_data.R
# ============================================

library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(stringr)

cat("Running Skill 01: Explore Data...\n")

# Load data
if (!file.exists("data/yelp_analysis_data.rds")) {
  stop("VALIDATION ERROR: Processed dataset 'data/yelp_analysis_data.rds' not found. Run R/00_preprocess_yelp.R first.")
}

data <- read_rds("data/yelp_analysis_data.rds")

# ---- Validation Check 1: Minimum Observations & Columns ----
if (nrow(data) < 100) {
  stop("VALIDATION ERROR: Dataset has fewer than 100 observations. Unable to perform reliable exploration.")
}

required_cols <- c("business_id", "checkins", "stars", "day", "hour", "service_type")
missing_cols <- setdiff(required_cols, colnames(data))
if (length(missing_cols) > 0) {
  stop(paste("VALIDATION ERROR: Missing required columns:", paste(missing_cols, collapse = ", ")))
}

# ---- Summary Statistics ----
summary_stats <- data %>%
  summarise(
    n_obs = n(),
    n_businesses = n_distinct(business_id),
    mean_checkins = mean(checkins, na.rm = TRUE),
    median_checkins = median(checkins, na.rm = TRUE),
    sd_checkins = sd(checkins, na.rm = TRUE),
    min_checkins = min(checkins, na.rm = TRUE),
    max_checkins = max(checkins, na.rm = TRUE),
    mean_stars = mean(stars, na.rm = TRUE),
    missing_checkins = sum(is.na(checkins)),
    missing_stars = sum(is.na(stars))
  )

print(summary_stats)

# ---- Visualization 1: Checkin Distribution by Day ----
p1 <- data %>%
  ggplot(aes(x = day, y = checkins, fill = day)) +
  geom_boxplot(outlier.alpha = 0.2, fill = "#4C72B0", alpha = 0.7) +
  scale_y_log10() +
  labs(title = "Check-in Distribution by Day of Week",
       subtitle = "Log scale representation across all open food/restaurant locations",
       x = "Day of Week", y = "Check-ins per Hour (Log Scale)") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave("output/skill_01_checkins_by_day.png", p1, width = 9, height = 5)

# ---- Visualization 2: Star Ratings Histogram ----
p2 <- data %>%
  distinct(business_id, .keep_all = TRUE) %>%
  ggplot(aes(x = stars)) +
  geom_histogram(bins = 9, fill = "#F5A623", color = "white", alpha = 0.85) +
  geom_vline(xintercept = 4.0, linetype = "dashed", color = "#D0021B", linewidth = 1) +
  annotate("text", x = 4.05, y = 500, label = "4.0 Benchmark", color = "#D0021B", hjust = 0) +
  labs(title = "Distribution of Average Star Ratings",
       subtitle = "Unique business location level",
       x = "Star Rating (1.0 - 5.0)", y = "Number of Businesses") +
  theme_minimal(base_size = 12)

ggsave("output/skill_01_ratings_hist.png", p2, width = 8, height = 5)

cat("Skill 01 executed successfully. Output saved to output/ directory.\n")

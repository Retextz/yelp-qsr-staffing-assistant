# ============================================
# Skill 02: Compare Two Groups
# File: R/skill_02_compare_groups.R
# ============================================

library(dplyr)
library(ggplot2)
library(readr)

cat("Running Skill 02: Compare Two Groups...\n")

if (!file.exists("data/yelp_analysis_data.rds")) {
  stop("VALIDATION ERROR: Processed dataset 'data/yelp_analysis_data.rds' not found. Run R/00_preprocess_yelp.R first.")
}

data <- read_rds("data/yelp_analysis_data.rds")

# ---- Validation Check 2: Two Valid Groups with n >= 30 ----
group_counts <- data %>%
  group_by(service_type) %>%
  summarise(n = n(), n_businesses = n_distinct(business_id), .groups = "drop")

print(group_counts)

if (nrow(group_counts) < 2) {
  stop("VALIDATION ERROR: Grouping variable 'service_type' does not contain at least two distinct groups.")
}

qsr_n <- group_counts %>% filter(service_type == "Quick Service") %>% pull(n)
full_n <- group_counts %>% filter(service_type == "Full Service") %>% pull(n)

if (length(qsr_n) == 0 || qsr_n < 30 || length(full_n) == 0 || full_n < 30) {
  stop("VALIDATION ERROR: Each comparison group must contain at least 30 observations for valid parametric inference.")
}

# ---- Welch's Two-Sample t-test: Hourly Checkins ----
qsr_checkins <- data %>% filter(service_type == "Quick Service") %>% pull(checkins)
full_checkins <- data %>% filter(service_type == "Full Service") %>% pull(checkins)

t_check <- t.test(qsr_checkins, full_checkins, var.equal = FALSE)

# Cohen's d (manual calculation for standard base R reproducibility)
s_pooled <- sqrt(((length(qsr_checkins) - 1) * var(qsr_checkins) + (length(full_checkins) - 1) * var(full_checkins)) / (length(qsr_checkins) + length(full_checkins) - 2))
d_check <- (mean(qsr_checkins) - mean(full_checkins)) / s_pooled

# ---- Welch's Two-Sample t-test: Star Ratings (Business Level) ----
qsr_stars <- data %>% filter(service_type == "Quick Service") %>% distinct(business_id, .keep_all = TRUE) %>% pull(stars)
full_stars <- data %>% filter(service_type == "Full Service") %>% distinct(business_id, .keep_all = TRUE) %>% pull(stars)

t_stars <- t.test(qsr_stars, full_stars, var.equal = FALSE)
s_pooled_stars <- sqrt(((length(qsr_stars) - 1) * var(qsr_stars) + (length(full_stars) - 1) * var(full_stars)) / (length(qsr_stars) + length(full_stars) - 2))
d_stars <- (mean(qsr_stars) - mean(full_stars)) / s_pooled_stars

# ---- Summary Table ----
comp_results <- tibble(
  Metric = c("Hourly Check-ins", "Star Ratings"),
  `Quick Service Mean` = c(round(mean(qsr_checkins), 2), round(mean(qsr_stars), 2)),
  `Full Service Mean` = c(round(mean(full_checkins), 2), round(mean(full_stars), 2)),
  `Estimated Difference` = c(round(t_check$estimate[1] - t_check$estimate[2], 2), round(t_stars$estimate[1] - t_stars$estimate[2], 2)),
  `95% CI Lower` = c(round(t_check$conf.int[1], 2), round(t_stars$conf.int[1], 2)),
  `95% CI Upper` = c(round(t_check$conf.int[2], 2), round(t_stars$conf.int[2], 2)),
  `p-value` = c(format.pval(t_check$p.value, digits = 3), format.pval(t_stars$p.value, digits = 3)),
  `Cohen's d` = c(round(d_check, 3), round(d_stars, 3))
)

print(comp_results)

# ---- Visualization ----
p_comp <- data %>%
  ggplot(aes(x = service_type, y = checkins, fill = service_type)) +
  geom_boxplot(outlier.alpha = 0.15, alpha = 0.75) +
  scale_y_log10() +
  scale_fill_manual(values = c("Quick Service" = "#2B5C8F", "Full Service" = "#D95F02")) +
  labs(title = "Hourly Check-in Volume: Quick Service vs Full Service",
       subtitle = paste0("Welch's t-test p < 0.001 | Estimated Difference = ", round(t_check$estimate[1] - t_check$estimate[2], 2), " checkins/hr"),
       x = "Service Category", y = "Check-ins per Hour (Log Scale)") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave("output/skill_02_group_comparison.png", p_comp, width = 8, height = 5)

cat("Skill 02 executed successfully. Output saved to output/ directory.\n")

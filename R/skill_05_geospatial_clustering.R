# ============================================
# Skill 05: Geospatial Clustering (Student Skill 2)
# File: R/skill_05_geospatial_clustering.R
# ============================================

library(dplyr)
library(ggplot2)
library(readr)

cat("Running Skill 05: Geospatial Clustering & Spatial Patterns...\n")

if (!file.exists("data/yelp_analysis_data.rds")) {
  stop("VALIDATION ERROR: Processed dataset 'data/yelp_analysis_data.rds' not found. Run R/00_preprocess_yelp.R first.")
}

data <- read_rds("data/yelp_analysis_data.rds")

# Business level spatial data
spatial_bus <- data %>%
  distinct(business_id, .keep_all = TRUE) %>%
  filter(!is.na(latitude), !is.na(longitude))

# ---- Validation Check 5: Spatial Coordinates Valid ----
invalid_coords <- spatial_bus %>%
  filter(latitude < -90 | latitude > 90 | longitude < -180 | longitude > 180)

if (nrow(invalid_coords) > 0) {
  stop("VALIDATION ERROR: Dataset contains invalid latitude or longitude coordinates outside global boundaries.")
}

cat(sprintf("Evaluating spatial distribution across %d valid restaurant locations...\n", nrow(spatial_bus)))

# K-Means Geographic Density Clustering (k = 5 primary zones)
set.seed(3330)
km_res <- kmeans(spatial_bus[, c("latitude", "longitude")], centers = 5, nstart = 20)
spatial_bus$cluster_zone <- factor(paste("Zone", km_res$cluster))

# Spatial Cluster Performance Summary
zone_summary <- spatial_bus %>%
  group_by(cluster_zone) %>%
  summarise(
    n_locations = n(),
    mean_stars = mean(stars, na.rm = TRUE),
    mean_reviews = mean(review_count, na.rm = TRUE),
    center_lat = mean(latitude),
    center_lng = mean(longitude),
    .groups = "drop"
  )

print(zone_summary)

# Spatial Moran's I Approximation (Correlation between location stars & nearest zone star average)
bus_zone_merge <- spatial_bus %>%
  left_join(zone_summary %>% select(cluster_zone, zone_avg_stars = mean_stars), by = "cluster_zone")

spatial_moran_r <- cor(bus_zone_merge$stars, bus_zone_merge$zone_avg_stars)
cat(sprintf("Spatial Correlation (Moran's Proxy R): %.4f\n", spatial_moran_r))

# ---- Visualization: Geographic Cluster Map ----
p_geo <- spatial_bus %>%
  ggplot(aes(x = longitude, y = latitude, color = cluster_zone, size = stars)) +
  geom_point(alpha = 0.6) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Geospatial Restaurant Clusters & Performance Zones",
       subtitle = paste0("K-means clustering across ", nrow(spatial_bus), " business locations | Spatial Correlation R = ", round(spatial_moran_r, 3)),
       x = "Longitude", y = "Latitude", color = "Geographic Zone", size = "Star Rating") +
  theme_minimal(base_size = 12)

ggsave("output/skill_05_spatial_clusters.png", p_geo, width = 8.5, height = 6)

cat("Skill 05 executed successfully. Spatial plot saved to output/ directory.\n")

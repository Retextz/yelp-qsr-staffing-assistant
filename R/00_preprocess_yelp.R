# ============================================
# Yelp Dataset Loading & Preprocessing (Standard R Libraries)
# File: R/00_preprocess_yelp.R
# ============================================

library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(stringr)
library(lubridate)
library(jsonlite)

cat("Starting full line-by-line ingestion of Yelp Business Dataset...\n")

# ---- Step 1: Stream Business JSON ----
con_bus <- file("dataset/yelp_academic_dataset_business.json", "r")
bus_list <- list()
i <- 0

while (TRUE) {
  line <- readLines(con_bus, n = 10000, warn = FALSE)
  if (length(line) == 0) break
  
  parsed_chunk <- lapply(line, function(x) {
    obj <- fromJSON(x)
    list(
      business_id  = if (is.null(obj$business_id)) NA_character_ else obj$business_id,
      name         = if (is.null(obj$name)) NA_character_ else obj$name,
      categories   = if (is.null(obj$categories)) NA_character_ else obj$categories,
      stars        = if (is.null(obj$stars)) NA_real_ else obj$stars,
      review_count = if (is.null(obj$review_count)) NA_integer_ else obj$review_count,
      latitude     = if (is.null(obj$latitude)) NA_real_ else obj$latitude,
      longitude    = if (is.null(obj$longitude)) NA_real_ else obj$longitude,
      city         = if (is.null(obj$city)) NA_character_ else obj$city,
      state        = if (is.null(obj$state)) NA_character_ else obj$state,
      postal_code  = if (is.null(obj$postal_code)) NA_character_ else obj$postal_code,
      is_open      = if (is.null(obj$is_open)) NA_integer_ else obj$is_open
    )
  })
  
  bus_list <- c(bus_list, parsed_chunk)
  i <- i + length(line)
  if (i %% 50000 == 0) cat(sprintf("Processed %d business records...\n", i))
}
close(con_bus)

business_df <- bind_rows(bus_list)
cat(sprintf("Loaded total businesses: %d\n", nrow(business_df)))

# ---- Step 2: Filter to Open Food/Restaurant Businesses ----
food_pattern <- "Restaurants|Food|Coffee|Bubble Tea|Juice|Bakery|Fast Food|Pizza|Burger|Sandwiches|Cafes"
business_restaurants <- business_df %>%
  filter(!is.na(categories)) %>%
  filter(str_detect(categories, regex(food_pattern, ignore_case = TRUE))) %>%
  filter(is_open == 1)

cat(sprintf("Filtered to %d active open food/restaurant businesses\n", nrow(business_restaurants)))

target_ids <- unique(business_restaurants$business_id)

# ---- Step 3: Stream & Parse Checkin JSON ----
cat("Processing full line-by-line checkin data for matching businesses...\n")
con_chk <- file("dataset/yelp_academic_dataset_checkin.json", "r")

chk_records <- list()
j <- 0

while (TRUE) {
  lines <- readLines(con_chk, n = 5000, warn = FALSE)
  if (length(lines) == 0) break
  
  for (line in lines) {
    obj <- fromJSON(line)
    if (obj$business_id %in% target_ids && !is.null(obj$date) && nchar(obj$date) > 0) {
      ts_vec <- unlist(strsplit(obj$date, ",\\s*"))
      if (length(ts_vec) > 0) {
        hours <- as.integer(substr(ts_vec, 12, 13))
        dt_dates <- as.Date(substr(ts_vec, 1, 10))
        days <- weekdays(dt_dates)
        
        tab <- table(days, hours)
        df_tab <- as.data.frame(tab, stringsAsFactors = FALSE)
        colnames(df_tab) <- c("day", "hour", "checkins")
        df_tab$checkins <- as.numeric(df_tab$checkins)
        df_tab <- df_tab[df_tab$checkins > 0, ]
        if (nrow(df_tab) > 0) {
          df_tab$business_id <- obj$business_id
          chk_records[[length(chk_records) + 1]] <- df_tab
        }
      }
    }
  }
  j <- j + length(lines)
  if (j %% 20000 == 0) cat(sprintf("Processed %d checkin business lines...\n", j))
}
close(con_chk)

cat("Aggregating checkin tables...\n")
checkin_aggregated <- bind_rows(chk_records) %>%
  mutate(hour = as.numeric(hour)) %>%
  group_by(business_id, day, hour) %>%
  summarise(checkins = sum(checkins), .groups = "drop")

cat(sprintf("Aggregated checkin records: %d rows\n", nrow(checkin_aggregated)))

# ---- Step 4: Merge Business Info & Create Final Feature Dataframe ----
analysis_data <- checkin_aggregated %>%
  left_join(business_restaurants, by = "business_id") %>%
  filter(!is.na(stars)) %>%
  mutate(
    day = factor(day, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")),
    log_review_count = log1p(review_count),
    primary_category = str_extract(categories, "^[^,]+"),
    service_type = case_when(
      str_detect(categories, regex("Fast Food|Pizza|Burger|Taco|Wings|Sandwich|Hot Dog|Coffee|Donut|Bagel|Juice|Bakery", ignore_case = TRUE)) ~ "Quick Service",
      TRUE ~ "Full Service"
    )
  )

cat("Saving processed dataset to data/yelp_analysis_data.rds...\n")
write_rds(analysis_data, "data/yelp_analysis_data.rds")

cat("SUCCESS: Data processing complete!\n")
cat(sprintf("Final Dimensions: %d rows x %d columns across %d unique businesses\n", 
            nrow(analysis_data), ncol(analysis_data), n_distinct(analysis_data$business_id)))

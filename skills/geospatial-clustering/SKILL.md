# Geospatial Clustering

## Purpose
Clusters restaurant locations into geographic performance zones and evaluates spatial autocorrelation (Moran's I) to determine if high customer ratings and foot traffic aggregate in specific geographic clusters.

## When to Use
Activate when the user asks where busy restaurant areas are located, requests spatial or geographic clustering, or wants to know if ratings depend on location/neighborhood.

## Required Inputs
- Geographic variables: `latitude` and `longitude`
- Performance variables: `stars`, `checkins`, `review_count`
- Dataset `data/yelp_analysis_data.rds`

## Files Used
- `R/skill_05_geospatial_clustering.R`
- `data/yelp_analysis_data.rds`
- Output visual asset: `output/skill_05_spatial_clusters.png`

## Method
K-Means geographic clustering based on latitude and longitude coordinates, combined with spatial autocorrelation analysis (Moran's I correlation proxy) between individual restaurant star ratings and regional zone averages.

## Procedure
1. Filter dataset for unique business locations with valid geographic coordinates.
2. Validate coordinate boundaries (latitude ∈ [-90, 90], longitude ∈ [-180, 180]).
3. Run K-Means spatial clustering (k = 5 performance zones).
4. Calculate average stars, review count, and foot traffic per geographic cluster.
5. Compute spatial correlation proxy and render geographic cluster map.

## Validation
- Validate spatial coordinates: If any latitude or longitude falls outside global coordinate bounds, halt and return error: *"VALIDATION ERROR: Dataset contains invalid latitude or longitude coordinates outside global boundaries."*
- Require at least 15 valid spatial points.

## Output
- Geographic cluster performance summary table (locations per zone, mean stars, mean reviews, center lat/lng).
- Spatial correlation coefficient (Moran's I proxy R).
- Color-coded geospatial scatter map of restaurant locations.

## Interpretation
Reveals distinct geographic performance clusters across the metropolitan area. Positive spatial correlation confirms that high-rated restaurants cluster together in designated "dining districts," assisting managers in contextualizing local competition.

## Limitation
Geographic clustering uses Euclidean spatial distance and does not account for physical barriers (rivers, highways), traffic congestion, zoning laws, or neighborhood demographic shifts.

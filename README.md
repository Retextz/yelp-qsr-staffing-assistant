# Yelp QSR Foot Traffic & Staffing Statistical Assistant
**Student Name: Alex Z**
**Selected Implementation Level**: **Level 1**  
**Industry**: Quick-Service Restaurant (QSR) & Food Service  
**Intended User**: Regional Operations Manager  
**Connected Decision Problem**: *"For each restaurant location, day, and hour: should staffing be increased, decreased, or held steady based on statistical foot traffic models, forecasts, and anomaly detection?"*  
**Dataset Source**: Official Yelp Open Dataset (`https://www.yelp.com/dataset`)

---

## Project Overview

This repository contains the complete, reproducible **Industry Statistical Assistant** designed for a QSR Regional Operations Manager. The assistant connects real-world business metrics from the Yelp Open Dataset to six reproducible R statistical analyses and six Google Antigravity agent skill definitions.

### Six-Skill Architecture Summary Table

| Skill Name | User Question | Method | Main Output | Decision Supported |
| :--- | :--- | :--- | :--- | :--- |
| **1. Explore Data** | What does baseline foot traffic and rating distribution look like? | EDA, Summary Statistics, Log Boxplots, Histograms | Summary Table, Distribution Plots | Identify overall busiest days and baseline quality benchmarks |
| **2. Compare Two Groups** | Do QSR locations differ in check-in volume and ratings vs Full Service? | Welch's Two-Sample t-test, Cohen's d | t-test Table, Group Boxplots | Calibrate different staffing models by service category |
| **3. Statistical Model** | What factors predict hourly check-in traffic? | Negative Binomial Count Regression | Model Fit Table, RMSE, Prediction Plot | Determine key shift traffic drivers (hour, day, review volume) |
| **4. Time Series Forecast** *(Student 1)* | What is the 48-hour shift traffic forecast for upcoming weekend shifts? | 48-Hour Ahead Model Horizon & 75th % Threshold | Shift Forecast Line Plot, Alert Table | Proactively add 1 to 2+ staff for predicted peak shifts |
| **5. Geospatial Clustering** *(Student 2)* | Are locations geographically clustered into distinct performance zones? | K-Means Spatial Clustering & Moran's I Proxy | Spatial Scatter Map, Zone Summary Table | Contextualize location performance within local dining districts |
| **6. Anomaly Detection** *(Student 3)* | Which operational shifts experienced unexpected traffic spikes/drops? | Standardized Model Residuals + Contextual IQR Fences | Anomaly Heatmap, Location Volatility Rank | Assign flexible on-call staffing to high-volatility locations |

---

## Required Software & R Packages

- **R Version**: $\ge 4.0.0$
- **Required R Packages**:
  - `dplyr`, `ggplot2`, `readr`, `tidyr`, `stringr`, `lubridate`, `jsonlite`, `MASS`, `broom`, `rmarkdown`, `knitr`

---

## Instructions for Running the Project

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/[username]/yelp-qsr-staffing-assistant.git
   cd yelp-qsr-staffing-assistant
   ```

2. **Data Setup**:
   Ensure raw Yelp JSON files are placed in `dataset/`:
   - `yelp_academic_dataset_business.json`
   - `yelp_academic_dataset_checkin.json`

3. **Execute Data Preprocessing**:
   ```bash
   Rscript R/00_preprocess_yelp.R
   ```
   *This script streams and parses the JSON files, producing `data/yelp_analysis_data.rds`.*

4. **Run Statistical Skills**:
   ```bash
   Rscript R/skill_01_explore_data.R
   Rscript R/skill_02_compare_groups.R
   Rscript R/skill_03_statistical_model.R
   Rscript R/skill_04_time_series_forecast.R
   Rscript R/skill_05_geospatial_clustering.R
   Rscript R/skill_06_anomaly_detection.R
   ```

5. **Render Quarto Statistical Report**:
   ```bash
   Rscript -e "rmarkdown::render('final_report.qmd', output_format='pdf_document')"
   ```

---

## How Google Antigravity and Agent Skills Were Used

1. **Example 1: Time Series Forecast (Skill 4)**
   - *Prompt Request*: *"Build a skill to forecast upcoming weekend shifts for a restaurant and convert point predictions into staffing actions."*
   - *Skill Used*: `skills/time-series-forecast/SKILL.md`
   - *File Created/Changed*: `R/skill_04_time_series_forecast.R`
   - *Review & Correction*: Antigravity drafted the forecast script. The student reviewed the script and added explicit validation ensuring `data/nb_model.rds` exists before generating forecasts.

2. **Example 2: Statistical Model (Skill 3)**
   - *Prompt Request*: *"Select and fit the most appropriate statistical model for hourly check-in count data."*
   - *Skill Used*: `skills/model/SKILL.md`
   - *File Created/Changed*: `R/skill_03_statistical_model.R`
   - *Review & Acceptance*: Antigravity evaluated outcome overdispersion ($\text{Variance} \gg \text{Mean}$) and selected Negative Binomial regression. The student accepted this choice after verifying the variance-to-mean ratio.

3. **Example 3: Anomaly Detection (Skill 6)**
   - *Prompt Request*: *"Create an anomaly detection skill combining statistical residuals and business-specific IQR fences."*
   - *Skill Used*: `skills/anomaly-detection/SKILL.md`
   - *File Created/Changed*: `R/skill_06_anomaly_detection.R`
   - *Review & Correction*: Antigravity initially flagged anomalies across all businesses without filtering out low-sample locations. The student corrected the script to enforce a minimum of 10 historical shifts per business location.

---

## Screenshots of Visualizations

Below is the sample output visualization:

- **Traffic Anomaly Rate Heatmap**: <img width="2700" height="1500" alt="skill_06_anomaly_heatmap" src="https://github.com/user-attachments/assets/23d79940-5609-4d31-b0ee-43f13f9c49fa" />
`

---

## Limitations

1. **Check-in Data Proxy**: Yelp check-ins rely on user smartphone activity and undercount total physical foot traffic.
2. **Observational Model**: Regression and spatial correlations show statistical associations rather than direct causation.
3. **Static Delivery**: The Quarto report requires manual re-rendering when new check-in data is collected.

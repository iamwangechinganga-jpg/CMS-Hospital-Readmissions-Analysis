# CMS Hospital Readmissions Analysis

An analysis of hospital readmission patterns using SQL and Tableau, with a focus on Excess Readmission Ratio (ERR), HRRP measures, state-level variation, discharge volume, and hospitals with multiple measures above the expected ratio.

## 📊 Dashboard

**[View the interactive Tableau dashboard](https://public.tableau.com/app/profile/wangechi.ng.ang.a5145/viz/CMS_Hospital_Readmissions_Analysis/CMSHospitalReadmissionsAnalysis)**

![CMS Hospital Readmissions Dashboard](Images/CMS%20Hospital%20Readmissions%20Analysis.png)

## 📌 Project Overview

This project analyzes data from the **CMS Hospital Readmissions Reduction Program (HRRP)** to identify patterns in excess readmission ratios across hospitals, HRRP measures, states, and discharge-volume groups.

The analysis is descriptive and focuses on observed patterns and associations rather than causal relationships.

### Key questions

- How does average Excess Readmission Ratio vary across HRRP measures?
- What percentage of reported observations have an ERR above 1.00?
- How does the share above expected vary across states?
- How does discharge volume relate to average ERR?
- How many hospitals have multiple HRRP measures above the expected ratio?

## 📂 Dataset

The dataset contains **18,330 hospital-condition observations** across six HRRP measures:

- AMI
- CABG
- COPD
- Heart Failure
- Hip/Knee Replacement
- Pneumonia

> **Important:** The 18,330 rows represent hospital-condition observations, not 18,330 unique hospitals.

The analysis identified **2,833 unique hospitals** with at least one reported ERR.

## 📏 Key Metric: Excess Readmission Ratio

The **Excess Readmission Ratio (ERR)** compares predicted readmissions with the expected number of readmissions for a hospital-condition observation.

- **ERR = 1.00** → predicted readmissions are approximately equal to expected
- **ERR > 1.00** → above expected
- **ERR < 1.00** → below expected

## 🛠️ Tools

- **MySQL** – data auditing, cleaning, and analysis
- **SQL** – data transformation and business analysis
- **Tableau Public** – interactive visualization
- **CSV** – source data format

## 🔍 Analysis Workflow

### 1. Data Audit

The raw dataset was examined for:

- Missing values
- `N/A` values
- `Too Few to Report` values
- Duplicate hospital-condition records
- Date coverage
- Available HRRP measures
- Missing identifiers
- Consistency between reported and calculated ERR

### 2. Data Cleaning

A raw staging table was used to safely import the source data before creating the cleaned analytical table.

The cleaning process converted:

- Discharges → `INT`
- Readmissions → `INT`
- ERR → `DECIMAL`
- Predicted readmission rate → `DECIMAL`
- Expected readmission rate → `DECIMAL`
- Start and end dates → `DATE`

Non-reportable values were converted to `NULL` where appropriate.

### 3. Business Analysis

The cleaned data was analyzed across HRRP measures, states, discharge-volume groups, and hospitals with multiple measures above expected.

## 📊 Key Findings

### Average ERR by HRRP Measure

Average ERR was close to 1.00 across all six HRRP measures.

| HRRP Measure | Average ERR |
|---|---:|
| Hip/Knee | 1.0040 |
| CABG | 1.0018 |
| AMI | 1.0018 |
| Pneumonia | 1.0015 |
| Heart Failure | 1.0014 |
| COPD | 1.0011 |

### Overall Share Above Expected

Among observations with a reported ERR:

- **11,720** observations had a reported ERR
- **5,643** were above 1.00
- **48.15%** were above expected

### Variation by HRRP Measure

The percentage of reported observations above expected ranged from:

- **Pneumonia:** 46.81%
- **CABG:** 49.89%

The proportions were relatively similar across the six measures.

### State-Level Variation

Among states with at least 100 reported observations, the share above expected ranged from:

- **Oregon:** 22.90%
- **New Jersey:** 65.44%

This indicates substantial variation across states within the dataset.

### Discharge Volume and ERR

Average ERR declined across discharge-volume bands:

| Discharge Volume | Average ERR |
|---|---:|
| Under 100 | 1.0310 |
| 100–249 | 1.0108 |
| 250–499 | 1.0021 |
| 500–999 | 0.9936 |
| 1,000+ | 0.9828 |

This represents an **observed association** in the dataset and should not be interpreted as evidence of causation.

### Hospitals with Multiple Measures Above Expected

A total of **1,661 hospitals** had at least two HRRP measures with an ERR above 1.00.

| Measures Above Expected | Hospitals |
|---:|---:|
| 2 | 680 |
| 3 | 511 |
| 4 | 314 |
| 5 | 139 |
| 6 | 17 |

## 📈 Tableau Dashboard

The interactive dashboard presents:

1. Average ERR by HRRP measure
2. Percentage above expected by state
3. Discharge volume versus ERR
4. Hospitals with two or more measures above expected
5. KPI summaries of the overall analysis

## ⚠️ Limitations

- The analysis is descriptive and does not establish causal relationships.
- The dataset contains hospital-condition observations rather than one row per hospital.
- Some observations contain missing or non-reportable values.
- State-level comparisons were restricted to states with at least 100 reported observations.
- Results should not be interpreted as rankings of hospital quality or as evidence that particular hospitals cause readmissions.

## 📁 Project Files

| File | Description |
|---|---|
| `01_data_audit.sql` | Audits the raw data and validates key fields |
| `02_data_cleaning.sql` | Creates and validates the cleaned analytical table |
| `03_business_analysis.sql` | Contains the business questions and analytical queries |

## 💡 Conclusion

The analysis found that average ERR remained close to the expected ratio across all six HRRP measures, while state-level variation was considerably larger.

The dataset also showed an observed association between discharge volume and ERR, with average ERR declining across higher discharge-volume bands. In addition, 1,661 hospitals had at least two measures above the expected ratio.

Together, these findings provide a descriptive view of patterns within the HRRP dataset and demonstrate a workflow from data auditing and cleaning through SQL analysis and Tableau visualization.

-- ============================================
-- CMS Hospital Readmissions Reduction Program Analysis
-- Business Analysis questions
-- =============================================

-- ============================================
-- 1. Which HRRP measures have the highest average excess readmission ratio?
-- =============================================

SELECT
    Measure_Name,
    AVG(Excess_Readmission_Ratio) AS average_ratio
FROM hrrp_clean
GROUP BY Measure_Name
ORDER BY average_ratio DESC;

-- Findings:
-- Average excess readmission ratios were close to 1.00 across all six HRRP measures
-- hip/knee replacement having the highest average ratio at approximately 1.004


-- ============================================
-- 2. What percentage of hospital-condition observations have an excess readmission ratio above 1?
-- =============================================


SELECT
    COUNT(*) AS total_observations,
    SUM(CASE
            WHEN Excess_Readmission_Ratio > 1 THEN 1
            ELSE 0
        END) AS above_expected,
    ROUND(100.0 * SUM(CASE
                WHEN Excess_Readmission_Ratio > 1 THEN 1
                ELSE 0
            END) / COUNT(Excess_Readmission_Ratio),2
    ) AS percent_above_expected
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL;

-- Findings:
-- 48.15% of hospital-condition observations with a reported excess readmission ratio had a ratio above 1


-- ============================================
-- 3. What percentage of observations are above the expected ratio for each HRRP measure?
-- =============================================


SELECT Measure_Name, COUNT(Excess_Readmission_Ratio) AS reported_observations,
SUM(CASE
		WHEN Excess_Readmission_Ratio > 1 THEN 1
            ELSE 0
        END) AS above_expected,
ROUND(100.0 * SUM(
            CASE
                WHEN Excess_Readmission_Ratio > 1 THEN 1
                ELSE 0
            END
        ) / COUNT(Excess_Readmission_Ratio),2
    ) AS percent_above_expected
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL
GROUP BY Measure_Name
ORDER BY percent_above_expected DESC;

-- Findings:
-- The share of reported hospital-condition observations with an excess readmission ratio above 1 
-- ranged from 46.81% for pneumonia to 49.89% for CABG
-- indicating relatively similar proportions across the six HRRP measures


-- ============================================
-- 4. What percentage of reported hospital-condition observations are above the expected ratio in each state?
-- =============================================

SELECT State, COUNT(Excess_Readmission_Ratio) AS reported_observations,
SUM(
        CASE
            WHEN Excess_Readmission_Ratio > 1 THEN 1
            ELSE 0
        END) AS above_expected,
    ROUND(100.0 * SUM(
            CASE
                WHEN Excess_Readmission_Ratio > 1 THEN 1
                ELSE 0
            END) / COUNT(Excess_Readmission_Ratio),
        2) AS percent_above_expected
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL
GROUP BY State
HAVING COUNT(Excess_Readmission_Ratio) >= 100
ORDER BY percent_above_expected DESC;

-- Findings:
-- Among states with at least 100 reported hospital-condition observations
-- the share with an excess readmission ratio above 1 varied substantially
-- ranging from 22.90% in Oregon to 65.44% in New Jersey


-- ============================================
-- 5. Do hospital-condition observations with different numbers of discharges show different average excess readmission ratios?
-- =============================================
    
    SELECT
    CASE
        WHEN Number_of_Discharges < 100 THEN 'Under 100'
        WHEN Number_of_Discharges < 250 THEN '100-249'
        WHEN Number_of_Discharges < 500 THEN '250-499'
        WHEN Number_of_Discharges < 1000 THEN '500-999'
        ELSE '1000+'
    END AS discharge_band,
    COUNT(Excess_Readmission_Ratio) AS reported_observations,
    ROUND(AVG(Excess_Readmission_Ratio),4) AS average_ratio
FROM hrrp_clean
WHERE Number_of_Discharges IS NOT NULL
  AND Excess_Readmission_Ratio IS NOT NULL
GROUP BY discharge_band
ORDER BY
    CASE
        WHEN discharge_band = 'Under 100' THEN 1
        WHEN discharge_band = '100-249' THEN 2
        WHEN discharge_band = '250-499' THEN 3
        WHEN discharge_band = '500-999' THEN 4
        ELSE 5
    END;
    

-- Findings:
-- Average excess readmission ratios declined across the discharge-volume bands
-- from 1.0310 among observations with fewer than 100 discharges to 0.9828 among observations with 1,000 or more discharges
-- this describes an observed association rather than a causal relationship


-- ============================================
-- 6. Which hospitals have above-expected ratios across multiple HRRP measures?
-- =============================================


SELECT Facility_ID, Facility_Name,  COUNT(Excess_Readmission_Ratio) AS reported_measures,
    SUM(CASE
            WHEN Excess_Readmission_Ratio > 1 THEN 1
            ELSE 0
        END) AS measures_above_expected
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL
GROUP BY Facility_ID, Facility_Name
HAVING measures_above_expected >= 2
ORDER BY measures_above_expected DESC,  reported_measures DESC;



-- ============================================
-- 7A. How many hospitals fall into each multiple-measure group?
-- =============================================


SELECT measures_above_expected, COUNT(*) AS hospital_count
FROM (
    SELECT Facility_ID,
        SUM(CASE
                WHEN Excess_Readmission_Ratio > 1 THEN 1
                ELSE 0
            END) AS measures_above_expected
    FROM hrrp_clean
    WHERE Excess_Readmission_Ratio IS NOT NULL
    GROUP BY Facility_ID
    HAVING measures_above_expected >= 2) AS hospital_summary
GROUP BY measures_above_expected
ORDER BY measures_above_expected;

-- ============================================
-- 7B. How many hospitals have at least two measures above expected?
-- =============================================

SELECT COUNT(*) AS hospitals_with_2_or_more_above_expected
FROM (
    SELECT Facility_ID
    FROM hrrp_clean
    WHERE Excess_Readmission_Ratio IS NOT NULL
    GROUP BY Facility_ID
    HAVING SUM(
        CASE
            WHEN Excess_Readmission_Ratio > 1 THEN 1
            ELSE 0
        END) >= 2
) AS hospital_summary;

-- Findings:
-- 1,661 hospitals had ratios above 1 across at least two HRRP measures

-- ============================================
-- 8. How many unique hospitals have at least one reported ratio?
-- =============================================

SELECT COUNT(DISTINCT Facility_ID) AS hospitals_with_reported_ratios
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL;

-- Findings:
-- 2,833 unique hospitals had at least one reported excess readmission ratio


-- ============================================
-- 9. Which hospitals have the highest excess readmission ratios within each state and HRRP measure?
-- =============================================

SELECT
    Facility_ID,
    Facility_Name,
    State,
    Measure_Name,
    Excess_Readmission_Ratio,
    RANK() OVER (
        PARTITION BY State, Measure_Name
        ORDER BY Excess_Readmission_Ratio DESC
    ) AS state_measure_rank
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL
ORDER BY State, Measure_Name, state_measure_rank;

-- Findings:
-- Hospitals were ranked by excess readmission ratio within each state
-- and HRRP measure, with rank 1 representing the highest reported ratio
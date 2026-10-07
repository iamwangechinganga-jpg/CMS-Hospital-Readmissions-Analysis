-- Check for N/A values in key analytical fields
SELECT
    SUM(CASE WHEN Number_of_Discharges = 'N/A' THEN 1 ELSE 0 END) AS discharge_na,
    SUM(CASE WHEN Excess_Readmission_Ratio = 'N/A' THEN 1 ELSE 0 END) AS ratio_na,
    SUM(CASE WHEN Predicted_Readmission_Rate = 'N/A' THEN 1 ELSE 0 END) AS predicted_rate_na,
    SUM(CASE WHEN Expected_Readmission_Rate = 'N/A' THEN 1 ELSE 0 END) AS expected_rate_na,
    SUM(CASE WHEN Number_of_Readmissions = 'N/A' THEN 1 ELSE 0 END) AS readmissions_na
FROM hrrp_raw;


-- Check for special reporting values
SELECT
    SUM(CASE WHEN Number_of_Discharges = 'Too Few to Report' THEN 1 ELSE 0 END) AS discharge_too_few,
    SUM(CASE WHEN Number_of_Readmissions = 'Too Few to Report' THEN 1 ELSE 0 END) AS readmissions_too_few,
    SUM(CASE WHEN Footnote IS NOT NULL AND Footnote <> '' THEN 1 ELSE 0 END) AS rows_with_footnotes
FROM hrrp_raw;

-- Check for Too Few to Report in Number_of_Discharges

SELECT
    SUM(CASE
        WHEN Number_of_Discharges = 'Too Few to Report'
        THEN 1
        ELSE 0
    END) AS discharge_too_few
FROM hrrp_raw;

-- Check for duplicate hospital-condition records
SELECT
    Facility_ID,
    Measure_Name,
    COUNT(*) AS record_count
FROM hrrp_raw
GROUP BY Facility_ID, Measure_Name
HAVING COUNT(*) > 1;


-- Check date coverage
SELECT
    MIN(Start_Date) AS earliest_start_date,
    MAX(Start_Date) AS latest_start_date,
    MIN(End_Date) AS earliest_end_date,
    MAX(End_Date) AS latest_end_date
FROM hrrp_raw;


-- Check available HRRP measures
SELECT
    Measure_Name,
    COUNT(*) AS record_count
FROM hrrp_raw
GROUP BY Measure_Name
ORDER BY record_count DESC;


-- Check for missing key identifiers
SELECT
    SUM(CASE WHEN Facility_ID IS NULL OR Facility_ID = '' THEN 1 ELSE 0 END) AS missing_facility_id,
    SUM(CASE WHEN Facility_Name IS NULL OR Facility_Name = '' THEN 1 ELSE 0 END) AS missing_facility_name,
    SUM(CASE WHEN State IS NULL OR State = '' THEN 1 ELSE 0 END) AS missing_state,
    SUM(CASE WHEN Measure_Name IS NULL OR Measure_Name = '' THEN 1 ELSE 0 END) AS missing_measure_name
FROM hrrp_raw;


SELECT Facility_ID, Measure_Name, Excess_Readmission_Ratio,
    ROUND(Predicted_Readmission_Rate / NULLIF(Expected_Readmission_Rate, 0),
        4) AS calculated_ratio
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL
  AND Predicted_Readmission_Rate IS NOT NULL
  AND Expected_Readmission_Rate IS NOT NULL
  AND ROUND(Predicted_Readmission_Rate / NULLIF(Expected_Readmission_Rate, 0),
        4) <> Excess_Readmission_Ratio;
        
	
    SELECT
    COUNT(*) AS rows_with_difference,
    MAX(
        ABS(
            Excess_Readmission_Ratio -
            ROUND(
                Predicted_Readmission_Rate /
                NULLIF(Expected_Readmission_Rate, 0),
                4
            )
        )
    ) AS max_difference
FROM hrrp_clean
WHERE Excess_Readmission_Ratio IS NOT NULL
  AND Predicted_Readmission_Rate IS NOT NULL
  AND Expected_Readmission_Rate IS NOT NULL
  AND ROUND(
        Predicted_Readmission_Rate /
        NULLIF(Expected_Readmission_Rate, 0),
        4
      ) <> Excess_Readmission_Ratio;
      
-- Findings:
-- 307 rows showed a difference between the reported and calculated ratio
-- The maximum difference was 0.0001, consistent with rounding precision
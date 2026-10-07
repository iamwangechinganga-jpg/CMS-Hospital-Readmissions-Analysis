-- Create cleaned HRRP table

DROP TABLE IF EXISTS hrrp_clean;

CREATE TABLE hrrp_clean (
    Facility_Name VARCHAR(255),
    Facility_ID VARCHAR(20),
    State VARCHAR(2),
    Measure_Name VARCHAR(100),
    Number_of_Discharges INT,
    Footnote VARCHAR(255),
    Excess_Readmission_Ratio DECIMAL(10,4),
    Predicted_Readmission_Rate DECIMAL(10,4),
    Expected_Readmission_Rate DECIMAL(10,4),
    Number_of_Readmissions INT,
    Start_Date DATE,
    End_Date DATE
);
-- Populate cleaned table

INSERT INTO hrrp_clean (
    Facility_Name,
    Facility_ID,
    State,
    Measure_Name,
    Number_of_Discharges,
    Footnote,
    Excess_Readmission_Ratio,
    Predicted_Readmission_Rate,
    Expected_Readmission_Rate,
    Number_of_Readmissions,
    Start_Date,
    End_Date
)
SELECT
    Facility_Name,
    Facility_ID,
    State,
    Measure_Name,
    
   CASE
    WHEN Number_of_Discharges IN ('N/A', 'Too Few to Report') THEN NULL
    ELSE CAST(Number_of_Discharges AS UNSIGNED)
END,
    Footnote,
    CASE
        WHEN Excess_Readmission_Ratio = 'N/A' THEN NULL
        ELSE CAST(Excess_Readmission_Ratio AS DECIMAL(10,4))
    END,

    CASE
        WHEN Predicted_Readmission_Rate = 'N/A' THEN NULL
        ELSE CAST(Predicted_Readmission_Rate AS DECIMAL(10,4))
    END,

    CASE
        WHEN Expected_Readmission_Rate = 'N/A' THEN NULL
        ELSE CAST(Expected_Readmission_Rate AS DECIMAL(10,4))
    END,
        CASE
        WHEN Number_of_Readmissions = 'N/A' THEN NULL
        WHEN Number_of_Readmissions = 'Too Few to Report' THEN NULL
        ELSE CAST(Number_of_Readmissions AS UNSIGNED)
    END,
    
    STR_TO_DATE(Start_Date, '%m/%d/%Y'),

    STR_TO_DATE(End_Date, '%m/%d/%Y')
    
FROM hrrp_raw;

SELECT COUNT(*) AS total_rows
FROM hrrp_clean;

DESCRIBE hrrp_clean;

SELECT
    SUM(Number_of_Discharges IS NULL) AS missing_discharges,
    SUM(Excess_Readmission_Ratio IS NULL) AS missing_ratios,
    SUM(Predicted_Readmission_Rate IS NULL) AS missing_predicted_rates,
    SUM(Expected_Readmission_Rate IS NULL) AS missing_expected_rates,
    SUM(Number_of_Readmissions IS NULL) AS missing_readmissions
FROM hrrp_clean;

SELECT
    Facility_ID,
    Start_Date,
    End_Date
FROM hrrp_clean
LIMIT 10;

SELECT
    (SELECT COUNT(*) FROM hrrp_raw) AS raw_rows,
    (SELECT COUNT(*) FROM hrrp_clean) AS clean_rows;
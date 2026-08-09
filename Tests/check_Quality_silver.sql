/*
===============================================================================
Quality Checks - Silver Layer
===============================================================================
Script Purpose:
    This script performs data validation, sanity, and quality checks across 
    the 'silver' schema tables. It verifies:
    - Primary key uniqueness and integrity (NULL / Duplicates).
    - Unwanted leading or trailing whitespace in text values.
    - Domain range validations (valid costs, quantities, prices).
    - Chronological logical consistency (Start vs. End dates, Order vs. Ship dates).
    - Mathematical calculation consistency (Sales = Quantity * Price).
    - Categorical values standardization.

Target Tables:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

Usage Notes:
    - Execute after loading or updating the Silver Layer pipelines.
    - All queries expect zero (0) records returned unless checking standard values.
===============================================================================
*/

-- ====================================================================
-- Table: silver.crm_cust_info
-- ====================================================================

-- Check for Primary Key Uniqueness & Integrity
-- Expectation: 0 Records
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Leading/Trailing Whitespaces
-- Expectation: 0 Records
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Inspect Unique Categorical Values (Data Standardization Check)
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;


-- ====================================================================
-- Table: silver.crm_prd_info
-- ====================================================================

-- Check for Primary Key Uniqueness & Integrity
-- Expectation: 0 Records
SELECT 
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Leading/Trailing Whitespaces
-- Expectation: 0 Records
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for Invalid Cost Values (Negative or NULL)
-- Expectation: 0 Records
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Inspect Product Line Values (Data Standardization Check)
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check Chronological Order (End Date < Start Date)
-- Expectation: 0 Records
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- Table: silver.crm_sales_details
-- ====================================================================

-- Validate Date Formats and Boundaries in Bronze Stage
-- Expectation: 0 Records
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
   OR LEN(sls_due_dt) != 8 
   OR sls_due_dt > 20500101 
   OR sls_due_dt < 19000101;

-- Check Chronological Order Integrity
-- Expectation: 0 Records
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Verify Sales Formula Integrity (Sales = Quantity * Price)
-- Expectation: 0 Records
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- Table: silver.erp_cust_az12
-- ====================================================================

-- Verify Out-of-Range Birthdates
-- Expectation: Birthdates between 1924-01-01 and GETDATE()
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Inspect Gender Values (Data Standardization Check)
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;


-- ====================================================================
-- Table: silver.erp_loc_a101
-- ====================================================================

-- Inspect Country Names (Data Standardization Check)
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ====================================================================
-- Table: silver.erp_px_cat_g1v2
-- ====================================================================

-- Check for Unwanted Leading/Trailing Whitespaces
-- Expectation: 0 Records
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Inspect Maintenance Values (Data Standardization Check)
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;

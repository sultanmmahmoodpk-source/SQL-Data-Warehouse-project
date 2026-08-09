/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Target Tables:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales

Usage Notes:
    - Execute after building or updating the Gold Layer star schema.
    - All queries expect zero (0) records returned.
    - Investigate and resolve any discrepancies found during execution.
===============================================================================
*/

-- ====================================================================
-- Table: gold.dim_customers
-- ====================================================================

-- Check for Uniqueness of Customer Key
-- Expectation: 0 Records
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Table: gold.dim_products
-- ====================================================================

-- Check for Uniqueness of Product Key
-- Expectation: 0 Records
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Table: gold.fact_sales
-- ====================================================================

-- Check Referential Integrity / Data Model Connectivity
-- Expectation: 0 Records (Ensures no orphan records exist in the fact table)
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;

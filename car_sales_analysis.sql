/* =====================================================================
   CAR SALES ANALYSIS 
   Business Question: Which dealer regions and car segments should the
   business prioritize for inventory and marketing spend, based on sales
   performance and customer income alignment?

   Dataset: car_data.csv (23,906 transactions, Jan 2022 - Dec 2023)
   ===================================================================== */

-- ---------------------------------------------------------------------
use TEST;
select * from dbo.sales;

-- ---------------------------------------------------------------------
-- 1. REGION PERFORMANCE: units sold, revenue, avg price, avg customer income
-- ---------------------------------------------------------------------
SELECT
    Dealer_Region,
    COUNT(*)                       AS units_sold,
    SUM(Price_)                    AS total_revenue,
    ROUND(AVG(Price_ * 1.0), 0)    AS avg_price,
    ROUND(AVG(Annual_Income * 1.0), 0) AS avg_customer_income
FROM dbo.sales
GROUP BY Dealer_Region
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------------------
-- 2. TOP-REVENUE BODY STYLE PER REGION (window function: RANK)
-- ---------------------------------------------------------------------
WITH region_style AS (
    SELECT
        Dealer_Region,
        Body_Style,
        COUNT(*)                          AS units,
        SUM(Price_)                       AS revenue,
        ROUND(AVG(Price_ * 1.0), 0)       AS avg_price,
        ROUND(AVG(Annual_Income * 1.0), 0) AS avg_income
    FROM dbo.sales
    GROUP BY Dealer_Region, Body_Style
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY Dealer_Region ORDER BY revenue DESC) AS rnk
    FROM region_style
)
SELECT Dealer_Region, Body_Style, units, revenue, avg_price, avg_income
FROM ranked
WHERE rnk = 1
ORDER BY revenue DESC;


-- ---------------------------------------------------------------------
-- 3. BODY STYLE PERFORMANCE OVERALL
-- ---------------------------------------------------------------------
SELECT
    Body_Style,
    COUNT(*)                           AS units,
    SUM(Price_)                        AS revenue,
    ROUND(AVG(Price_ * 1.0), 0)        AS avg_price,
    ROUND(AVG(Annual_Income * 1.0), 0) AS avg_income
FROM dbo.sales
GROUP BY Body_Style
ORDER BY revenue DESC;


-- ---------------------------------------------------------------------
-- 4. INCOME-SEGMENT SPENDING BEHAVIOR (window function: NTILE)
-- ---------------------------------------------------------------------
WITH seg AS (
    SELECT *,
           NTILE(3) OVER (ORDER BY Annual_Income) AS income_tercile
    FROM dbo.sales
)
SELECT
    CASE income_tercile
        WHEN 1 THEN 'Low Income'
        WHEN 2 THEN 'Mid Income'
        ELSE 'High Income'
    END                                                       AS segment,
    COUNT(*)                                                   AS units,
    ROUND(AVG(Annual_Income * 1.0), 0)                         AS avg_income,
    ROUND(AVG(Price_ * 1.0), 0)                                AS avg_price_paid,
    ROUND(AVG(Price_ * 1.0) / AVG(Annual_Income * 1.0) * 100, 2) AS price_to_income_pct
FROM seg
GROUP BY income_tercile;

-- Correlation between income and price (SQL Server has no built-in CORR(),
-- so compute Pearson's r manually):
WITH stats AS (
    SELECT
        Annual_Income * 1.0 AS x,
        Price_ * 1.0        AS y
    FROM dbo.sales
)
SELECT
    (COUNT(*) * SUM(x*y) - SUM(x) * SUM(y))
    /
    NULLIF(
        SQRT(COUNT(*) * SUM(x*x) - SUM(x)*SUM(x)) *
        SQRT(COUNT(*) * SUM(y*y) - SUM(y)*SUM(y)),
    0) AS pearson_correlation
FROM stats;


-- ---------------------------------------------------------------------
-- 5. % OF HIGH-INCOME CUSTOMERS BY REGION
-- ---------------------------------------------------------------------
WITH seg AS (
    SELECT *,
           NTILE(3) OVER (ORDER BY Annual_Income) AS income_tercile
    FROM dbo.sales
)
SELECT
    Dealer_Region,
    ROUND(100.0 * SUM(CASE WHEN income_tercile = 3 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_high_income_customers,
    ROUND(AVG(Price_ * 1.0), 0) AS avg_price
FROM seg
GROUP BY Dealer_Region
ORDER BY pct_high_income_customers DESC;


-- ---------------------------------------------------------------------
-- 6. SEASONALITY: units & revenue by calendar month (both years combined)
--    Uses MONTH() instead of SQLite's strftime()
-- ---------------------------------------------------------------------
SELECT
    MONTH(SaleDate) AS month_num,
    COUNT(*)         AS units,
    SUM(Price_)      AS revenue
FROM dbo.sales
GROUP BY MONTH(SaleDate)
ORDER BY month_num;


-- ---------------------------------------------------------------------
-- 7. YEAR-OVER-YEAR REVENUE GROWTH BY REGION
--    Uses YEAR() instead of SQLite's strftime()
-- ---------------------------------------------------------------------
WITH yearly AS (
    SELECT
        Dealer_Region,
        YEAR(SaleDate) AS yr,
        SUM(Price_)    AS revenue
    FROM dbo.sales
    GROUP BY Dealer_Region, YEAR(SaleDate)
)
SELECT
    Dealer_Region,
    MAX(CASE WHEN yr = 2022 THEN revenue END) AS revenue_2022,
    MAX(CASE WHEN yr = 2023 THEN revenue END) AS revenue_2023,
    ROUND(
        (MAX(CASE WHEN yr = 2023 THEN revenue END) - MAX(CASE WHEN yr = 2022 THEN revenue END))
        * 100.0 / MAX(CASE WHEN yr = 2022 THEN revenue END), 1
    ) AS growth_pct
FROM yearly
GROUP BY Dealer_Region
ORDER BY growth_pct DESC;


-- ---------------------------------------------------------------------
-- 8. TOP / BOTTOM 10 BRANDS BY REVENUE
-- ---------------------------------------------------------------------
SELECT TOP 10 Company, COUNT(*) AS units, SUM(Price_) AS revenue, ROUND(AVG(Price_ * 1.0),0) AS avg_price
FROM dbo.sales GROUP BY Company ORDER BY revenue DESC;

SELECT TOP 10 Company, COUNT(*) AS units, SUM(Price_) AS revenue, ROUND(AVG(Price_ * 1.0),0) AS avg_price
FROM dbo.sales GROUP BY Company ORDER BY revenue ASC;

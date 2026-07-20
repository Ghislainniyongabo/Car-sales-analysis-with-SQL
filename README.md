Car_Sales_Dataset_Analysis
Car Sales Data Exploration and Analysis with SQL (SQL SERVER)

Car dealerships generate a huge amount of transactional data every day — which region sold what, to whom, at what price — but most of it never gets turned into a decision. The idea of analysing the Car_Sales dataset is to figure out where a dealership network should actually put its inventory and marketing dollars, instead of guessing. The dataset consists of 23,906 rows with columns such as Car_id, Dealer_Region, Company, Body_Style, Annual_Income, Price and many more...

While Exploring Data with SQL, I was working on the following things...

1. Checked all the details of the table such as column names, data types and constraints
2. Checked for duplicate values in the [Car_id] column
3. Fixed a double-encoded UTF-8 issue in the [Engine] column that was displaying as "DoubleÂ Overhead Camshaft" instead of "Double Overhead Camshaft"
4. Converted the [SaleDate] column from text (M/D/YYYY) to a proper DATE data type, since a naive string comparison on the raw column gave a wrong date range
5. Checked min, max and avg values for [Annual_Income] and [Price] columns to understand the spread before drawing any conclusions
6. Counted distinct values in [Dealer_Region] (7), [Company] (30) and [Body_Style] (5) to confirm the categorical columns were clean enough to group on
7. Split customers into Low / Mid / High income groups using the NTILE() window function, to test whether income actually predicts what price car someone buys
8. Ranked body styles within each region using the RANK() window function to find the top-selling body style per region without writing a separate query per region

After Data Exploration with SQL, I started working on Analysing the Data with SQL where I found insights such as...

1. According to this dataset, Austin is the top performing region with 4,135 units sold and $117.2M in total revenue, followed by Janesville (3,821 units, $106.4M) and Scottsdale (3,433 units, $96.0M).
2. Every single region grew between 20.2% and 25.5% in revenue from 2022 to 2023 — Scottsdale posted the fastest growth (+25.5%) despite being only mid-sized in total revenue, making it the strongest "invest ahead of the curve" candidate.
3. SUV and Hatchback are the top two revenue-generating body styles in every one of the 7 regions, together accounting for close to 59% of total revenue — this is a company-wide pattern, not a regional coincidence.
4. The correlation between a customer's annual income and the price they actually paid for a car is only 0.01, meaning income level has practically no relationship with how expensive a car someone buys.
5. Customers in the Low Income group ($154K avg income) paid an average price of $28,067, almost identical to the High Income group ($1.6M avg income) who paid $28,267 — a gap of under 2%, despite a 10x difference in income.
6. The share of high-income customers only ranges from 32.3% (Austin) to 35.1% (Pasco) across all 7 regions, confirming income is spread almost evenly everywhere rather than concentrated in any one region.
7. September, November and December are the strongest months, each moving roughly double the units of a typical mid-year month, while January and February are consistently the slowest.
8. Chevrolet, Ford and Dodge are the top 3 brands by revenue (1,600+ units sold each), while Jaguar, Hyundai and Infiniti are the bottom 3, each selling under 300 units across the full 2-year period — worth a separate stocking/demand review.
9. Best regions to prioritize for inventory and marketing spend are Austin, for its scale and steady growth, and Scottsdale, for its momentum — with inventory weighted toward SUVs and Hatchbacks and marketing spend concentrated ahead of the September–December peak, since income-based targeting is not supported by the data.

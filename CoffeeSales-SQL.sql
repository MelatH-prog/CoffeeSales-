-- Join three different table(customes,orders,products) and create a table

SELECT O.Order_ID, O.Order_Date, C.Customer_ID,
	   P.Product_ID, O.Quantity,C.Customer_Name,
	   C.City,C.Country, C.Loyalty_Card, P.Coffee_Type, 
	   P.Roast_Type, P.Size, P.Unit_Price,P.Price_per_100g,
	   P.Profit
INTO CoffeeSales
FROM Orders O
JOIN Customers C
ON O.Customer_ID = C.Customer_ID
JOIN Products P
ON O.Product_ID = P.Product_ID

-- created a table called CoffeeSales for simplicity
-- Now add a new column called sales

ALTER TABLE CoffeeSales
ADD Sales
DECIMAL (10,2)

-- Update it with calculated values by multipling quantity and unit_price
UPDATE CoffeeSales
SET Sales=Quantity*Unit_Price

--Let's Check
SELECT *
FROM CoffeeSales

--Data Cleaning, Let's check for missing values
 
SELECT COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Missing_OrderID,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Missing_OrderDate,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerID,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_ProductID
FROM CoffeeSales 

-- There is no missing values 
-- Data Cleaning, check for duplicates and remove

WITH Noduplicate AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Customer_ID, Order_ID, Product_ID ORDER BY Order_Date) AS rn
    FROM CoffeeSales
)
DELETE FROM Noduplicate WHERE rn > 1

--Data Cleaning, Standardize data type and formats

ALTER TABLE CoffeeSales 
ALTER COLUMN Order_Date DATE

UPDATE CoffeeSales
SET Coffee_Type =CASE
	WHEN Coffee_Type = 'Ara' THEN 'Arabica'
	WHEN Coffee_Type = 'Rob' THEN 'Robesta'
	WHEN Coffee_Type = 'Lib' THEN 'Liberica'
	WHEN Coffee_Type = 'Exc' THEN 'Excelsa'
	ELSE Coffee_Type
END

--Similarly change the values of Roast types

UPDATE CoffeeSales
SET Roast_Type =CASE
	WHEN Roast_Type = 'L' THEN 'Light'
	WHEN Roast_Type = 'M' THEN 'Medium'
	WHEN Roast_Type = 'D' THEN 'Dark'
	ELSE Roast_Type
END

--Analysis
--Which coffee type generates the highest revenue

SELECT Coffee_Type, SUM(Sales) AS Total_Sales
FROM CoffeeSales
GROUP BY Coffee_Type
ORDER BY Total_Sales DESC

--Total Sales over time

SELECT Order_Date, SUM(Sales) AS Total_Sales
FROM CoffeeSales
GROUP BY Order_Date
ORDER BY Order_Date 

-- Top Customer by revenue

SELECT Customer_Name, SUM(Sales) AS Total_Spent
FROM CoffeeSales
GROUP BY Customer_Name
ORDER BY Total_Spent DESC 

--Most Popular Roast type

SELECT Roast_Type, SUM(Sales) AS Total_Sales
FROM CoffeeSales
GROUP BY Roast_Type
ORDER BY Total_Sales DESC








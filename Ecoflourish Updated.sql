-- This shows how all products would be accounted for even if inventory records are incomplete

SELECT
productid,
productname,
category,
price,
COALESCE (Stockquantity, 0) AS "Stock Quantity"
FROM Dimproduct;

-- This shows product haven't been popular in the past year and should be consider for the end of season sale

-- This uses the inner nested query


SELECT
productid,
productname
FROM dimproduct
WHERE productid NOT IN (SELECT productid
					   FROM factsales
					   WHERE EXTRACT (YEAR FROM SALEDATE) = 2023
					   GROUP BY productid
					   HAVING SUM(quantitysold) >=2)
					   ORDER BY productname;

--This shows how EcoFlourish  products can be grouped into simpliefied price categories

-- To obtain price categories
SELECT
ROUND(MAX(price)) AS "Maximum Price",
ROUND(MIN(price)) AS "Minimum Price",
ROUND(AVG(price)) AS "Average Price"
FROM Dimproduct;

SELECT
productid, 
productname,
CASE	
	WHEN price<= 499 THEN 'Budget Friendly'
	WHEN price BETWEEN 500 AND 900 THEN 'Mid Range'
	WHEN price>=901 THEN 'Premium'
		ELSE 'Unknown'
	END AS Pricecategory,
price
	FROM Dimproduct
	ORDER BY price DESC;

--List all sales transactions and match them with product information, including sales with unlisted products.
SELECT factsales.SaleID, dimproduct.ProductName, dimproduct.Price
FROM FactSales
RIGHT JOIN DimProduct ON factsales.ProductID = dimproduct.ProductID;

--Show every product and its last sale date, including products that have never been sold.
SELECT dimproduct.ProductName, MAX(factsales.SaleDate) AS LastSaleDate
FROM DimProduct
RIGHT JOIN FactSales ON dimproduct.ProductID = factsales.ProductID
GROUP BY dimproduct.ProductName;

--Identify products that have never been sold.
SELECT dp.ProductName
FROM DimProduct dp
LEFT JOIN FactSales fs ON dp.ProductID = fs.ProductID
WHERE fs.SaleID IS NULL;

--Find customers who have not made any purchases.
SELECT dc.FirstName, dc.LastName
FROM DimCustomer dc
LEFT JOIN FactSales fs ON dc.CustomerID = fs.CustomerID
WHERE fs.SaleID IS NULL
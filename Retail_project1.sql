CREATE TABLE customers (
    CustomerID NVARCHAR(20) PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender NVARCHAR(10),
    BirthDate DATE,
    City NVARCHAR(50),
    JoinDate DATE
);

CREATE TABLE products (
    ProductID NVARCHAR(20) PRIMARY KEY,
    ProductName NVARCHAR(100),
    Category NVARCHAR(50),
    SubCategory NVARCHAR(50),
    UnitPrice FLOAT,
    CostPrice FLOAT
);

CREATE TABLE stores (
    StoreID NVARCHAR(20) PRIMARY KEY,
    StoreName NVARCHAR(100),
    City NVARCHAR(50),
    Region NVARCHAR(50)
);

CREATE TABLE transactions (
    TransactionID NVARCHAR(20) PRIMARY KEY,
    Date DATE,
    CustomerID NVARCHAR(20),
    ProductID NVARCHAR(20),
    StoreID NVARCHAR(20),
    Quantity INT,
    Discount FLOAT,
    PaymentMethod NVARCHAR(50),

    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID),
    FOREIGN KEY (StoreID) REFERENCES stores(StoreID)
);

SELECT COUNT(*) FROM customers;

BULK INSERT customers
FROM 'C:\Users\Avantika\OneDrive\Desktop\4_month\P1\Customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

BULK INSERT products
FROM 'C:\Users\Avantika\OneDrive\Desktop\4_month\P1\Products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

SELECT COUNT(*) FROM products;

BULK INSERT stores
FROM 'C:\Users\Avantika\OneDrive\Desktop\4_month\P1\Stores.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

SELECT COUNT(*) FROM stores;

BULK INSERT transactions
FROM 'C:\Users\Avantika\OneDrive\Desktop\4_month\P1\Transactions.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

SELECT COUNT(*) FROM transactions;



CREATE VIEW sales_analysis AS
SELECT 
    t.TransactionID,
    t.Date,
    t.CustomerID,
    c.FirstName,
    c.LastName,
    c.City AS CustomerCity,
    p.ProductName,
    p.Category,
    s.StoreName,
    s.Region,
    t.Quantity,
    t.Discount,
    
    (t.Quantity * p.UnitPrice) AS GrossSales,
    (t.Quantity * p.UnitPrice * t.Discount) AS DiscountAmount,
    (t.Quantity * p.UnitPrice) - 
    (t.Quantity * p.UnitPrice * t.Discount) AS NetSales,
    
    (t.Quantity * p.CostPrice) AS TotalCost,
    
    ((t.Quantity * p.UnitPrice) - 
    (t.Quantity * p.UnitPrice * t.Discount)) - 
    (t.Quantity * p.CostPrice) AS Profit

FROM transactions t
JOIN customers c ON t.CustomerID = c.CustomerID
JOIN products p ON t.ProductID = p.ProductID
JOIN stores s ON t.StoreID = s.StoreID;

SELECT TOP 10 * FROM sales_analysis;




SELECT SUM(NetSales) AS TotalRevenue
FROM sales_analysis;

SELECT SUM(Profit) AS TotalProfit
FROM sales_analysis;

SELECT TOP 5 ProductName, SUM(NetSales) AS Revenue
FROM sales_analysis
GROUP BY ProductName
ORDER BY Revenue DESC;

SELECT Region, SUM(NetSales) AS Revenue
FROM sales_analysis
GROUP BY Region
ORDER BY Revenue DESC;

SELECT 
    FORMAT(Date, 'yyyy-MM') AS Month,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit
FROM sales_analysis
GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY Month;

SELECT TOP 5 
    CustomerID,
    FirstName,
    LastName,
    SUM(NetSales) AS TotalSpent
FROM sales_analysis
GROUP BY CustomerID, FirstName, LastName
ORDER BY TotalSpent DESC;

SELECT TOP 5
    ProductName,
    SUM(Profit) AS TotalProfit
FROM sales_analysis
GROUP BY ProductName
ORDER BY TotalProfit DESC;

SELECT 
    Category,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit
FROM sales_analysis
GROUP BY Category
ORDER BY Revenue DESC;

SELECT 
    AVG(Discount) AS AvgDiscount,
    SUM(DiscountAmount) AS TotalDiscountGiven
FROM sales_analysis;

SELECT 
    CustomerID,
    FirstName,
    LastName,
    SUM(NetSales) AS LifetimeRevenue,
    SUM(Profit) AS LifetimeProfit
FROM sales_analysis
GROUP BY CustomerID, FirstName, LastName
ORDER BY LifetimeRevenue DESC;

SELECT 
    CASE 
        WHEN COUNT(TransactionID) = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS CustomerType,
    COUNT(DISTINCT CustomerID) AS NumberOfCustomers
FROM sales_analysis
GROUP BY CustomerID;


SELECT 
    StoreName,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit
FROM sales_analysis
GROUP BY StoreName
ORDER BY Revenue DESC;

SELECT 
    Category,
    SUM(Profit) * 100.0 / SUM(NetSales) AS ProfitMarginPercent
FROM sales_analysis
GROUP BY Category
ORDER BY ProfitMarginPercent DESC;

SELECT TOP 5
    Date,
    SUM(NetSales) AS Revenue
FROM sales_analysis
GROUP BY Date
ORDER BY Revenue DESC;
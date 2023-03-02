--*************************************************************************--
-- Title: Assignment07
-- Author: AOrdonio
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,AOrdonio,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_AOrdonio')
	 Begin 
	  Alter Database [Assignment07DB_AOrdonio] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_AOrdonio;
	 End
	Create Database Assignment07DB_AOrdonio;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_AOrdonio;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
GO

-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --

/* 
List --> Table

SELECT 
ProductName,
UnitPrice
	FROM vProducts

SELECT 
ProductName,
Format (Select UnitPrice, 'C', 'en-us') as [UnitPrice]
	FROM vProducts

SELECT TOP 1000
	ProductName, 
	Format (UnitPrice, 'C', 'en-us') as [UnitPrice]
		FROM vProducts
	Order by ProductName ASC;
go

*/

SELECT TOP 1000
	ProductName, 
	Format (UnitPrice, 'C', 'en-us') as [UnitPrice]
		FROM vProducts
	Order by ProductName ASC;
go


-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

/* 

List --> Table 
Table vCategories and vProducts --> Inner Join

SELECT TOP 10000
CategoryName,
ProductName,
UnitPrice
	FROM vCategory INNER JOIN vProducts
	ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY CategoryName ASC, ProductName ASC

SELECT TOP 10000
CategoryName,
ProductName,
Format (UnitPrice, 'C', 'en-us') as [UnitPrice]
	FROM vCategory INNER JOIN vProducts
	ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY CategoryName ASC, ProductName ASC

*/

SELECT TOP 10000
CategoryName,
ProductName,
Format (UnitPrice, 'C', 'en-us') as [UnitPrice]
	FROM vCategories INNER JOIN vProducts
	ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY CategoryName ASC, ProductName ASC
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/*

SELECT TOP 10000
ProductName,
InventoryDate,
Count
	FROM vProducts INNER JOIN vInventories
	ON vProducts.ProductID = vInventories.ProductID
ORDER BY ProductName ASC, Date ASC

SELECT TOP 10000
ProductName,
Format (GetDate(), 'MMMM,yyyy') as [InventoryDate],
Count
	FROM vProducts INNER JOIN vInventories
	ON vProducts.ProductID = vInventories.ProductID
ORDER BY ProductName ASC, [InventoryDate] ASC;
go


SELECT TOP 10000
ProductName,
Format (InventoryDate, 'MMMM,yyyy') as [InventoryDate],			SCRAP THIS FXN BC ITS NOT ORDERING CORRECTLY
Count
	FROM vProducts INNER JOIN vInventories
	ON vProducts.ProductID = vInventories.ProductID
ORDER BY ProductName ASC, [InventoryDate] ASC;
go

SELECT TOP 10000
ProductName,
Concat(Datename(Month,InventoryDate), ' ' , Datename(Year, InventoryDate)) as [InventoryDate],
Count
	FROM vProducts INNER JOIN vInventories
	ON vProducts.ProductID = vInventories.ProductID
ORDER BY ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;
go


*/

SELECT TOP 10000
ProductName,
Concat(Datename(Month,InventoryDate), ',' , Datename(Year, InventoryDate)) as [InventoryDate],
Count
	FROM vProducts INNER JOIN vInventories
	ON vProducts.ProductID = vInventories.ProductID
ORDER BY ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;
go


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/* 

Create View:

CREATE or ALTER VIEW vProductInventories
AS
	SELECT TOP 100000
	ProductName,
	InventoryDate,
	Count
		FROM vProducts INNER JOIN vInventories
		ON vProducts.ProductID = vInventories.ProductID
	Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;
go

*/

CREATE or ALTER VIEW vProductInventories
AS
	SELECT TOP 1000000
	ProductName,
	Concat(Datename(Month,InventoryDate), ',' , Datename(Year, InventoryDate)) as [InventoryDate],
	Count
		FROM vProducts INNER JOIN vInventories
		ON vProducts.ProductID = vInventories.ProductID
	Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;
go

-- Check that it works: Select * From vProductInventories;

Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/*
WITHOUT FUNCTIONS:

CREATE or ALTER VIEW vCategoriesInventories
AS
	SELECT TOP 10000
	CategoryNames,
	InventoryDates,
	InventoryCount
	FROM dbo.vCategories as C
		INNER JOIN dbo.vProducts as P
		ON C.CategoryID = P.CategoryID
		INNER JOIN dbo.vInventories as I
		ON I.ProductID = P.ProductID

FUNCTIONS:

CREATE or ALTER VIEW vCategoriesInventories
AS
	SELECT TOP 10000
	CategoryNames,
	Concat(Datename(Month,InventoryDate), ',' , Datename(Year, InventoryDate)) as [InventoryDate],
	Sum(Count)
	FROM dbo.vCategories as C
		INNER JOIN dbo.vProducts as P
		ON C.CategoryID = P.CategoryID
		INNER JOIN dbo.vInventories as I
		ON I.ProductID = P.ProductID
	Group by CategoryNames
	Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;
*/

CREATE or ALTER VIEW vCategoryInventories 
AS
	SELECT TOP 100000
	CategoryName,
	Concat(Datename(Month,InventoryDate), ',' , Datename(Year, InventoryDate)) as [InventoryDate],
	Sum(Count) as [TotalInventoryCount]
	FROM dbo.vCategories as C
		INNER JOIN dbo.vProducts as P
		ON C.CategoryID = P.CategoryID
		INNER JOIN dbo.vInventories as I
		ON I.ProductID = P.ProductID
	Group by CategoryName, [InventoryDate]
	Order by CategoryName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC
go

-- Check that it works: Select * From vCategoryInventories;

Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
/*

Create or Alter View vProductInventoriesWithPreviousMonthCounts
AS
SELECT 
ProductName,
InventoryDate,
Count,
--[PreviousMonthCount]
	FROM vProductsInventories
	Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC

Create or Alter View vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 100000
	ProductName,
	InventoryDate,
	Count,
	[PreviousMonthCount] = IIF(InventoryDate like ('January,2017'), 0, Lag(Count) over (Order by ProductName, Year(InventoryDate)))
		FROM vProductsInventories
		Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC

*/

Create or Alter View vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 1000000
	ProductName,
	InventoryDate,
	Count,
	[PreviousMonthCount] = IIF(InventoryDate like ('January,2017'), 0, Lag(Count) over (Order by ProductName, Year(InventoryDate)))
		FROM vProductInventories
	Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;

Select * From vProductInventoriesWithPreviousMonthCounts
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

/*

SELECT TOP 1000000
ProductName,
InventoryDate,
Count,
PreviousMonthCount
	FROM vProductInventoriesWithPreviousMonthCounts
	Order by ProductName ASC, InventoryDate ASC

Create or alter view vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 1000000
	ProductName,
	InventoryDate,
	Count,
	[PreviousMonthCount]
		FROM vProductInventoriesWithPreviousMonthCounts
		Order by ProductName ASC, InventoryDate ASC

Create or alter view vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 1000000
	ProductName,
	InventoryDate,
	Count,
	PreviousMonthCount,
	[CountVsPreviousCountKPI] = IsNull(Case
		When Count > PreviousMonthCount then 1
			Count = PreviousMonthCount then 0
			Count < PreviousMonthCount then -1
			End, 0)
		FROM vProductInventoriesWithPreviousMonthCounts
		Order by ProductName ASC, InventoryDate ASC

*/

Create or alter view vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 1000000
	ProductName,
	InventoryDate,
	Count,
	PreviousMonthCount,
	[CountVsPreviousCountKPI] = IsNull(Case
		When Count > PreviousMonthCount then 1
		When Count = PreviousMonthCount then 0
		When Count < PreviousMonthCount then -1
			End, 0)
		FROM vProductInventoriesWithPreviousMonthCounts
		Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
/*

SELECT TOP 10000000
	ProductName,
	InventoryDate,
	Count,
	PreviousMonthCount
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
	Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;

SELECT TOP 10000000
	ProductName,
	InventoryDate,
	Count,
	[PreviousMonthCount] = IsNull(Case
		When Count > PreviousMonthCount then 1
		When Count = PreviousMonthCount then 0
		When Count < PreviousMonthCount then -1
			End, 0)
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
	Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC;

Create function fProductInventoriesWithPreviousMonthCountsWithKPIs
Returns table
AS
Return(
	SELECT TOP 10000000
		ProductName,
		InventoryDate,
		Count,
		PreviousMonthCount,
		[CountVsPreviousCountKPI] = IsNull(Case
			When Count > PreviousMonthCount then 1
			When Count = PreviousMonthCount then 0
			When Count < PreviousMonthCount then -1
				End, 0)
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
		Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC);

Create function fProductInventoriesWithPreviousMonthCountsWithKPIs
	(@KPIvalue INT)
Returns table
AS
Return(
	SELECT TOP 1000000
		ProductName,
		InventoryDate,
		Count,
		PreviousMonthCount,
		[CountVsPreviousCountKPI] = IsNull(Case
			When Count > PreviousMonthCount then 1
			When Count = PreviousMonthCount then 0
			When Count < PreviousMonthCount then -1
				End, 0)
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
		WHERE [CountVsPreviousCountKPI] = @KPIvalue
		Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC);
*/

Create function fProductInventoriesWithPreviousMonthCountsWithKPIs
	(@KPIvalue INT)
Returns table
AS
Return(
	SELECT TOP 1000000
		ProductName,
		InventoryDate,
		Count,
		PreviousMonthCount,
		[CountVsPreviousCountKPI] = IsNull(Case
			When Count > PreviousMonthCount then 1
			When Count = PreviousMonthCount then 0
			When Count < PreviousMonthCount then -1
				End, 0)
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
		WHERE [CountVsPreviousCountKPI] = @KPIvalue
		Order by ProductName ASC, Month(InventoryDate) ASC, Year(InventoryDate) ASC);
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/
--*************************************************************************--
-- Title: Assignment07
-- Author: TErickson
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,TErickson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_TErickson')
	 Begin 
	  Alter Database [Assignment07DB_TErickson] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_TErickson;
	 End
	Create Database Assignment07DB_TErickson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_TErickson;

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
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
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
--Print
--'NOTES------------------------------------------------------------------------------------ 
-- 1) You must use the BASIC views for each table.
-- 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
-- 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- show a list of Product names and the price of each product
-- Use a function to format the price as US dollars?
-- Order the result by the product name.

--Showing my work: Looked up UnitPrice column in vProducts view to determine existing format. In this
--case, it was Money, added concatenation.

USE Assignment07DB_TErickson
GO
SELECT vProducts.ProductName
,'$' + CAST(vProducts.UnitPrice AS varchar(50))
FROM vProducts
ORDER BY vProducts.ProductName
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product
-- Format the price as US dollars.
-- Order the result by the Category and Product.

--Show my work: Looked up US currency formatting from DEMOs folder. Incorporated format in lieu of cast.

USE Assignment07DB_TErickson
GO
SELECT dbo.vCategories.CategoryName
,dbo.vProducts.ProductName
,FORMAT(dbo.vProducts.UnitPrice ,'C', 'en-US') As UnitPriceUS
FROM dbo.vCategories
JOIN vProducts on vCategories.CategoryID = vProducts.CategoryID
ORDER BY dbo.vCategories.CategoryName,.vProducts.ProductName
GO


-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count.

--Showing my work: Looked up data type for InventoryDate in Inventories View. Used a function to create a 
--string for the month and date. Used function in select statement.  It took me a long time to figure out the 
--sort, but I finally figured out you can use the date field without the function in the group by clause
--to get it to sort properly.

USE Assignment07DB_TErickson;
GO
CREATE FUNCTION dbo.finventorydate (@Date Date)
Returns varchar(100)
As
	Begin
		Return(
			Select DateName(mm,@Date)+
			', '+
			DateName(yy,@Date)
		)
	End;
GO

USE Assignment07DB_TErickson;
GO
SELECT dbo.vProducts.ProductName
,dbo.finventorydate(vInventories.InventoryDate) as InventoryDate
,dbo.vInventories.Count as InventoryCount
FROM vProducts
JOIN dbo.vInventories on vProducts.ProductID = vInventories.ProductID
GROUP BY vproducts.ProductName,vInventories.InventoryDate,vInventories.Count
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count!

--Showing my work:  Created the view with the specified columns.  Adjusted the inventory date column to 
--match the formatting (used the function from Question 03 above).

USE Assignment07DB_TErickson
GO
CREATE 
VIEW vProductInventories 
AS
	SELECT TOP 1000 dbo.vProducts.ProductName
	,dbo.finventorydate(vInventories.InventoryDate) as InventoryDate
	,dbo.vInventories.Count
	FROM dbo.vProducts 
	LEFT JOIN dbo.vInventories ON dbo.vProducts.ProductID = dbo.vInventories.ProductID
	GROUP BY vProducts.ProductName, vInventories.InventoryDate, vInventories.Count
GO

SELECT * FROM vProductInventories
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.

--Showing my work:  Determined joins, used function created in Question 3, 
--SELECT * FROM vInventories
--SELECT * FROM vCategories
--SELECT * FROM vProducts

USE Assignment07DB_TErickson
GO
CREATE
VIEW vCategoryInventories
AS
	SELECT TOP 1000 vCategories.CategoryName
	,dbo.finventorydate(vInventories.InventoryDate) as InventoryDate
	,InventoryCount = Sum(vInventories.Count)
	FROM vCategories	
	JOIN vProducts ON vCategories.CategoryID = vProducts.CategoryID	
	JOIN vInventories ON  vProducts.ProductID = vInventories.ProductID 
	GROUP BY vCategories.CategoryName,vInventories.InventoryDate
	ORDER BY vCategories.CategoryName,vInventories.InventoryDate,SUM(vInventories.Count)
GO

SELECT * FROM vCategoryInventories
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product, Date, and Count. 
-- This new view must use your vProductInventories view!

--Showing my work:Built the Select statement piece by piece. Previous month count - buily lag/over, then added isnull, then added IIF
--Then added Create View. Phew!

USE Assignment07DB_TErickson
GO
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 1000 vProductInventories.ProductName
	,dbo.finventorydate(vInventories.InventoryDate) AS InventoryDate
	,vProductInventories.Count
	,PreviousMonthCount = IIF(Month(dbo.finventorydate(vInventories.InventoryDate)) = 01, 0 ,IsNull( Lag(vProductInventories.Count) Over (Order By ProductName,Month(dbo.finventorydate(vInventories.InventoryDate))), 0))
	FROM vProductInventories
	JOIN vInventories ON vProductInventories.InventoryDate = vInventories.InventoryDate
	GROUP BY vProductInventories.ProductName,dbo.finventorydate(vInventories.InventoryDate),vProductInventories.Count
GO

SELECT * FROM vProductInventoriesWithPreviousMonthCounts
GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Order the results by the Product, Date, and Count!

--Showing my work:  Used columns from view created in Question 6. Altered column for previous month count to place a 0 for nulls.
--created case steament for KPIs
--Inserted order by clause
--created view

USE Assignment07DB_TErickson
GO
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 1000 ProductName
	,InventoryDate
	,Count
	,PreviousMonthCount = IsNull(PreviousMonthCount, 0)
	,[CountChangeKPI] = IsNull(Case 
	   When Count > PreviousMonthCount Then 1
	   When Count = PreviousMonthCount Then 0
	   When Count < PreviousMonthCount Then -1
	   End, 0) 
	FROM vProductInventoriesWithPreviousMonthCounts
	ORDER BY ProductName,month(InventoryDate),Count
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view!

--Showing my work:  Created select statement using Question 7, Added Create Function,
--Added Parameter
--Added Where Clause

USE Assignment07DB_TErickson
GO
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@CountChangeKPI Int)
RETURNS TABLE
AS
	RETURN(
		SELECT ProductName
		,InventoryDate
		,Count
		,PreviousMonthCount
		,CountChangeKPI
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
			WHERE CountChangeKPI = @CountChangeKPI
		)
GO

SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO

/***************************************************************************************/
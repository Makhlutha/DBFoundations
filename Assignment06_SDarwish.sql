--*************************************************************************--
-- Title: Assignment06
-- Author: Safaa Darwish
-- Desc: This file demonstrates how to use Views
-- Change Log:
-- November 25, 2021,Safaa Darwish
-- This file was originally created on January 1st, 2017 by Randal Root. 
-- I have created several views to be used in future projects. These views 
-- are meant to be useful but displaying things like managers and their
-- direct reports, units sold on specific dates, and Chai/Chang product sell dates.
-- The views that I have created in this file are as follows:
-- vData112521_Products . . . Displays columns in dbo.Products 
-- vData112521_Inventories . . . Displays columns in dbo.Inventories
-- vData112521_Employees . . . Displays columns in dbo.Employees
-- vData112521_Categories . . . Displays columns in dbo.Categories
-- vCategoryProductPrice . . . Displays the category product and price
-- vProductsInventoriesCounts . . . Displays Products, Inventories and respective counts
-- vInventories_Employees_byDate . . . Displays the Inventory counts picked up by Employee by date
-- vInvCatProd_DateCount . . . Displays the Inventory, Category, Product and their inventory count. 
--                             Date of count is displayed.
-- vEmployee_InventoryProductCount . . . Displays the Product Inventory counts by employee.
-- vInvCatProd_ChaiChang . . . Displays all Chai and Chang inventory, categories and product names.
-- vList_ManagersEmployees . . . Displays the Managers and their direct reports
-- vAllData_EmployeesCatProdInv . . . Displays all data for views generated for Products
--									  inventories, employees, and categories.
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SDarwish')
	 Begin 
	  Alter Database [Assignment06DB_SDarwish] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SDarwish;
	 End
	Create Database Assignment06DB_SDarwish;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SDarwish;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE VIEW vData112521_Categories
	WITH SCHEMABINDING 
AS
	SELECT 
	C.CategoryName,
	C.CategoryID
	FROM 
	dbo.Categories as C
GO

CREATE VIEW vData112521_Products
	WITH SCHEMABINDING 
AS
	SELECT 
	P.ProductID,
	P.ProductName,
	P.CategoryID,
	P.UnitPrice
	FROM dbo.Products as P
GO

CREATE VIEW vData112521_Inventories
	WITH SCHEMABINDING 
AS
	SELECT 
	I.InventoryID,
	I.EmployeeID,
	I.[Count],
	I.InventoryDate,
	I.ProductID
	FROM dbo.Inventories as I
GO

CREATE VIEW vData112521_Employees
	WITH SCHEMABINDING 
AS
	SELECT 
	E.EmployeeFirstName,
	E.EmployeeLastName,
	E.EmployeeID,
	E.ManagerID
	FROM dbo.Employees as E
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON dbo.Categories TO PUBLIC;
DENY SELECT ON dbo.Employees TO PUBLIC;
DENY SELECT ON dbo.Inventories TO PUBLIC;
DENY SELECT ON dbo.Products TO PUBLIC;
GO

GRANT SELECT ON vData112521_Categories TO PUBLIC;
GRANT SELECT ON vData112521_Employees TO PUBLIC;
GRANT SELECT ON vData112521_Inventories TO PUBLIC;
GRANT SELECT ON vData112521_Products TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

CREATE VIEW vCategoryProductPrice
AS
SELECT TOP 100000000
	C.CategoryName,
	P.ProductName,
	P.UnitPrice
FROM 
	vData112521_Categories as C
	INNER JOIN vData112521_Products as P
	ON C.CategoryID = P.CategoryID
		ORDER BY CategoryName, ProductName, UnitPrice;
GO

SELECT * FROM vCategoryProductPrice;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33
CREATE VIEW vProductsInventoriesCounts
AS
SELECT TOP 100000000 
	P.ProductName,
	I.InventoryDate,
	I.[Count]
FROM 
	vData112521_Products as P
	INNER JOIN vData112521_Inventories as I
	ON I.ProductID = P.ProductID
		ORDER BY P.ProductID, I.InventoryDate, I.[Count];
GO

SELECT * FROM vProductsInventoriesCounts;
GO
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE VIEW vInventories_Employees_byDate
AS 
SELECT DISTINCT TOP 10000
	I.InventoryDate,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeFullName
FROM vData112521_Inventories as I
	INNER JOIN vData112521_Employees as E
	ON I.EmployeeID = E.EmployeeID
		ORDER BY I.InventoryDate, EmployeeFullName;
GO

SELECT * FROM vInventories_Employees_byDate;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37
CREATE VIEW vInvCatProd_DateCount
AS 
SELECT TOP 1000000
	C.CategoryName,
	P.ProductName,
	I.InventoryDate,
	I.[Count]
FROM vData112521_Products as P
	INNER JOIN vData112521_Categories as C
	ON P.CategoryID = C.CategoryID
	INNER JOIN vData112521_Inventories as I
	ON I.ProductID = P.ProductID
	INNER JOIN vData112521_Employees as E
	ON I.EmployeeID = E.EmployeeID
		ORDER BY C.CategoryID, P.ProductName,I.InventoryDate,I.[Count];
GO

SELECT * FROM vInvCatProd_DateCount;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

CREATE VIEW vEmployee_InventoryProductCount
AS
	SELECT TOP 100000000
	C.CategoryName,
	P.ProductName,
	I.InventoryDate,
	I.[Count],
	E.EmployeeFirstName + ' ' + EmployeeLastName as EmployeeFullName
	FROM vData112521_Inventories as I
		INNER JOIN vData112521_Employees as E
		ON I.EmployeeID = E.EmployeeID
		INNER JOIN vData112521_Products as P
		ON I.ProductID = P.ProductID
		INNER JOIN vData112521_Categories as C
		ON P.CategoryID = C.CategoryID
		ORDER BY 3,1,2,4;
GO

SELECT * FROM vEmployee_InventoryProductCount;
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

CREATE VIEW vInvCatProd_ChaiChang
AS 
SELECT TOP 1000000
	C.CategoryName,
	P.ProductName,
	I.InventoryDate,
	I.[Count],
	E.EmployeeFirstName + ' ' + EmployeeLastName as EmployeeFullName
FROM vData112521_Products as P
	INNER JOIN vData112521_Categories as C
	ON P.CategoryID = C.CategoryID
	INNER JOIN vData112521_Inventories as I
	ON I.ProductID = P.ProductID
	INNER JOIN vData112521_Employees as E
	ON I.EmployeeID = E.EmployeeID
	WHERE I.ProductID IN (SELECT ProductID FROM vData112521_Products WHERE ProductName in  ('Chai', 'Chang'))
		ORDER BY C.CategoryID, P.ProductName,I.InventoryDate,I.[Count], EmployeeFullName;
GO

SELECT * FROM vInvCatProd_ChaiChang;
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

CREATE VIEW vList_ManagersEmployees
AS 
SELECT TOP 1000000
	M.EmployeeFirstName + ' ' + M.EmployeeLastName as ManagerFullName,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeFullName
FROM vData112521_Employees as E
	INNER JOIN vData112521_Employees as M
	ON E.ManagerID = M.EmployeeID
		ORDER BY ManagerFullName, EmployeeFullName;
GO

SELECT * FROM vList_ManagersEmployees;
GO
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

CREATE VIEW vAllData_EmployeesCatProdInv
AS 
SELECT TOP 1000000
	C.CategoryName,
	C.CategoryID,
	P.ProductID,
	P.ProductName,
	P.UnitPrice,
	I.InventoryID,
	I.InventoryDate,
	I.[Count],
	E.EmployeeID,
	E.ManagerID,
	M.EmployeeFirstName + ' ' + M.EmployeeLastName as ManagerFullName,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeFullName
FROM vData112521_Categories as C
	INNER JOIN vData112521_Products as P
	ON P.CategoryID = C.CategoryID
	INNER JOIN vData112521_Inventories as I
	ON P.ProductID = I.ProductID
	INNER JOIN vData112521_Employees as E
	ON I.EmployeeID = E.EmployeeID
	INNER JOIN vData112521_Employees as M
	ON E.ManagerID = M.EmployeeID
	ORDER BY	C.CategoryID, C.CategoryName,
		        P.ProductID, P.ProductName, P.UnitPrice,
	     		I.InventoryID, I.InventoryDate, I.[Count], 
				E.EmployeeID, EmployeeFullName, ManagerFullName;
GO

SELECT * FROM vAllData_EmployeesCatProdInv;
GO
-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vData112521_Categories]
Select * From [dbo].[vData112521_Products]
Select * From [dbo].[vData112521_Inventories]
Select * From [dbo].[vData112521_Employees]

Select * From [dbo].[vCategoryProductPrice]
Select * From [dbo].[vProductsInventoriesCounts]
Select * From [dbo].[vInventories_Employees_byDate]
Select * From [dbo].[vInvCatProd_DateCount]
Select * From [dbo].[vEmployee_InventoryProductCount]
Select * From [dbo].[vInvCatProd_ChaiChang]
Select * From [dbo].[vList_ManagersEmployees]
Select * From [dbo].[vAllData_EmployeesCatProdInv]

/***************************************************************************************/
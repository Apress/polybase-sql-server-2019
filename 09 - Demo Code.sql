USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF (SCHEMA_ID('ELT') IS NULL)
BEGIN
	EXEC(N'CREATE SCHEMA [ELT]');
END
GO
-- Step 1:  Create external tables.
IF (OBJECT_ID('ELT.Invoices') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE [ELT].[Invoices]
	(
		[InvoiceID] [int] NOT NULL,
		[CustomerID] [int] NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[OrderID] [int] NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[ContactPersonID] [int] NOT NULL,
		[AccountsPersonID] [int] NOT NULL,
		[SalespersonPersonID] [int] NOT NULL,
		[PackedByPersonID] [int] NOT NULL,
		[InvoiceDate] [date] NOT NULL,
		[CustomerPurchaseOrderNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[IsCreditNote] [bit] NOT NULL,
		[CreditNoteReason] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[Comments] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[DeliveryInstructions] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[InternalComments] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[TotalDryItems] [int] NOT NULL,
		[TotalChillerItems] [int] NOT NULL,
		[DeliveryRun] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[RunPosition] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[ReturnedDeliveryData] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[LastEditedBy] [int] NOT NULL,
		[LastEditedWhen] [datetime2](7) NOT NULL
	)
	WITH
    (
        LOCATION = 'WideWorldImporters.Sales.Invoices',
        DATA_SOURCE = Desktop
    );
END
GO
IF (OBJECT_ID('ELT.InvoiceLines') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE [ELT].[InvoiceLines]
    (
        [InvoiceLineID] [int] NOT NULL,
        [InvoiceID] [int] NOT NULL,
        [StockItemID] [int] NOT NULL,
        [Description] [nvarchar](100) COLLATE Latin1_General_100_CI_AS NOT NULL,
        [PackageTypeID] [int] NOT NULL,
        [Quantity] [int] NOT NULL,
        [UnitPrice] [decimal](18, 2) NULL,
        [TaxRate] [decimal](18, 3) NOT NULL,
        [TaxAmount] [decimal](18, 2) NOT NULL,
        [LineProfit] [decimal](18, 2) NOT NULL,
        [ExtendedPrice] [decimal](18, 2) NOT NULL,
        [LastEditedBy] [int] NOT NULL,
        [LastEditedWhen] [datetime2](7) NOT NULL
    )
    WITH
    (
        LOCATION = 'WideWorldImporters.Sales.InvoiceLines',
        DATA_SOURCE = Desktop
    );
END
GO
IF (OBJECT_ID('ELT.Customers') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE [ELT].[Customers]
	(
		[CustomerID] [int] NOT NULL,
		[CustomerName] [nvarchar](100) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[CustomerCategoryID] [int] NOT NULL,
		[BuyingGroupID] [int] NULL,
		[PrimaryContactPersonID] [int] NOT NULL,
		[AlternateContactPersonID] [int] NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[DeliveryCityID] [int] NOT NULL,
		[PostalCityID] [int] NOT NULL,
		[CreditLimit] [decimal](18, 2) NULL,
		[AccountOpenedDate] [date] NOT NULL,
		[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
		[IsStatementSent] [bit] NOT NULL,
		[IsOnCreditHold] [bit] NOT NULL,
		[PaymentDays] [int] NOT NULL,
		[PhoneNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[FaxNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryRun] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[RunPosition] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[WebsiteURL] [nvarchar](256) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryAddressLine1] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryAddressLine2] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NULL,
		[DeliveryPostalCode] [nvarchar](10) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PostalAddressLine1] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PostalAddressLine2] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NULL,
		[PostalPostalCode] [nvarchar](10) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[LastEditedBy] [int] NOT NULL,
		[ValidFrom] [datetime2](7) NOT NULL,
		[ValidTo] [datetime2](7) NOT NULL
	)
	WITH
    (
        LOCATION = 'WideWorldImporters.Sales.Customers',
        DATA_SOURCE = Desktop
    );
END
GO
IF (OBJECT_ID('ELT.People') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE [ELT].[People]
	(
		[PersonID] [int] NOT NULL,
		[FullName] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PreferredName] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[IsSystemUser] [bit] NOT NULL,
		[IsEmployee] [bit] NOT NULL,
		[IsSalesperson] [bit] NOT NULL,
		[PhoneNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[FaxNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[EmailAddress] [nvarchar](256) COLLATE Latin1_General_100_CI_AS NULL,
		[LastEditedBy] [int] NOT NULL,
		[ValidFrom] [datetime2](7) NOT NULL,
		[ValidTo] [datetime2](7) NOT NULL
	)
	WITH
	(
		LOCATION = 'WideWorldImporters.Application.People',
		DATA_SOURCE = Desktop
	);
END
GO
IF (SCHEMA_ID('Staging') IS NULL)
BEGIN
	EXEC(N'CREATE SCHEMA [Staging]');
END
GO
-- Step 2:  Create staging tables.
-- For simplicity's sake, I'm not creating any keys, constraints, etc.
-- You could do that in a real solution.
IF (OBJECT_ID('Staging.Invoices') IS NULL)
BEGIN
	CREATE TABLE [Staging].[Invoices]
	(
		[InvoiceID] [int] NOT NULL,
		[CustomerID] [int] NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[OrderID] [int] NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[ContactPersonID] [int] NOT NULL,
		[AccountsPersonID] [int] NOT NULL,
		[SalespersonPersonID] [int] NOT NULL,
		[PackedByPersonID] [int] NOT NULL,
		[InvoiceDate] [date] NOT NULL,
		[CustomerPurchaseOrderNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[IsCreditNote] [bit] NOT NULL,
		[CreditNoteReason] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[Comments] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[DeliveryInstructions] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[InternalComments] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[TotalDryItems] [int] NOT NULL,
		[TotalChillerItems] [int] NOT NULL,
		[DeliveryRun] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[RunPosition] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[ReturnedDeliveryData] [nvarchar](max) COLLATE Latin1_General_100_CI_AS NULL,
		[LastEditedBy] [int] NOT NULL,
		[LastEditedWhen] [datetime2](7) NOT NULL
	);
END
GO
IF (OBJECT_ID('Staging.InvoiceLines') IS NULL)
BEGIN
    CREATE TABLE [Staging].[InvoiceLines]
    (
        [InvoiceLineID] [int] NOT NULL,
        [InvoiceID] [int] NOT NULL,
        [StockItemID] [int] NOT NULL,
        [Description] [nvarchar](100) COLLATE Latin1_General_100_CI_AS NOT NULL,
        [PackageTypeID] [int] NOT NULL,
        [Quantity] [int] NOT NULL,
        [UnitPrice] [decimal](18, 2) NULL,
        [TaxRate] [decimal](18, 3) NOT NULL,
        [TaxAmount] [decimal](18, 2) NOT NULL,
        [LineProfit] [decimal](18, 2) NOT NULL,
        [ExtendedPrice] [decimal](18, 2) NOT NULL,
        [LastEditedBy] [int] NOT NULL,
        [LastEditedWhen] [datetime2](7) NOT NULL
    );
END
GO
IF (OBJECT_ID('Staging.Customers') IS NULL)
BEGIN
	CREATE TABLE [Staging].[Customers]
	(
		[CustomerID] [int] NOT NULL,
		[CustomerName] [nvarchar](100) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[CustomerCategoryID] [int] NOT NULL,
		[BuyingGroupID] [int] NULL,
		[PrimaryContactPersonID] [int] NOT NULL,
		[AlternateContactPersonID] [int] NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[DeliveryCityID] [int] NOT NULL,
		[PostalCityID] [int] NOT NULL,
		[CreditLimit] [decimal](18, 2) NULL,
		[AccountOpenedDate] [date] NOT NULL,
		[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
		[IsStatementSent] [bit] NOT NULL,
		[IsOnCreditHold] [bit] NOT NULL,
		[PaymentDays] [int] NOT NULL,
		[PhoneNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[FaxNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryRun] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[RunPosition] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[WebsiteURL] [nvarchar](256) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryAddressLine1] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryAddressLine2] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NULL,
		[DeliveryPostalCode] [nvarchar](10) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PostalAddressLine1] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PostalAddressLine2] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NULL,
		[PostalPostalCode] [nvarchar](10) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[LastEditedBy] [int] NOT NULL,
		[ValidFrom] [datetime2](7) NOT NULL,
		[ValidTo] [datetime2](7) NOT NULL
	);
END
GO
IF (OBJECT_ID('Staging.People') IS NULL)
BEGIN
	CREATE TABLE [Staging].[People]
	(
		[PersonID] [int] NOT NULL,
		[FullName] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PreferredName] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[IsSystemUser] [bit] NOT NULL,
		[IsEmployee] [bit] NOT NULL,
		[IsSalesperson] [bit] NOT NULL,
		[PhoneNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[FaxNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[EmailAddress] [nvarchar](256) COLLATE Latin1_General_100_CI_AS NULL,
		[LastEditedBy] [int] NOT NULL,
		[ValidFrom] [datetime2](7) NOT NULL,
		[ValidTo] [datetime2](7) NOT NULL
	);
END
GO
-- Step 3:  Create dbo tables.
-- For simplicity's sake, I'm not creating any keys, constraints, etc.
-- You should do that in a real solution.
IF (OBJECT_ID('dbo.FactInvoiceLine') IS NULL)
BEGIN
	CREATE TABLE dbo.FactInvoiceLine
	(
		[InvoiceLineID] [int] NOT NULL,
		[InvoiceID] [int] NOT NULL,
		[CustomerID] [int] NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[OrderID] [int] NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[ContactPersonID] [int] NOT NULL,
		[AccountsPersonID] [int] NOT NULL,
		[SalespersonPersonID] [int] NOT NULL,
		[PackedByPersonID] [int] NOT NULL,
		[InvoiceDate] [date] NOT NULL,
        [StockItemID] [int] NOT NULL,
        [PackageTypeID] [int] NOT NULL,
        [Quantity] [int] NOT NULL,
        [UnitPrice] [decimal](18, 2) NULL,
        [TaxRate] [decimal](18, 3) NOT NULL,
        [TaxAmount] [decimal](18, 2) NOT NULL,
        [LineProfit] [decimal](18, 2) NOT NULL,
        [ExtendedPrice] [decimal](18, 2) NOT NULL
	);
END
GO
IF (OBJECT_ID('dbo.DimCustomer') IS NULL)
BEGIN
	CREATE TABLE dbo.DimCustomer
	(
		[CustomerID] [int] NOT NULL,
		[CustomerName] [nvarchar](100) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[CustomerCategoryID] [int] NOT NULL,
		[BuyingGroupID] [int] NULL,
		[PrimaryContactPersonID] [int] NOT NULL,
		[PrimaryContactFullName] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PrimaryContactPreferredName] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PrimaryContactIsSystemUser] [bit] NOT NULL,
		[PrimaryContactIsEmployee] [bit] NOT NULL,
		[PrimaryContactIsSalesperson] [bit] NOT NULL,
		[PrimaryContactPhoneNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[PrimaryContactFaxNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
		[PrimaryContactEmailAddress] [nvarchar](256) COLLATE Latin1_General_100_CI_AS NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[DeliveryCityID] [int] NOT NULL,
		[PostalCityID] [int] NOT NULL,
		[CreditLimit] [decimal](18, 2) NULL,
		[AccountOpenedDate] [date] NOT NULL,
		[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
		[IsStatementSent] [bit] NOT NULL,
		[IsOnCreditHold] [bit] NOT NULL,
		[PaymentDays] [int] NOT NULL,
		[PhoneNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[FaxNumber] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryRun] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[RunPosition] [nvarchar](5) COLLATE Latin1_General_100_CI_AS NULL,
		[WebsiteURL] [nvarchar](256) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryAddressLine1] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[DeliveryAddressLine2] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NULL,
		[DeliveryPostalCode] [nvarchar](10) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PostalAddressLine1] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[PostalAddressLine2] [nvarchar](60) COLLATE Latin1_General_100_CI_AS NULL,
		[PostalPostalCode] [nvarchar](10) COLLATE Latin1_General_100_CI_AS NOT NULL,
		[LastEditedBy] [int] NOT NULL,
		[ValidFrom] [datetime2](7) NOT NULL,
		[ValidTo] [datetime2](7) NOT NULL
	);
END
GO

-- Step 4:  Load staging tables.
-- For a proper load, we'd look at things like modified dates or use change tracking / change data capture.
-- For the sake of simplicty, we will perform a full load.
INSERT INTO Staging.InvoiceLines
SELECT * FROM ELT.InvoiceLines;

INSERT INTO Staging.Invoices
SELECT * FROM ELT.Invoices;

INSERT INTO Staging.People
SELECT * FROM ELT.People;

INSERT INTO Staging.Customers
SELECT * FROM ELT.Customers;

-- Step 5:  Merge to dbo tables.
-- 
INSERT INTO dbo.DimCustomer
SELECT
	c.[CustomerID],
	c.[CustomerName],
	c.[BillToCustomerID],
	c.[CustomerCategoryID],
	c.[BuyingGroupID],
	c.[PrimaryContactPersonID],
	p.FullName AS [PrimaryContactFullName],
	p.PreferredName AS [PrimaryContactPreferredName],
	p.IsSystemUser AS [PrimaryContactIsSystemUser],
	p.IsEmployee AS [PrimaryContactIsEmployee],
	p.IsSalesperson AS [PrimaryContactIsSalesperson],
	p.PhoneNumber AS [PrimaryContactPhoneNumber],
	p.FaxNumber AS [PrimaryContactFaxNumber],
	p.EmailAddress AS [PrimaryContactEmailAddress],
	c.[DeliveryMethodID],
	c.[DeliveryCityID],
	c.[PostalCityID],
	c.[CreditLimit],
	c.[AccountOpenedDate],
	c.[StandardDiscountPercentage],
	c.[IsStatementSent],
	c.[IsOnCreditHold],
	c.[PaymentDays],
	c.[PhoneNumber],
	c.[FaxNumber],
	c.[DeliveryRun],
	c.[RunPosition],
	c.[WebsiteURL],
	c.[DeliveryAddressLine1],
	c.[DeliveryAddressLine2],
	c.[DeliveryPostalCode],
	c.[PostalAddressLine1],
	c.[PostalAddressLine2],
	c.[PostalPostalCode],
	c.[LastEditedBy],
	c.[ValidFrom],
	c.[ValidTo]
FROM Staging.Customers c
	LEFT OUTER JOIN Staging.People p
		ON c.PrimaryContactPersonID = p.PersonID;

INSERT INTO dbo.FactInvoiceLine
SELECT
	il.[InvoiceLineID],
	il.[InvoiceID],
	i.[CustomerID],
	i.[BillToCustomerID],
	i.[OrderID],
	i.[DeliveryMethodID],
	i.[ContactPersonID],
	i.[AccountsPersonID],
	i.[SalespersonPersonID],
	i.[PackedByPersonID],
	i.[InvoiceDate],
	il.[StockItemID],
	il.[PackageTypeID],
	il.[Quantity],
	il.[UnitPrice],
	il.[TaxRate],
	il.[TaxAmount],
	il.[LineProfit],
	il.[ExtendedPrice]
FROM Staging.InvoiceLines il
	INNER JOIN Staging.Invoices i
		ON il.InvoiceID = i.InvoiceID;
GO


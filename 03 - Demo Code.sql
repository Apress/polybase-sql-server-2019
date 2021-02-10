USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_scoped_credentials dsc
    WHERE
        dsc.name = N'DesktopCredentials'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL DesktopCredentials
    WITH IDENTITY = 'PolyBaseUser', Secret = '<<Some Password>>';
END
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources e
    WHERE
        e.name = N'Desktop'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE Desktop WITH
    (
        LOCATION = 'sqlserver://<<Your server location>>',
        PUSHDOWN = ON,
        CREDENTIAL = DesktopCredentials
    );
END
GO

IF (OBJECT_ID('Sales.InvoiceLines') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE [Sales].[InvoiceLines]
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

SELECT
    SUM(LineProfit) AS TotalProfit
FROM Sales.InvoiceLines r;
GO

SELECT
    i.CustomerID,
    COUNT(DISTINCT i.InvoiceID) AS NumberOfInvoices,
    COUNT(il.InvoiceLineID) AS NumberOfInvoiceLines
FROM Sales.Invoices i
    INNER JOIN Sales.InvoiceLines il
        ON i.InvoiceID = il.InvoiceID
GROUP BY
    i.CustomerID
ORDER BY
    NumberOfInvoiceLines DESC;
GO

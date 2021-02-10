USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-- Quick reminder from last segment
SELECT *
FROM Sales.InvoiceLines
WHERE InvoiceID = 134;

-- Introducing a problem with parameters
DECLARE @InvoiceID INT = 134;
SELECT *
FROM Sales.InvoiceLines
WHERE InvoiceID = @InvoiceID;
GO

-- Force external pushdown.  Great for Hadoop, useless for Blob Storage,
-- sometimes good for V2 sources...but not here.
DECLARE @InvoiceID INT = 134;
SELECT *
FROM Sales.InvoiceLines
WHERE InvoiceID = @InvoiceID
OPTION(FORCE EXTERNALPUSHDOWN);
GO

-- Recompile the query.  This does work.
DECLARE @InvoiceID INT = 134;
SELECT *
FROM Sales.InvoiceLines
WHERE InvoiceID = @InvoiceID
OPTION(RECOMPILE);
GO

-- Another example.  Start off with an easy query.
SELECT
    SUM(LineProfit) AS TotalProfit
FROM Sales.InvoiceLines r;
GO

-- This query makes the optimizer go crazy.
DECLARE
    @MinQuantity INT,
    @Description NVARCHAR(100);

SET @MinQuantity = 2;
SET @Description = N'USB food flash drive - chocolate bar';

SELECT
    SUM(LineProfit) AS TotalProfit
FROM Sales.InvoiceLines r
WHERE
    r.Quantity >= @MinQuantity
    AND r.Description = @Description;
GO

-- OPTION(RECOMPILE) works.
DECLARE
    @MinQuantity INT,
    @Description NVARCHAR(100);

SET @MinQuantity = 2;
SET @Description = N'USB food flash drive - chocolate bar';

SELECT
    SUM(LineProfit) AS TotalProfit
FROM Sales.InvoiceLines r
WHERE
    r.Quantity >= @MinQuantity
    AND r.Description = @Description
OPTION(RECOMPILE);
GO

-- But wait!
DECLARE @TotalProfit DECIMAL(15,0);
DECLARE
    @MinQuantity INT,
    @Description NVARCHAR(100);

SET @MinQuantity = 2;
SET @Description = N'USB food flash drive - chocolate bar';

SELECT
    @TotalProfit = SUM(LineProfit)
FROM Sales.InvoiceLines r
WHERE
    r.Quantity >= @MinQuantity
    AND r.Description = @Description
OPTION(RECOMPILE);
GO

-- Solution:  use a temp table and build it piecemeal.
CREATE TABLE #TotalProfit
(
    TotalProfit DECIMAL(15,0)
);

DECLARE @TotalProfit DECIMAL(15,0);
DECLARE
    @MinQuantity INT,
    @Description NVARCHAR(100);

SET @MinQuantity = 2;
SET @Description = N'USB food flash drive - chocolate bar';

INSERT INTO #TotalProfit(TotalProfit)
SELECT
    SUM(LineProfit)
FROM Sales.InvoiceLines r
WHERE
    r.Description = @Description
OPTION(RECOMPILE);

SELECT @TotalProfit = TotalProfit FROM #TotalProfit;
GO

-- Can also use dynamic SQL when applying a list to another table.
-- Start with a query against a local table.
SELECT
    i.InvoiceID
FROM Sales.Invoices i
WHERE
    i.SalespersonPersonID = 7
    AND i.BillToCustomerID = 401
    AND i.ContactPersonID = 2181
    AND i.TotalDryItems < 3;
GO

-- Join to an external table.  This works well!
SELECT
    il.InvoiceLineID,
    il.InvoiceID
FROM Sales.Invoices i
    INNER JOIN Sales.InvoiceLines il
        ON i.InvoiceID = il.InvoiceID
WHERE
    i.SalespersonPersonID = 7
    AND i.BillToCustomerID = 401
    AND i.ContactPersonID = 2181
    AND i.TotalDryItems = 2
    AND i.PackedByPersonID = 2;
GO

-- But just in case it didn't work out well, we have another option:  dynamic SQL.
DECLARE @sql NVARCHAR(MAX);
SELECT @sql = CONCAT(N'SELECT il.InvoiceLineID, il.InvoiceID
    FROM Sales.InvoiceLines il
    WHERE il.InvoiceID IN (', STRING_AGG(i.InvoiceID, ','), ');')
FROM Sales.Invoices i
WHERE
    i.SalespersonPersonID = 7
    AND i.BillToCustomerID = 401
    AND i.ContactPersonID = 2181
    AND i.TotalDryItems = 2
    AND i.PackedByPersonID = 2;
EXEC(@sql);

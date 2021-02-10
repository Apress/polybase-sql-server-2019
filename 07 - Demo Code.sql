USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-- NOTE:  the Sales.InvoiceLines external table is created in the code sample for segment 3.

-- Create statistics
CREATE STATISTICS [S_InvoiceLines_InvoiceID]
ON Sales.InvoiceLines(InvoiceID)
WITH SAMPLE 30 PERCENT;

-- View the statistic details
DBCC SHOW_STATISTICS('Sales.InvoiceLines', S_InvoiceLines_InvoiceID)

DROP STATISTICS Sales.InvoiceLines.[S_InvoiceLines_InvoiceID];

CREATE STATISTICS [S_InvoiceLines_InvoiceID]
ON Sales.InvoiceLines(InvoiceID)
WITH FULLSCAN;

-- Can't update
UPDATE STATISTICS Sales.InvoiceLines [S_InvoiceLines_InvoiceID]
WITH FULLSCAN;

-- Can't create an index
CREATE INDEX [IX_InvoiceLines_InvoiceID]
ON Sales.InvoiceLines(InvoiceID);

-- Can make use of indexes on the source table
SELECT *
FROM Sales.InvoiceLines
WHERE InvoiceID = 134;

-- Introducing a problem with parameters
DECLARE @InvoiceID INT = 134;
SELECT *
FROM Sales.InvoiceLines
WHERE InvoiceID = @InvoiceID;

USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_scoped_credentials dsc
    WHERE
        dsc.name = N'CosmosCredential'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL CosmosCredential
    WITH IDENTITY = '<Your User>', Secret = '<Your PWD>';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'CosmosDB'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE CosmosDB WITH
    (
        LOCATION = 'mongodb://cspolybase2.documents.azure.com:10255',
        CONNECTION_OPTIONS = 'ssl=true',
        CREDENTIAL = CosmosCredential,
        PUSHDOWN = ON
    );
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'Volcano'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.Volcano
    (
        _id NVARCHAR(100) NOT NULL, 
        VolcanoName NVARCHAR(100) NOT NULL, 
        Country NVARCHAR(100) NULL, 
        Region NVARCHAR(100) NULL,
        Location_Type NVARCHAR(100) NULL,
        Elevation INT NULL,
        Type NVARCHAR(100) NULL,
        Status NVARCHAR(200) NULL,
        LastEruption NVARCHAR(300) NULL,
        [Volcano_Coordinates] FLOAT(53)
    )
    WITH
    (
        LOCATION='PolyBaseTest.Volcano',
        DATA_SOURCE = CosmosDB
    );
END
GO

-- A basic SELECT * returns "duplicates" due to flattening.
SELECT * FROM dbo.Volcano;
GO

-- Removing coordinates and adding a DISTINCT clause removes them.
SELECT DISTINCT
	v._id,
    v.VolcanoName,
    v.Country,
    v.Region,
    v.Elevation,
    v.Type,
    v.Status,
    v.LastEruption
FROM dbo.Volcano v;
GO

-- A better solution is to use STRING_AGG() to turn them into a list.
SELECT *
INTO #Volcanoes
FROM dbo.Volcano;

SELECT
	v._id,
    v.VolcanoName,
    v.Country,
    v.Region,
    v.Location_Type AS LocationType,
    STRING_AGG(v.Volcano_Coordinates, ',') AS Coordinates,
    v.Elevation,
    v.Type,
    v.Status,
    v.LastEruption
FROM #Volcanoes v
GROUP BY
	v._id,
    v.VolcanoName,
    v.Country,
    v.Region,
    v.Location_Type,
    v.Elevation,
    v.Type,
    v.Status,
    v.LastEruption
ORDER BY
    v.Elevation ASC;
GO

-- We can also create a separate table without the coordinates.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'Volcano2'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.Volcano2
    (
        _id NVARCHAR(100) NOT NULL, 
        VolcanoName NVARCHAR(100) NOT NULL, 
        Country NVARCHAR(100) NULL, 
        Region NVARCHAR(100) NULL,
        Location_Type NVARCHAR(100) NULL,
        Elevation INT NULL,
        Type NVARCHAR(100) NULL,
        Status NVARCHAR(200) NULL,
        LastEruption NVARCHAR(300) NULL
    )
    WITH
    (
        LOCATION='PolyBaseTest.Volcano',
        DATA_SOURCE = CosmosDB
    );
END
GO

-- Now we get one row per volcano; PolyBase skips the coordinates column.
SELECT * FROM dbo.Volcano2;
GO
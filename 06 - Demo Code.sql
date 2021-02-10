/*
Postgres Demo Prep
Step 1:  set up Postgres.  If you don't have it but do have Docker, the following commands will configure a simple Postgres database:
	docker pull postgres
	docker run --name pg -e POSTGRES_PASSWORD=pgtestpwd -p 5432:5432 -d postgres
Step 2:  retrieve the Postgres ODBC driver.  You can find drivers at https://www.postgresql.org/ftp/odbc/versions/.
	I am using Windows, so I grabbed the latest MSI from https://www.postgresql.org/ftp/odbc/versions/msi/.
Step 3:  Create an event table and populate it with some basic data.  Run the following from Azure Data Studio, pgadmin4, or whatever other tool you'd like.
CREATE TABLE event(
    id serial,
    machine_id int,
    event_id varchar(40),
    event_type varchar(70),
    entity_type varchar(70),
    entity_id varchar(40),
    event_data json
)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Run this several times to generate data.
INSERT INTO event(
    machine_id,
    event_id,
    event_type,
    entity_type,
    entity_id,
    event_data
)
VALUES
(
    21644,
    uuid_generate_v4(),
    'Telemetry Ingest',
    'MachineTelemetry',
    uuid_generate_v4(),
    '{ "Test": "Yes" }'
);

SELECT * FROM event;
*/

USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
	SELECT 1
	FROM sys.database_scoped_credentials
	WHERE
		name = N'PostgresCredential'
)
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL PostgresCredential
	WITH IDENTITY = 'postgres',
	SECRET = 'pgtestpwd';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'PostgresEvents'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE PostgresEvents WITH
    (
        LOCATION = 'odbc://localhost:5432',
        CONNECTION_OPTIONS = 'Driver={PostgreSQL Unicode}; Database=postgres',
		CREDENTIAL = PostgresCredential,
		PUSHDOWN = ON
    );
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'PostgresEvent'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.PostgresEvent
    (
        id INT,
        machine_id INT,
        event_id NVARCHAR(40),
        event_type NVARCHAR(70),
        entity_type NVARCHAR(70),
        entity_id NVARCHAR(40),
        event_data NVARCHAR(255)
    )
    WITH
    (
        LOCATION = 'event',
        DATA_SOURCE = PostgresEvents
    );
END
GO

SELECT * FROM dbo.PostgresEvent;
GO

SELECT
    pe.id,
    pe.machine_id,
    pe.event_id,
    pe.event_type,
    pe.entity_type,
    pe.entity_id,
    JSON_VALUE(pe.event_data, '$.IsTest') AS IsTest
FROM dbo.PostgresEvent pe;
GO

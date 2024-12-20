CREATE TABLE [Stage].[NonMigInvoice]
(
	[RN_MAX] bigint NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[AgestageID] int NULL,
	[VehicleID] bigint NULL,
	[CollectionStatus] bigint NULL,
	[InvoiceStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([InvoiceNumber] ASC), DISTRIBUTION = HASH([InvoiceNumber]))

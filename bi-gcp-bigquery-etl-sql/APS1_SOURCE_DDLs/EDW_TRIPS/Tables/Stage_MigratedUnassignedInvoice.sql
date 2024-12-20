CREATE TABLE [Stage].[MigratedUnassignedInvoice]
(
	[InvoiceNumber_Unass] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UnassignedTxnCnt] int NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TotalTxnCnt] int NULL,
	[Tolls] decimal(38,2) NULL,
	[UnassignedFlag] int NOT NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([InvoiceNumber]))

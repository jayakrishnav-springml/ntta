CREATE TABLE [dbo].[Dim_InvoiceStatus]
(
	[InvoiceStatusID] int NOT NULL,
	[InvoiceStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([InvoiceStatusID] ASC), DISTRIBUTION = REPLICATE)

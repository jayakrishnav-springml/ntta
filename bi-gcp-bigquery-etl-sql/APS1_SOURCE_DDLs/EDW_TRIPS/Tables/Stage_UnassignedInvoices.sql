CREATE TABLE [Stage].[UnassignedInvoices]
(
	[InvoiceNumber_Unass] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CitationID_Unassgned] int NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CitationID_All] int NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([InvoiceNumber]))

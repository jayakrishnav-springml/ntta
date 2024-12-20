CREATE TABLE [Ref].[RitemigratedInvoices]
(
	[InvoiceNumber] decimal(18,0) NULL,
	[ZipCashDate] datetime2(0) NOT NULL,
	[UnassignedFlag] int NOT NULL,
	[InvoiceStatus] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TollAmount] decimal(38,4) NULL,
	[AdjustedAmount] decimal(38,2) NULL,
	[PaidTxns] int NULL
)
WITH(CLUSTERED INDEX ([InvoiceNumber] ASC), DISTRIBUTION = HASH([InvoiceNumber]))

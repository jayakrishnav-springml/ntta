CREATE TABLE [TollPlus].[TP_Violated_Trip_Receipts_Tracker]
(
	[TripReceiptID] bigint NOT NULL,
	[CitationID] bigint NULL,
	[ViolatorID] bigint NULL,
	[LinkID] bigint NULL,
	[AmountReceived] decimal(19,2) NULL,
	[TxnDate] datetime2(3) NULL,
	[LinkSourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripChargeID] bigint NULL,
	[InvoiceID] bigint NULL,
	[OverpaymentID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TripReceiptID] ASC), DISTRIBUTION = HASH([CitationID]))

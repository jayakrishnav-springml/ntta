CREATE TABLE [TollPlus].[TP_Invoice_Receipts_Tracker]
(
	[ReceiptID] bigint NOT NULL,
	[InvoiceID] bigint NULL,
	[Invoice_ChargeID] bigint NULL,
	[InvBatchID] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AmountReceived] decimal(19,2) NULL,
	[LinkID] bigint NULL,
	[LinkSourceName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnDate] datetime2(3) NULL,
	[OverpaymentID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ReceiptID] DESC), DISTRIBUTION = HASH([ReceiptID]))

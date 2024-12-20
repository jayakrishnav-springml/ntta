CREATE TABLE [Stage].[Invoice_Charges_Tracker]
(
	[InvoiceChargeID] bigint NOT NULL,
	[InvoiceID] bigint NULL,
	[InvBatchID] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Amount] decimal(19,2) NULL,
	[FeeCode] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentStatusID] int NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[IsWriteOff] bit NULL,
	[ICNID] bigint NULL,
	[WriteOffDate] datetime2(3) NULL,
	[WriteOffAmount] decimal(19,2) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([InvoiceChargeID] DESC), DISTRIBUTION = HASH([InvoiceChargeID]))

CREATE TABLE [Stage].[MigratedDimissedVToll]
(
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TotalTxnCnt] int NULL,
	[VTollTxnCnt] int NULL,
	[UnassignedTxnCnt] int NULL,
	[UnassignedVtolledTxnCnt] int NOT NULL,
	[VTollPaidTxnCnt] int NULL,
	[FirstPaymentDate] datetime2(3) NULL,
	[LastPaymentDate] datetime2(3) NULL,
	[PBMTollAmount] decimal(38,2) NULL,
	[AVITollAmount] decimal(38,2) NULL,
	[PremiumAmount] decimal(38,2) NULL,
	[Tolls] decimal(38,2) NULL,
	[PaidAmount_VT] decimal(38,2) NULL,
	[TollsAdjusted] decimal(38,2) NULL,
	[TollsAdjustedAfterVtoll] int NOT NULL,
	[AdjustedAmount_Excused] int NOT NULL,
	[ClassAdj] int NOT NULL,
	[OutstandingAmount] decimal(38,2) NULL,
	[PaidTnxs] int NOT NULL,
	[VtollFlag] int NOT NULL,
	[VtollFlagDescription] varchar(24) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_Update_Date] datetime2(7) NOT NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([InvoiceNumber]))

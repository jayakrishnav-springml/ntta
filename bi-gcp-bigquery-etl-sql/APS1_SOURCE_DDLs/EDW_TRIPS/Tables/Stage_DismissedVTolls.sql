CREATE TABLE [Stage].[DismissedVTolls]
(
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CitationTotal] int NULL,
	[CitationID_VToll] int NULL,
	[UnassignedTxnCnt] int NULL,
	[FirstPaymentDate] datetime2(3) NULL,
	[LastPaymentDate] datetime2(3) NULL,
	[PaidAmount_VT] decimal(38,2) NULL,
	[TollsAdjusted] decimal(38,2) NULL,
	[TollsAdjustedAfterVtoll] decimal(38,4) NULL,
	[AdjustedAmount_Excused] int NOT NULL,
	[ClassAdj] decimal(38,2) NULL,
	[OutstandingAmount] decimal(38,2) NULL,
	[PaidTnxs] int NULL,
	[VtollFlag] int NOT NULL,
	[VtollFlagDescription] varchar(24) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_Update_Date] datetime2(7) NOT NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([InvoiceNumber]))

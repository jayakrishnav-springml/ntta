CREATE TABLE [Ref].[RitemigratedTxnInvoices]
(
	[InvoiceNumber] decimal(18,0) NULL,
	[InvoiceStatus] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VBI_INVOICE_ID] decimal(18,0) NOT NULL,
	[ZipcashDate] datetime2(0) NOT NULL,
	[FirstNoticeDate] datetime2(0) NOT NULL,
	[SecondNoticeDate] datetime2(0) NULL,
	[VBI_STATUS] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VIOL_INVOICE_ID] decimal(18,0) NULL,
	[ViolInvoiceDate] datetime2(0) NULL,
	[VIOL_INV_STATUS] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VIOLATION_ID] decimal(18,0) NULL,
	[FinalViolStatus] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VB_VIOL_STATUS] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VIV_VIOL_STATUS] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[INVOICE_STAGE_ID] int NOT NULL,
	[FinalTollAmount] decimal(38,4) NULL,
	[VB_TollDue] money NULL,
	[VIV_TollDue] decimal(38,2) NULL,
	[VB_REUNASSIGNED_EXCUSED_AMT] money NULL,
	[VIOL_REUNASSIGNED_EXCUSED_AMT] decimal(38,2) NULL,
	[VB_REUNASSIGNED_EXCUSED_TXNCNT] int NULL,
	[VIOL_REUNASSIGNED_EXCUSED_TXNCNT] int NULL,
	[TotalTxns] int NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([VIOLATION_ID]))

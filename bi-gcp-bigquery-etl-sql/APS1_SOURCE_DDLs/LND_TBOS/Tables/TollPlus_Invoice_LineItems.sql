CREATE TABLE [TollPlus].[Invoice_LineItems]
(
	[InvLineItemID] bigint NOT NULL,
	[InvoiceID] bigint NULL,
	[LinkID] bigint NULL,
	[CustTxnCategory] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Stmt_Literal] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Amount] decimal(19,2) NULL,
	[SubSystem] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LinkSourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnDate] datetime2(3) NULL,
	[ReferenceInvoiceID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceViolationStatus] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([InvLineItemID] DESC), DISTRIBUTION = HASH([InvLineItemID]))

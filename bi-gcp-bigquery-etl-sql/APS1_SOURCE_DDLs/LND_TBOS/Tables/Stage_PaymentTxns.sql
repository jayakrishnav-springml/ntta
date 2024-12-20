CREATE TABLE [Stage].[PaymentTxns]
(
	[PaymentID] bigint NOT NULL,
	[PaymentDate] datetime2(3) NOT NULL,
	[VoucherNo] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubSystem] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentModeID] bigint NOT NULL,
	[IntiatedBy] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ActivityType] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatementNote] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnAmount] decimal(19,2) NOT NULL,
	[PaymentStatusID] bigint NOT NULL,
	[RefPaymentID] bigint NULL,
	[RefType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourcePKID] bigint NULL,
	[AccountStatusID] bigint NOT NULL,
	[ApprovedBy] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[LocationID] bigint NULL,
	[SourceOfEntry] bigint NULL,
	[ReasonText] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ICNID] bigint NULL,
	[IsVirtualCheck] bit NULL,
	[PmtTxnType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourcePmtID] smallint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PaymentID] DESC), DISTRIBUTION = HASH([PaymentID]))

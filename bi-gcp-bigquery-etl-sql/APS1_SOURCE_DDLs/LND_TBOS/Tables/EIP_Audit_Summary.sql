CREATE TABLE [EIP].[Audit_Summary]
(
	[AgencyCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SourceCode] int NOT NULL,
	[Timestamp] int NOT NULL,
	[TxnsReceived] int NOT NULL,
	[TxnsAccepted] int NOT NULL,
	[TxnsRejected] int NOT NULL,
	[TxnsAutoReadALPR] int NOT NULL,
	[TxnsAutoReadVSR] int NOT NULL,
	[TxnsMIRRead] int NOT NULL,
	[TxnsPendingMatch] int NOT NULL,
	[TxnsPendingMIR] int NOT NULL,
	[TxnsPendingResponse] int NOT NULL,
	[TxnsCompleted] int NOT NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] nvarchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(0) NULL,
	[UpdatedUser] nvarchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AgencyCode] ASC, [SourceCode] ASC, [Timestamp] ASC), DISTRIBUTION = HASH([AgencyCode]))

CREATE TABLE [EIP].[AuditTracker]
(
	[AuditsetupID] bigint NOT NULL,
	[AuditName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AuditType] bigint NOT NULL,
	[AuditStatus] int NOT NULL,
	[AuditTranCount] int NULL,
	[StartDate] datetime2(0) NULL,
	[EndDate] datetime2(0) NULL,
	[AuditValidTill] datetime2(0) NULL,
	[AuditStatusDate] datetime2(0) NULL,
	[QualifiedTxnsCnt] int NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AuditsetupID] ASC), DISTRIBUTION = HASH([AuditsetupID]))

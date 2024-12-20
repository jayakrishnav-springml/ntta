CREATE TABLE [Stage].[Transaction_InputLog]
(
	[TxninputLogID] bigint NOT NULL,
	[AgencyCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyTxnID] varchar(75) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyTimestamp] bigint NOT NULL,
	[ClentSendDate] datetime2(0) NULL,
	[ResponseCode] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RejectCode] int NOT NULL,
	[RejectReason] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EIPTxnID] bigint NOT NULL,
	[TransactionDate] date NULL,
	[TransactionTime] int NULL,
	[PlazaID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LaneID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DayNightTwilight] smallint NULL,
	[ReferenceTrackerID] int NULL,
	[SubscriberID] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(0) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TxninputLogID] ASC), DISTRIBUTION = HASH([TxninputLogID]))

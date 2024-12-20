CREATE TABLE [Stage].[TP_TollTxn_ReasonCodes]
(
	[ReasonCodeID] bigint NOT NULL,
	[ReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ReasonDesc] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReasonType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AutoAccepted] bit NOT NULL,
	[Remarks] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsReprocessingAllowed] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ReasonCodeID] DESC), DISTRIBUTION = HASH([ReasonCodeID]))

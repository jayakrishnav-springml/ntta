CREATE TABLE [Stage].[TxnStagesHistory]
(
	[StageID] smallint NOT NULL,
	[StageName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StageCode] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StageDescription] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[HistID] int NOT NULL,
	[Action] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ActionDateTime] datetime2(0) NULL,
	[ChangesSummary] varchar(2000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(0) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([HistID] ASC), DISTRIBUTION = HASH([HistID]))

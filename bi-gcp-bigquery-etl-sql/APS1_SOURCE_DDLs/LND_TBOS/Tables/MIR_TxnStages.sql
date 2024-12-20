CREATE TABLE [MIR].[TxnStages]
(
	[StageID] smallint NOT NULL,
	[StageName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StageCode] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StageDescription] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([StageID] ASC), DISTRIBUTION = HASH([StageID]))

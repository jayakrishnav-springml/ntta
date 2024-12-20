CREATE TABLE [Stage].[Ref_Invoice_Workflow_Stages]
(
	[StageID] int NOT NULL,
	[StageName] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StageOrder] tinyint NULL,
	[StepsCount] tinyint NULL,
	[IsActive] bit NULL,
	[StageCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgingPeriod] int NULL,
	[GracePeriod] int NULL,
	[WaiveAllFees] bit NOT NULL,
	[ApplyAVIRate] bit NOT NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([StageID] DESC), DISTRIBUTION = HASH([StageID]))

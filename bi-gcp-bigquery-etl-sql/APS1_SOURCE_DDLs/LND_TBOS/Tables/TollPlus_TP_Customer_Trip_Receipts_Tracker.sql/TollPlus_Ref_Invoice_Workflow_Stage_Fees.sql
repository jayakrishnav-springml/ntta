CREATE TABLE [TollPlus].[Ref_Invoice_Workflow_Stage_Fees]
(
	[StageFeeID] int NOT NULL,
	[StageID] int NULL,
	[FeeTypeID] int NOT NULL,
	[IsActive] bit NULL,
	[Fee_Days] int NOT NULL,
	[AppliedFor] int NOT NULL,
	[IsWaiveFee] bit NOT NULL,
	[IsConsiderFeeForMbs] bit NOT NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([StageFeeID] DESC), DISTRIBUTION = HASH([StageFeeID]))

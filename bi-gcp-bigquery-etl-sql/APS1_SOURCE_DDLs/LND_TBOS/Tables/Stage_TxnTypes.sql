CREATE TABLE [Stage].[TxnTypes]
(
	[TxnTypeID] int NOT NULL,
	[TxnType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TxnDesc] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnType_CategoryID] int NOT NULL,
	[StatementNote] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerNote] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ViolatorNote] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsAutomatic] tinyint NOT NULL,
	[AdjustmentCategoryID] int NULL,
	[LevelID] int NOT NULL,
	[Status] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LevelCode] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BusinessUnitID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TxnTypeID] DESC), DISTRIBUTION = HASH([TxnTypeID]))

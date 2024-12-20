CREATE TABLE [dbo].[Dim_GL_TxnType]
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
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([TxnTypeID] ASC), DISTRIBUTION = REPLICATE)

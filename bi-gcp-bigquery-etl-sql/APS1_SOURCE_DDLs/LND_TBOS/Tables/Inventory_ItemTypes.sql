CREATE TABLE [Inventory].[ItemTypes]
(
	[ItemTypeID] int NOT NULL,
	[ItemTypeName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ItemTypeDesc] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[IsSerialized] bit NOT NULL,
	[FilePath] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ItemTypeID] DESC), DISTRIBUTION = HASH([ItemTypeID]))

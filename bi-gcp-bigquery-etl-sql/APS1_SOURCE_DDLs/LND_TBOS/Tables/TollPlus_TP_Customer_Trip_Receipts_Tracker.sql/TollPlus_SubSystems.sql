CREATE TABLE [TollPlus].[SubSystems]
(
	[SubSystemID] int NOT NULL,
	[SubSystemName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubSystemCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubSystemDescription] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentSubSystemID] int NULL,
	[IsWebDisplay] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([SubSystemID] DESC), DISTRIBUTION = HASH([SubSystemID]))

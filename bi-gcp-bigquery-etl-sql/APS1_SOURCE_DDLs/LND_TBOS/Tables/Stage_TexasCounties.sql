CREATE TABLE [Stage].[TexasCounties]
(
	[CountyID] int NOT NULL,
	[CountyNo] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CountyName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CountyID] ASC), DISTRIBUTION = HASH([CountyID]))

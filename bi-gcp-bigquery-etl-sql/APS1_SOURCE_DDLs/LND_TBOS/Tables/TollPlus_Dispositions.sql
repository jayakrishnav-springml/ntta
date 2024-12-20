CREATE TABLE [TollPlus].[Dispositions]
(
	[DIspID] int NOT NULL,
	[DispositionCategory] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Disposition] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DispositionCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([DIspID] ASC), DISTRIBUTION = HASH([DIspID]))

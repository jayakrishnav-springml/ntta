CREATE TABLE [dbo].[Dim_Time_OLD]
(
	[TimeID] int NOT NULL,
	[Hour] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Minute] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Second] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[12_Hour] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AM_PM] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[5_Minute] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[10_Minute] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[15_Minute] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[30_Minute] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LastModified] datetime NOT NULL
)
WITH(CLUSTERED INDEX ([TimeID] ASC), DISTRIBUTION = REPLICATE)

CREATE TABLE [Ref].[Dim_Time]
(
	[TIME_ID] int NOT NULL,
	[HOUR] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[12_HOUR] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AM_PM] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[30_MINUTE] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[15_MINUTE] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[10_MINUTE] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[5_MINUTE] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[MINUTE] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SECOND] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
)
WITH(CLUSTERED INDEX ([TIME_ID] ASC), DISTRIBUTION = REPLICATE)

CREATE TABLE [dbo].[Dim_DayRange]
(
	[DayRangeID] int NOT NULL,
	[DayRangeDesc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[DayRangeStart] int NOT NULL,
	[DayRangeEnd] int NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([DayRangeID] ASC), DISTRIBUTION = REPLICATE)

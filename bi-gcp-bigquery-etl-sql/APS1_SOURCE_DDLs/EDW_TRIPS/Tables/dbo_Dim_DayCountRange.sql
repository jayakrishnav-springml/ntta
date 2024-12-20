CREATE TABLE [dbo].[Dim_DayCountRange]
(
	[DayCountID] bigint NULL,
	[DayRangeID] int NOT NULL,
	[DayRangeDesc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[DayRangeStart] int NOT NULL,
	[DayRangeEnd] int NOT NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([DayCountID] ASC), DISTRIBUTION = REPLICATE)

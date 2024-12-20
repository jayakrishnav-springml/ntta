CREATE TABLE [dbo].[Dim_LaneCategory]
(
	[LaneCategoryID] int NOT NULL,
	[LaneCategoryDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([LaneCategoryID] ASC), DISTRIBUTION = REPLICATE)

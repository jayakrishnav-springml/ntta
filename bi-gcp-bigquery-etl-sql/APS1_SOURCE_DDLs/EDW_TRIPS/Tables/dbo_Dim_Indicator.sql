CREATE TABLE [dbo].[Dim_Indicator]
(
	[Indicator_ID] smallint NOT NULL,
	[Yes_No_Abbrev] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Indicator] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
)
WITH(CLUSTERED INDEX ([Indicator_ID] ASC), DISTRIBUTION = REPLICATE)

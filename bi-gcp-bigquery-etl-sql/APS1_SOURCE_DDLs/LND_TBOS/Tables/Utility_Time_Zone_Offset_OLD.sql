CREATE TABLE [Utility].[Time_Zone_Offset_OLD]
(
	[YYYY] smallint NULL,
	[DST_Start_Date] datetime2(0) NULL,
	[DST_End_Date] datetime2(3) NULL,
	[Daylight_Weeks] smallint NULL,
	[Source_TZ] char(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Target_TZ] char(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DST_Offset] smallint NULL,
	[Non_DST_Offset] smallint NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)

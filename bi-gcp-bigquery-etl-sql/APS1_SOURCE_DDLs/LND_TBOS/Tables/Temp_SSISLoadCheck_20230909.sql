CREATE TABLE [Temp].[SSISLoadCheck_20230909]
(
	[LoadDate] datetime2(3) NOT NULL,
	[LoadSource] varchar(130) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LoadStep] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LoadInfo] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Row_Count] bigint NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN)

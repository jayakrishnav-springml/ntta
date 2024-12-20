CREATE TABLE [Ref].[Lane_Camera_Mapping]
(
	[Controller] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Metric_Suffix] smallint NOT NULL,
	[Camera] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(3) NULL,
	[MSTR_UpdateUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MSTR_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Controller] ASC, [Metric_Suffix] ASC), DISTRIBUTION = REPLICATE)

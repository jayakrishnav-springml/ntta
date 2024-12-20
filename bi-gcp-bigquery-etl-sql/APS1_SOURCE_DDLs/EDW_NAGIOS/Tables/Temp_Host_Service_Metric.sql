CREATE TABLE [Temp].[Host_Service_Metric]
(
	[Nagios_Object_ID] int NOT NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Name] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Suffix] smallint NULL,
	[Metric_Target] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(HEAP, DISTRIBUTION = HASH([Nagios_Object_ID]))

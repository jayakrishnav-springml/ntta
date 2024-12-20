CREATE TABLE [Stage].[Host_Service_Event]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Nagios_Object_ID] int NOT NULL,
	[Event_Date] datetime NOT NULL,
	[Host_Service_State] tinyint NOT NULL,
	[Host] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Event_Info] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Perf_Data] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Count] tinyint NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Host_Service_Event_ID] ASC), DISTRIBUTION = HASH([Nagios_Object_ID]))

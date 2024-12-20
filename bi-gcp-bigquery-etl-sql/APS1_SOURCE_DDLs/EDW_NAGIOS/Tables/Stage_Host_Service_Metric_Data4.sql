CREATE TABLE [Stage].[Host_Service_Metric_Data4]
(
	[Host_Service_Event_ID] bigint NOT NULL,
	[Host_Service_State] tinyint NOT NULL,
	[Host] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Service] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Count] tinyint NULL,
	[Metric_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Metric_Index] int NOT NULL,
	[Metric_Name] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Value_String] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Value_Unit] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DELIM_1] int NULL,
	[DELIM_2] int NULL,
	[DELIM_3] int NULL,
	[DELIM_4] int NULL
)
WITH(HEAP, DISTRIBUTION = HASH([Host_Service_Event_ID]))
